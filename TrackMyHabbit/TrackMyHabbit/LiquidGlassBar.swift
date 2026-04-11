import SwiftUI

struct LiquidGlassBar<Content: View>: View {
    let height: CGFloat
    let cornerRadius: CGFloat
    @ViewBuilder var content: () -> Content

    init(height: CGFloat = AppTheme.Layout.glassBarHeight, cornerRadius: CGFloat = AppTheme.Radius.glass, @ViewBuilder content: @escaping () -> Content) {
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
                            Color.white.opacity(AppTheme.Glass.fillTop),
                            Color.white.opacity(AppTheme.Glass.fillBottom)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .stroke(Color.white.opacity(AppTheme.Glass.stroke), lineWidth: AppTheme.Spacing.hairline)

            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(AppTheme.Glass.innerTop),
                            Color.white.opacity(AppTheme.Glass.innerBottom)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .padding(AppTheme.Spacing.insetFine)
                .mask(
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .padding(AppTheme.Spacing.insetFine)
                )
        }
        .frame(height: height)
        .background(.clear)
        .appShadow(AppTheme.Elevation.glassDark)
        .appShadow(AppTheme.Elevation.glassLight)
        .overlay {
            HStack { content() }
                .padding(.horizontal, AppTheme.Spacing.md)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.sm)
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
