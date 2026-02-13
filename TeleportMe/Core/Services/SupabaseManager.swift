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
        let url = URL(string: "https://REDACTED_PROJECT_REF.supabase.co")!
        let key = "REDACTED_SUPABASE_ANON_KEY"

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
}
