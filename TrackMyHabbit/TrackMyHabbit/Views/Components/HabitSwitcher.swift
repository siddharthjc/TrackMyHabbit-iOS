import SwiftUI

struct HabitSwitcher: View {
    let habits: [Habit]
    let activeHabitId: UUID?
    let onSelect: (UUID) -> Void

    private var activeHabitName: String {
        habits.first(where: { $0.id == activeHabitId })?.name
            ?? habits.first?.name
            ?? ""
    }

    var body: some View {
        Group {
            if habits.count >= 2 {
                Menu {
                    ForEach(habits) { habit in
                        Button {
                            onSelect(habit.id)
                        } label: {
                            if habit.id == activeHabitId {
                                Label(habit.name, systemImage: "checkmark")
                            } else {
                                Text(habit.name)
                            }
                        }
                    }
                } label: {
                    switcherLabel
                }
            } else {
                switcherLabel
            }
        }
        .padding(.vertical, AppTheme.Spacing.md)
    }

    private var switcherLabel: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            Text(activeHabitName)
                .customFont(.semibold, size: AppTheme.Typography.Size.lg, lineHeight: AppTheme.Typography.Line.body24, tracking: AppTheme.Typography.Tracking.nav)
                .foregroundColor(AppTheme.Colors.textPrimary)

            if habits.count >= 2 {
                Image(systemName: "chevron.down")
                    .font(.system(size: AppTheme.Typography.Size.sm, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textSecondary)
            }
        }
    }
}
