import SwiftUI

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
                                .customFont(.semibold, size: 24, lineHeight: 28.8, tracking: -0.48)
                                .foregroundColor(AppTheme.Colors.textPrimary)

                            Text("Small habits. Big change.")
                                .customFont(.semibold, size: 24, lineHeight: 28.8, tracking: -0.48)
                                .foregroundColor(AppTheme.Colors.textSecondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)

                    Spacer(minLength: 18)

                    Button(action: onCreateHabit) {
                        EmptyStateCTA(title: "Continue")
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, 20)

                    Spacer(minLength: max(20, safeBottom + 8))
                }
            }
        }
    }
}

private struct EmptyStateCTA: View {
    let title: String
    private let cornerRadius: CGFloat = 56

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text(title)
                .customFont(.semibold, size: 16, lineHeight: 19.2, tracking: -0.32)
                .foregroundColor(AppTheme.Neutral._0)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            Gradient.Stop(color: Color(red: 0.43, green: 0.56, blue: 1), location: 0.00),
                            Gradient.Stop(color: Color(red: 0.3, green: 0.43, blue: 0.92), location: 0.55),
                            Gradient.Stop(color: Color(red: 0.34, green: 0.47, blue: 0.95), location: 1.00)
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1.56)
                    )
                )
                .innerShadow(
                    color: Color(hex: "060606").opacity(0.2),
                    radius: 0.58,
                    x: 0,
                    y: -3,
                    cornerRadius: cornerRadius
                )
                .innerShadow(
                    color: .black.opacity(0.2),
                    radius: 0.58,
                    x: 0,
                    y: -0.42,
                    cornerRadius: cornerRadius
                )
        )
    }
}

private struct InnerShadowModifier: ViewModifier {
    var color: Color
    var radius: CGFloat
    var x: CGFloat
    var y: CGFloat
    var cornerRadius: CGFloat

    func body(content: Content) -> some View {
        content.overlay(
            RoundedRectangle(cornerRadius: cornerRadius)
                .stroke(color, lineWidth: 1)
                .blur(radius: radius)
                .offset(x: x, y: y)
                .mask(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .fill(
                            LinearGradient(
                                colors: [.black, .clear],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                )
        )
    }
}

private extension View {
    func innerShadow(
        color: Color,
        radius: CGFloat,
        x: CGFloat,
        y: CGFloat,
        cornerRadius: CGFloat
    ) -> some View {
        modifier(
            InnerShadowModifier(
                color: color,
                radius: radius,
                x: x,
                y: y,
                cornerRadius: cornerRadius
            )
        )
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
