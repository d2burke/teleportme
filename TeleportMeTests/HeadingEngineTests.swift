import Testing
import Foundation
@testable import TeleportMe

// MARK: - HeadingEngine Tests

struct HeadingEngineTests {

    // MARK: - heading(from:) Tests

    @Test func headingFromEmptyWeights_returnsExplorer() {
        let heading = HeadingEngine.heading(from: [:])
        #expect(heading.name == "Explorer")
        #expect(heading.emoji == "🧭")
        #expect(heading.topSignals.isEmpty)
    }

    @Test func headingFromSingleSignal_returnsExplorer() {
        let heading = HeadingEngine.heading(from: [.climate: 3.0])
        #expect(heading.name == "Explorer")
        #expect(heading.topSignals.isEmpty)
    }

    @Test func headingFromTwoSignals_returnsCorrectPersonality() {
        let heading = HeadingEngine.heading(from: [.climate: 3.0, .cost: 2.0])
        #expect(heading.name == "Nomad Soul")
        #expect(heading.emoji == "🌴")
        #expect(heading.topSignals.count == 2)
        #expect(heading.topSignals.contains(.climate))
        #expect(heading.topSignals.contains(.cost))
    }

    @Test func headingPicksTopTwoByWeight() {
        let heading = HeadingEngine.heading(from: [
            .climate: 3.0,
            .cost: 2.0,
            .culture: 1.0
        ])
        // Top 2 should be climate (3) and cost (2)
        #expect(heading.name == "Nomad Soul")
        #expect(heading.topSignals[0] == .climate) // highest
        #expect(heading.topSignals[1] == .cost)    // second
    }

    @Test func headingFoodAndCulture_bonVivant() {
        let heading = HeadingEngine.heading(from: [.food: 3.0, .culture: 2.0])
        #expect(heading.name == "Bon Vivant")
        #expect(heading.emoji == "🥂")
    }

    @Test func headingFoodAndNightlife_lateNightFoodie() {
        let heading = HeadingEngine.heading(from: [.food: 3.0, .nightlife: 2.0])
        #expect(heading.name == "Late Night Foodie")
        #expect(heading.emoji == "🍷")
    }

    @Test func headingCareerAndCost_leanBuilder() {
        let heading = HeadingEngine.heading(from: [.career: 3.0, .cost: 2.0])
        #expect(heading.name == "Lean Builder")
        #expect(heading.emoji == "🔧")
    }

    @Test func headingNatureAndSafety_quietStrength() {
        let heading = HeadingEngine.heading(from: [.nature: 3.0, .safety: 2.0])
        #expect(heading.name == "Quiet Strength")
        #expect(heading.emoji == "🌿")
    }

    @Test func headingColorFromPrimarySignal() {
        let heading = HeadingEngine.heading(from: [.food: 3.0, .culture: 2.0])
        #expect(heading.color == CompassSignal.food.colorHex)
    }

    @Test func headingFiltersOutZeroWeights() {
        let heading = HeadingEngine.heading(from: [
            .climate: 3.0,
            .cost: 0.0,
            .culture: 2.0
        ])
        // cost=0 filtered, so top-2 = climate + culture
        #expect(heading.name == "Sunset Chaser")
    }

    @Test func headingFiltersOutNegativeWeights() {
        let heading = HeadingEngine.heading(from: [
            .climate: 3.0,
            .cost: -1.0,
            .culture: 2.0
        ])
        #expect(heading.name == "Sunset Chaser")
    }

    @Test func headingTiedWeights_deterministic() {
        // When tied, sorted pair key is alphabetical, order of topSignals depends on sort stability
        let heading1 = HeadingEngine.heading(from: [.climate: 3.0, .cost: 3.0])
        let heading2 = HeadingEngine.heading(from: [.cost: 3.0, .climate: 3.0])
        // Same pair key regardless of input order
        #expect(heading1.name == heading2.name)
        #expect(heading1.emoji == heading2.emoji)
    }

    @Test func headingAllSignalsEqualWeight_returnsValidHeading() {
        var weights: [CompassSignal: Double] = [:]
        for signal in CompassSignal.allCases {
            weights[signal] = 2.0
        }
        let heading = HeadingEngine.heading(from: weights)
        // Should return some valid heading, not crash
        #expect(!heading.name.isEmpty)
        #expect(!heading.emoji.isEmpty)
        #expect(heading.topSignals.count == 2)
    }

    @Test func headingAllKnownPairsAreMapped() {
        // Verify personality count covers enough combinations
        #expect(HeadingEngine.personalities.count == 28)
    }

    // MARK: - heading(fromRaw:) Tests

    @Test func headingFromRaw_validKeys() {
        let heading = HeadingEngine.heading(fromRaw: ["climate": 3.0, "cost": 2.0])
        #expect(heading.name == "Nomad Soul")
    }

    @Test func headingFromRaw_invalidKeysIgnored() {
        let heading = HeadingEngine.heading(fromRaw: [
            "climate": 3.0,
            "invalid_signal": 2.0,
            "also_bad": 1.0
        ])
        // Only 1 valid signal → returns explorer
        #expect(heading.name == "Explorer")
    }

    @Test func headingFromRaw_mixedValidInvalid() {
        let heading = HeadingEngine.heading(fromRaw: [
            "climate": 3.0,
            "cost": 2.0,
            "not_a_signal": 5.0
        ])
        #expect(heading.name == "Nomad Soul")
    }

    @Test func headingFromRaw_emptyDictionary() {
        let heading = HeadingEngine.heading(fromRaw: [:])
        #expect(heading.name == "Explorer")
    }

    // MARK: - signalWeights(fromCityScores:) Tests

    @Test func signalWeightsFromCityScores_highScore() {
        let weights = HeadingEngine.signalWeights(fromCityScores: [
            "Environmental Quality": 8.0
        ])
        #expect(weights[.climate] == 3)
    }

    @Test func signalWeightsFromCityScores_mediumScore() {
        let weights = HeadingEngine.signalWeights(fromCityScores: [
            "Environmental Quality": 5.0
        ])
        #expect(weights[.climate] == 2)
    }

    @Test func signalWeightsFromCityScores_lowScore() {
        let weights = HeadingEngine.signalWeights(fromCityScores: [
            "Environmental Quality": 2.5
        ])
        #expect(weights[.climate] == 1)
    }

    @Test func signalWeightsFromCityScores_veryLowScoreOmitted() {
        let weights = HeadingEngine.signalWeights(fromCityScores: [
            "Environmental Quality": 1.99
        ])
        #expect(weights[.climate] == nil)
    }

    @Test func signalWeightsFromCityScores_boundaryAt7() {
        let weights = HeadingEngine.signalWeights(fromCityScores: [
            "Environmental Quality": 7.0
        ])
        #expect(weights[.climate] == 3)
    }

    @Test func signalWeightsFromCityScores_boundaryAt4() {
        let weights = HeadingEngine.signalWeights(fromCityScores: [
            "Environmental Quality": 4.0
        ])
        #expect(weights[.climate] == 2)
    }

    @Test func signalWeightsFromCityScores_boundaryAt2() {
        let weights = HeadingEngine.signalWeights(fromCityScores: [
            "Environmental Quality": 2.0
        ])
        #expect(weights[.climate] == 1)
    }

    @Test func signalWeightsFromCityScores_missingCategory() {
        let weights = HeadingEngine.signalWeights(fromCityScores: [:])
        // All signals should be absent (score defaults to 0 < 2)
        #expect(weights.isEmpty)
    }

    @Test func signalWeightsFromCityScores_allHighScores() {
        let scores: [String: Double] = [
            "Environmental Quality": 8.0,
            "Cost of Living": 7.5,
            "Leisure & Culture": 9.0,
            "Safety": 8.0,
            "Economy": 7.0,
            "Outdoors": 8.5,
        ]
        let weights = HeadingEngine.signalWeights(fromCityScores: scores)
        // climate, cost, culture, food, nightlife, safety, career, nature should all be present
        #expect(weights[.climate] == 3)
        #expect(weights[.cost] == 3)
        #expect(weights[.safety] == 3)
        #expect(weights[.career] == 3)
        #expect(weights[.nature] == 3)
        // culture, food, nightlife all map to "Leisure & Culture"
        #expect(weights[.culture] == 3)
        #expect(weights[.food] == 3)
        #expect(weights[.nightlife] == 3)
    }

}
