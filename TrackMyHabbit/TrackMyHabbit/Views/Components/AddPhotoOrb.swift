import SwiftUI

/// Gradient circular "add photo" CTA — matches `EmptyStateCTA` chrome
/// (gradient, inset rims, hairline, outer shadow). Used by the calendar
/// empty-photo state and the home wallet day-card stack.
struct AddPhotoOrb: View {
    private let navyRimY: CGFloat = 3.45
    private let navyRimLineWidth: CGFloat = 5.5
    private let navyRimAccentY: CGFloat = 0.42
    private let navyRimAccentWidth: CGFloat = 2.2
    private let lightRimOffsetY: CGFloat = 2.05
    private let bottomLightRimWidth: CGFloat = 2.4
    private let bottomLightRimOpacity: Double = 0.36
    private let hairline: CGFloat = 0.5

    var body: some View {
        ZStack {
            ctaCircleBackground
            AddPhotoGlyph()
        }
        .compositingGroup()
        .appShadow(AppTheme.Elevation.ctaOuter)
    }

    private var ctaCircleBackground: some View {
        let shape = Circle()
        return shape
            .fill(figmaGradient)
            .innerInsetRim(
                shape: shape,
                color: AppTheme.Colors.ctaInsetNavy.opacity(0.2),
                lineWidth: navyRimLineWidth,
                blur: 0,
                offsetX: 0,
                offsetY: -navyRimY
            )
            .innerInsetRim(
                shape: shape,
                color: AppTheme.Overlay.black020,
                lineWidth: navyRimAccentWidth,
                blur: 0,
                offsetX: 0,
                offsetY: -navyRimAccentY
            )
            .innerInsetRim(
                shape: shape,
                color: Color.white.opacity(bottomLightRimOpacity),
                lineWidth: bottomLightRimWidth,
                blur: 0,
                offsetX: 0,
                offsetY: lightRimOffsetY
            )
            .overlay(
                shape.stroke(
                    AppTheme.Colors.ctaHairline,
                    lineWidth: hairline
                )
            )
    }

    private var figmaGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: AppTheme.Colors.emptyStateCTAStart, location: 0),
                .init(color: AppTheme.Colors.emptyStateCTAMid, location: 0.85222),
                .init(color: AppTheme.Colors.emptyStateCTAEnd, location: 1)
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1.5556)
        )
    }
}

struct AddPhotoGlyph: View {
    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(AppTheme.Colors.textInverse)
                .frame(
                    width: AppTheme.Layout.calendarAddGlyphLength,
                    height: AppTheme.Layout.calendarAddGlyphThickness
                )
            Capsule(style: .continuous)
                .fill(AppTheme.Colors.textInverse)
                .frame(
                    width: AppTheme.Layout.calendarAddGlyphThickness,
                    height: AppTheme.Layout.calendarAddGlyphLength
                )
        }
        .frame(
            width: AppTheme.Typography.Size.calendarPlusGlyph,
            height: AppTheme.Typography.Size.calendarPlusGlyph
        )
    }
}
