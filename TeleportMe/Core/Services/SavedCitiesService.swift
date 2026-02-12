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

        do {
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString
            cachedUserId = userId

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
        do {
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString
            cachedUserId = userId

            // Optimistic update
            savedCityIds.insert(cityId)
            let optimistic = SavedCity(
                id: nil,
                userId: userId,
                cityId: cityId,
                createdAt: Date()
            )
            savedCities.insert(optimistic, at: 0)
            writeThroughCache(userId: userId)

            // Persist to Supabase
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
            // Rollback optimistic update
            savedCityIds.remove(cityId)
            savedCities.removeAll { $0.cityId == cityId }
            writeThroughCache(userId: cachedUserId)
            print("Failed to save city: \(error)")
        }
    }

    // MARK: - Unsave

    func unsave(cityId: String) async {
        // Optimistic update
        let removedCities = savedCities.filter { $0.cityId == cityId }
        savedCityIds.remove(cityId)
        savedCities.removeAll { $0.cityId == cityId }
        writeThroughCache(userId: cachedUserId)

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
            // Rollback optimistic update
            savedCityIds.insert(cityId)
            savedCities.append(contentsOf: removedCities)
            savedCities.sort { ($0.createdAt ?? .distantPast) > ($1.createdAt ?? .distantPast) }
            writeThroughCache(userId: cachedUserId)
            print("Failed to unsave city: \(error)")
        }
    }

    // MARK: - Cache Helpers

    private func writeThroughCache(userId: String?) {
        guard let userId else { return }
        cache.save(savedCities, for: .savedCities(userId: userId))
    }
}
