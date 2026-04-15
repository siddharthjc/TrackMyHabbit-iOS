import SwiftUI

/// Streak card + binary contribution heat-map (Figma 510:1864).
///
/// Displays the active habit's current streak as a hero (fire + digit + label)
/// followed by a 7×12 grid of the last 84 days. Each cell is binary: green if a
/// `HabitEntry` exists for that date, gray otherwise. Tapping a cell forwards
/// the date to `onSelectDate`.
struct HabitContributionGraphCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let habit: Habit
    let calendar: Calendar
    let today: Date
    let cardWidth: CGFloat
    var onSelectDate: ((Date) -> Void)? = nil

    private var columns: Int { AppTheme.Layout.heatmapColumns }
    private var rows: Int { AppTheme.Layout.heatmapRows }
    private var cellSize: CGFloat { AppTheme.Layout.heatmapCell }

    private var contentWidth: CGFloat { cardWidth - AppTheme.Spacing.lg * 2 }

    /// Horizontal gap fills the row width (Figma `justify-between`).
    private var cellHorizontalGap: CGFloat {
        let cols = CGFloat(columns)
        let raw = (contentWidth - cols * cellSize) / max(cols - 1, 1)
        return max(AppTheme.Layout.heatmapMinGap, raw)
    }

    private var entrySet: Set<String> {
        Set(habit.entries.map(\.dateString))
    }

    private var todayStart: Date {
        calendar.startOfDay(for: today)
    }

    /// Date for grid position. Cells flow chronologically: top-left is the oldest
    /// day in the rolling window, bottom-right is `today`.
    private func date(row: Int, column: Int) -> Date {
        let totalCells = rows * columns
        let index = row * columns + column
        let daysBack = (totalCells - 1) - index
        return calendar.date(byAdding: .day, value: -daysBack, to: todayStart) ?? todayStart
    }

    /// Streak length ending on `date` (inclusive). 0 if `date` is not completed.
    private func streak(endingAt date: Date, set: Set<String>) -> Int {
        var count = 0
        var cursor = calendar.startOfDay(for: date)
        for _ in 0..<366 {
            let key = DateUtils.toDateString(date: cursor)
            if !set.contains(key) { break }
            count += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = prev
        }
        return count
    }

    private var inactiveColor: Color {
        colorScheme == .dark ? AppTheme.Colors.Heatmap.darkTier0 : AppTheme.Colors.Heatmap.lightTier0
    }

    private var activeColor: Color {
        colorScheme == .dark ? AppTheme.Colors.Heatmap.darkTier4 : AppTheme.Colors.Heatmap.lightTier4
    }

    var body: some View {
        let set = entrySet
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            streakHero(set: set)
            grid(set: set)
            divider
            legend
        }
        .padding(.top, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.md)
        .frame(width: cardWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .fill(AppTheme.Colors.dayCardFill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .inset(by: 0.5)
                .stroke(AppTheme.Colors.calendarShellBorder, lineWidth: AppTheme.Spacing.hairline)
        )
        .appShadow(AppTheme.Elevation.contributionGraphCard)
    }

    private func streakHero(set: Set<String>) -> some View {
        let streakCount = streak(endingAt: todayStart, set: set)
        let label = streakCount < 2 ? "day streak" : "days streak"
        return VStack(alignment: .center, spacing: 0) {
            HStack(spacing: AppTheme.Spacing.xs) {
                Image("StreakFire")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(
                        width: AppTheme.Layout.streakFireIconSize,
                        height: AppTheme.Layout.streakFireIconSize
                    )
                Text("\(streakCount)")
                    .customFont(
                        .serifsemibold,
                        size: AppTheme.Typography.Size.streakHero,
                        tracking: AppTheme.Typography.Tracking.tight
                    )
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .contentTransition(.numericText())
            }
            Text(label)
                .customFont(
                    .semibold,
                    size: AppTheme.Typography.Size.lg,
                    tracking: AppTheme.Typography.Tracking.tight
                )
                .foregroundColor(AppTheme.Colors.textPrimary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text("\(streakCount) \(label)"))
    }

    private func grid(set: Set<String>) -> some View {
        VStack(spacing: AppTheme.Spacing.xs) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: cellHorizontalGap) {
                    ForEach(0..<columns, id: \.self) { column in
                        cellView(row: row, column: column, set: set)
                    }
                }
            }
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    private func cellView(row: Int, column: Int, set: Set<String>) -> some View {
        let cellDate = date(row: row, column: column)
        let key = DateUtils.toDateString(date: cellDate)
        let isActive = set.contains(key)
        return Button {
            onSelectDate?(cellDate)
        } label: {
            RoundedRectangle(cornerRadius: AppTheme.Layout.heatmapCellRadius, style: .continuous)
                .fill(isActive ? activeColor : inactiveColor)
                .frame(width: cellSize, height: cellSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(DateUtils.formatDateWithOrdinal(key)))
        .accessibilityValue(Text(isActive ? "Completed" : "Missed"))
    }

    private var divider: some View {
        Rectangle()
            .fill(AppTheme.Colors.borderSubtle)
            .frame(height: AppTheme.Spacing.hairline)
    }

    private var legend: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Spacer(minLength: 0)
            Text("No Activity")
                .customFont(
                    .medium,
                    size: AppTheme.Typography.Size.xs,
                    lineHeight: AppTheme.Typography.Line.body196,
                    tracking: AppTheme.Typography.Tracking.calendarHabitChip
                )
                .foregroundColor(AppTheme.Colors.textSecondary)
            RoundedRectangle(cornerRadius: AppTheme.Layout.heatmapCellRadius, style: .continuous)
                .fill(inactiveColor)
                .frame(width: cellSize, height: cellSize)
            RoundedRectangle(cornerRadius: AppTheme.Layout.heatmapCellRadius, style: .continuous)
                .fill(activeColor)
                .frame(width: cellSize, height: cellSize)
            Text("Active")
                .customFont(
                    .medium,
                    size: AppTheme.Typography.Size.xs,
                    lineHeight: AppTheme.Typography.Line.body196,
                    tracking: AppTheme.Typography.Tracking.calendarHabitChip
                )
                .foregroundColor(AppTheme.Colors.textSecondary)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }
}
