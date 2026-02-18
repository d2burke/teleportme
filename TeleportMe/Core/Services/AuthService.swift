import Foundation
import Supabase

// MARK: - Auth Service

@Observable
final class AuthService {
    private let supabase = SupabaseManager.shared.client

    var currentUser: User?
    var currentProfile: UserProfile?
    var isAuthenticated: Bool { currentUser != nil }
    var isLoading = false
    var error: String?

    init() {
        // Session check is handled by AppCoordinator.checkExistingSession()
        // Don't fire a redundant network call here
    }

    // MARK: - Session

    func checkSession() async {
        do {
            let session = try await withTimeout(seconds: 10) {
                try await self.supabase.auth.session
            }
            currentUser = session.user
            await loadProfile()
        } catch {
            currentUser = nil
            currentProfile = nil
        }
    }

    /// Ensures the current session is valid, refreshing the token if needed.
    /// The Supabase SDK auto-refreshes expired tokens when you access `auth.session`.
    /// Call this before any edge function invocation to prevent 401s from expired tokens.
    func refreshSessionIfNeeded() async throws {
        let session = try await withTimeout(seconds: 10) {
            try await self.supabase.auth.session
        }
        currentUser = session.user
    }

    // MARK: - Sign Up

    func signUp(email: String, password: String, name: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let response = try await withTimeout(seconds: 15) {
                try await self.supabase.auth.signUp(
                    email: email,
                    password: password
                )
            }
            currentUser = response.user

            // Update profile with name
            let userId = response.user.id
            let _: Bool = try await withTimeout(seconds: 10) {
                _ = try await self.supabase
                    .from("profiles")
                    .update(["name": name])
                    .eq("id", value: userId.uuidString)
                    .execute()
                return true
            }

            await loadProfile()
        } catch let authError {
            self.error = authError.localizedDescription
            throw authError
        }
    }

    // MARK: - Sign In

    func signIn(email: String, password: String) async throws {
        isLoading = true
        error = nil
        defer { isLoading = false }

        do {
            let session = try await withTimeout(seconds: 15) {
                try await self.supabase.auth.signIn(
                    email: email,
                    password: password
                )
            }
            currentUser = session.user
            await loadProfile()
        } catch let authError {
            self.error = authError.localizedDescription
            throw authError
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        try? await supabase.auth.signOut()
        currentUser = nil
        currentProfile = nil
    }

    // MARK: - Profile

    func loadProfile() async {
        guard let userId = currentUser?.id else { return }
        do {
            let profile: UserProfile = try await withTimeout(seconds: 10) {
                try await self.supabase
                    .from("profiles")
                    .select()
                    .eq("id", value: userId.uuidString)
                    .single()
                    .execute()
                    .value
            }
            currentProfile = profile
        } catch {
            print("Failed to load profile: \(error)")
        }
    }

    // MARK: - Deep Link (Universal Link callback)

    /// Handles an incoming Universal Link from Supabase auth (e.g. email confirmation).
    /// The SDK extracts the PKCE auth code from the URL and exchanges it for a session.
    func handleDeepLink(_ url: URL) {
        Task {
            do {
                let session = try await supabase.auth.session(from: url)
                currentUser = session.user
                await loadProfile()
            } catch {
                print("Deep link auth failed: \(error)")
            }
        }
    }

    // MARK: - Update Profile

    func updateProfile(name: String? = nil, currentCityId: String? = nil) async throws {
        guard let userId = currentUser?.id else { return }

        let updates: [String: String] = {
            var dict: [String: String] = [:]
            if let name { dict["name"] = name }
            if let currentCityId { dict["current_city_id"] = currentCityId }
            return dict
        }()

        let _: Bool = try await withTimeout(seconds: 10) {
            _ = try await self.supabase
                .from("profiles")
                .update(updates)
                .eq("id", value: userId.uuidString)
                .execute()
            return true
        }

        await loadProfile()
    }
}
