import Foundation

// MARK: - Heading Engine

/// Pure computation engine for deriving headings from signal weights.
/// Scoring and heading evolution are server-authoritative (generate-report edge function).
/// This engine is kept for client-side live preview in TripVibesView.
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

}
