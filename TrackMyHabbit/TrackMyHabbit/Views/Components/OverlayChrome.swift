import SwiftUI

extension View {
    /// 48×48 white rounded square with floating shadow (Figma 522:3265 / 604:2575).
    /// Apply to a glyph (`Image(systemName:)`) inside a `Button` or `Menu` label
    /// so both styles share the same chrome.
    func overlayChromeShape() -> some View {
        self
            .frame(
                width: AppTheme.Layout.calendarOverlayChromeButton,
                height: AppTheme.Layout.calendarOverlayChromeButton
            )
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                    .fill(AppTheme.Colors.dayCardFill)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
                    .stroke(AppTheme.Colors.dayCardFill, lineWidth: AppTheme.Spacing.hairline)
            )
            .appShadow(AppTheme.Elevation.floatingCircularButton)
    }
}

/// Tap-action variant of the overlay chrome button (close / single action).
struct OverlayChromeButton: View {
    let systemName: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.system(size: AppTheme.Typography.Size.md, weight: .semibold))
                .foregroundColor(AppTheme.Colors.textPrimary)
                .overlayChromeShape()
        }
        .buttonStyle(.plain)
    }
}
