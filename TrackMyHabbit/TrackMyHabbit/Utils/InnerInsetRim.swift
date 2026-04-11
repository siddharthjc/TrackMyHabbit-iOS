import SwiftUI

/// Inset stroke used by `EmptyState` CTA and calendar add-photo orb for Figma-matched rim lighting.
struct InnerInsetRimModifier<S: Shape>: ViewModifier {
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

extension View {
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
