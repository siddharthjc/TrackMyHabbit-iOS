import SwiftUI

/// Contribution heat-map for the active habit (Figma 483:2159).
///
/// Renders a `heatmapRows × heatmapColumns` grid of completion cells ending on
/// `today`, ordered chronologically left→right, top→bottom. Each cell's tier
/// is derived from the streak length ending on that day — binary `HabitEntry`
/// data → 4-tier ramp by rewarding consistency.
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

    private func tier(forStreak streak: Int) -> Int {
        switch streak {
        case 0: return 0
        case 1...2: return 1
        case 3...6: return 2
        default: return 3
        }
    }

    private func tierColor(_ tier: Int) -> Color {
        let isDark = colorScheme == .dark
        switch tier {
        case 1: return isDark ? AppTheme.Colors.Heatmap.darkTier1 : AppTheme.Colors.Heatmap.lightTier1
        case 2: return isDark ? AppTheme.Colors.Heatmap.darkTier2 : AppTheme.Colors.Heatmap.lightTier2
        case 3: return isDark ? AppTheme.Colors.Heatmap.darkTier3 : AppTheme.Colors.Heatmap.lightTier3
        default: return isDark ? AppTheme.Colors.Heatmap.darkTier0 : AppTheme.Colors.Heatmap.lightTier0
        }
    }

    var body: some View {
        let set = entrySet
        VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
            title
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

    private var title: some View {
        Text("Latest trends")
            .customFont(
                .semibold,
                size: AppTheme.Typography.Size.md,
                lineHeight: AppTheme.Typography.Line.body192,
                tracking: AppTheme.Typography.Tracking.tight
            )
            .foregroundColor(AppTheme.Colors.textPrimary)
            .padding(.horizontal, AppTheme.Spacing.lg)
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
        let t = tier(forStreak: streak(endingAt: cellDate, set: set))
        return Button {
            onSelectDate?(cellDate)
        } label: {
            RoundedRectangle(cornerRadius: AppTheme.Layout.heatmapCellRadius, style: .continuous)
                .fill(tierColor(t))
                .frame(width: cellSize, height: cellSize)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(Text(DateUtils.formatDateWithOrdinal(key)))
        .accessibilityValue(Text(set.contains(key) ? "Completed" : "Missed"))
    }

    private var divider: some View {
        Rectangle()
            .fill(AppTheme.Colors.borderSubtle)
            .frame(height: AppTheme.Spacing.hairline)
    }

    private var legend: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Spacer(minLength: 0)
            Text("Less")
                .customFont(
                    .medium,
                    size: AppTheme.Typography.Size.xs,
                    lineHeight: AppTheme.Typography.Line.body196,
                    tracking: AppTheme.Typography.Tracking.calendarHabitChip
                )
                .foregroundColor(AppTheme.Colors.textSecondary)
            ForEach(0..<4, id: \.self) { tier in
                RoundedRectangle(cornerRadius: AppTheme.Layout.heatmapCellRadius, style: .continuous)
                    .fill(tierColor(tier))
                    .frame(width: cellSize, height: cellSize)
            }
            Text("More")
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
