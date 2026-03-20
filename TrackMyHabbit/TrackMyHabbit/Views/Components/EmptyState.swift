import SwiftUI
import UIKit

struct EmptyState: View {
    let onCreateHabit: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let safeBottom = geometry.safeAreaInsets.bottom
            let availableWidth = geometry.size.width
            let heroSize = min(availableWidth, 402)
            let illustrationHeight = heroSize * (456.0 / 402.0)

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

                    VStack(alignment: .leading, spacing: 12) {
                        Text("")
                            .customFont(.medium, size: 24, lineHeight: 28.8, tracking: -0.48)
                            .foregroundColor(AppTheme.Colors.textSecondary.opacity(0.5))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Meet your better self.")
                                .customFont(.serifsemibold, size: 24, lineHeight: 28.8, tracking: -0.48)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("Small habits. Big change.")
                                .customFont(.serifsemibold, size: 24, lineHeight: 28.8, tracking: -0.48)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)

                    Spacer(minLength: 18)

                    Button(action: onCreateHabit) {
                        Text("Continue")
                    }
                    .buttonStyle(EmptyStateCTAButtonStyle())
                    .padding(.horizontal, 20)

                    Spacer(minLength: max(20, safeBottom + 8))
                }
            }
        }
    }
}

/// White bottom rim fixed at rest; navy top rim **Y** decreases while pressed (`offsetY` is **−Y**, so smaller Y → subtler top lip).
private struct EmptyStateCTA: View {
    var title: String
    var isPressed: Bool

    private let cornerRadius: CGFloat = 56

    private var navyRimY: CGFloat { isPressed ? 2.0 : 3.45 }
    private let navyRimLineWidth: CGFloat = 5.5
    private var navyRimAccentY: CGFloat { isPressed ? 0.28 : 0.42 }
    private let navyRimAccentWidth: CGFloat = 2.2

    private let lightRimOffsetY: CGFloat = 2.05

    private let bottomLightRimWidth: CGFloat = 2.4
    private let bottomLightRimOpacity: Double = 0.36

    /// Figma `0px 1px 2px rgba(94,94,114,0.3)` — fixed; not tied to press.
    private let outerShadowY: CGFloat = 1
    private let outerShadowRadius: CGFloat = 1.25
    private let outerShadowOpacity: Double = 0.3

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .customFont(.semibold, size: 16, lineHeight: 19.2, tracking: -0.32)
                .foregroundColor(AppTheme.Neutral._0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(ctaBackground)
        .compositingGroup()
        .shadow(
            color: Color(red: 94 / 255, green: 94 / 255, blue: 114 / 255).opacity(outerShadowOpacity),
            radius: outerShadowRadius,
            x: 0,
            y: outerShadowY
        )
    }

    private var ctaBackground: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let hairline = 1 / max(UIScreen.main.scale, 2)
        return shape
            .fill(figmaGradient)
            .innerInsetRim(
                shape: shape,
                color: Color(red: 0.07, green: 0.11, blue: 0.36).opacity(0.2),
                lineWidth: navyRimLineWidth,
                blur: 0,
                offsetX: 0,
                offsetY: -navyRimY
            )
            .innerInsetRim(
                shape: shape,
                color: Color.black.opacity(0.2),
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
                    Color(red: 138 / 255, green: 138 / 255, blue: 159 / 255).opacity(0.23),
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
        .animation(.spring(response: 0.18, dampingFraction: 0.86), value: configuration.isPressed)
    }
}

private struct EmptyStateBackgroundPattern: View {
    var body: some View {
        GeometryReader { proxy in
            let size = proxy.size
            let dotSpacing: CGFloat = 22
            let dotRadius: CGFloat = 1.2

            Canvas { context, _ in
                let cols = Int(ceil(size.width / dotSpacing))
                let rows = Int(ceil(size.height / dotSpacing))

                for r in 0...rows {
                    for c in 0...cols {
                        let x = CGFloat(c) * dotSpacing + dotSpacing * 0.5
                        let y = CGFloat(r) * dotSpacing + dotSpacing * 0.5
                        let rect = CGRect(x: x - dotRadius, y: y - dotRadius, width: dotRadius * 2, height: dotRadius * 2)
                        context.fill(Path(ellipseIn: rect), with: .color(AppTheme.Neutral._500.opacity(0.10)))
                    }
                }
            }
            .mask(
                RadialGradient(
                    gradient: Gradient(stops: [
                        .init(color: Color.black.opacity(0.55), location: 0),
                        .init(color: Color.black.opacity(0.0), location: 1)
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
