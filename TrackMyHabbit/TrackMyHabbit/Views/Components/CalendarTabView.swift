import PhotosUI
import SwiftData
import SwiftUI
import UIKit

private enum DayChipStripScrollOffsetKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct CalendarTabView: View {
    @Environment(\.modelContext) private var modelContext

    let habits: [Habit]
    /// Overrides calendar “today” (e.g. 11 Apr 2026 in previews).
    var todayOverride: Date? = nil

    @State private var selectedDate: Date
    @State private var showDateSheet = false
    @State private var dayStripScrollHapticBucket: Int?
    /// Which day card is aligned in the horizontal strip; drives header + chip highlight.
    @State private var dayCardScrollPosition = ScrollPosition(idType: String.self)

    init(habits: [Habit], todayOverride: Date? = nil, initialSelectedDate: Date? = nil) {
        self.habits = habits
        self.todayOverride = todayOverride
        let seed = initialSelectedDate ?? todayOverride ?? Date()
        _selectedDate = State(initialValue: seed)
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

    /// Day shown in the title + chip row — follows whichever day card is scrolled into view.
    private var calendarDisplayDayStart: Date {
        if let key = dayCardScrollPosition.viewID(type: String.self),
           let date = DateUtils.parseDate(key) {
            return calendar.startOfDay(for: date)
        }
        return selectedDayStart
    }

    private var displayedDateKey: String {
        DateUtils.toDateString(date: calendarDisplayDayStart)
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
                // Derive the screen from the current window scene through UIKit bridge to avoid UIScreen.main
                // We use a tiny helper view to capture the window at render time if needed
                if let windowScene = UIApplication.shared.connectedScenes
                    .compactMap({ $0 as? UIWindowScene })
                    .first,
                   let screen = windowScene.screen as UIScreen? {
                    return screen.bounds.width
                }
                return geo.size.width // fallback (should be 0 only during first pass)
            }()
            let cardWidth = min(AppTheme.Layout.calendarCardWidth, effectiveWidth - AppTheme.Spacing.lg * 2)

            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    VStack(alignment: .leading, spacing: AppTheme.Spacing.calendarHeaderInner) {
                        dateTitleRow
                        dayChipStrip
                    }

                    if habits.isEmpty {
                        emptyHabitsPlaceholder
                            .padding(.top, AppTheme.Spacing.calendarDayStripToCard)
                    } else if let habit = habits.first {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: AppTheme.Spacing.sm) {
                                ForEach(daysInSelectedMonth, id: \.timeIntervalSince1970) { day in
                                    let dayStart = calendar.startOfDay(for: day)
                                    let dateKey = DateUtils.toDateString(date: dayStart)
                                    CalendarHabitDayCard(
                                        habit: habit,
                                        selectedDate: dayStart,
                                        cardWidth: cardWidth,
                                        calendar: calendar,
                                        effectiveToday: effectiveToday,
                                        onImagePicked: { data in
                                            saveEntryImage(data, habit: habit, date: dayStart)
                                        }
                                    )
                                    .id(dateKey)
                                }
                            }
                            .padding(.bottom, AppTheme.Spacing.calendarHabitCardShadowBleed)
                            .scrollTargetLayout()
                        }
                        .contentMargins(.horizontal, (effectiveWidth - cardWidth) / 2)
                        .scrollTargetBehavior(.viewAligned)
                        .scrollBounceBehavior(.basedOnSize)
                        .scrollPosition($dayCardScrollPosition)
                        .onAppear {
                            scrollToSelectedDay()
                        }
                        .padding(.top, AppTheme.Spacing.calendarDayStripToCard)
                        .scrollClipDisabled()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, AppTheme.Spacing.md)
                .padding(.bottom, AppTheme.Spacing.xxl + AppTheme.Spacing.calendarHabitCardShadowBleed)
            }
            .scrollClipDisabled()
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
                                    applyAbsoluteDisplayedDay(calendar.startOfDay(for: newValue))
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
                            .customFont(.semibold, size: AppTheme.Typography.Size.lg, lineHeight: AppTheme.Typography.Line.body24, tracking: AppTheme.Typography.Tracking.tight)
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Done") {
                            showDateSheet = false
                        }
                        .tint(AppTheme.Colors.tabBarAccent)
                    }
                }
            }
            .background(AppTheme.Colors.bgSecondary)
            .presentationDetents([.height(AppTheme.Layout.calendarDateSheetDetentHeight)])
            .presentationDragIndicator(.visible)
        }
    }

    private var dateTitleRow: some View {
        HStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            Button {
                showDateSheet = true
            } label: {
                HStack(alignment: .firstTextBaseline, spacing: AppTheme.Spacing.sm) {
                    HStack(alignment: .firstTextBaseline, spacing: 0) {
                        Text(String(calendar.component(.day, from: calendarDisplayDayStart)))
                            .customFont(
                                .serifsemibold,
                                size: AppTheme.Typography.Size.xl,
                                lineHeight: AppTheme.Typography.Line.title288,
                                tracking: AppTheme.Typography.Tracking.titleXL
                            )
                            .foregroundColor(AppTheme.Colors.textPrimary)
                            .contentTransition(.numericText())
                        Text(" \(DateUtils.monthName(for: calendarDisplayDayStart))")
                            .customFont(
                                .serifsemibold,
                                size: AppTheme.Typography.Size.xl,
                                lineHeight: AppTheme.Typography.Line.title288,
                                tracking: AppTheme.Typography.Tracking.titleXL
                            )
                            .foregroundColor(AppTheme.Colors.textPrimary)
                    }
                    Image(systemName: "chevron.down")
                        .font(.system(size: AppTheme.Typography.Size.md, weight: .semibold))
                        .foregroundColor(AppTheme.Colors.textPrimary)
                }
            }
            .buttonStyle(.plain)
            .animation(AppTheme.Motion.easeTab, value: calendarDisplayDayStart)

            Spacer(minLength: 0)

            Color.clear
                .frame(width: AppTheme.Spacing.xxl, height: AppTheme.Spacing.xxl)
                .accessibilityHidden(true)
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
    }

    /// Figma `389:5141`: day chips in a row with horizontal padding 20; full month scrolls horizontally (shadow bleed inside scroll content).
    private var dayChipStrip: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .center, spacing: AppTheme.Spacing.calendarDayChipGap) {
                    ForEach(daysInSelectedMonth, id: \.timeIntervalSince1970) { day in
                        let start = calendar.startOfDay(for: day)
                        let dayKey = DateUtils.toDateString(date: start)
                        let isSelected = calendar.isDate(start, inSameDayAs: calendarDisplayDayStart)
                        let isToday = calendar.isDate(start, inSameDayAs: effectiveToday)
                        CalendarDayChip(
                            date: start,
                            calendar: calendar,
                            isSelected: isSelected,
                            isToday: isToday
                        ) {
                            withAnimation(AppTheme.Motion.easeTab) {
                                applyAbsoluteDisplayedDay(start)
                            }
                        }
                        .id(dayKey)
                    }
                }
                .background {
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: DayChipStripScrollOffsetKey.self,
                            value: geo.frame(in: .named("dayChipStripScroll")).minX
                        )
                    }
                }
                .scrollTargetLayout()
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.vertical, AppTheme.Spacing.calendarChipStripShadowBleed)
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollBounceBehavior(.basedOnSize)
            .coordinateSpace(name: "dayChipStripScroll")
            .onPreferenceChange(DayChipStripScrollOffsetKey.self) { minX in
                let stridePx = AppTheme.Layout.calendarDayChipWidth + AppTheme.Spacing.calendarDayChipGap
                guard stridePx > 0 else { return }
                let scrolled = max(0, -minX)
                let bucket = Int(floor(scrolled / stridePx))
                if dayStripScrollHapticBucket == nil {
                    dayStripScrollHapticBucket = bucket
                    return
                }
                if bucket != dayStripScrollHapticBucket! {
                    dayStripScrollHapticBucket = bucket
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .onAppear {
                scrollDayStripToSelection(proxy: proxy, animated: false)
            }
            .onChange(of: displayedDateKey) { _, _ in
                dayStripScrollHapticBucket = nil
                scrollDayStripToSelection(proxy: proxy, animated: true)
            }
            .scrollClipDisabled()
        }
    }

    /// Navigates to an absolute day: updates the month anchor if needed, then scrolls the card strip.
    private func applyAbsoluteDisplayedDay(_ absoluteDayStart: Date) {
        let abs = calendar.startOfDay(for: absoluteDayStart)
        let key = DateUtils.toDateString(date: abs)

        if !calendar.isDate(abs, equalTo: selectedDayStart, toGranularity: .month) {
            // Different month — regenerate cards first, then scroll after layout.
            selectedDate = abs
            DispatchQueue.main.async {
                withAnimation(AppTheme.Motion.easeTab) {
                    dayCardScrollPosition.scrollTo(id: key, anchor: .center)
                }
            }
        } else {
            // Same month — scroll directly with animation.
            withAnimation(AppTheme.Motion.easeTab) {
                dayCardScrollPosition.scrollTo(id: key, anchor: .center)
            }
        }
    }

    private func scrollToSelectedDay() {
        let key = selectedDateKey
        dayCardScrollPosition.scrollTo(id: key, anchor: .center)
    }

    private func scrollDayStripToSelection(proxy: ScrollViewProxy, animated: Bool) {
        guard !daysInSelectedMonth.isEmpty else { return }
        let key = displayedDateKey
        DispatchQueue.main.async {
            if animated {
                withAnimation(AppTheme.Motion.easeTab) {
                    proxy.scrollTo(key, anchor: .center)
                }
            } else {
                proxy.scrollTo(key, anchor: .center)
            }
        }
    }

    private var emptyHabitsPlaceholder: some View {
        VStack(alignment: .center, spacing: AppTheme.Spacing.sm) {
            Text("No habits yet")
                .customFont(.semibold, size: AppTheme.Typography.Size.lg, lineHeight: AppTheme.Typography.Line.body24, tracking: AppTheme.Typography.Tracking.nav)
                .foregroundColor(AppTheme.Colors.textPrimary)
            Text("Create a habit from the Home tab to see it here.")
                .customFont(.medium, size: AppTheme.Typography.Size.sm, lineHeight: AppTheme.Typography.Line.body20, tracking: AppTheme.Typography.Tracking.caption)
                .foregroundColor(AppTheme.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, AppTheme.Spacing.block)
        .padding(.top, AppTheme.Spacing.xl)
    }

    private func saveEntryImage(_ data: Data, habit: Habit, date: Date) {
        let dateString = DateUtils.toDateString(date: date)
        let existing = resolveEntry(habit: habit, dateString: dateString)

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

// MARK: - Day chip

private struct CalendarDayChip: View {
    let date: Date
    let calendar: Calendar
    let isSelected: Bool
    let isToday: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 0) {
                Text(DateUtils.weekdayAbbrevUppercased(for: date))
                    .customFont(
                        .medium,
                        size: AppTheme.Typography.Size.calendarDayAbbrev,
                        lineHeight: AppTheme.Typography.Line.calendarDayAbbrev,
                        tracking: AppTheme.Typography.Tracking.calendarDayAbbrev
                    )
                Text(String(calendar.component(.day, from: date)))
                    .customFont(
                        isToday ? .serifsemibold : .semibold,
                        size: AppTheme.Typography.Size.md,
                        lineHeight: AppTheme.Typography.Line.title288,
                        tracking: AppTheme.Typography.Tracking.calendarDayNumber
                    )
                    .contentTransition(.numericText())
            }
            .multilineTextAlignment(.center)
            .foregroundColor(isSelected ? AppTheme.Colors.textInverse : AppTheme.Colors.textSecondary)
            .padding(.horizontal, AppTheme.Spacing.sm3)
            .frame(
                width: AppTheme.Layout.calendarDayChipWidth,
                height: AppTheme.Layout.calendarDayChipHeight,
                alignment: .center
            )
            .background(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .fill(isSelected ? AppTheme.Colors.calendarDaySelectedFill : AppTheme.Colors.surfaceSelected)
            )
            .overlay(
                RoundedRectangle(cornerRadius: AppTheme.Radius.md, style: .continuous)
                    .stroke(isSelected ? AppTheme.Colors.calendarDaySelectedStroke : Color.clear, lineWidth: AppTheme.Spacing.hairline)
            )
            .modifier(CalendarChipShadowModifier(isSelected: isSelected))
        }
        .buttonStyle(.plain)
        .animation(AppTheme.Motion.easeTab, value: isSelected)
    }
}

// MARK: - Habit card

private struct CalendarHabitDayCard: View {
    let habit: Habit
    let selectedDate: Date
    let cardWidth: CGFloat
    let calendar: Calendar
    let effectiveToday: Date
    let onImagePicked: (Data) -> Void

    @State private var selectedPhoto: PhotosPickerItem?
    @State private var showPhotoPicker = false
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

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            photoFrame
            footerContent
        }
        .padding(.top, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.md)
        .padding(.horizontal, AppTheme.Spacing.lg)
        .frame(width: cardWidth, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .fill(AppTheme.Colors.bgPrimary)
        )
        .overlay(
            RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous)
                .stroke(AppTheme.Colors.calendarShellBorder, lineWidth: AppTheme.Spacing.hairline)
        )
        .clipShape(RoundedRectangle(cornerRadius: AppTheme.Radius.calendarShell, style: .continuous))
        .appShadow(AppTheme.Elevation.calendarShellCard)
        .photosPicker(isPresented: $showPhotoPicker, selection: $selectedPhoto, matching: .images)
        .task(id: selectedPhoto) {
            guard let selectedPhoto else { return }
            defer { self.selectedPhoto = nil }
            if let data = try? await selectedPhoto.loadTransferable(type: Data.self) {
                onImagePicked(data)
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
        .background(AppTheme.Colors.bgPrimary)
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
            showPhotoPicker = true
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
                CalendarAddPhotoOrb()
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

/// Matches `EmptyStateCTA` chrome (gradient, inset rims, hairline, outer shadow) on a circle (`EmptyState.swift`).
private struct CalendarAddPhotoOrb: View {
    private let navyRimY: CGFloat = 3.45
    private let navyRimLineWidth: CGFloat = 5.5
    private let navyRimAccentY: CGFloat = 0.42
    private let navyRimAccentWidth: CGFloat = 2.2
    private let lightRimOffsetY: CGFloat = 2.05
    private let bottomLightRimWidth: CGFloat = 2.4
    private let bottomLightRimOpacity: Double = 0.36
    private let hairline: CGFloat = 0.5

    var body: some View {
        ZStack {
            ctaCircleBackground
            CalendarAddPhotoGlyph()
        }
        .compositingGroup()
        .appShadow(AppTheme.Elevation.ctaOuter)
    }

    private var ctaCircleBackground: some View {
        let shape = Circle()
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
                .init(color: AppTheme.Colors.emptyStateCTAEnd, location: 1)
            ],
            startPoint: UnitPoint(x: 0.5, y: 0),
            endPoint: UnitPoint(x: 0.5, y: 1.5556)
        )
    }
}

private struct CalendarAddPhotoGlyph: View {
    var body: some View {
        ZStack {
            Capsule(style: .continuous)
                .fill(AppTheme.Colors.textInverse)
                .frame(
                    width: AppTheme.Layout.calendarAddGlyphLength,
                    height: AppTheme.Layout.calendarAddGlyphThickness
                )
            Capsule(style: .continuous)
                .fill(AppTheme.Colors.textInverse)
                .frame(
                    width: AppTheme.Layout.calendarAddGlyphThickness,
                    height: AppTheme.Layout.calendarAddGlyphLength
                )
        }
        .frame(
            width: AppTheme.Typography.Size.calendarPlusGlyph,
            height: AppTheme.Typography.Size.calendarPlusGlyph
        )
    }
}

private struct CalendarChipShadowModifier: ViewModifier {
    let isSelected: Bool

    @ViewBuilder
    func body(content: Content) -> some View {
        if isSelected {
            content.appShadow(AppTheme.Elevation.calendarDayChipSelected)
        } else {
            content
        }
    }
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
    .environment(\.colorScheme, .dark)
}
