import SwiftUI

enum CustomFont: String {
    case regular = "Geist-Regular"
    case medium = "Geist-Medium"
    case semibold = "Geist-SemiBold"
    case bold = "Geist-Bold"
    case extra_bold = "Extra-Bold"
    case black = "Geist-Black"
    case serifsemibold = "SeasonMix-SemiBold-TRIAL"
    case serifsemibolditalic = "SeasonMix-SemiBoldItalic-TRIAL"
}

enum TypographyStyle {
    case titlePrefix
    case body
    case subtitle

    var font: CustomFont {
        switch self {
        case .titlePrefix: return .semibold
        case .body: return .regular
        case .subtitle: return .medium
        }
    }

    var size: CGFloat {
        switch self {
        case .titlePrefix: return AppTheme.Typography.Size.xl
        case .body: return AppTheme.Typography.Size.md
        case .subtitle: return AppTheme.Typography.Size.md
        }
    }

    var lineHeight: CGFloat? {
        switch self {
        case .titlePrefix: return AppTheme.Typography.Line.title29
        case .body: return nil
        case .subtitle: return nil
        }
    }

    var tracking: CGFloat? {
        switch self {
        case .titlePrefix: return AppTheme.Typography.Tracking.titleXL
        case .body: return nil
        case .subtitle: return AppTheme.Typography.Tracking.body
        }
    }

    var color: Color {
        switch self {
        case .titlePrefix: return AppTheme.Colors.textPrimary
        case .body: return AppTheme.Colors.textPrimary
        case .subtitle: return AppTheme.Colors.textDisabled
        }
    }
}

struct CustomFontModifier: ViewModifier {
    let font: CustomFont
    let size: CGFloat
    let lineHeight: CGFloat?
    let tracking: CGFloat?
    
    func body(content: Content) -> some View {
        let baseFont = Font.custom(font.rawValue, size: size)
        
        content
            .font(baseFont)
            .lineSpacing(lineHeight.map { $0 - size } ?? 0)
            // SwiftUI tracking is in points, React Native letterSpacing is also in points but often slightly differently interpreted. It maps well enough directly passing it.
            .tracking(tracking ?? 0)
    }
}

extension View {
    func customFont(
        _ font: CustomFont = .regular,
        size: CGFloat = AppTheme.Typography.Size.md,
        lineHeight: CGFloat? = nil,
        tracking: CGFloat? = nil
    ) -> some View {
        self.modifier(CustomFontModifier(font: font, size: size, lineHeight: lineHeight, tracking: tracking))
    }
    
    func textStyle(_ style: TypographyStyle) -> some View {
        self
            .customFont(style.font, size: style.size, lineHeight: style.lineHeight, tracking: style.tracking)
            .foregroundColor(style.color)
    }
}
