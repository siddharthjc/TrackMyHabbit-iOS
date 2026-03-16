import SwiftUI

struct HabitSwitcher: View {
    let habitName: String
    let habitCount: Int
    let onSwitchPress: () -> Void
    
    var body: some View {
        Button(action: onSwitchPress) {
            HStack(alignment: .center, spacing: 8) {
                Text(habitName)
                    .customFont(.semibold, size: 20, lineHeight: 24, tracking: -0.4)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if habitCount >= 1 {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
        }
        .disabled(habitCount < 2)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.vertical, 8)
    }
}
