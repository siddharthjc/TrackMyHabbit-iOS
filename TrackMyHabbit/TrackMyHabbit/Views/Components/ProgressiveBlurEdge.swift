import SwiftUI

/// A `.ultraThinMaterial` strip masked by a linear gradient so the blur fades
/// from solid (at the screen edge) to clear (toward the content). Used on the
/// home wallet stack to feather the top and bottom edges of the scroll view.
///
/// In dark mode `.ultraThinMaterial` reads as a lighter gray seam against the
/// near-black page background, so we fall back to a solid page-bg fill and
/// rely on the gradient mask alone (same trick as `CalendarProgressiveBlurHeader`).
struct ProgressiveBlurEdge: View {
    enum Edge {
        case top
        case bottom
    }

    @Environment(\.colorScheme) private var colorScheme
    let edge: Edge
    let height: CGFloat

    var body: some View {
        fill
            .frame(height: height)
            .mask(
                LinearGradient(
                    stops: maskStops,
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
            .allowsHitTesting(false)
    }

    // Use the page background colour rather than `.ultraThinMaterial` — the
    // material's noise texture interacts with the gradient mask to produce
    // visible moiré rings against light content (see Figma 604:1934).
    private var fill: some View {
        Rectangle().fill(AppTheme.Colors.emptyStateBackground)
    }

    private var maskStops: [Gradient.Stop] {
        switch edge {
        case .top:
            return [
                .init(color: .black, location: 0),
                .init(color: .clear, location: 1)
            ]
        case .bottom:
            return [
                .init(color: .clear, location: 0),
                .init(color: .black, location: 1)
            ]
        }
    }
}
