//
//  ContentView.swift
//  TrackMyHabbit
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

import SwiftUI
import SwiftData
import UIKit

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var activeHabitId: UUID?
    @State private var selectedTab: AppTab = .home

    @State private var showCreateSheet = false
    @State private var showEditSheet = false
    @State private var homeDays: [String] = DateUtils.generateDays(count: 30)
    @State private var homeScreenWidth: CGFloat = 393

    var activeHabit: Habit? {
        // Fallback to the first habit if active is not set or not found
        habits.first(where: { $0.id == activeHabitId }) ?? habits.first
    }

    var body: some View {
        ZStack {
            TabView(selection: tabSelection) {
                Tab(value: AppTab.home) {
                    homeScreen
                } label: {
                    Label(AppTab.home.title, systemImage: AppTab.home.icon)
                }

                Tab(value: AppTab.calendar) {
                    CalendarTabView(
                        habits: habits,
                        activeHabitId: activeHabitId,
                        onCreateHabit: { presentCreateSheetAfterCTADelay() }
                    )
                } label: {
                    Label(AppTab.calendar.title, systemImage: AppTab.calendar.icon)
                }

                Tab(value: AppTab.habits) {
                    // Placeholder — the tab action opens the edit sheet instead
                    Color.clear.ignoresSafeArea()
                } label: {
                    Label(AppTab.habits.title, systemImage: AppTab.habits.icon)
                }

                Tab(value: AppTab.add, role: .search) {
                    Color.clear
                        .ignoresSafeArea()
                } label: {
                    Label(AppTab.add.title, systemImage: AppTab.add.icon)
                }
            }
            .tint(AppTheme.Colors.tabBarAccent)
            .tabBarMinimizeBehavior(.onScrollDown)
            .onAppear {
                if activeHabitId == nil, let first = habits.first {
                    activeHabitId = first.id
                }
            }
            .onChange(of: habits) { _, newHabits in
                if activeHabitId == nil || !newHabits.contains(where: { $0.id == activeHabitId }) {
                    activeHabitId = newHabits.last?.id
                }
            }
            .sheet(isPresented: $showCreateSheet) {
                CreateHabitSheet()
            }
            .sheet(isPresented: $showEditSheet) {
                if let habit = activeHabit {
                    CreateHabitSheet(editingHabit: habit)
                }
            }

        }
    }

    /// Custom binding that intercepts tab selection so "Habits" and "Add" never
    /// actually switch away from the current screen.
    private var tabSelection: Binding<AppTab> {
        Binding<AppTab>(
            get: { selectedTab },
            set: { newTab in
                if newTab == .add {
                    showCreateSheet = true
                } else if newTab == .habits {
                    if activeHabit != nil {
                        showEditSheet = true
                    }
                } else {
                    selectedTab = newTab
                }
            }
        )
    }

    /// Lets the CTA finish its press animation before the sheet appears.
    private func presentCreateSheetAfterCTADelay() {
        Task { @MainActor in
            try? await Task.sleep(nanoseconds: AppTheme.Motion.createSheetDelayNanoseconds)
            showCreateSheet = true
        }
    }

    @ViewBuilder
    private var homeScreen: some View {
        ZStack {
            AppTheme.Colors.emptyStateBackground
                .ignoresSafeArea()

            if habits.isEmpty {
                EmptyState {
                    presentCreateSheetAfterCTADelay()
                }
            } else if habits.count == 1, let habit = habits.first {
                singleHabitHome(habit: habit)
            } else if let habit = activeHabit {
                VStack(spacing: 0) {
                    HabitSwitcher(
                        habits: habits,
                        activeHabitId: activeHabitId,
                        onSelect: { id in activeHabitId = id }
                    )
                    .padding(.top, AppTheme.Spacing.tabBarTopInset)

                    Spacer()
                    HabitCarousel(habit: habit)
                    Spacer()
                }
                .padding(.bottom, AppTheme.Spacing.lg)
            }
        }
    }

    // MARK: - Single-Habit Home

    private var homeHeader: some View {
        HStack {
            Text("TrackMyHabbit")
                .customFont(
                    .serifsemibold,
                    size: AppTheme.Typography.Size.xl,
                    tracking: AppTheme.Typography.Tracking.titleXL
                )
                .foregroundColor(AppTheme.Colors.textPrimary)

            Spacer()

            Button(action: { showCreateSheet = true }) {
                Image(systemName: "plus")
                    .font(.system(size: AppTheme.Typography.Size.lg, weight: .medium))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .frame(
                        width: AppTheme.Layout.navIconSize,
                        height: AppTheme.Layout.navIconSize
                    )
            }
            .glassEffect(.regular, in: Circle())
        }
        .padding(.horizontal, AppTheme.Spacing.lg)
        .padding(.top, AppTheme.Spacing.tabBarTopInset)
    }

    @ViewBuilder
    private func singleHabitHome(habit: Habit) -> some View {
        let cardWidth = min(
            AppTheme.Layout.calendarCardWidth,
            homeScreenWidth - AppTheme.Spacing.lg * 2
        )
        let today = Calendar.current.startOfDay(for: Date())

        VStack(spacing: 0) {
            homeHeader

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: AppTheme.Spacing.horizontalHabitCardGap) {
                    ForEach(homeDays, id: \.self) { dateStr in
                        HomeDayCard(
                            habit: habit,
                            dateStr: dateStr,
                            cardWidth: cardWidth,
                            effectiveToday: today,
                            onImagePicked: { data in
                                saveHomeEntryImage(data, habit: habit, dateStr: dateStr)
                            }
                        )
                    }
                }
                .padding(.horizontal, AppTheme.Spacing.lg)
                .padding(.bottom, AppTheme.Spacing.calendarHabitCardShadowBleed)
                .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollBounceBehavior(.basedOnSize)
            .scrollClipDisabled()
            .padding(.top, AppTheme.Layout.homeHeaderToCard)

            Spacer(minLength: 0)
        }
        .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.width
        } action: { newWidth in
            homeScreenWidth = newWidth
        }
        .onAppear { refreshHomeDays() }
        .onReceive(
            NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)
        ) { _ in
            refreshHomeDays()
        }
    }

    private func saveHomeEntryImage(_ data: Data, habit: Habit, dateStr: String) {
        let existing = habit.entries.first(where: { $0.dateString == dateStr })

        do {
            let fileURL = try HabitPhotoFileStore.persistJPEG(
                data: data,
                habitID: habit.id,
                dateString: dateStr
            )
            do {
                if let existing {
                    existing.imageUri = fileURL.absoluteString
                } else {
                    let newEntry = HabitEntry(
                        dateString: dateStr,
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
            print("Failed to save home photo: \(error.localizedDescription)")
        }
    }

    private func refreshHomeDays() {
        let newDays = DateUtils.generateDays(count: 30)
        if newDays != homeDays { homeDays = newDays }
    }
}

// MARK: - App Tab Enum

private enum AppTab: Hashable, CaseIterable {
    case home
    case calendar
    case habits
    case add

    var title: String {
        switch self {
        case .home:
            return "Home"
        case .calendar:
            return "Calendar"
        case .habits:
            return "Habits"
        case .add:
            return "Add"
        }
    }

    var icon: String {
        switch self {
        case .home:
            return "house.fill"
        case .calendar:
            return "calendar"
        case .habits:
            return "line.3.horizontal.decrease"
        case .add:
            return "plus"
        }
    }
}

@MainActor
private func contentViewPreviewContainer() -> ModelContainer {
    let schema = Schema([Habit.self, HabitEntry.self])
    let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: configuration)
    let ctx = container.mainContext
    ctx.insert(Habit(name: "Morning jog", frequency: "Daily"))
    ctx.insert(Habit(name: "Read 20 pages", frequency: "Daily"))
    try? ctx.save()
    return container
}

#Preview {
    ContentView()
        .modelContainer(contentViewPreviewContainer())
}

#Preview("Dark") {
    ContentView()
        .modelContainer(contentViewPreviewContainer())
        .environment(\.colorScheme, .dark)
}
