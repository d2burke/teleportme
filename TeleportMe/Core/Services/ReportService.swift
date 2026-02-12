import Foundation
import Supabase

// MARK: - Edge Function Request Body

private struct GenerateReportRequest: Encodable {
    let currentCityId: String
    let preferences: Preferences

    struct Preferences: Encodable {
        let cost: Double
        let climate: Double
        let culture: Double
        let jobMarket: Double

        enum CodingKeys: String, CodingKey {
            case cost, climate, culture
            case jobMarket = "job_market"
        }
    }

    enum CodingKeys: String, CodingKey {
        case currentCityId = "current_city_id"
        case preferences
    }
}

// MARK: - Report Service

@Observable
final class ReportService {
    private let supabase = SupabaseManager.shared.client

    var currentReport: GenerateReportResponse?
    var isGenerating = false
    var error: String?

    // MARK: - Generate Report (calls Edge Function)

    func generateReport(
        currentCityId: String,
        preferences: UserPreferences
    ) async throws -> GenerateReportResponse {
        isGenerating = true
        error = nil
        defer { isGenerating = false }

        do {
            let body = GenerateReportRequest(
                currentCityId: currentCityId,
                preferences: .init(
                    cost: preferences.costPreference,
                    climate: preferences.climatePreference,
                    culture: preferences.culturePreference,
                    jobMarket: preferences.jobMarketPreference
                )
            )

            let response: GenerateReportResponse = try await supabase.functions
                .invoke(
                    "generate-report",
                    options: .init(body: body)
                )

            currentReport = response
            return response
        } catch {
            self.error = error.localizedDescription
            throw error
        }
    }

    // MARK: - Load Past Reports

    func loadReports(userId: String) async -> [CityReport] {
        do {
            let reports: [CityReport] = try await supabase
                .from("city_reports")
                .select()
                .eq("user_id", value: userId)
                .order("created_at", ascending: false)
                .limit(20)
                .execute()
                .value
            return reports
        } catch {
            print("Failed to load reports: \(error)")
            return []
        }
    }
}
