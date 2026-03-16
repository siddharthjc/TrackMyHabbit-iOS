import SwiftUI
import SwiftData

struct DayCard: View {
    let dateStr: String
    let entry: HabitEntry?
    var isActive: Bool = true
    let tapAction: () -> Void
    
    var cardWidth: CGFloat = UIScreen.main.bounds.width * 0.72
    var cardHeight: CGFloat { cardWidth * 1.38 }
    
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
                        
                        // Footer Gradient Overlay
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
                                        .customFont(isActive ? .bold : .medium, size: isActive ? 16 : 14, tracking: isActive ? -0.08 : 0)
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
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(AppTheme.Neutral._0, lineWidth: 1))
                    
                } else {
                    // Empty State
                    ZStack {
                        if isActive {
                            LinearGradient(
                                colors: [Color(hex: "#E2E8FF"), AppTheme.Neutral._0],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        } else {
                            AppTheme.Neutral._0
                        }
                    }
                    .overlay(
                        VStack(alignment: .leading) {
                            HStack(spacing: isActive ? 8 : 6) {
                                Image(systemName: "plus")
                                    .font(.system(size: isActive ? 20 : 16, weight: .semibold))
                                Text("Add photo")
                                    .customFont(isActive ? .bold : .medium, size: isActive ? 20 : 14, tracking: isActive ? -0.4 : 0)
                            }
                            .foregroundColor(isActive ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(DateUtils.formatDate(dateStr))
                                    .customFont(isActive ? .bold : .medium, size: isActive ? 16 : 14, tracking: isActive ? -0.08 : 0)
                                Text(DateUtils.getRelativeLabel(dateStr))
                                    .customFont(.medium, size: 12)
                            }
                            .foregroundColor(isActive ? AppTheme.Colors.textPrimary : AppTheme.Colors.textSecondary)
                        }
                        .padding(20),
                        alignment: .topLeading
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 24))
                    .overlay(RoundedRectangle(cornerRadius: 24).stroke(isActive ? AppTheme.Neutral._0 : Color.clear, lineWidth: 1))
                }
            }
            .frame(width: cardWidth, height: cardHeight)
        }
        .buttonStyle(PlainButtonStyle())
        // Shadow wrapper
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

