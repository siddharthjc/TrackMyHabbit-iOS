import SwiftUI

struct EmptyState: View {
    let onCreateHabit: () -> Void

    var body: some View {
        GeometryReader { geometry in
            let safeTop = geometry.safeAreaInsets.top
            let safeBottom = geometry.safeAreaInsets.bottom
            let illustrationWidth = min(geometry.size.width - 40, 355)

            VStack(spacing: 0) {
                Spacer(minLength: max(56, safeTop + 24))

                EmptyStateIllustration(illustrationWidth: illustrationWidth)

                Spacer(minLength: max(44, geometry.size.height * 0.08))

                VStack(spacing: 24) {
                    Text("Create my first habit")
                        .customFont(.semibold, size: 24, lineHeight: 28.8, tracking: -0.48)
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .multilineTextAlignment(.center)

                    Button(action: onCreateHabit) {
                        EmptyStateCTA()
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 20)

                Spacer(minLength: max(20, safeBottom + 8))
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

private struct EmptyStateCTA: View {
    private let cornerRadius: CGFloat = 56

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            Text("Create habit")
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

private struct EmptyStateIllustration: View {
    let illustrationWidth: CGFloat

    private var noteWidth: CGFloat { illustrationWidth * 0.82 }
    private var noteHeight: CGFloat { noteWidth * 1.525 }
    private let cornerRadius: CGFloat = 24
    private let visualCenterOffset: CGFloat = 10

    var body: some View {
        ZStack {
            noteCard
                .rotationEffect(.degrees(-7.2))
                .offset(x: -26, y: 9)

            noteCard
                .rotationEffect(.degrees(-3.8))
                .offset(x: -12, y: 4)

            noteCard
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "paperclip")
                        .font(.system(size: 58, weight: .light))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                        .rotationEffect(.degrees(11))
                        .offset(x: 16, y: -12)
                }
        }
        .offset(x: visualCenterOffset)
        .frame(width: illustrationWidth, height: noteHeight + 18)
    }

    private var noteCard: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [AppTheme.Colors.emptyStateCardTint, AppTheme.Neutral._0],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: noteWidth, height: noteHeight)
            .overlay(
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .stroke(Color.white.opacity(0.95), lineWidth: 1)
            )
            .shadow(color: AppTheme.Neutral._700.opacity(0.2), radius: 24, x: 0, y: 4)
    }
}

#Preview {
    EmptyState {}
        .background(AppTheme.Colors.emptyStateBackground)
}
