import SwiftUI

struct HabitSwitcher: View {
    let habitName: String
    let habitCount: Int
    let onSwitchPress: () -> Void
    
    var body: some View {
        Button(action: {
            guard habitCount >= 2 else { return }
            onSwitchPress()
        }) {
            HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
                Text(habitName)
                    .customFont(.semibold, size: AppTheme.Typography.Size.lg, lineHeight: AppTheme.Typography.Line.body24, tracking: AppTheme.Typography.Tracking.nav)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if habitCount >= 2 {
                    Image(systemName: "chevron.down")
                        .font(.system(size: AppTheme.Typography.Size.md, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, minHeight: AppTheme.Layout.minTouchTarget, alignment: .center)
        .padding(.vertical, AppTheme.Spacing.md)
        .opacity(habitCount >= 2 ? 1.0 : 0.6)
    }
}
