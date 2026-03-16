import SwiftUI
import SwiftData

struct DayCard: View {
    let dateStr: String
    let entry: HabitEntry?
    var isActive: Bool = true
    var cardWidth: CGFloat = 288
    var cardHeight: CGFloat = 397
    let tapAction: () -> Void

    var isEmpty: Bool { entry?.imageUri == nil }
    
    var body: some View {
        Button(action: tapAction) {
            ZStack {
                if !isEmpty {
                    // Photo State
                    GeometryReader { proxy in
                        if let uri = entry?.imageUri, let url = URL(string: uri) {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } placeholder: {
                                Color.gray.opacity(0.3)
                            }
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .clipped()
                        } else {
                            Color.gray.opacity(0.3)
                        }
                        
                        VStack {
                            Spacer()
                            LinearGradient(
                                colors: [.clear, Color.black.opacity(0.18)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            .frame(height: 80)
                            .overlay(
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(DateUtils.formatDate(dateStr))
                                        .customFont(isActive ? .semibold : .medium, size: isActive ? 16 : 14, tracking: isActive ? -0.08 : 0)
                                        .foregroundColor(AppTheme.Neutral._0)
                                        .shadow(color: .black.opacity(0.22), radius: 3, x: 0, y: 1)
                                    
                                    Text(DateUtils.getRelativeLabel(dateStr))
                                        .customFont(.medium, size: 12)
                                        .foregroundColor(AppTheme.Neutral._0)
                                        .shadow(color: .black.opacity(0.22), radius: 3, x: 0, y: 1)
                                }
                                .padding(.horizontal, AppTheme.Spacing.lg)
                                .padding(.bottom, AppTheme.Spacing.md),
                                alignment: .bottomLeading
                            )
                        }
                    }
                    .background(AppTheme.Neutral._0)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .stroke(AppTheme.Neutral._0, lineWidth: 1)
                    )
                    
                } else {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(
                            isActive
                            ? LinearGradient(
                                colors: [Color(hex: "#E2E8FF"), AppTheme.Neutral._0],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                            : LinearGradient(
                                colors: [AppTheme.Neutral._0, AppTheme.Neutral._0],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(AppTheme.Neutral._0, lineWidth: 1)
                        )
                        .overlay(alignment: .topLeading) {
                            HStack(spacing: isActive ? 8 : 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: 16, weight: .semibold))

                                Text("Add photo")
                                    .customFont(.semibold, size: 16, lineHeight: 22.4, tracking: -0.32)
                            }
                            .foregroundColor(isActive ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                            .padding(20)
                        }
                        .overlay(alignment: .bottomLeading) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(DateUtils.formatDate(dateStr))
                                    .customFont(isActive ? .semibold : .medium, size: isActive ? 16 : 14, lineHeight: isActive ? 22.4 : 19.6, tracking: isActive ? -0.08 : 0)
                                Text(DateUtils.getRelativeLabel(dateStr))
                                    .customFont(.medium, size: 12)
                            }
                            .foregroundColor(isActive ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                            .padding(20)
                        }
                }
            }
            .frame(width: cardWidth, height: cardHeight)
        }
        .buttonStyle(.plain)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.Neutral._0)
                .shadow(
                    color: Color(hex: "#5E5E72").opacity(isActive ? 0.2 : 0),
                    radius: isActive ? 56 : 0,
                    x: 0,
                    y: isActive ? 2 : 0
                )
        )
    }
}
