import SwiftUI

struct LiquidGlassBar<Content: View>: View {
    let height: CGFloat
    let cornerRadius: CGFloat
    @ViewBuilder var content: () -> Content

    init(height: CGFloat = 56, cornerRadius: CGFloat = 28, @ViewBuilder content: @escaping () -> Content) {
        self.height = height
        self.cornerRadius = cornerRadius
        self.content = content
    }

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(.ultraThinMaterial)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.42),
                            Color.white.opacity(0.16)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(0.78), lineWidth: 1)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.48),
                            Color.white.opacity(0.02)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(1.5)
                .mask(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .padding(1.5)
                )
        }
        .frame(height: height)
        .background(.clear)
        .shadow(color: Color.black.opacity(0.12), radius: 20, x: 0, y: 10)
        .shadow(color: Color.white.opacity(0.35), radius: 8, x: 0, y: -1)
        .overlay {
            HStack { content() }
                .padding(.horizontal, 16)
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

#Preview {
    ZStack(alignment: .top) {
        LinearGradient(colors: [.blue.opacity(0.2), .purple.opacity(0.2)], startPoint: .top, endPoint: .bottom)
            .ignoresSafeArea()
        LiquidGlassBar {
            Text("Title")
                .font(.headline)
            Spacer()
            Image(systemName: "gearshape.fill")
        }
    }
}
