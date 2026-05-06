import SwiftUI

/// Iridescent radial burst used for the liquid-glass intro → main transition.
/// Pure SwiftUI: an angular gradient (rotating slowly via `TimelineView`) layered
/// over a radial falloff, sized by `progress * maxRadius` and centred on `center`.
struct AppleIntelligenceBurstView: View {
    let center: CGPoint
    let progress: Double
    let maxRadius: CGFloat

    var body: some View {
        TimelineView(.animation) { timeline in
            let t = timeline.date.timeIntervalSinceReferenceDate
            let radius = max(maxRadius * CGFloat(progress), 1)

            ZStack {
                AngularGradient(
                    stops: AppTheme.Colors.appleIntelligenceBurstStops,
                    center: .center,
                    angle: .radians(t * 0.9)
                )
                .blendMode(.plusLighter)

                RadialGradient(
                    colors: [Color.white.opacity(0.85), Color.clear],
                    center: .center,
                    startRadius: 0,
                    endRadius: radius
                )
                .blendMode(.screen)
            }
            .frame(width: radius * 2, height: radius * 2)
            .clipShape(Circle())
            .position(center)
            .opacity(envelope(progress))
            .compositingGroup()
            .blur(radius: 8 + 24 * (1 - progress))
            .allowsHitTesting(false)
        }
    }

    private func envelope(_ p: Double) -> Double {
        if p < 0.25 { return p / 0.25 }
        if p > 0.7 { return max(1 - (p - 0.7) / 0.3, 0) }
        return 1
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        GeometryReader { proxy in
            AppleIntelligenceBurstView(
                center: CGPoint(x: proxy.size.width / 2, y: proxy.size.height / 2),
                progress: 0.6,
                maxRadius: hypot(proxy.size.width, proxy.size.height)
            )
        }
    }
}
