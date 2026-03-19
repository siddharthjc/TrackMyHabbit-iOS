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
            HStack(alignment: .center, spacing: 8) {
                Text(habitName)
                    .customFont(.semibold, size: 20, lineHeight: 24, tracking: -0.4)
                    .foregroundColor(AppTheme.Colors.textPrimary)
                
                if habitCount >= 2 {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
        }
        .buttonStyle(.plain)
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity, minHeight: 44, alignment: .center)
        .padding(.vertical, 8)
        .opacity(habitCount >= 2 ? 1.0 : 0.6)
    }
}
