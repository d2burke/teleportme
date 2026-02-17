import Foundation

// MARK: - Heading Engine

/// Pure computation engine for deriving headings, scoring cities, and applying constraints.
/// No side effects, no dependencies — just math.
struct HeadingEngine {

    // MARK: - Personality Lookup

    /// All heading personalities keyed by sorted top-2 signal pair.
    /// Keys are alphabetically sorted: "climate+cost", not "cost+climate".
    static let personalities: [String: (name: String, emoji: String)] = [
        // Climate pairs
        "climate+cost":      ("Nomad Soul", "🌴"),
        "climate+culture":   ("Sunset Chaser", "🌅"),
        "climate+nature":    ("Tropic Explorer", "🦜"),
        "climate+safety":    ("Warm Harbor", "🏝️"),
        "climate+food":      ("Spice Route", "🌶️"),
        "climate+nightlife": ("Moonlit Wanderer", "🌙"),
        "climate+career":    ("Sun & Hustle", "🌞"),

        // Cost pairs
        "cost+culture":      ("Free Spirit", "✨"),
        "cost+nature":       ("Off-Grid Dreamer", "🏕️"),
        "cost+food":         ("Street Food Soul", "🥘"),
        "cost+safety":       ("Smart Traveler", "🎒"),
        "cost+nightlife":    ("Budget Nighthawk", "🦇"),
        "career+cost":       ("Lean Builder", "🔧"),

        // Culture pairs
        "culture+safety":    ("Old World Seeker", "🏛️"),
        "culture+food":      ("Bon Vivant", "🥂"),
        "culture+nightlife": ("Night Owl", "🦉"),
        "culture+nature":    ("Renaissance Soul", "🎨"),
        "career+culture":    ("Urban Achiever", "🌃"),

        // Safety pairs
        "career+safety":     ("Career Builder", "📈"),
        "nature+safety":     ("Quiet Strength", "🌿"),
        "food+safety":       ("Comfort Seeker", "🍵"),
        "nightlife+safety":  ("Safe Nighthawk", "🎶"),

        // Career pairs
        "career+nature":     ("Mountain Climber", "⛰️"),
        "career+food":       ("Power Lunch", "🏙️"),
        "career+nightlife":  ("After Hours", "🍸"),

        // Nature pairs
        "food+nature":       ("Forager", "🌾"),
        "nature+nightlife":  ("Wild & Free", "🐺"),

        // Food + Nightlife
        "food+nightlife":    ("Late Night Foodie", "🍷"),
    ]

    // MARK: - Heading Computation

    /// Compute a heading from signal weights.
    /// Finds the top 2 signals by weight and looks up the personality.
    static func heading(from weights: [CompassSignal: Double]) -> Heading {
        let sorted = weights
            .filter { $0.value > 0 }
            .sorted { $0.value > $1.value }

        guard sorted.count >= 2 else {
            return .explorer
        }

        let s1 = sorted[0].key
        let s2 = sorted[1].key
        let pair = [s1.rawValue, s2.rawValue].sorted().joined(separator: "+")

        let personality = personalities[pair] ?? (name: "Explorer", emoji: "🧭")
        return Heading(
            name: personality.name,
            emoji: personality.emoji,
            topSignals: [s1, s2],
            color: s1.colorHex
        )
    }

    /// Compute heading from a raw [String: Double] dictionary (for decoding from JSON).
    static func heading(fromRaw weights: [String: Double]) -> Heading {
        var typed: [CompassSignal: Double] = [:]
        for (key, value) in weights {
            if let signal = CompassSignal(rawValue: key) {
                typed[signal] = value
            }
        }
        return heading(from: typed)
    }

    // MARK: - Signal Weight Conversion

    /// Convert signal weights to old-style UserPreferences for backward compatibility.
    /// Maps compass signals to the 7 preference dimensions.
    static func inferPreferences(from weights: [CompassSignal: Double]) -> (cost: Double, climate: Double, culture: Double, jobMarket: Double, safety: Double, commute: Double, healthcare: Double) {
        // Scale: signal weights are 0-3, preferences are 0-10
        let scale = 10.0 / 3.0

        let costVal: Double = weights[.cost] ?? 0
        let climateVal: Double = weights[.climate] ?? 0
        let cultureVal: Double = weights[.culture] ?? 0
        let foodVal: Double = weights[.food] ?? 0
        let nightlifeVal: Double = weights[.nightlife] ?? 0
        let careerVal: Double = weights[.career] ?? 0
        let safetyVal: Double = weights[.safety] ?? 0
        let natureVal: Double = weights[.nature] ?? 0

        let cost = costVal * scale
        let climate = climateVal * scale
        let culture = (cultureVal + foodVal * 0.3 + nightlifeVal * 0.3) * scale / 1.6
        let jobMarket = careerVal * scale
        let safety = safetyVal * scale
        let commute = (natureVal * 0.5 + nightlifeVal * 0.3) * scale
        let healthcare = safetyVal * 0.8 * scale

        return (
            cost: min(10, max(0, cost)),
            climate: min(10, max(0, climate)),
            culture: min(10, max(0, culture)),
            jobMarket: min(10, max(0, jobMarket)),
            safety: min(10, max(0, safety)),
            commute: min(10, max(0, commute)),
            healthcare: min(10, max(0, healthcare))
        )
    }

    /// Convert a city's scores to signal weights for pre-loading the compass grid.
    /// Used when a user picks a baseline city in the "City I Love" flow.
    static func signalWeights(fromCityScores scores: [String: Double]) -> [CompassSignal: Double] {
        var weights: [CompassSignal: Double] = [:]

        for signal in CompassSignal.allCases {
            let score = scores[signal.scoreCategory] ?? 0
            // Map 0-10 score to 0-3 intensity
            // Score >= 7 → high (3), >= 4 → medium (2), >= 2 → low (1), else off (0)
            if score >= 7 {
                weights[signal] = 3
            } else if score >= 4 {
                weights[signal] = 2
            } else if score >= 2 {
                weights[signal] = 1
            }
            // else: leave absent (off)
        }

        return weights
    }

    // MARK: - City Scoring

    /// Compute a vibe match score (0-100) for a city against signal weights.
    static func vibeScore(weights: [CompassSignal: Double], cityScores: [String: Double]) -> Double {
        var score: Double = 0
        var totalWeight: Double = 0

        for (signal, weight) in weights where weight > 0 {
            let cityScore = cityScores[signal.scoreCategory] ?? 5.0
            score += (cityScore / 10.0) * weight
            totalWeight += weight
        }

        guard totalWeight > 0 else { return 50 }
        return (score / totalWeight) * 100
    }

    /// Compute constraint modifier (±15 points) based on how well a city fits constraints.
    static func constraintModifier(
        constraints: TripConstraints,
        safetyScore: Double,
        costScore: Double,
        latitude: Double,
        longitude: Double,
        userLatitude: Double = 38.9, // default: Washington DC area
        userLongitude: Double = -77.0
    ) -> Double {
        var bonus: Double = 0
        var count: Int = 0

        // Travel distance
        if let travel = constraints.travelDistance {
            count += 1
            let distance = haversineDistance(
                lat1: userLatitude, lon1: userLongitude,
                lat2: latitude, lon2: longitude
            )
            // Rough: 800km/h average, so distance/800 ≈ flight hours
            let flightHours = distance / 800.0

            switch travel {
            case .short:
                bonus += flightHours <= 5 ? 1 : -0.4 * min(2.0, (flightHours - 5) / 5)
            case .medium:
                bonus += flightHours <= 10 ? 1 : -0.3
            case .far:
                bonus += 1 // anywhere is always fine
            }
        }

        // Safety comfort
        if let safety = constraints.safetyComfort {
            count += 1
            let userThreshold: Double = {
                switch safety {
                case .adventurous: return 0
                case .streetSmart: return 5
                case .relaxed: return 7
                }
            }()
            if safetyScore >= userThreshold {
                bonus += 1
            } else {
                bonus -= (userThreshold - safetyScore) / 10.0
            }
        }

        // Budget vibe
        if let budget = constraints.budgetVibe {
            count += 1
            // Cost of Living score: higher = more affordable
            let isAffordable = costScore >= 6
            let isModerate = costScore >= 4
            switch budget {
            case .affordable:
                bonus += isAffordable ? 1 : isModerate ? 0.3 : -0.5
            case .moderate:
                bonus += isModerate ? 1 : isAffordable ? 0.8 : -0.3
            case .splurge:
                bonus += 1 // any budget works for splurge
            }
        }

        guard count > 0 else { return 0 }
        // Scale to ±15 points
        return (bonus / Double(count)) * 15.0
    }

    /// Full scoring: vibeScore + constraintModifier, clamped to 20-99.
    static func finalScore(
        weights: [CompassSignal: Double],
        constraints: TripConstraints,
        cityScores: [String: Double],
        safetyScore: Double,
        costScore: Double,
        latitude: Double,
        longitude: Double,
        userLatitude: Double = 38.9,
        userLongitude: Double = -77.0
    ) -> Int {
        let vibe = vibeScore(weights: weights, cityScores: cityScores)
        let constraintMod = constraintModifier(
            constraints: constraints,
            safetyScore: safetyScore,
            costScore: costScore,
            latitude: latitude,
            longitude: longitude,
            userLatitude: userLatitude,
            userLongitude: userLongitude
        )
        return Int(min(99, max(20, (vibe + constraintMod).rounded())))
    }

    // MARK: - Heading Evolution

    /// Blend existing heading weights with new trip vibes.
    /// Existing heading evolves slowly (retainRatio controls how much old heading is kept).
    static func evolveHeading(
        existing: [String: Double],
        tripVibes: [CompassSignal: Double],
        retainRatio: Double = 0.7
    ) -> [String: Double] {
        var result = existing
        for (signal, weight) in tripVibes {
            let key = signal.rawValue
            let old = result[key] ?? 0
            result[key] = old * retainRatio + weight * (1.0 - retainRatio)
        }
        return result
    }

    // MARK: - Helpers

    /// Haversine distance between two coordinates in kilometers.
    private static func haversineDistance(lat1: Double, lon1: Double, lat2: Double, lon2: Double) -> Double {
        let R = 6371.0 // Earth radius in km
        let dLat = (lat2 - lat1) * .pi / 180
        let dLon = (lon2 - lon1) * .pi / 180
        let a = sin(dLat / 2) * sin(dLat / 2) +
                cos(lat1 * .pi / 180) * cos(lat2 * .pi / 180) *
                sin(dLon / 2) * sin(dLon / 2)
        let c = 2 * atan2(sqrt(a), sqrt(1 - a))
        return R * c
    }
}
