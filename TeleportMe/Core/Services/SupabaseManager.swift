import Foundation
import Supabase

// MARK: - Supabase Manager

/// Central Supabase client configured from environment.
@Observable
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    /// The redirect URL used in auth confirmation emails.
    /// Supabase will embed this in email links so they open the app via Universal Links.
    static let authCallbackURL = URL(string: "https://getteleport.me/auth/callback")!

    private init() {
        let url = URL(string: Secrets.supabaseURL)!
        let key = Secrets.supabaseAnonKey

        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: .init(
                auth: .init(
                    redirectToURL: SupabaseManager.authCallbackURL
                )
            )
        )
    }

    // MARK: - Direct Edge Function Invocation

    /// Calls a Supabase edge function directly via URLSession, bypassing the SDK's
    /// `fetchWithAuth` which can overwrite the Authorization header with an expired token.
    ///
    /// The Supabase Swift SDK's `SupabaseClient.adapt()` always overwrites the Authorization
    /// header with the result of `_getAccessToken()`. When the session token is stale/expired,
    /// this causes 401s that can't be fixed by passing custom headers via `FunctionInvokeOptions`.
    /// This helper bypasses the SDK entirely, refreshing the session first so the edge function
    /// can still identify the user and persist explorations.
    static func invokeEdgeFunctionDirect<T: Decodable>(
        _ name: String,
        body: some Encodable,
        decoder: JSONDecoder = JSONDecoder()
    ) async throws -> T {
        let url = URL(string: "\(Secrets.supabaseURL)/functions/v1/\(name)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue(Secrets.supabaseAnonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONEncoder().encode(body)
        request.timeoutInterval = 30

        // Force-refresh the session token so the server can identify the user.
        // This is the 401 retry path — the SDK's cached token was stale, so we
        // explicitly call refreshSession() to get a new one.
        // Falls back to anon key if refresh fails (results returned but not persisted).
        let accessToken: String
        do {
            let session = try await shared.client.auth.refreshSession()
            accessToken = session.accessToken
        } catch {
            print("invokeEdgeFunctionDirect: session refresh failed, using anon key: \(error)")
            accessToken = Secrets.supabaseAnonKey
        }
        request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            let code = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw FunctionsError.httpError(code: code, data: data)
        }

        return try decoder.decode(T.self, from: data)
    }
}
