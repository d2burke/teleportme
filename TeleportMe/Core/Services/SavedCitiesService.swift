import Foundation
import Supabase

// MARK: - Saved Cities Service

@Observable
final class SavedCitiesService {
    private let supabase = SupabaseManager.shared.client
    private let cache = CacheManager.shared

    private let savedCitiesTTL: TimeInterval = 5 * 60  // 5 minutes

    var savedCityIds: Set<String> = []
    var savedCities: [SavedCity] = []
    var isLoading = false
    var loadError: String?

    /// The userId used for per-user cache keys.
    /// Set by AppCoordinator after auth resolves.
    var cachedUserId: String?

    // MARK: - Load Saved Cities

    func loadSavedCities() async {
        isLoading = true
        loadError = nil
        defer { isLoading = false }

        // Try to resolve userId — from cache first, then session
        var userId = cachedUserId
        if userId == nil {
            do {
                let session = try await supabase.auth.session
                userId = session.user.id.uuidString
                cachedUserId = userId
            } catch {
                // If we can't get a session, try loading from cache with whatever userId we have
                if savedCities.isEmpty {
                    loadError = error.localizedDescription
                }
                print("Failed to get session for saved cities: \(error)")
                return
            }
        }

        guard let userId else { return }

        // Step 1: Load from cache immediately
        if let cached = cache.load(
            [SavedCity].self,
            for: .savedCities(userId: userId),
            ttl: savedCitiesTTL
        ) {
            savedCities = cached.data
            savedCityIds = Set(cached.data.map { $0.cityId })
            if !cached.isStale { return }  // Fresh cache — skip network
        }

        // Step 2: Fetch from network
        do {
            let cities: [SavedCity] = try await withTimeout(seconds: 10) {
                try await self.supabase
                    .from("saved_cities")
                    .select()
                    .eq("user_id", value: userId)
                    .order("created_at", ascending: false)
                    .execute()
                    .value
            }

            savedCities = cities
            savedCityIds = Set(cities.map { $0.cityId })
            cache.save(cities, for: .savedCities(userId: userId))
        } catch {
            // Only show error if we have no cached data
            if savedCities.isEmpty {
                loadError = error.localizedDescription
            }
            print("Failed to load saved cities: \(error)")
        }
    }

    // MARK: - Toggle Save

    func toggleSave(cityId: String) async {
        if isSaved(cityId: cityId) {
            await unsave(cityId: cityId)
        } else {
            await save(cityId: cityId)
        }
    }

    // MARK: - Is Saved

    func isSaved(cityId: String) -> Bool {
        savedCityIds.contains(cityId)
    }

    // MARK: - Save

    private func save(cityId: String) async {
        // Resolve userId — use cached value if available (works offline)
        let userId: String
        if let cached = cachedUserId {
            userId = cached
        } else {
            do {
                let session = try await supabase.auth.session
                userId = session.user.id.uuidString
                cachedUserId = userId
            } catch {
                print("Failed to save city (no session): \(error)")
                return
            }
        }

        // Optimistic update FIRST (before any network calls)
        savedCityIds.insert(cityId)
        let optimistic = SavedCity(
            id: nil,
            userId: userId,
            cityId: cityId,
            createdAt: Date()
        )
        savedCities.insert(optimistic, at: 0)
        writeThroughCache(userId: userId)

        // Persist to Supabase in background (non-blocking)
        do {
            let inserted: SavedCity = try await supabase
                .from("saved_cities")
                .insert([
                    "user_id": userId,
                    "city_id": cityId
                ])
                .select()
                .single()
                .execute()
                .value

            // Replace optimistic entry with server response
            if let index = savedCities.firstIndex(where: { $0.cityId == cityId && $0.id == nil }) {
                savedCities[index] = inserted
            }
            writeThroughCache(userId: userId)
        } catch {
            // Network failed — keep the local save (it's cached and will show on relaunch).
            // The save stays visible to the user and persists in cache.
            // It will be reconciled on next successful loadSavedCities() from server.
            print("Failed to persist save to server (kept locally): \(error)")
        }
    }

    // MARK: - Unsave

    func unsave(cityId: String) async {
        // Optimistic update FIRST
        let removedCities = savedCities.filter { $0.cityId == cityId }
        savedCityIds.remove(cityId)
        savedCities.removeAll { $0.cityId == cityId }
        writeThroughCache(userId: cachedUserId)

        // Persist to Supabase in background
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString

            try await supabase
                .from("saved_cities")
                .delete()
                .eq("user_id", value: userId)
                .eq("city_id", value: cityId)
                .execute()
        } catch {
            // Network failed — keep the unsave (removed locally).
            // Will be reconciled on next loadSavedCities() from server.
            print("Failed to persist unsave to server (kept locally): \(error)")
        }
    }

    // MARK: - Cache Helpers

    private func writeThroughCache(userId: String?) {
        guard let userId else { return }
        cache.save(savedCities, for: .savedCities(userId: userId))
    }
}
