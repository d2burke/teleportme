import Foundation
import SwiftUI

// MARK: - Compass Signal

/// The 8 core signals that define a user's travel/living personality.
/// Each signal maps to one or more city_scores categories in the database.
enum CompassSignal: String, CaseIterable, Codable, Identifiable, Hashable {
    case climate
    case cost
    case culture
    case safety
    case career
    case nature
    case food
    case nightlife

    var id: String { rawValue }

    var label: String {
        switch self {
        case .climate: "Climate"
        case .cost: "Affordability"
        case .culture: "Culture"
        case .safety: "Safety"
        case .career: "Career"
        case .nature: "Nature"
        case .food: "Food"
        case .nightlife: "Nightlife"
        }
    }

    var shortLabel: String {
        switch self {
        case .climate: "Sun"
        case .cost: "Budget"
        case .culture: "Culture"
        case .safety: "Safe"
        case .career: "Career"
        case .nature: "Nature"
        case .food: "Food"
        case .nightlife: "Night"
        }
    }

    var emoji: String {
        switch self {
        case .climate: "☀️"
        case .cost: "💰"
        case .culture: "🎭"
        case .safety: "🛡️"
        case .career: "💼"
        case .nature: "🏔️"
        case .food: "🍜"
        case .nightlife: "🌙"
        }
    }

    var color: Color {
        switch self {
        case .climate: Color(hex: "E8855D")
        case .cost: Color(hex: "4ECB71")
        case .culture: Color(hex: "D4A056")
        case .safety: Color(hex: "5B9BD5")
        case .career: Color(hex: "9B6FB6")
        case .nature: Color(hex: "1ABC9C")
        case .food: Color(hex: "E6922E")
        case .nightlife: Color(hex: "8B7EC8")
        }
    }

    var colorHex: String {
        switch self {
        case .climate: "E8855D"
        case .cost: "4ECB71"
        case .culture: "D4A056"
        case .safety: "5B9BD5"
        case .career: "9B6FB6"
        case .nature: "1ABC9C"
        case .food: "E6922E"
        case .nightlife: "8B7EC8"
        }
    }

    /// Maps this signal to the primary DB city_scores category name.
    /// Display-only on the client — actual scoring is server-authoritative (generate-report edge function).
    var scoreCategory: String {
        switch self {
        case .climate: "Environmental Quality"
        case .cost: "Cost of Living"
        case .culture: "Leisure & Culture"
        case .safety: "Safety"
        case .career: "Economy"
        case .nature: "Outdoors"
        case .food: "Leisure & Culture"
        case .nightlife: "Leisure & Culture"
        }
    }

    /// Secondary DB category used for more nuanced scoring.
    var secondaryScoreCategory: String? {
        switch self {
        case .food: "Healthcare" // fallback; food-specific scoring handled in edge function
        case .nightlife: "Commute" // nightlife cities tend to have good transit
        default: nil
        }
    }
}

// MARK: - Heading

/// A computed personality identity derived from a user's top-2 signal weights.
struct Heading: Codable, Equatable, Hashable {
    let name: String
    let emoji: String
    let topSignals: [CompassSignal]
    let color: String // hex

    static let explorer = Heading(name: "Explorer", emoji: "🧭", topSignals: [], color: "888888")
}

// MARK: - Trip Constraints

/// Practical constraints for a specific trip — travel distance, safety comfort, budget.
struct TripConstraints: Codable, Equatable {
    var travelDistance: TravelDistance?
    var safetyComfort: SafetyComfort?
    var budgetVibe: BudgetVibe?

    enum CodingKeys: String, CodingKey {
        case travelDistance = "travel_distance"
        case safetyComfort = "safety_comfort"
        case budgetVibe = "budget_vibe"
    }

    /// True if at least one constraint is set.
    var hasAny: Bool {
        travelDistance != nil || safetyComfort != nil || budgetVibe != nil
    }

    /// Number of constraints set (0-3).
    var count: Int {
        [travelDistance != nil, safetyComfort != nil, budgetVibe != nil].filter { $0 }.count
    }

    enum TravelDistance: String, Codable, CaseIterable, Identifiable {
        case short
        case medium
        case far

        var id: String { rawValue }

        var label: String {
            switch self {
            case .short: "Quick hop"
            case .medium: "Worth a connection"
            case .far: "Anywhere"
            }
        }

        var emoji: String {
            switch self {
            case .short: "🏖️"
            case .medium: "🌎"
            case .far: "🌍"
            }
        }

        var description: String {
            switch self {
            case .short: "Under 5 hours"
            case .medium: "5–10 hours is fine"
            case .far: "Distance is irrelevant"
            }
        }
    }

    enum SafetyComfort: String, Codable, CaseIterable, Identifiable {
        case adventurous
        case streetSmart = "street_smart"
        case relaxed

        var id: String { rawValue }

        var label: String {
            switch self {
            case .adventurous: "Adventure mode"
            case .streetSmart: "Street smart"
            case .relaxed: "Peace of mind"
            }
        }

        var emoji: String {
            switch self {
            case .adventurous: "⚡"
            case .streetSmart: "🧠"
            case .relaxed: "🛡️"
            }
        }

        var description: String {
            switch self {
            case .adventurous: "I can handle myself"
            case .streetSmart: "Aware, not anxious"
            case .relaxed: "Safe is non-negotiable"
            }
        }
    }

    enum BudgetVibe: String, Codable, CaseIterable, Identifiable {
        case affordable
        case moderate
        case splurge

        var id: String { rawValue }

        var label: String {
            switch self {
            case .affordable: "Keep it lean"
            case .moderate: "Comfortable"
            case .splurge: "Treat ourselves"
            }
        }

        var emoji: String {
            switch self {
            case .affordable: "🎒"
            case .moderate: "✈️"
            case .splurge: "🥂"
            }
        }

        var description: String {
            switch self {
            case .affordable: "More trips > bigger trips"
            case .moderate: "Don't think about every dollar"
            case .splurge: "This is the trip"
            }
        }
    }
}

// Note: Color(hex:) extension is defined in TeleportTheme.swift
