import SwiftUI
import SwiftData

struct HabitPickerModal: View {
    @Query private var habits: [Habit]
    let activeHabitId: UUID?
    let onSelect: (UUID) -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            Text("Your Habits")
                .customFont(.semibold, size: AppTheme.Typography.Size.lg)
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, AppTheme.Spacing.xl)
                .padding(.top, AppTheme.Spacing.xl)
                .padding(.bottom, AppTheme.Spacing.md)
            
            List {
                ForEach(habits) { habit in
                    Button {
                        onSelect(habit.id)
                        dismiss()
                    } label: {
                        HStack {
                            Text(habit.name)
                                .customFont(habit.id == activeHabitId ? .semibold : .medium, size: AppTheme.Typography.Size.md)
                                .foregroundColor(habit.id == activeHabitId ? AppTheme.Colors.primary : AppTheme.Colors.textPrimary)
                            
                            Spacer()
                            
                            if habit.id == activeHabitId {
                                Image(systemName: "checkmark")
                                    .font(.system(size: AppTheme.Typography.Size.md, weight: .bold))
                                    .foregroundColor(AppTheme.Colors.primary)
                            }
                        }
                        .padding(.vertical, AppTheme.Spacing.sm3)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .background(habit.id == activeHabitId ? AppTheme.Colors.primaryLight : Color.clear)
                        .cornerRadius(AppTheme.Radius.sm)
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: AppTheme.Spacing.xl, bottom: 0, trailing: AppTheme.Spacing.xl))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.visible)
                    .listRowSeparatorTint(AppTheme.Neutral._300)
                }
            }
            .listStyle(.plain)
        }
        .background(AppTheme.Colors.bgPrimary)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }
}
