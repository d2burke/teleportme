import Testing
import Foundation
@testable import TeleportMe

// MARK: - CompassModels Tests

struct CompassModelsTests {

    // MARK: - CompassSignal Tests

    @Test func allSignalsHaveLabels() {
        for signal in CompassSignal.allCases {
            #expect(!signal.label.isEmpty, "\(signal) should have a non-empty label")
        }
    }

    @Test func allSignalsHaveEmojis() {
        for signal in CompassSignal.allCases {
            #expect(!signal.emoji.isEmpty, "\(signal) should have a non-empty emoji")
        }
    }

    @Test func allSignalsHaveUniqueLabels() {
        let labels = CompassSignal.allCases.map(\.label)
        let unique = Set(labels)
        #expect(labels.count == unique.count, "All signal labels should be unique")
    }

    @Test func allSignalsHaveValidColorHex() {
        for signal in CompassSignal.allCases {
            let hex = signal.colorHex
            #expect(hex.count == 6, "\(signal) colorHex should be 6 characters")
            // Verify hex chars only
            let valid = hex.allSatisfy { "0123456789ABCDEFabcdef".contains($0) }
            #expect(valid, "\(signal) colorHex should contain only hex characters")
        }
    }

    @Test func signalCount_is8() {
        #expect(CompassSignal.allCases.count == 8)
    }

    @Test func scoreCategoryMappings() {
        #expect(CompassSignal.climate.scoreCategory == "Environmental Quality")
        #expect(CompassSignal.cost.scoreCategory == "Cost of Living")
        #expect(CompassSignal.culture.scoreCategory == "Leisure & Culture")
        #expect(CompassSignal.safety.scoreCategory == "Safety")
        #expect(CompassSignal.career.scoreCategory == "Economy")
        #expect(CompassSignal.nature.scoreCategory == "Outdoors")
        #expect(CompassSignal.food.scoreCategory == "Leisure & Culture")
        #expect(CompassSignal.nightlife.scoreCategory == "Leisure & Culture")
    }

    @Test func foodAndNightlifeShareCategory() {
        #expect(CompassSignal.food.scoreCategory == CompassSignal.nightlife.scoreCategory)
        #expect(CompassSignal.culture.scoreCategory == CompassSignal.food.scoreCategory)
    }

    @Test func secondaryScoreCategory() {
        #expect(CompassSignal.food.secondaryScoreCategory == "Healthcare")
        #expect(CompassSignal.nightlife.secondaryScoreCategory == "Commute")
        #expect(CompassSignal.climate.secondaryScoreCategory == nil)
        #expect(CompassSignal.cost.secondaryScoreCategory == nil)
        #expect(CompassSignal.culture.secondaryScoreCategory == nil)
        #expect(CompassSignal.safety.secondaryScoreCategory == nil)
        #expect(CompassSignal.career.secondaryScoreCategory == nil)
        #expect(CompassSignal.nature.secondaryScoreCategory == nil)
    }

    @Test func signalCodableRoundTrip() throws {
        for signal in CompassSignal.allCases {
            let data = try JSONEncoder().encode(signal)
            let decoded = try JSONDecoder().decode(CompassSignal.self, from: data)
            #expect(decoded == signal, "\(signal) should survive Codable round-trip")
        }
    }

    @Test func signalRawValues() {
        #expect(CompassSignal.climate.rawValue == "climate")
        #expect(CompassSignal.cost.rawValue == "cost")
        #expect(CompassSignal.culture.rawValue == "culture")
        #expect(CompassSignal.safety.rawValue == "safety")
        #expect(CompassSignal.career.rawValue == "career")
        #expect(CompassSignal.nature.rawValue == "nature")
        #expect(CompassSignal.food.rawValue == "food")
        #expect(CompassSignal.nightlife.rawValue == "nightlife")
    }

    // MARK: - Heading Tests

    @Test func explorerStaticProperty() {
        let explorer = Heading.explorer
        #expect(explorer.name == "Explorer")
        #expect(explorer.emoji == "🧭")
        #expect(explorer.topSignals.isEmpty)
        #expect(explorer.color == "888888")
    }

    @Test func headingCodableRoundTrip() throws {
        let heading = Heading(
            name: "Nomad Soul",
            emoji: "🌴",
            topSignals: [.climate, .cost],
            color: "E8855D"
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(heading)
        let decoded = try JSONDecoder().decode(Heading.self, from: data)
        #expect(decoded == heading)
    }

    @Test func headingEquatable() {
        let h1 = Heading(name: "Test", emoji: "🧭", topSignals: [.climate], color: "AABBCC")
        let h2 = Heading(name: "Test", emoji: "🧭", topSignals: [.climate], color: "AABBCC")
        let h3 = Heading(name: "Other", emoji: "🧭", topSignals: [.climate], color: "AABBCC")
        #expect(h1 == h2)
        #expect(h1 != h3)
    }

    @Test func headingHashable() {
        let h1 = Heading(name: "Test", emoji: "🧭", topSignals: [.climate], color: "AABBCC")
        let h2 = Heading(name: "Test", emoji: "🧭", topSignals: [.climate], color: "AABBCC")
        #expect(h1.hashValue == h2.hashValue)
    }

    // MARK: - TripConstraints Tests

    @Test func tripConstraints_defaultInit() {
        let constraints = TripConstraints()
        #expect(constraints.travelDistance == nil)
        #expect(constraints.safetyComfort == nil)
        #expect(constraints.budgetVibe == nil)
        #expect(!constraints.hasAny)
        #expect(constraints.count == 0)
    }

    @Test func tripConstraints_hasAny_oneSet() {
        let constraints = TripConstraints(travelDistance: .short)
        #expect(constraints.hasAny)
        #expect(constraints.count == 1)
    }

    @Test func tripConstraints_count_allSet() {
        let constraints = TripConstraints(
            travelDistance: .medium,
            safetyComfort: .streetSmart,
            budgetVibe: .moderate
        )
        #expect(constraints.hasAny)
        #expect(constraints.count == 3)
    }

    @Test func tripConstraints_codableRoundTrip() throws {
        let constraints = TripConstraints(
            travelDistance: .far,
            safetyComfort: .adventurous,
            budgetVibe: .splurge
        )
        let encoder = JSONEncoder()
        let data = try encoder.encode(constraints)
        let decoded = try JSONDecoder().decode(TripConstraints.self, from: data)
        #expect(decoded == constraints)
    }

    @Test func tripConstraints_codableSnakeCaseKeys() throws {
        // Verify snake_case encoding — all fields set so all keys appear
        let constraints = TripConstraints(travelDistance: .short, safetyComfort: .streetSmart, budgetVibe: .moderate)
        let data = try JSONEncoder().encode(constraints)
        let json = String(data: data, encoding: .utf8)!
        #expect(json.contains("travel_distance"))
        #expect(json.contains("safety_comfort"))
        #expect(json.contains("budget_vibe"))
    }

    @Test func tripConstraints_codablePartialFields() throws {
        let constraints = TripConstraints(budgetVibe: .affordable)
        let data = try JSONEncoder().encode(constraints)
        let decoded = try JSONDecoder().decode(TripConstraints.self, from: data)
        #expect(decoded.travelDistance == nil)
        #expect(decoded.safetyComfort == nil)
        #expect(decoded.budgetVibe == .affordable)
    }

    @Test func tripConstraints_codableAllNil() throws {
        let constraints = TripConstraints()
        let data = try JSONEncoder().encode(constraints)
        let decoded = try JSONDecoder().decode(TripConstraints.self, from: data)
        #expect(decoded == constraints)
        #expect(!decoded.hasAny)
    }

    // MARK: - TravelDistance Tests

    @Test func travelDistance_labels() {
        #expect(TripConstraints.TravelDistance.short.label == "Quick hop")
        #expect(TripConstraints.TravelDistance.medium.label == "Worth a connection")
        #expect(TripConstraints.TravelDistance.far.label == "Anywhere")
    }

    @Test func travelDistance_emojis() {
        #expect(!TripConstraints.TravelDistance.short.emoji.isEmpty)
        #expect(!TripConstraints.TravelDistance.medium.emoji.isEmpty)
        #expect(!TripConstraints.TravelDistance.far.emoji.isEmpty)
    }

    @Test func travelDistance_descriptions() {
        #expect(!TripConstraints.TravelDistance.short.description.isEmpty)
        #expect(!TripConstraints.TravelDistance.medium.description.isEmpty)
        #expect(!TripConstraints.TravelDistance.far.description.isEmpty)
    }

    // MARK: - SafetyComfort Tests

    @Test func safetyComfort_labels() {
        #expect(TripConstraints.SafetyComfort.adventurous.label == "Adventure mode")
        #expect(TripConstraints.SafetyComfort.streetSmart.label == "Street smart")
        #expect(TripConstraints.SafetyComfort.relaxed.label == "Peace of mind")
    }

    @Test func safetyComfort_streetSmartRawValue() {
        #expect(TripConstraints.SafetyComfort.streetSmart.rawValue == "street_smart")
    }

    @Test func safetyComfort_codableRoundTrip() throws {
        for comfort in TripConstraints.SafetyComfort.allCases {
            let data = try JSONEncoder().encode(comfort)
            let decoded = try JSONDecoder().decode(TripConstraints.SafetyComfort.self, from: data)
            #expect(decoded == comfort)
        }
    }

    // MARK: - BudgetVibe Tests

    @Test func budgetVibe_labels() {
        #expect(TripConstraints.BudgetVibe.affordable.label == "Keep it lean")
        #expect(TripConstraints.BudgetVibe.moderate.label == "Comfortable")
        #expect(TripConstraints.BudgetVibe.splurge.label == "Treat ourselves")
    }

    @Test func budgetVibe_codableRoundTrip() throws {
        for vibe in TripConstraints.BudgetVibe.allCases {
            let data = try JSONEncoder().encode(vibe)
            let decoded = try JSONDecoder().decode(TripConstraints.BudgetVibe.self, from: data)
            #expect(decoded == vibe)
        }
    }
}
