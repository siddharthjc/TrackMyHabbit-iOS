//
//  ContentView.swift
//  TrackMyHabbit
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Query(sort: \Habit.createdAt) private var habits: [Habit]

    @State private var activeHabitId: UUID?
    @State private var selectedTab: AppTab = ProcessInfo.processInfo.arguments.contains("--start-calendar") ? .calendar : .home

    @State private var showCreateSheet = false
    @State private var showEditSheet = false
    @State private var photoSourceController = PhotoSourceController()

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
                        onCreateHabit: { presentCreateSheetAfterCTADelay() },
                        onEditHabit: { showEditSheet = true }
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
        .environment(photoSourceController)
        .photoSourcePickerRoot(photoSourceController)
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
