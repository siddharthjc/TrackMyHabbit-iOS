import SwiftUI

struct EmptyState: View {
    let onCreateHabit: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let safeBottom = geometry.safeAreaInsets.bottom
            let availableWidth = geometry.size.width
            let heroSize = min(availableWidth, AppTheme.Layout.emptyHeroWidth)
            let illustrationHeight = heroSize * AppTheme.Layout.emptyHeroAspect

            ZStack {
                AppTheme.Colors.emptyStateBackground
                    .ignoresSafeArea()

                EmptyStateBackgroundPattern()
                    .frame(width: heroSize, height: heroSize)
                    .offset(y: -geometry.size.height * 0.14)
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    Spacer(minLength: geometry.size.height * 0.06)

                    Image("EmptyStateHero")
                        .resizable()
                        .scaledToFill()
                        .frame(width: heroSize, height: illustrationHeight, alignment: .top)
                        .clipped()
                        .frame(maxWidth: .infinity)

                    Spacer(minLength: geometry.size.height * 0.02)

                    VStack(alignment: .leading, spacing: AppTheme.Spacing.sm3) {
                        Text("")
                            .customFont(.medium, size: AppTheme.Typography.Size.xl, lineHeight: AppTheme.Typography.Line.title288, tracking: AppTheme.Typography.Tracking.titleXL)
                            .foregroundColor(AppTheme.Colors.textSecondary.opacity(AppTheme.Opacity.emptyStatePlaceholder))

                        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
                            Text("Meet your better self.")
                                .customFont(.serifsemibold, size: AppTheme.Typography.Size.xl, lineHeight: AppTheme.Typography.Line.title288, tracking: AppTheme.Typography.Tracking.titleXL)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("Small habits. Big change.")
                                .customFont(.serifsemibold, size: AppTheme.Typography.Size.xl, lineHeight: AppTheme.Typography.Line.title288, tracking: AppTheme.Typography.Tracking.titleXL)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)

                    Spacer(minLength: AppTheme.Spacing.relaxed)

                    Button(action: onCreateHabit) {
                        Text("Continue")
                    }
                    .buttonStyle(EmptyStateCTAButtonStyle())
                    .padding(.horizontal, AppTheme.Spacing.lg)

                    Spacer(minLength: max(AppTheme.Spacing.lg, safeBottom + AppTheme.Spacing.sm))
                }
            }
        }
    }
}

/// White bottom rim fixed at rest; navy top rim **Y** decreases while pressed (`offsetY` is **−Y**, so smaller Y → subtler top lip).
private struct EmptyStateCTA: View {
    var title: String
    var isPressed: Bool

    private let cornerRadius: CGFloat = AppTheme.Radius.pill

    private var navyRimY: CGFloat { isPressed ? 2.0 : 3.45 }
    private let navyRimLineWidth: CGFloat = 5.5
    private var navyRimAccentY: CGFloat { isPressed ? 0.28 : 0.42 }
    private let navyRimAccentWidth: CGFloat = 2.2

    private let lightRimOffsetY: CGFloat = 2.05

    private let bottomLightRimWidth: CGFloat = 2.4
    private let bottomLightRimOpacity: Double = 0.36

    var body: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            Text(title)
                .customFont(.semibold, size: AppTheme.Typography.Size.md, lineHeight: AppTheme.Typography.Line.body192, tracking: AppTheme.Typography.Tracking.tight)
                .foregroundColor(AppTheme.Neutral._0)
        }
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, AppTheme.Spacing.lg)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(ctaBackground)
        .compositingGroup()
        .appShadow(AppTheme.Elevation.ctaOuter)
    }

    private var ctaBackground: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let hairline: CGFloat = 0.5
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

    /// Figma: `to-b` from `#6f8eff`, via `#4d6fea` @ 85.222%, to `#5778f1` with end ~155.56% (`shadow-[...to-[155.56%]...]`).
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

/// Stroke + offset + `mask(shape)` — inner rim; optional blur (CTA uses `0` for crisp edges).
private struct InnerInsetRimModifier<S: Shape>: ViewModifier {
    let shape: S
    var color: Color
    var lineWidth: CGFloat
    var blur: CGFloat
    var offsetX: CGFloat
    var offsetY: CGFloat

    func body(content: Content) -> some View {
        content.overlay {
            Group {
                if blur > 0.001 {
                    shape.stroke(color, lineWidth: lineWidth).blur(radius: blur)
                } else {
                    shape.stroke(color, lineWidth: lineWidth)
                }
            }
            .offset(x: offsetX, y: offsetY)
            .mask(shape.fill(Color.black))
        }
    }
}

private extension View {
    func innerInsetRim<S: Shape>(
        shape: S,
        color: Color,
        lineWidth: CGFloat,
        blur: CGFloat,
        offsetX: CGFloat,
        offsetY: CGFloat
    ) -> some View {
        modifier(
            InnerInsetRimModifier(
                shape: shape,
                color: color,
                lineWidth: lineWidth,
                blur: blur,
                offsetX: offsetX,
                offsetY: offsetY
            )
        )
    }
}

/// `isPressed` only drives navy rim **Y**; white rim and outer shadow stay fixed.
private struct EmptyStateCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            EmptyStateCTA(title: "Continue", isPressed: configuration.isPressed)
            configuration.label
                .hidden()
                .accessibilityHidden(true)
        }
        .animation(AppTheme.Motion.springCTA, value: configuration.isPressed)
    }
}

private struct EmptyStateBackgroundPattern: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let dotSpacing: CGFloat = AppTheme.Layout.patternDotSpacing
            let dotRadius: CGFloat = AppTheme.Layout.patternDotRadius

            Canvas { context, _ in
                let cols = Int(ceil(size.width / dotSpacing))
                let rows = Int(ceil(size.height / dotSpacing))

                for r in 0...rows {
                    for c in 0...cols {
                        let x = CGFloat(c) * dotSpacing + dotSpacing * 0.5
                        let y = CGFloat(r) * dotSpacing + dotSpacing * 0.5
                        let rect = CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                        context.fill(Path(ellipseIn: rect), with: .color(AppTheme.Neutral._500.opacity(AppTheme.Layout.patternDotOpacity)))
                    }
                }
            }
            .mask(
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: AppTheme.Overlay.black055, location: 0),
                        .init(color: AppTheme.Overlay.black000, location: 1)
                    ]),
                    center: .center,
                    startRadius: 0,
                    endRadius: max(size.width, size.height) * 0.55
                )
            )
        }
    }
}

#Preview {
    EmptyState {}
}
