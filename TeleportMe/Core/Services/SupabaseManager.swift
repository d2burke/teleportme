import Foundation
import Supabase

// MARK: - Supabase Manager

/// Central Supabase client configured from environment.
@Observable
final class SupabaseManager {
    static let shared = SupabaseManager()

    let client: SupabaseClient

    private init() {
        let url = URL(string: "https://REDACTED_PROJECT_REF.supabase.co")!
        let key = "REDACTED_SUPABASE_ANON_KEY"

        client = SupabaseClient(supabaseURL: url, supabaseKey: key)
    }
}
