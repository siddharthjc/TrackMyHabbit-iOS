import SwiftUI

struct EmptyState: View {
    let onCreateHabit: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let safeBottom = geometry.safeAreaInsets.bottom
            let availableWidth = geometry.size.width
            let heroSize = min(availableWidth, 402)

            ZStack {
                AppTheme.Colors.emptyStateBackground
                    .ignoresSafeArea()

                EmptyStateBackgroundPattern()
                    .frame(width: heroSize, height: heroSize)
                    .offset(y: -geometry.size.height * 0.14)
                    .allowsHitTesting(false)

                VStack(spacing: 0) {
                    Spacer(minLength: geometry.size.height * 0.06)

                    EmptyStateHeroIllustration(size: min(geometry.size.width, geometry.size.height) * 0.55)
                        .frame(maxWidth: .infinity)

                    Spacer(minLength: geometry.size.height * 0.02)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("TrackMyHabbit.")
                            .customFont(.regular, size: 24, lineHeight: 28.8, tracking: -0.48)
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
        .toolbar(.hidden, for: .navigationBar)
        .navigationBarHidden(true)
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
        .padding(.vertical, 18)
        .frame(maxWidth: .infinity, alignment: .center)
        .background {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: AppTheme.Colors.emptyStateCTAStart, location: 0),
                            .init(color: AppTheme.Colors.emptyStateCTAMid, location: 0.55),
                            .init(color: AppTheme.Colors.emptyStateCTAEnd, location: 1)
                        ],
                        startPoint: UnitPoint(x: 0.5, y: 0),
                        endPoint: UnitPoint(x: 0.5, y: 1.56)
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .inset(by: 0.1)
                        .stroke(Color(hex: "#8A8A9F").opacity(0.23), lineWidth: 0.2)
                )
                .overlay(alignment: .bottom) {
                    Capsule()
                        .fill(Color.black.opacity(0.16))
                        .frame(height: 6)
                        .blur(radius: 0.9)
                        .padding(.horizontal, 6)
                        .offset(y: 1.4)
                }
                .overlay(alignment: .bottom) {
                    Capsule()
                        .fill(Color.black.opacity(0.1))
                        .frame(height: 3.2)
                        .blur(radius: 0.3)
                        .padding(.horizontal, 8)
                        .offset(y: 0.4)
                }
                .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        }
        .shadow(color: AppTheme.Neutral._700.opacity(0.3), radius: 1, x: 0, y: 1)
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

private struct EmptyStateHeroIllustration: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            EmptyStateHeroLine()
                .stroke(AppTheme.Neutral._500.opacity(0.20), style: StrokeStyle(lineWidth: 1, lineCap: .round, lineJoin: .round))
                .frame(width: size * 0.95, height: size * 0.35)
                .offset(y: size * 0.22)

            EmptyStateIconBubble(
                size: size * 0.26,
                fill: Color(hex: "#fecfc7"),
                overlay: Color(hex: "#ff9b8a"),
                symbol: "dumbbell.fill",
                symbolColor: Color(hex: "#ff7d6a")
            )
            .rotationEffect(.degrees(-10.95))
            .offset(x: -size * 0.28, y: -size * 0.18)

            EmptyStateIconBubble(
                size: size * 0.24,
                fill: Color(hex: "#a6cfbc"),
                overlay: Color(hex: "#a6cfbc"),
                symbol: "leaf.fill",
                symbolColor: Color(hex: "#0bbf6a")
            )
            .rotationEffect(.degrees(3.06))
            .offset(x: size * 0.28, y: -size * 0.20)

            EmptyStateIconBubble(
                size: size * 0.30,
                fill: Color(hex: "#749bcf"),
                overlay: Color(hex: "#b5d5ff"),
                symbol: "bicycle",
                symbolColor: Color(hex: "#2f6fd6")
            )
            .rotationEffect(.degrees(1.64))
            .offset(y: -size * 0.05)

            EmptyStateOpenBox(size: size * 0.78)
                .offset(y: size * 0.22)
        }
        .frame(width: size, height: size)
    }
}

private struct EmptyStateHeroLine: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        let start = CGPoint(x: rect.minX + rect.width * 0.08, y: rect.midY + rect.height * 0.15)
        let end = CGPoint(x: rect.maxX - rect.width * 0.08, y: rect.midY - rect.height * 0.05)
        let c1 = CGPoint(x: rect.minX + rect.width * 0.35, y: rect.minY + rect.height * 0.85)
        let c2 = CGPoint(x: rect.minX + rect.width * 0.65, y: rect.minY + rect.height * 0.05)
        p.move(to: start)
        p.addCurve(to: end, control1: c1, control2: c2)
        return p
    }
}

private struct EmptyStateIconBubble: View {
    let size: CGFloat
    let fill: Color
    let overlay: Color
    let symbol: String
    let symbolColor: Color

    var body: some View {
        ZStack {
            Circle()
                .fill(fill)
                .overlay(
                    Circle()
                        .inset(by: 0.1)
                        .stroke(Color(hex: "#8A8A9F").opacity(0.23), lineWidth: 0.2)
                )
                .overlay(
                    Circle()
                        .inset(by: size * 0.02)
                        .fill(overlay.opacity(0.25))
                        .blendMode(.overlay)
                )
                .shadow(color: AppTheme.Neutral._700.opacity(0.30), radius: 1.6, x: 0, y: 1.2)
                .overlay {
                    Circle()
                        .stroke(Color.black.opacity(0.12), lineWidth: 0.6)
                        .blur(radius: 0.2)
                        .opacity(0.6)
                        .blendMode(.overlay)
                }
                .overlay {
                    Circle()
                        .fill(Color.clear)
                        .shadow(color: Color.black.opacity(0.18), radius: 0, x: 0, y: size * 0.03)
                        .clipShape(Circle())
                        .allowsHitTesting(false)
                }

            Image(systemName: symbol)
                .font(.system(size: size * 0.34, weight: .semibold))
                .foregroundColor(symbolColor)
                .opacity(0.92)
        }
        .frame(width: size, height: size)
    }
}

private struct EmptyStateOpenBox: View {
    let size: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [Color(hex: "#f3f4f6"), Color(hex: "#e9eaee")],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(width: size * 0.92, height: size * 0.42)
                .shadow(color: AppTheme.Neutral._700.opacity(0.18), radius: 14, x: 0, y: 10)

            RoundedRectangle(cornerRadius: size * 0.04, style: .continuous)
                .fill(Color.white.opacity(0.65))
                .frame(width: size * 0.92, height: size * 0.42)
                .mask(
                    LinearGradient(colors: [Color.black.opacity(0.0), Color.black.opacity(1.0)], startPoint: .top, endPoint: .bottom)
                )
                .offset(y: size * 0.06)

            EmptyStateBoxFlap(side: .left)
                .frame(width: size * 0.42, height: size * 0.16)
                .offset(x: -size * 0.36, y: -size * 0.12)

            EmptyStateBoxFlap(side: .right)
                .frame(width: size * 0.42, height: size * 0.16)
                .offset(x: size * 0.36, y: -size * 0.12)

            RoundedRectangle(cornerRadius: size * 0.035, style: .continuous)
                .fill(Color(hex: "#f7f7fa"))
                .frame(width: size * 0.88, height: size * 0.13)
                .offset(y: -size * 0.14)
                .shadow(color: AppTheme.Neutral._700.opacity(0.10), radius: 10, x: 0, y: 6)
        }
        .frame(width: size, height: size * 0.55)
    }
}

private struct EmptyStateBoxFlap: View {
    enum Side { case left, right }
    let side: Side

    var body: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [Color(hex: "#ffffff"), Color(hex: "#eceef2")],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .rotationEffect(.degrees(side == .left ? -18 : 18))
            .shadow(color: AppTheme.Neutral._700.opacity(0.16), radius: 10, x: 0, y: 8)
    }
}

#Preview {
    EmptyState {}
}
