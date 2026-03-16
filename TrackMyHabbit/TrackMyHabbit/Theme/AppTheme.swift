import SwiftUI

enum AppTheme {
    
    // MARK: - Color Primitives
    
    enum Neutral {
        static let _0 = Color(hex: "#ffffff")
        static let _100 = Color(hex: "#fafafc")
        static let _200 = Color(hex: "#f5f5f8")
        static let _300 = Color(hex: "#e9e9ef")
        static let _400 = Color(hex: "#d4d4dc")
        static let _500 = Color(hex: "#b3b3c3")
        static let _600 = Color(hex: "#8a8a9f")
        static let _700 = Color(hex: "#5e5e72")
        static let _800 = Color(hex: "#2e2e3d")
        static let _900 = Color(hex: "#1a1a25")
    }
    
    enum Brand {
        static let _0 = Color(hex: "#f3f1ff")
        static let _100 = Color(hex: "#e2dfff")
        static let _200 = Color(hex: "#c7c0fb")
        static let _300 = Color(hex: "#aba0f5")
        static let _400 = Color(hex: "#8f84ee")
        static let _500 = Color(hex: "#7569e0")
        static let _600 = Color(hex: "#6253d5")
        static let _700 = Color(hex: "#4d3dbd")
        static let _800 = Color(hex: "#392c9d")
    }
    
    // MARK: - Semantic Colors
    
    enum Colors {
        // Text
        static let textPrimary = Color(hex: "#16191d")
        static let textSecondary = Color(hex: "#5b6271")
        static let textDisabled = Color(hex: "#8c95a6")
        
        // Backgrounds
        static let bgPrimary = Color(hex: "#ffffff")
        static let bgSecondary = Color(hex: "#f6f7f9")
        static let bgTertiary = Color(hex: "#edeff3")
        
        // System / Brand
        static let systemBlue = Color(hex: "#007aff")
        static let primary = Brand._600
        static let primaryLight = Brand._0
        static let cardBorder = Brand._200
        static let emptyStateBackground = Color(hex: "#f9fafa")
        static let emptyStateCardTint = Color(hex: "#f0f3ff")
        static let emptyStateCTAStart = Color(hex: "#6f8eff")
        static let emptyStateCTAMid = Color(hex: "#4d6fea")
        static let emptyStateCTAEnd = Color(hex: "#5778f1")
    }
    
    // MARK: - Layout Constants
    
    enum Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 20
        static let xl: CGFloat = 24
        static let xxl: CGFloat = 40
        static let xxxl: CGFloat = 80
    }
    
    enum Radius {
        static let sm: CGFloat = 8
        static let md: CGFloat = 12
        static let lg: CGFloat = 20
        static let xl: CGFloat = 30
        static let full: CGFloat = 999
    }
}

// MARK: - Color Hex Initializer
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
