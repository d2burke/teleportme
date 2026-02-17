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

    // MARK: - inferPreferences(from:) Tests

    @Test func inferPreferences_allZeros() {
        let prefs = HeadingEngine.inferPreferences(from: [:])
        #expect(prefs.cost == 0)
        #expect(prefs.climate == 0)
        #expect(prefs.culture == 0)
        #expect(prefs.jobMarket == 0)
        #expect(prefs.safety == 0)
        #expect(prefs.commute == 0)
        #expect(prefs.healthcare == 0)
    }

    @Test func inferPreferences_maxWeights() {
        var weights: [CompassSignal: Double] = [:]
        for signal in CompassSignal.allCases {
            weights[signal] = 3.0
        }
        let prefs = HeadingEngine.inferPreferences(from: weights)
        // cost at max: 3 * (10/3) = 10
        #expect(prefs.cost == 10.0)
        #expect(prefs.climate == 10.0)
        #expect(prefs.jobMarket == 10.0)
        #expect(prefs.safety == 10.0)
    }

    @Test func inferPreferences_scaleFactorAccuracy() {
        let scale = 10.0 / 3.0
        let prefs = HeadingEngine.inferPreferences(from: [.cost: 1.0])
        #expect(prefs.cost == 1.0 * scale, "Cost with weight 1.0 should be ~3.33")
    }

    @Test func inferPreferences_cultureBlending() {
        // Culture only
        let prefs1 = HeadingEngine.inferPreferences(from: [.culture: 3.0])
        let scale = 10.0 / 3.0
        let expected = 3.0 * scale / 1.6
        #expect(abs(prefs1.culture - expected) < 0.01)

        // Culture + food + nightlife cross-factors
        let prefs2 = HeadingEngine.inferPreferences(from: [.food: 3.0, .nightlife: 3.0])
        let expectedCross = (0 + 3.0 * 0.3 + 3.0 * 0.3) * scale / 1.6
        #expect(abs(prefs2.culture - expectedCross) < 0.01)
    }

    @Test func inferPreferences_healthcareUsesSafety() {
        let scale = 10.0 / 3.0
        let prefs = HeadingEngine.inferPreferences(from: [.safety: 3.0])
        let expected = 3.0 * 0.8 * scale
        #expect(abs(prefs.healthcare - expected) < 0.01)
    }

    @Test func inferPreferences_commuteUsesNatureAndNightlife() {
        let scale = 10.0 / 3.0
        let prefs = HeadingEngine.inferPreferences(from: [.nature: 2.0, .nightlife: 2.0])
        let expected = (2.0 * 0.5 + 2.0 * 0.3) * scale
        #expect(abs(prefs.commute - expected) < 0.01)
    }

    @Test func inferPreferences_outputsClampedTo0_10() {
        // All prefs should be in [0, 10] regardless of inputs
        let prefs = HeadingEngine.inferPreferences(from: [.cost: 3.0, .safety: 3.0])
        #expect(prefs.cost >= 0 && prefs.cost <= 10)
        #expect(prefs.safety >= 0 && prefs.safety <= 10)
        #expect(prefs.healthcare >= 0 && prefs.healthcare <= 10)
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

    // MARK: - vibeScore(weights:cityScores:) Tests

    @Test func vibeScore_noWeights_returns50() {
        let score = HeadingEngine.vibeScore(weights: [:], cityScores: ["Safety": 8.0])
        #expect(score == 50)
    }

    @Test func vibeScore_perfectMatch() {
        let score = HeadingEngine.vibeScore(
            weights: [.safety: 3.0],
            cityScores: ["Safety": 10.0]
        )
        // (10/10) * 3 / 3 * 100 = 100
        #expect(score == 100)
    }

    @Test func vibeScore_zeroMatch() {
        let score = HeadingEngine.vibeScore(
            weights: [.safety: 3.0],
            cityScores: ["Safety": 0.0]
        )
        // (0/10) * 3 / 3 * 100 = 0
        #expect(score == 0)
    }

    @Test func vibeScore_missingCityScore_defaults5() {
        let score = HeadingEngine.vibeScore(
            weights: [.safety: 3.0],
            cityScores: [:]
        )
        // Missing score defaults to 5.0 → (5/10)*3/3*100 = 50
        #expect(score == 50)
    }

    @Test func vibeScore_multipleSignals_weightedAverage() {
        let score = HeadingEngine.vibeScore(
            weights: [.safety: 3.0, .cost: 1.0],
            cityScores: ["Safety": 10.0, "Cost of Living": 10.0]
        )
        // (10/10*3 + 10/10*1) / (3+1) * 100 = (3+1)/4*100 = 100
        #expect(score == 100)
    }

    @Test func vibeScore_resultRange() {
        let score = HeadingEngine.vibeScore(
            weights: [.climate: 2.0, .food: 1.0],
            cityScores: ["Environmental Quality": 7.0, "Leisure & Culture": 5.0]
        )
        // (7/10*2 + 5/10*1) / (2+1) * 100 = (1.4+0.5)/3*100 = 63.33...
        #expect(score >= 0 && score <= 100)
        #expect(abs(score - 63.33) < 0.5)
    }

    // MARK: - constraintModifier(...) Tests

    @Test func constraintModifier_noConstraints_returnsZero() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(),
            safetyScore: 5.0,
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        #expect(mod == 0)
    }

    @Test func constraintModifier_travelShort_nearbyCity_positive() {
        // Washington DC (default user) to NYC (~330km, ~0.4h flight)
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(travelDistance: .short),
            safetyScore: 5.0,
            costScore: 5.0,
            latitude: 40.7, // NYC
            longitude: -74.0
        )
        // flightHours ≈ 330/800 ≈ 0.41 < 5 → bonus = 1 → mod = 1/1*15 = 15
        #expect(mod == 15.0)
    }

    @Test func constraintModifier_travelShort_farCity_negative() {
        // Washington DC to Tokyo (~10,000km, ~12.5h flight)
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(travelDistance: .short),
            safetyScore: 5.0,
            costScore: 5.0,
            latitude: 35.7, // Tokyo
            longitude: 139.7
        )
        // flightHours ≈ 11000/800 ≈ 13.75 > 5 → negative bonus
        #expect(mod < 0)
    }

    @Test func constraintModifier_travelFar_alwaysPositive() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(travelDistance: .far),
            safetyScore: 5.0,
            costScore: 5.0,
            latitude: -33.9, // Sydney (very far)
            longitude: 151.2
        )
        // Far → always +1 → mod = 15
        #expect(mod == 15.0)
    }

    @Test func constraintModifier_safetyAdventurous_alwaysPositive() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(safetyComfort: .adventurous),
            safetyScore: 0.0, // even zero safety
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // Threshold = 0, score >= 0 → +1 → mod = 15
        #expect(mod == 15.0)
    }

    @Test func constraintModifier_safetyStreetSmart_atThreshold() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(safetyComfort: .streetSmart),
            safetyScore: 5.0, // exactly at threshold
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // Threshold = 5, score = 5 → +1 → mod = 15
        #expect(mod == 15.0)
    }

    @Test func constraintModifier_safetyStreetSmart_belowThreshold() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(safetyComfort: .streetSmart),
            safetyScore: 3.0, // below threshold
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // Threshold = 5, score = 3 → bonus -= (5-3)/10 = -0.2 → mod = -0.2/1*15 = -3.0
        #expect(abs(mod - (-3.0)) < 0.01)
    }

    @Test func constraintModifier_safetyRelaxed_highSafety() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(safetyComfort: .relaxed),
            safetyScore: 8.0,
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // Threshold = 7, score = 8 → +1 → mod = 15
        #expect(mod == 15.0)
    }

    @Test func constraintModifier_safetyRelaxed_belowThreshold() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(safetyComfort: .relaxed),
            safetyScore: 4.0,
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // Threshold = 7, score = 4 → bonus -= (7-4)/10 = -0.3 → mod = -0.3/1*15 = -4.5
        #expect(abs(mod - (-4.5)) < 0.01)
    }

    @Test func constraintModifier_budgetAffordable_highCost() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(budgetVibe: .affordable),
            safetyScore: 5.0,
            costScore: 7.0, // affordable
            latitude: 40.0,
            longitude: -74.0
        )
        // costScore >= 6 → +1 → mod = 15
        #expect(mod == 15.0)
    }

    @Test func constraintModifier_budgetAffordable_lowCost() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(budgetVibe: .affordable),
            safetyScore: 5.0,
            costScore: 3.0, // expensive
            latitude: 40.0,
            longitude: -74.0
        )
        // costScore < 4 → -0.5 → mod = -0.5/1*15 = -7.5
        #expect(abs(mod - (-7.5)) < 0.01)
    }

    @Test func constraintModifier_budgetSplurge_alwaysPositive() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(budgetVibe: .splurge),
            safetyScore: 5.0,
            costScore: 2.0, // very expensive — but splurge doesn't care
            latitude: 40.0,
            longitude: -74.0
        )
        // Splurge → always +1 → mod = 15
        #expect(mod == 15.0)
    }

    @Test func constraintModifier_allThreeMaxBonus() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(
                travelDistance: .far,
                safetyComfort: .adventurous,
                budgetVibe: .splurge
            ),
            safetyScore: 0.0,
            costScore: 0.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // All +1 → (3/3)*15 = 15
        #expect(mod == 15.0)
    }

    @Test func constraintModifier_allThreeAveraged() {
        let mod = HeadingEngine.constraintModifier(
            constraints: TripConstraints(
                travelDistance: .far,        // +1
                safetyComfort: .relaxed,     // below threshold → negative
                budgetVibe: .splurge         // +1
            ),
            safetyScore: 4.0, // below relaxed threshold of 7
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // far: +1, relaxed with safety=4: -(7-4)/10 = -0.3, splurge: +1
        // total bonus = 1 - 0.3 + 1 = 1.7
        // mod = (1.7/3) * 15 = 8.5
        #expect(abs(mod - 8.5) < 0.01)
    }

    // MARK: - finalScore(...) Tests

    @Test func finalScore_midVibeNoConstraints() {
        let score = HeadingEngine.finalScore(
            weights: [.safety: 3.0],
            constraints: TripConstraints(),
            cityScores: ["Safety": 5.0],
            safetyScore: 5.0,
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // vibeScore = (5/10)*3/3*100 = 50, constraintMod = 0 → final = 50
        #expect(score == 50)
    }

    @Test func finalScore_clampedToMinimum20() {
        let score = HeadingEngine.finalScore(
            weights: [.safety: 3.0],
            constraints: TripConstraints(safetyComfort: .relaxed),
            cityScores: ["Safety": 0.0],
            safetyScore: 0.0, // far below threshold
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // vibeScore = 0, constraintMod = negative → clamped to 20
        #expect(score == 20)
    }

    @Test func finalScore_clampedToMaximum99() {
        let score = HeadingEngine.finalScore(
            weights: [.safety: 3.0],
            constraints: TripConstraints(
                travelDistance: .far,
                safetyComfort: .adventurous,
                budgetVibe: .splurge
            ),
            cityScores: ["Safety": 10.0],
            safetyScore: 10.0,
            costScore: 10.0,
            latitude: 40.0,
            longitude: -74.0
        )
        // vibeScore = 100, constraintMod = +15 → 115 → clamped to 99
        #expect(score == 99)
    }

    @Test func finalScore_roundsCorrectly() {
        // Verify the score is an Int (rounded)
        let score = HeadingEngine.finalScore(
            weights: [.climate: 2.0, .food: 1.0],
            constraints: TripConstraints(),
            cityScores: ["Environmental Quality": 7.0, "Leisure & Culture": 5.0],
            safetyScore: 5.0,
            costScore: 5.0,
            latitude: 40.0,
            longitude: -74.0
        )
        #expect(score >= 20 && score <= 99)
    }

    // MARK: - evolveHeading(existing:tripVibes:retainRatio:) Tests

    @Test func evolveHeading_emptyExisting_newVibes() {
        let result = HeadingEngine.evolveHeading(
            existing: [:],
            tripVibes: [.climate: 3.0, .cost: 2.0]
        )
        // old = 0, new weight * 0.3
        #expect(abs(result["climate"]! - 0.9) < 0.01) // 0*0.7 + 3*0.3 = 0.9
        #expect(abs(result["cost"]! - 0.6) < 0.01)    // 0*0.7 + 2*0.3 = 0.6
    }

    @Test func evolveHeading_existingUnchanged_emptyVibes() {
        let existing = ["climate": 3.0, "cost": 2.0]
        let result = HeadingEngine.evolveHeading(existing: existing, tripVibes: [:])
        #expect(result["climate"] == 3.0)
        #expect(result["cost"] == 2.0)
    }

    @Test func evolveHeading_defaultRatio() {
        let result = HeadingEngine.evolveHeading(
            existing: ["climate": 2.0],
            tripVibes: [.climate: 3.0]
        )
        // 2.0 * 0.7 + 3.0 * 0.3 = 1.4 + 0.9 = 2.3
        #expect(abs(result["climate"]! - 2.3) < 0.01)
    }

    @Test func evolveHeading_ratioZero_fullyNew() {
        let result = HeadingEngine.evolveHeading(
            existing: ["climate": 2.0],
            tripVibes: [.climate: 3.0],
            retainRatio: 0.0
        )
        // 2.0 * 0.0 + 3.0 * 1.0 = 3.0
        #expect(abs(result["climate"]! - 3.0) < 0.01)
    }

    @Test func evolveHeading_ratioOne_fullyExisting() {
        let result = HeadingEngine.evolveHeading(
            existing: ["climate": 2.0],
            tripVibes: [.climate: 3.0],
            retainRatio: 1.0
        )
        // 2.0 * 1.0 + 3.0 * 0.0 = 2.0
        #expect(abs(result["climate"]! - 2.0) < 0.01)
    }

    @Test func evolveHeading_preservesExistingSignalsNotInVibes() {
        let result = HeadingEngine.evolveHeading(
            existing: ["climate": 2.0, "safety": 3.0],
            tripVibes: [.climate: 1.0]
        )
        // safety not in tripVibes → preserved as-is
        #expect(result["safety"] == 3.0)
        // climate is evolved
        #expect(abs(result["climate"]! - (2.0 * 0.7 + 1.0 * 0.3)) < 0.01)
    }

    @Test func evolveHeading_newSignalNotInExisting() {
        let result = HeadingEngine.evolveHeading(
            existing: ["climate": 2.0],
            tripVibes: [.food: 3.0]
        )
        // food not in existing → old = 0
        #expect(abs(result["food"]! - 0.9) < 0.01) // 0*0.7 + 3*0.3
        // climate preserved
        #expect(result["climate"] == 2.0)
    }
}
