import SwiftUI

enum CustomFont {
    case regular
    case medium
    case semibold
    case bold
    
    var name: String {
        switch self {
        case .regular: return "Geist-Regular"
        case .medium: return "Geist-Medium"
        case .semibold: return "Geist-SemiBold"
        case .bold: return "Geist-Bold"
        }
    }

    var weight: Font.Weight? {
        switch self {
        case .semibold:
            return .semibold
        default:
            return nil
        }
    }
}

struct CustomFontModifier: ViewModifier {
    let font: CustomFont
    let size: CGFloat
    let lineHeight: CGFloat?
    let tracking: CGFloat?
    
    func body(content: Content) -> some View {
        let baseFont = Font.custom(font.name, size: size)
        
        content
            .font(baseFont)
            .fontWeight(font.weight)
            .lineSpacing(lineHeight.map { $0 - size } ?? 0)
            // SwiftUI tracking is in points, React Native letterSpacing is also in points but often slightly differently interpreted. It maps well enough directly passing it.
            .tracking(tracking ?? 0)
    }
}

extension View {
    func customFont(
        _ font: CustomFont = .regular,
        size: CGFloat = AppTheme.Spacing.md, // 16 is default
        lineHeight: CGFloat? = nil,
        tracking: CGFloat? = nil
    ) -> some View {
        self.modifier(CustomFontModifier(font: font, size: size, lineHeight: lineHeight, tracking: tracking))
    }
    
    // Semantic Typography Helpers (Mapping from React Native's styles)
    
    /// Title prefix (e.g. "I want to")
    func titlePrefixStyle() -> some View {
        self.customFont(.bold, size: 24, lineHeight: 29, tracking: -0.48)
            .foregroundColor(AppTheme.Colors.textPrimary)
    }
    
    /// Regular body text
    func bodyStyle() -> some View {
        self.customFont(.regular, size: AppTheme.Spacing.md)
            .foregroundColor(AppTheme.Colors.textPrimary)
    }
    
    /// Subtitle / hint text
    func subtitleStyle() -> some View {
        self.customFont(.medium, size: AppTheme.Spacing.md, tracking: -0.08)
            .foregroundColor(AppTheme.Colors.textDisabled)
    }
}
