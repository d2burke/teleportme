import SwiftUI

// MARK: - Theme

enum TeleportTheme {
    // MARK: Colors
    enum Colors {
        /// Primary background — near black
        static let background = Color(hex: "0A0A0A")
        /// Card / surface background
        static let surface = Color(hex: "1A1A1A")
        /// Elevated surface (active cards, selected states)
        static let surfaceElevated = Color(hex: "222222")
        /// Card border / divider
        static let border = Color(hex: "2A2A2A")
        /// Primary accent — lime/chartreuse
        static let accent = Color(hex: "D4FF00")
        /// Accent with reduced opacity (for progress bars, backgrounds)
        static let accentSubtle = Color(hex: "D4FF00").opacity(0.15)
        /// Primary text
        static let textPrimary = Color.white
        /// Secondary text / labels
        static let textSecondary = Color(hex: "8E8E93")
        /// Tertiary text / placeholders
        static let textTertiary = Color(hex: "636366")

        // Score category colors
        static let scoreCost = Color(hex: "4ECDC4")       // teal
        static let scoreSafety = Color(hex: "FF6B6B")     // coral/red
        static let scoreCulture = Color(hex: "D4FF00")    // lime (matches accent)
        static let scoreCommute = Color(hex: "4A90D9")    // blue
        static let scoreClimate = Color(hex: "7ED957")    // green
        static let scoreJobs = Color(hex: "C084FC")       // purple
        static let scoreMobility = Color(hex: "34D399")   // emerald
        static let scoreHealth = Color(hex: "F472B6")     // pink
        static let scoreEducation = Color(hex: "FBBF24")  // amber
        static let scoreOutdoors = Color(hex: "2DD4BF")   // teal-light

        /// Returns the appropriate color for a score category
        static func forCategory(_ category: String) -> Color {
            switch category {
            case "Housing", "Cost of Living", "Taxation":
                return scoreCost
            case "Safety":
                return scoreSafety
            case "Leisure & Culture", "Tolerance":
                return scoreCulture
            case "Commute", "Travel Connectivity":
                return scoreCommute
            case "Environmental Quality":
                return scoreClimate
            case "Startups", "Venture Capital", "Economy":
                return scoreJobs
            case "Business Freedom", "Internet Access":
                return scoreMobility
            case "Healthcare":
                return scoreHealth
            case "Education":
                return scoreEducation
            case "Outdoors":
                return scoreOutdoors
            default:
                return accent
            }
        }
    }

    // MARK: Typography
    enum Typography {
        /// Large hero titles — "San Francisco", match percentages
        static func heroTitle(_ size: CGFloat = 40) -> Font {
            .system(size: size, weight: .bold, design: .default)
        }
        /// Screen titles — "Your Lifestyle Match"
        static func title(_ size: CGFloat = 28) -> Font {
            .system(size: size, weight: .bold, design: .default)
        }
        /// Section headers — "LIVE DATA TRACKING"
        static func sectionHeader(_ size: CGFloat = 12) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }
        /// Card titles — "Cost of Living"
        static func cardTitle(_ size: CGFloat = 17) -> Font {
            .system(size: size, weight: .semibold, design: .default)
        }
        /// Body text
        static func body(_ size: CGFloat = 15) -> Font {
            .system(size: size, weight: .regular, design: .default)
        }
        /// Small labels — "/ 10", "LOWER", "HIGHER"
        static func caption(_ size: CGFloat = 12) -> Font {
            .system(size: size, weight: .medium, design: .default)
        }
        /// Large score numbers — "9.5"
        static func scoreValue(_ size: CGFloat = 32) -> Font {
            .system(size: size, weight: .bold, design: .rounded)
        }
    }

    // MARK: Spacing
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    // MARK: Corner Radius
    enum Radius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let card: CGFloat = 16
        static let large: CGFloat = 20
        static let pill: CGFloat = 28
    }
}

// MARK: - Color Extension (Hex)

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
