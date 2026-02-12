import Foundation
import Supabase

// MARK: - Saved Cities Service

@Observable
final class SavedCitiesService {
    private let supabase = SupabaseManager.shared.client

    var savedCityIds: Set<String> = []
    var savedCities: [SavedCity] = []
    var isLoading = false

    // MARK: - Load Saved Cities

    func loadSavedCities() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let session = try await supabase.auth.session
            let userId = session.user.id.uuidString

            let cities: [SavedCity] = try await supabase
                .from("saved_cities")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .execute()
                .value

            savedCities = cities
            savedCityIds = Set(cities.map { $0.cityId })
        } catch {
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

            // Optimistic update
            savedCityIds.insert(cityId)
            let optimistic = SavedCity(
                id: nil,
                userId: userId,
                cityId: cityId,
                createdAt: Date()
            )
            savedCities.insert(optimistic, at: 0)

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
        } catch {
            // Rollback optimistic update
            savedCityIds.remove(cityId)
            savedCities.removeAll { $0.cityId == cityId }
            print("Failed to save city: \(error)")
        }
    }

    // MARK: - Unsave

    func unsave(cityId: String) async {
        // Optimistic update
        let removedCities = savedCities.filter { $0.cityId == cityId }
        savedCityIds.remove(cityId)
        savedCities.removeAll { $0.cityId == cityId }

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
            print("Failed to unsave city: \(error)")
        }
    }
}
