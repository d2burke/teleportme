import Foundation
import Supabase

// MARK: - Edge Function Request Body

private struct GenerateReportRequest: Encodable {
    let currentCityId: String?
    let startType: String
    let title: String?
    let preferences: Preferences

    struct Preferences: Encodable {
        let cost: Double
        let climate: Double
        let culture: Double
        let jobMarket: Double
        let safety: Double
        let commute: Double
        let healthcare: Double

        enum CodingKeys: String, CodingKey {
            case cost, climate, culture, safety, commute, healthcare
            case jobMarket = "job_market"
        }
    }

    enum CodingKeys: String, CodingKey {
        case preferences
        case currentCityId = "current_city_id"
        case startType = "start_type"
        case title
    }
}

// MARK: - Report Service

@Observable
final class ReportService {
    private let supabase = SupabaseManager.shared.client
    private let cache = CacheManager.shared

    private let pastReportsTTL: TimeInterval = 60 * 60  // 1 hour

    var currentReport: GenerateReportResponse?
    var isGenerating = false
    var error: String?

    // MARK: - Generate Report (calls Edge Function)

    func generateReport(
        currentCityId: String?,
        startType: StartType = .cityILove,
        title: String? = nil,
        preferences: UserPreferences,
        userId: String? = nil
    ) async throws -> GenerateReportResponse {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            let body = GenerateReportRequest(
                currentCityId: currentCityId,
                startType: startType.rawValue,
                title: title,
                preferences: .init(
                    cost: preferences.costPreference,
                    climate: preferences.climatePreference,
                    culture: preferences.culturePreference,
                    jobMarket: preferences.jobMarketPreference,
                    safety: preferences.safetyPreference,
                    commute: preferences.commutePreference,
                    healthcare: preferences.healthcarePreference
                )
            )

            let response: GenerateReportResponse = try await withTimeout(seconds: 30) {
                try await self.supabase.functions
                    .invoke(
                        "generate-report",
                        options: .init(body: body)
                    )
            }

            currentReport = response

            // Write-through cache
            if let userId {
                cache.save(response, for: .currentReport(userId: userId))
            }

            return response
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }

    // MARK: - Load Past Reports

    func loadReports(userId: String) async -> [CityReport] {
        // Step 1: Load from cache immediately
        if let cached = cache.load(
            [CityReport].self,
            for: .pastReports(userId: userId),
            ttl: pastReportsTTL
        ) {
            // If fresh, return immediately without network call
            if !cached.isStale {
                self.error = nil
                return cached.data
            }

            // Stale: try network, fall back to cached on failure
            do {
                let reports = try await fetchReportsFromNetwork(userId: userId)
                self.error = nil
                return reports
            } catch {
                self.error = error.localizedDescription
                print("Failed to refresh reports, using cache: \(error)")
                return cached.data
            }
        }

        // Step 2: No cache — must fetch from network
        do {
            let reports = try await fetchReportsFromNetwork(userId: userId)
            self.error = nil
            return reports
        } catch {
            self.error = error.localizedDescription
            print("Failed to load reports: \(error)")
            return []
        }
    }

    // MARK: - Restore Current Report from Cache

    /// Restores `currentReport` from disk cache (called on app relaunch).
    func restoreCurrentReport(userId: String) {
        if let cached = cache.load(
            GenerateReportResponse.self,
            for: .currentReport(userId: userId)
        ) {
            currentReport = cached.data
        }
    }

    // MARK: - Private Helpers

    private func fetchReportsFromNetwork(userId: String) async throws -> [CityReport] {
        let reports: [CityReport] = try await withTimeout(seconds: 10) {
            try await self.supabase
                .from("city_reports")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(20)
                .execute()
                .value
        }
        cache.save(reports, for: .pastReports(userId: userId))
        return reports
    }
}
