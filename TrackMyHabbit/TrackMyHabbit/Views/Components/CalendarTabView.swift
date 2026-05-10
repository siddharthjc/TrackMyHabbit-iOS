import PhotosUI
import SwiftData
import SwiftUI
import UIKit

struct CalendarTabView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme

    let habits: [Habit]
    /// Currently selected habit; mirrors home tab so switching in one place updates the other.
    let activeHabitId: UUID?
    /// Overrides calendar “today” (e.g. 11 Apr 2026 in previews).
    var todayOverride: Date? = nil
    /// Called when the user taps “Add habit” in the empty state.
    var onCreateHabit: (() -> Void)? = nil
    /// Called when the user taps the 3-dot menu on the tap-open card screen —
    /// opens the edit-habit sheet in the parent for the active habit.
    var onEditHabit: (() -> Void)? = nil

    @State private var selectedDate: Date
    @State private var showDateSheet = false
    /// Non-nil when a day cell has been tapped — drives the full-screen cover.
    @State private var tappedDate: Date?
    /// Set when the 3-dot menu is tapped so the edit sheet fires after the
    /// full-screen cover finishes dismissing (prevents modal-on-modal conflicts).
    @State private var pendingEditAfterDismiss = false
    @Namespace private var overlayCardNamespace

    init(
        habits: [Habit],
        activeHabitId: UUID? = nil,
        todayOverride: Date? = nil,
        initialSelectedDate: Date? = nil,
        onCreateHabit: (() -> Void)? = nil,
        onEditHabit: (() -> Void)? = nil
    ) {
        self.habits = habits
        self.activeHabitId = activeHabitId
        self.todayOverride = todayOverride
        self.onCreateHabit = onCreateHabit
        self.onEditHabit = onEditHabit
        let seed = initialSelectedDate ?? todayOverride ?? Date()
        _selectedDate = State(initialValue: seed)
    }

    private var resolvedHabit: Habit? {
        habits.first(where: { $0.id == activeHabitId }) ?? habits.first
    }

    private var calendar: Calendar {
        var c = Calendar(identifier: .gregorian)
        c.timeZone = .current
        c.locale = .current
        return c
    }

    private var effectiveToday: Date {
        calendar.startOfDay(for: todayOverride ?? Date())
    }

    private var selectedDayStart: Date {
        calendar.startOfDay(for: selectedDate)
    }

    private var selectedDateKey: String {
        DateUtils.toDateString(date: selectedDayStart)
    }

    /// Day shown in the title row — mirrors `selectedDate` (user picks via date sheet or tapping a grid cell).
    private var calendarDisplayDayStart: Date { selectedDayStart }

    private var displayedDateKey: String { selectedDateKey }

    /// Figma 465:2017 (dark): Geist semibold; light: existing Season Mix display.
    private var calendarDateTitleFont: CustomFont {
        colorScheme == .dark ? .semibold : .serifsemibold
    }

    /// Every calendar day in the month that contains the selection (Figma 389:5141 — full month, horizontally scrollable).
    private var daysInSelectedMonth: [Date] {
        guard let interval = calendar.dateInterval(of: .month, for: selectedDayStart) else { return [] }
        var result: [Date] = []
        var day = calendar.startOfDay(for: interval.start)
        let end = interval.end
        while day < end {
            result.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = calendar.startOfDay(for: next)
        }
        return result
    }

    var body: some View {
        GeometryReader { geo in
            // TabView lazily loads tab content; the first layout pass can propose width 0, collapsing cards until a relayout.
            let effectiveWidth: CGFloat = {
                if geo.size.width > 0 {
                    return geo.size.width
                }
                if let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first,
                   let screen = windowScene.screen as UIScreen? {
                    return screen.bounds.width
                }
                return geo.size.width
            }()
            let horizontalInset = AppTheme.Spacing.lg
            let availableContentWidth = max(effectiveWidth - horizontalInset * 2, 0)
            let cardWidth = min(AppTheme.Layout.calendarCardWidth, availableContentWidth)

            ZStack(alignment: .top) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 0) {
                        Color.clear.frame(height: AppTheme.Layout.calendarTitleContentHeight)

                        if habits.isEmpty {
                            emptyHabitsPlaceholder
                                .padding(.top, AppTheme.Spacing.calendarGridHeaderToGrid)
                        } else if let habit = resolvedHabit {
                            CalendarMonthGrid(
                                habit: habit,
                                monthAnchor: selectedDayStart,
                                effectiveToday: effectiveToday,
                                calendar: calendar,
                                gridWidth: availableContentWidth,
                                namespace: overlayCardNamespace,
                                tappedDateKey: tappedDate.map { DateUtils.toDateString(date: calendar.startOfDay(for: $0)) },
                                onTapDay: { date in
                                    let dayStart = calendar.startOfDay(for: date)
                                    guard dayStart <= effectiveToday else { return }
                                    selectedDate = dayStart
                                    withAnimation(AppTheme.Motion.springSheetOverlay) {
                                        tappedDate = dayStart
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                            )
                            .padding(.horizontal, horizontalInset)
                            .padding(.top, AppTheme.Spacing.calendarGridHeaderToGrid)

                            HabitContributionGraphCard(
                                habit: habit,
                                calendar: calendar,
                                today: effectiveToday,
                                cardWidth: cardWidth,
                                onSelectDate: { date in
                                    withAnimation(AppTheme.Motion.easeTab) {
                                        selectedDate = calendar.startOfDay(for: date)
                                    }
                                }
                            )
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.top, AppTheme.Spacing.calendarGridToGraphGap)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, AppTheme.Spacing.md)
                    .padding(.bottom, AppTheme.Spacing.xxl)
                }
                .scrollClipDisabled()
                .overlay {
                    if let tapped = tappedDate, let habit = resolvedHabit {
                        CalendarCardOverlay(
                            habit: habit,
                            selectedDate: tapped,
                            cardWidth: cardWidth,
                            calendar: calendar,
                            effectiveToday: effectiveToday,
                            onImagePicked: { data in
                                saveEntryImage(data, habit: habit, date: tapped)
                            },
                            onDismiss: dismissOverlay,
                            onMenu: onEditHabit.map { _ in
                                {
                                    requestEditAfterOverlayDismiss()
                                }
                            }
                        )
                        .transition(.opacity)
                    }
                }

                CalendarProgressiveBlurHeader(
                    safeAreaTopInset: geo.safeAreaInsets.top,
                    titlePadding: AppTheme.Spacing.md,
                    titleContentHeight: AppTheme.Layout.calendarTitleContentHeight,
                    fadeExtension: AppTheme.Layout.calendarTitleBlurFadeHeight
                )
                .ignoresSafeArea(edges: .top)
                .allowsHitTesting(false)

                dateTitleRow
                    .padding(.top, AppTheme.Spacing.md)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppTheme.Colors.emptyStateBackground.ignoresSafeArea())
        .sheet(isPresented: $showDateSheet) {
            NavigationStack {
                VStack(spacing: 0) {
                    DatePicker(
                        "",
                        selection: Binding(
                            get: { calendarDisplayDayStart },
                            set: { newValue in
                                withAnimation(AppTheme.Motion.easeTab) {
                                    selectedDate = calendar.startOfDay(for: newValue)
                                }
                            }
                        ),
                        displayedComponents: [.date]
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal, AppTheme.Spacing.lg)
                }
                .frame(maxWidth: .infinity)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Choose date")
                            .customFont(.serifsemibold, size: AppTheme.Typography.Size.lg, lineHeight: AppTheme.Typography.Line.body24, tracking: AppTheme.Typography.Tracking.tight)
                            .foregroundColor(AppTheme.Colors.calendarDateHeaderText)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showDateSheet = false
                        }
                        .tint(AppTheme.Colors.tabBarAccent)
                    }
                }
            }
            .presentationBackground(AppTheme.Colors.bgSecondary)
            .presentationDetents([.height(AppTheme.Layout.calendarDateSheetDetentHeight)])
            .presentationDragIndicator(.visible)
        }
        .onChange(of: tappedDate) { _, newValue in
            guard newValue == nil, pendingEditAfterDismiss else { return }
            pendingEditAfterDismiss = false
            DispatchQueue.main.asyncAfter(deadline: .now() + AppTheme.Motion.durationNormal) {
                onEditHabit?()
            }
        }
    }

    private var dateTitleRow: some View {
        Button {
            showDateSheet = true
        } label: {
            HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.sm) {
                HStack(alignment: .firstTextBaseline, spacing: 0) {
                    Text(String(calendar.component(.day, from: calendarDisplayDayStart)))
                        .customFont(
                            calendarDateTitleFont,
                            size: AppTheme.Typography.Size.xl,
                            lineHeight: AppTheme.Typography.Line.title288,
                            tracking: AppTheme.Typography.Tracking.titleXL
                        )
                        .foregroundColor(AppTheme.Colors.calendarDateHeaderText)
                        .contentTransition(.numericText())
                    Text(" \(DateUtils.monthName(for: calendarDisplayDayStart))")
                        .customFont(
                            calendarDateTitleFont,
                            size: AppTheme.Typography.Size.xl,
                            lineHeight: AppTheme.Typography.Line.title288,
                            tracking: AppTheme.Typography.Tracking.titleXL
                        )
                        .foregroundColor(AppTheme.Colors.calendarDateHeaderText)
                }
                Image(systemName: "chevron.down")
                    .font(.system(size: AppTheme.Typography.Size.md, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.calendarDateHeaderText)
            }
        }
        .buttonStyle(.plain)
        .animation(AppTheme.Motion.easeTab, value: calendarDisplayDayStart)
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    private func dismissOverlay() {
        withAnimation(AppTheme.Motion.springSheetOverlay) {
            tappedDate = nil
        }
    }

    private func requestEditAfterOverlayDismiss() {
        pendingEditAfterDismiss = true
        dismissOverlay()
    }

    private var emptyHabitsPlaceholder: some View {
        VStack(spacing: AppTheme.Spacing.relaxed) {
            CalendarEmptyStateCollage()

            VStack(spacing: AppTheme.Spacing.xs) {
                Text("No habits yet")
                    .customFont(
                        .semibold,
                        size: AppTheme.Typography.Size.lg,
                        lineHeight: AppTheme.Typography.Line.body24,
                        tracking: AppTheme.Typography.Tracking.nav
                    )
                    .foregroundColor(AppTheme.Colors.textPrimary)
                Text("Create a habit from the Home tab to see it here")
                    .customFont(
                        .medium,
                        size: AppTheme.Typography.Size.sm,
                        lineHeight: AppTheme.Typography.Line.body196,
                        tracking: AppTheme.Typography.Tracking.suggestion
                    )
                    .foregroundColor(AppTheme.Colors.textDisabled)
            }
            .multilineTextAlignment(.center)

            if let onCreateHabit {
                Button(action: onCreateHabit) {
                    Text("Add habit")
                }
                .buttonStyle(CalendarEmptyCTAButtonStyle())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, AppTheme.Spacing.touch)
    }

    private func saveEntryImage(_ data: Data, habit: Habit, date: Date) {
        let dateString = DateUtils.toDateString(date: date)
        let existing = resolveEntry(habit: habit, dateString: dateString)
        let replacedPhotoURL = existing?.imageUri.flatMap(URL.init(string:))

        do {
            let fileURL = try HabitPhotoFileStore.persistJPEG(data: data, habitID: habit.id, dateString: dateString)
            do {
                if let existing {
                    existing.imageUri = fileURL.absoluteString
                } else {
                    let newEntry = HabitEntry(
                        dateString: dateString,
                        imageUri: fileURL.absoluteString,
                        habit: habit
                    )
                    modelContext.insert(newEntry)
                }
                try modelContext.save()
                HabitPhotoFileStore.removePhoto(at: replacedPhotoURL, replacingWith: fileURL)
            } catch {
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Failed to save calendar photo: \(error.localizedDescription)")
        }
    }

    private func resolveEntry(habit: Habit, dateString: String) -> HabitEntry? {
        do {
            let habitId = habit.id
            let predicate = #Predicate<HabitEntry> { entry in
                entry.dateString == dateString && entry.habit?.id == habitId
            }
            var descriptor = FetchDescriptor<HabitEntry>(predicate: predicate)
            descriptor.fetchLimit = 2
            let results = try modelContext.fetch(descriptor)
            if results.count > 1 {
                for dup in results.dropFirst() {
                    modelContext.delete(dup)
                }
                try? modelContext.save()
            }
            return results.first
        } catch {
            return habit.entries.first(where: { $0.dateString == dateString })
        }
    }
}

// MARK: - Month grid (Instagram-style stories archive)

/// Full-month grid of day cells (Sun…Sat). Days with a photo entry render
/// the photo; other days render an empty rounded-rect chip with the day number.
/// Today is marked with an outline ring. Tapping a cell calls `onTapDay`.
private struct CalendarMonthGrid: View {
    let habit: Habit
    /// Any date inside the month to display.
    let monthAnchor: Date
    let effectiveToday: Date
    let calendar: Calendar
    let gridWidth: CGFloat
    let namespace: Namespace.ID
    /// Key of the currently tapped-open day (hidden from grid so `matchedGeometryEffect` can move it).
    let tappedDateKey: String?
    let onTapDay: (Date) -> Void

    private var columns: Int { AppTheme.Layout.calendarGridColumns }
    private var cellGap: CGFloat { AppTheme.Spacing.calendarGridCellGap }
    private var rowGap: CGFloat { AppTheme.Spacing.calendarGridRowGap }

    /// Fixed 48×48 cells per Figma 510:1543; shrinks only if the container
    /// is too narrow to fit the preferred size + gaps.
    private var cellSize: CGFloat {
        let preferred: CGFloat = AppTheme.Layout.calendarDayChipWidth
        let cols = CGFloat(columns)
        let totalGap = cellGap * (cols - 1)
        let maxFit = (gridWidth - totalGap) / cols
        return min(preferred, maxFit)
    }

    private var monthInterval: DateInterval {
        calendar.dateInterval(of: .month, for: monthAnchor) ?? DateInterval(start: monthAnchor, duration: 0)
    }

    /// Sun=0 … Sat=6, regardless of `calendar.firstWeekday`.
    private var leadingBlankCount: Int {
        let first = calendar.startOfDay(for: monthInterval.start)
        return calendar.component(.weekday, from: first) - 1
    }

    private var daysInMonth: [Date] {
        var result: [Date] = []
        var day = calendar.startOfDay(for: monthInterval.start)
        let end = monthInterval.end
        while day < end {
            result.append(day)
            guard let next = calendar.date(byAdding: .day, value: 1, to: day) else { break }
            day = calendar.startOfDay(for: next)
        }
        return result
    }

    /// Photo entries keyed by `YYYY-MM-DD` so cells do a single dictionary lookup.
    private var entriesByDate: [String: HabitEntry] {
        HabitEntry.photoEntriesByDate(habit.entries)
    }

    private var weekdaySymbols: [String] {
        let base = calendar.shortStandaloneWeekdaySymbols
        return base.map { $0.uppercased() }
    }

    var body: some View {
        let byDate = entriesByDate
        VStack(alignment: .leading, spacing: AppTheme.Spacing.calendarGridWeekdayToGrid) {
            weekdayHeader
            gridBody(entriesByDate: byDate)
        }
        .frame(width: gridWidth, alignment: .leading)
    }

    private var weekdayHeader: some View {
        HStack(spacing: cellGap) {
            ForEach(Array(weekdaySymbols.enumerated()), id: \.offset) { _, symbol in
                Text(symbol)
                    .customFont(
                        .medium,
                        size: AppTheme.Typography.Size.calendarDayAbbrev,
                        lineHeight: AppTheme.Typography.Line.calendarDayAbbrev,
                        tracking: AppTheme.Typography.Tracking.calendarDayAbbrev
                    )
                    .foregroundColor(AppTheme.Colors.calendarGridWeekdayText)
                    .frame(width: cellSize, alignment: .center)
            }
        }
    }

    private func gridBody(entriesByDate: [String: HabitEntry]) -> some View {
        let leading = leadingBlankCount
        let days = daysInMonth
        let total = leading + days.count
        let rows = Int((Double(total) / Double(columns)).rounded(.up))

        return VStack(spacing: rowGap) {
            ForEach(0..<rows, id: \.self) { row in
                HStack(spacing: cellGap) {
                    ForEach(0..<columns, id: \.self) { column in
                        let cellIndex = row * columns + column
                        if cellIndex < leading || cellIndex >= leading + days.count {
                            Color.clear
                                .frame(width: cellSize, height: cellSize)
                        } else {
                            let day = days[cellIndex - leading]
                            let key = DateUtils.toDateString(date: day)
                            let isFuture = day > effectiveToday
                            CalendarMonthDayCell(
                                date: day,
                                dayNumber: calendar.component(.day, from: day),
                                entry: entriesByDate[key],
                                size: cellSize,
                                isToday: calendar.isDate(day, inSameDayAs: effectiveToday),
                                isFuture: isFuture,
                                namespace: namespace,
                                isHidden: tappedDateKey == key,
                                action: { onTapDay(day) }
                            )
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Month grid day cell

private struct CalendarMonthDayCell: View {
    @Environment(\.colorScheme) private var colorScheme

    let date: Date
    let dayNumber: Int
    let entry: HabitEntry?
    let size: CGFloat
    let isToday: Bool
    /// Dates after `effectiveToday` are read-only: cannot be tapped to log a photo.
    let isFuture: Bool
    let namespace: Namespace.ID
    /// Hide while the overlay is animating to / from this cell.
    let isHidden: Bool
    let action: () -> Void

    private var dateKey: String { DateUtils.toDateString(date: date) }

    private var hasPhoto: Bool { entry?.imageUri != nil }

    var body: some View {
        Button(action: action) {
            ZStack {
                if hasPhoto {
                    photoBody
                } else {
                    emptyBody
                }
            }
            .frame(width: size, height: size)
            .clipShape(cellShape)
            .overlay {
                if isToday {
                    cellShape
                        .stroke(
                            AppTheme.Colors.calendarGridTodayRing,
                            lineWidth: AppTheme.Layout.calendarGridTodayRingWidth
                        )
                }
            }
            .matchedGeometryEffect(id: dateKey, in: namespace)
            .opacity(isHidden ? 0 : (isFuture ? AppTheme.Opacity.calendarFutureDay : 1))
        }
        .buttonStyle(.plain)
        .disabled(isFuture)
        .accessibilityLabel(Text(DateUtils.formatDateWithOrdinal(dateKey)))
        .accessibilityValue(Text(hasPhoto ? "Photo logged" : (isFuture ? "Not yet available" : "No entry")))
    }

    private var cellShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppTheme.Layout.calendarGridCellRadius, style: .continuous)
    }

    @ViewBuilder
    private var photoBody: some View {
        if let uri = entry?.imageUri, let url = URL(string: uri) {
            AsyncImage(url: url) { phase in
                switch phase {
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                default:
                    AppTheme.Overlay.grayPhotoPlaceholder
                }
            }
            .frame(width: size, height: size)
            .clipped()
        } else {
            emptyBody
        }
    }

    private var emptyBody: some View {
        Text(String(dayNumber))
            .customFont(
                .semibold,
                size: AppTheme.Typography.Size.md,
                lineHeight: AppTheme.Typography.Line.title288,
                tracking: AppTheme.Typography.Tracking.calendarDayNumber
            )
            .foregroundColor(AppTheme.Colors.calendarDayChipRestText)
    }
}

// MARK: - Progressive blur header backdrop

/// Translucent material strip rendered at the top of the calendar tab.
/// The material provides a fixed-radius system blur; the gradient mask fades
/// it out toward the bottom, approximating a variable blur without depending
/// on private APIs. Sized to cover the safe area + floating title row + a
/// short fade region beneath it.
private struct CalendarProgressiveBlurHeader: View {
    @Environment(\.colorScheme) private var colorScheme

    let safeAreaTopInset: CGFloat
    let titlePadding: CGFloat
    let titleContentHeight: CGFloat
    let fadeExtension: CGFloat

    private var totalHeight: CGFloat {
        safeAreaTopInset + titlePadding + titleContentHeight + fadeExtension
    }

    private var solidStop: CGFloat {
        guard totalHeight > 0 else { return 0 }
        return (safeAreaTopInset + titlePadding + titleContentHeight) / totalHeight
    }

    var body: some View {
        VStack(spacing: 0) {
            headerFill
                .frame(height: totalHeight)
                .mask(
                    LinearGradient(
                        stops: [
                            .init(color: .black, location: 0),
                            .init(color: .black, location: max(solidStop - 0.15, 0)),
                            .init(color: .clear, location: 1)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            Spacer(minLength: 0)
        }
    }

    // `.ultraThinMaterial` reads as a lighter gray band against the near-black
    // page bg in dark mode, producing a visible seam. Falling back to the page
    // background colour preserves the fade illusion without the washed tint.
    @ViewBuilder
    private var headerFill: some View {
        if colorScheme == .dark {
            Rectangle().fill(AppTheme.Colors.emptyStateBackground)
        } else {
            Rectangle().fill(.ultraThinMaterial)
        }
    }
}

// MARK: - Habit card

private struct CalendarHabitDayCard: View {
    @Environment(\.colorScheme) private var colorScheme

    let habit: Habit
    let selectedDate: Date
    let cardWidth: CGFloat
    let calendar: Calendar
    let effectiveToday: Date
    let onImagePicked: (Data) -> Void
    /// When set, the title row shows a `…` menu button on the right (Figma 522:3251).
    var onMenu: (() -> Void)? = nil

    @Environment(PhotoSourceController.self) private var photoSource
    /// Selected marketing tag on the placeholder row (Figma 410:7611); drives darker chip + radial overlay.
    @State private var selectedPlaceholderTagID: String?

    private var dateString: String {
        DateUtils.toDateString(date: selectedDate)
    }

    private var entry: HabitEntry? {
        habit.entries.first(where: { $0.dateString == dateString })
    }

    private var hasPhoto: Bool {
        entry?.imageUri != nil
    }

    private var addPhotoTitle: String {
        calendar.isDate(selectedDate, inSameDayAs: effectiveToday)
            ? "Add today's photo"
            : "Add photo"
    }

    private var dayNumber: Int {
        DateUtils.dayNumber(createdAt: habit.createdAt, dateStr: dateString)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            titleSection
            photoFrame
            footerContent
        }
        .padding(.top, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .frame(width: cardWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .fill(AppTheme.Gradients.calendarHabitShell(colorScheme: colorScheme))
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .inset(by: 0.5)
                .stroke(AppTheme.Colors.calendarShellBorder, lineWidth: AppTheme.Spacing.hairline)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous))
        .appShadow(AppTheme.Elevation.calendarShellCard)
    }

    // MARK: - Title (Figma 522:3241 — left-aligned name + meta row, optional 3-dot menu)

    private var titleSection: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
                Text(habit.name)
                    .customFont(
                        .serifsemibold,
                        size: AppTheme.Typography.Size.lg,
                        lineHeight: AppTheme.Typography.Line.body24,
                        tracking: AppTheme.Typography.Tracking.nav
                    )
                    .foregroundColor(AppTheme.Colors.textPrimary)

                HStack(spacing: AppTheme.Spacing.sm) {
                    Text(DateUtils.formatDateWithOrdinal(dateString))
                        .customFont(
                            .semibold,
                            size: AppTheme.Typography.Size.sm,
                            tracking: AppTheme.Typography.Tracking.uppercaseLabel
                        )
                        .foregroundColor(AppTheme.Colors.calendarCardMetaText)
                        .textCase(.uppercase)

                    Circle()
                        .fill(AppTheme.Colors.calendarCardMetaText)
                        .frame(width: 4, height: 4)

                    Text("DAY \(dayNumber)")
                        .customFont(
                            .semibold,
                            size: AppTheme.Typography.Size.sm,
                            tracking: AppTheme.Typography.Tracking.uppercaseLabel
                        )
                        .foregroundColor(AppTheme.Colors.calendarCardMetaText)
                        .textCase(.uppercase)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            if let onMenu {
                OverlayChromeButton(systemName: "ellipsis", action: onMenu)
            }
        }
    }

    private var footerContent: some View {
        placeholderPillRow
    }

    private var placeholderPillRow: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            ForEach(placeholderPills, id: \.id) { pill in
                let isSelected = selectedPlaceholderTagID == pill.id
                Button {
                    withAnimation(AppTheme.Motion.easeTab) {
                        if selectedPlaceholderTagID == pill.id {
                            selectedPlaceholderTagID = nil
                        } else {
                            selectedPlaceholderTagID = pill.id
                        }
                    }
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                } label: {
                    Text(pill.title)
                        .customFont(
                            .medium,
                            size: AppTheme.Typography.Size.xs,
                            lineHeight: AppTheme.Typography.Line.body192,
                            tracking: AppTheme.Typography.Tracking.calendarHabitChip
                        )
                        .foregroundColor(pill.textColor)
                        .lineLimit(1)
                        .padding(.horizontal, AppTheme.Spacing.sm)
                        .padding(.vertical, AppTheme.Spacing.sm)
                        .background(placeholderPillCapsuleBackground(pill: pill, isSelected: isSelected))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(pill.title)
                .accessibilityAddTraits(isSelected ? .isButton.union(.isSelected) : .isButton)
            }
        }
    }

    private var placeholderPills: [CalendarPlaceholderPill] {
        [
            .init(
                title: "Personal",
                fillColor: AppTheme.Colors.calendarPlaceholderPillBlueFill,
                selectedFillColor: AppTheme.Colors.calendarPlaceholderPillBlueFillSelected,
                textColor: AppTheme.Colors.calendarPlaceholderPillBlueText
            ),
            .init(
                title: "Study",
                fillColor: AppTheme.Colors.calendarPlaceholderPillOrangeFill,
                selectedFillColor: AppTheme.Colors.calendarPlaceholderPillOrangeFillSelected,
                textColor: AppTheme.Colors.calendarPlaceholderPillOrangeText
            ),
            .init(
                title: "Health",
                fillColor: AppTheme.Colors.calendarPlaceholderPillGreenFill,
                selectedFillColor: AppTheme.Colors.calendarPlaceholderPillGreenFillSelected,
                textColor: AppTheme.Colors.calendarPlaceholderPillGreenText
            )
        ]
    }

    /// White inner rim on the photo frame when any footer tag is selected.
    private var calendarPhotoFrameHasInnerShadow: Bool {
        selectedPlaceholderTagID != nil
    }

    private var photoFrame: some View {
        Group {
            if hasPhoto {
                photoContent
            } else {
                emptyPhotoContent
            }
        }
        .frame(maxWidth: .infinity)
        .frame(height: AppTheme.Layout.calendarPhotoFrameHeight)
        .background(AppTheme.Colors.calendarPhotoPlaceholderFill)
        .clipShape(calendarPhotoClipShape)
        .overlay {
            if !hasPhoto {
                calendarPhotoClipShape
                    .stroke(
                        AppTheme.Colors.surfaceSelected,
                        style: StrokeStyle(lineWidth: AppTheme.Spacing.hairline, dash: [6, 5])
                    )
            }
        }
        .modifier(
            CalendarPhotoInnerShadowModifier(
                isActive: calendarPhotoFrameHasInnerShadow,
                cornerRadius: AppTheme.Radius.xl
            )
        )
        .appShadow(AppTheme.Elevation.calendarPhotoFrame)
        .contentShape(Rectangle())
        .onTapGesture {
            photoSource.present(onImagePicked: onImagePicked)
        }
    }

    @ViewBuilder
    private func placeholderPillCapsuleBackground(pill: CalendarPlaceholderPill, isSelected: Bool) -> some View {
        let capsule = Capsule(style: .continuous)
        if isSelected {
            capsule
                .fill(pill.selectedFillColor)
                .innerInsetRim(
                    shape: capsule,
                    color: AppTheme.Colors.calendarPlaceholderPillTagInnerShadow,
                    lineWidth: AppTheme.Layout.calendarPlaceholderPillTagInnerShadowSpread,
                    blur: AppTheme.Layout.calendarPlaceholderPillTagInnerShadowBlur,
                    offsetX: AppTheme.Layout.calendarPlaceholderPillTagInnerShadowOffsetX,
                    offsetY: AppTheme.Layout.calendarPlaceholderPillTagInnerShadowOffsetY
                )
        } else {
            capsule
                .fill(pill.fillColor)
        }
    }

    /// Inset media well — uniform radius on all corners (Figma 389:5194 / 402pt artboard).
    private var calendarPhotoClipShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: AppTheme.Radius.xl, style: .continuous)
    }

    @ViewBuilder
    private var photoContent: some View {
        if let uri = entry?.imageUri, let url = URL(string: uri) {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    AppTheme.Overlay.grayPhotoPlaceholder
                case let .success(image):
                    image
                        .resizable()
                        .scaledToFill()
                case .failure:
                    AppTheme.Overlay.grayPhotoPlaceholder
                @unknown default:
                    AppTheme.Overlay.grayPhotoPlaceholder
                }
            }
            .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .background(AppTheme.Colors.bgPrimary)
            .clipped()
            .contentShape(Rectangle())
        } else {
            AppTheme.Overlay.grayPhotoPlaceholder
        }
    }

    private var emptyPhotoContent: some View {
        VStack(spacing: 0) {
            Color.clear
                .frame(height: AppTheme.Spacing.calendarPlaceholderTopInset)
            VStack(spacing: AppTheme.Spacing.calendarAddOrbTitle) {
                AddPhotoOrb()
                    .frame(
                        width: AppTheme.Layout.calendarAddOrbSize,
                        height: AppTheme.Layout.calendarAddOrbSize
                    )
                Text(addPhotoTitle)
                    .customFont(
                        .semibold,
                        size: AppTheme.Typography.Size.md,
                        lineHeight: AppTheme.Typography.Line.body192,
                        tracking: AppTheme.Typography.Tracking.tight
                    )
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(addPhotoTitle)
        .accessibilityAddTraits(.isButton)
    }

}

private struct CalendarPhotoInnerShadowModifier: ViewModifier {
    let isActive: Bool
    let cornerRadius: CGFloat

    @ViewBuilder
    func body(content: Content) -> some View {
        if isActive {
            content
                .innerInsetRim(
                    shape: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous),
                    color: AppTheme.Colors.calendarPhotoSelectedInnerShadow,
                    lineWidth: AppTheme.Layout.calendarPhotoInnerShadowLineWidth,
                    blur: AppTheme.Layout.calendarPhotoInnerShadowBlur,
                    offsetX: 0,
                    offsetY: AppTheme.Layout.calendarPhotoInnerShadowOffsetY
                )
        } else {
            content
        }
    }
}

private struct CalendarPlaceholderPill: Identifiable {
    let title: String
    let fillColor: Color
    let selectedFillColor: Color
    let textColor: Color

    var id: String { title }
}

// MARK: - Tap-open card screen (Figma 522:3016)

/// Standalone screen presented as a full-screen cover when a calendar day is tapped.
/// Renders the floating X close button above a `CalendarHabitDayCard`. Background
/// matches the calendar tab page color — the iOS modal slide-up provides the
/// transition (no manual scrim/blur needed).
private struct CalendarCardOverlay: View {
    let habit: Habit
    let selectedDate: Date
    let cardWidth: CGFloat
    let calendar: Calendar
    let effectiveToday: Date
    let onImagePicked: (Data) -> Void
    let onDismiss: () -> Void
    /// Invoked when the card's 3-dot menu is tapped (Figma 522:3250 — opens the
    /// edit-habit sheet in the parent after this cover dismisses).
    var onMenu: (() -> Void)? = nil

    var body: some View {
        ZStack(alignment: .topLeading) {
            AppTheme.Colors.emptyStateBackground
                .ignoresSafeArea()

            VStack(alignment: .leading, spacing: AppTheme.Spacing.md) {
                OverlayChromeButton(systemName: "xmark", action: onDismiss)
                    .padding(.leading, AppTheme.Spacing.lg)

                CalendarHabitDayCard(
                    habit: habit,
                    selectedDate: selectedDate,
                    cardWidth: cardWidth,
                    calendar: calendar,
                    effectiveToday: effectiveToday,
                    onImagePicked: onImagePicked,
                    onMenu: onMenu
                )
                .frame(maxWidth: .infinity, alignment: .center)

                Spacer(minLength: 0)
            }
            .padding(.top, AppTheme.Spacing.md)
        }
    }
}

// MARK: - Calendar empty-state collage (Figma 458:1620)

/// Four overlapping, rotated photo thumbnails used as a decorative illustration
/// in the calendar empty state (Figma node 458:1620).
private struct CalendarEmptyStateCollage: View {
    private struct CollageItem {
        let image: String
        let rotation: Double
        let offsetX: CGFloat
        let offsetY: CGFloat
        let zIndex: Double
    }

    private let items: [CollageItem] = [
        // Back-right (Figma 458:1584)
        .init(image: "CalendarCollage1", rotation: 8.89, offsetX: 36, offsetY: 3, zIndex: 0),
        // Back-left (Figma 458:1585)
        .init(image: "CalendarCollage2", rotation: -13.68, offsetX: -34, offsetY: 4, zIndex: 1),
        // Middle (Figma 458:1586)
        .init(image: "CalendarCollage3", rotation: -8.1, offsetX: -15, offsetY: -5, zIndex: 2),
        // Front-center (Figma 458:1587)
        .init(image: "CalendarCollage4", rotation: -1.21, offsetX: 5, offsetY: 3, zIndex: 3),
    ]

    var body: some View {
        ZStack {
            ForEach(items.indices, id: \.self) { i in
                let item = items[i]
                Image(item.image)
                    .resizable()
                    .scaledToFill()
                    .frame(
                        width: AppTheme.Layout.calendarCollagePhotoSize,
                        height: AppTheme.Layout.calendarCollagePhotoSize
                    )
                    .clipShape(
                        RoundedRectangle(
                            cornerRadius: AppTheme.Layout.calendarCollagePhotoRadius,
                            style: .continuous
                        )
                    )
                    .overlay(
                        RoundedRectangle(
                            cornerRadius: AppTheme.Layout.calendarCollagePhotoRadius,
                            style: .continuous
                        )
                        .stroke(Color.white, lineWidth: AppTheme.Layout.calendarCollageBorderWidth)
                    )
                    .appShadow(AppTheme.Elevation.calendarCollagePhoto)
                    .rotationEffect(.degrees(item.rotation))
                    .offset(x: item.offsetX, y: item.offsetY)
                    .zIndex(item.zIndex)
            }
        }
        .frame(
            width: AppTheme.Layout.calendarCollageWidth,
            height: AppTheme.Layout.calendarCollageHeight
        )
    }
}

// MARK: - Calendar empty-state CTA (Figma 458:1582)

/// Pill-shaped blue gradient "Add habit" button matching the EmptyStateCTA chrome.
private struct CalendarEmptyCTA: View {
    var title: String
    var isPressed: Bool

    private let cornerRadius: CGFloat = AppTheme.Radius.pill

    private var navyRimY: CGFloat { isPressed ? 2.0 : 3.45 }
    private let navyRimLineWidth: CGFloat = 5.5
    private var navyRimAccentY: CGFloat { isPressed ? 0.28 : 0.42 }
    private let navyRimAccentWidth: CGFloat = 2.2

    private let lightRimOffsetY: CGFloat = 2.05
    private let bottomLightRimWidth: CGFloat = 2.4
    private let bottomLightRimOpacity: Double = 0.36

    var body: some View {
        Text(title)
            .customFont(
                .medium,
                size: AppTheme.Typography.Size.md,
                lineHeight: AppTheme.Typography.Line.body224,
                tracking: AppTheme.Typography.Tracking.body
            )
            .foregroundColor(AppTheme.Colors.textInverse)
            .padding(.horizontal, AppTheme.Spacing.lg)
            .padding(.vertical, AppTheme.Spacing.md)
            .frame(
                width: AppTheme.Layout.calendarEmptyCTAWidth,
                height: AppTheme.Layout.calendarEmptyCTAHeight
            )
            .background(ctaBackground)
            .compositingGroup()
            .appShadow(AppTheme.Elevation.ctaOuter)
    }

    private var ctaBackground: some View {
        let shape = RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
        let hairline: CGFloat = 0.5
        return shape
            .fill(figmaGradient)
            .innerInsetRim(
                shape: shape,
                color: AppTheme.Colors.ctaInsetNavy.opacity(0.2),
                lineWidth: navyRimLineWidth,
                blur: 0,
                offsetX: 0,
                offsetY: -navyRimY
            )
            .innerInsetRim(
                shape: shape,
                color: AppTheme.Overlay.black020,
                lineWidth: navyRimAccentWidth,
                blur: 0,
                offsetX: 0,
                offsetY: -navyRimAccentY
            )
            .innerInsetRim(
                shape: shape,
                color: Color.white.opacity(bottomLightRimOpacity),
                lineWidth: bottomLightRimWidth,
                blur: 0,
                offsetX: 0,
                offsetY: lightRimOffsetY
            )
            .overlay(
                shape.stroke(
                    AppTheme.Colors.ctaHairline,
                    lineWidth: hairline
                )
            )
    }

    private var figmaGradient: LinearGradient {
        LinearGradient(
            stops: [
                .init(color: AppTheme.Colors.emptyStateCTAStart, location: 0),
                .init(color: AppTheme.Colors.emptyStateCTAMid, location: 0.85222),
                .init(color: AppTheme.Colors.emptyStateCTAEnd, location: 1),
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1.5556)
        )
    }
}

private struct CalendarEmptyCTAButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            CalendarEmptyCTA(title: "Add habit", isPressed: configuration.isPressed)
            configuration.label
                .hidden()
                .accessibilityHidden(true)
        }
        .animation(AppTheme.Motion.springCTA, value: configuration.isPressed)
    }
}

#Preview("Calendar — Empty State") {
    let schema = Schema([Habit.self, HabitEntry.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: configuration)
    let cal = Calendar(identifier: .gregorian)
    let april11 = cal.date(from: DateComponents(year: 2026, month: 4, day: 11))!

    return CalendarTabView(
        habits: [],
        todayOverride: april11,
        initialSelectedDate: april11,
        onCreateHabit: {}
    )
    .modelContainer(container)
    .environment(PhotoSourceController())
}

#Preview("Calendar — 11 Apr 2026") {
    let schema = Schema([Habit.self, HabitEntry.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: configuration)
    let ctx = ModelContext(container)
    let jogging = Habit(name: "Morning jog", frequency: "Daily")
    let read = Habit(name: "Read 20 pages", frequency: "Daily")
    ctx.insert(jogging)
    ctx.insert(read)
    try? ctx.save()

    let cal = Calendar(identifier: .gregorian)
    let april11 = cal.date(from: DateComponents(year: 2026, month: 4, day: 11))!

    return CalendarTabView(
        habits: [jogging, read],
        todayOverride: april11,
        initialSelectedDate: april11
    )
    .modelContainer(container)
    .environment(PhotoSourceController())
}

#Preview("Calendar — 11 Apr 2026 Dark") {
    let schema = Schema([Habit.self, HabitEntry.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: configuration)
    let ctx = ModelContext(container)
    let jogging = Habit(name: "Morning jog", frequency: "Daily")
    ctx.insert(jogging)
    try? ctx.save()
    let cal = Calendar(identifier: .gregorian)
    let april11 = cal.date(from: DateComponents(year: 2026, month: 4, day: 11))!

    return CalendarTabView(
        habits: [jogging],
        todayOverride: april11,
        initialSelectedDate: april11
    )
    .modelContainer(container)
    .preferredColorScheme(.dark)
    .environment(PhotoSourceController())
}
