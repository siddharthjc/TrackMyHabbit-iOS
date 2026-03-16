import SwiftUI

struct HabitSwitcher: View {
    let habitName: String
    let habitCount: Int
    let onSwitchPress: () -> Void
    
    var body: some View {
        Button(action: onSwitchPress) {
            HStack(alignment: .center, spacing: 8) {
                Text(habitName)
                    .customFont(.bold, size: 20, tracking: -0.4)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if habitCount >= 2 {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
        }
        .disabled(habitCount < 2)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, AppTheme.Spacing.md)
    }
}
