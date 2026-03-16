//
//  ContentView.swift
//  TrackMyHabbit
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Habit.createdAt) private var habits: [Habit]
    
    @State private var activeHabitId: UUID?
    @State private var selectedTab: AppTab = .habits
    
    @State private var showCreateSheet = false
    @State private var showPickerSheet = false
    
    var activeHabit: Habit? {
        // Fallback to the first habit if active is not set or not found
        habits.first(where: { $0.id == activeHabitId }) ?? habits.first
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab(value: AppTab.habits) {
                homeScreen
            } label: {
                Label(AppTab.habits.title, systemImage: AppTab.habits.icon)
            }

            Tab(value: AppTab.calendar) {
                CalendarPlaceholderView()
            } label: {
                Label(AppTab.calendar.title, systemImage: AppTab.calendar.icon)
            }

            Tab(value: AppTab.add, role: .search) {
                Color.clear
                    .ignoresSafeArea()
            } label: {
                Label(AppTab.add.title, systemImage: AppTab.add.icon)
            }
        }
        .tint(AppTheme.Colors.emptyStateCTAMid)
        .tabBarMinimizeBehavior(.onScrollDown)
        .onChange(of: selectedTab) { previousTab, newTab in
            if newTab == .add {
                showCreateSheet = true
                selectedTab = previousTab
            }
        }
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
        .sheet(isPresented: $showPickerSheet) {
            HabitPickerModal(
                activeHabitId: activeHabitId,
                onSelect: { id in
                    activeHabitId = id
                }
            )
        }
    }

    @ViewBuilder
    private var homeScreen: some View {
        ZStack {
            AppTheme.Colors.emptyStateBackground
                .ignoresSafeArea()

            VStack(spacing: 0) {
                if habits.isEmpty {
                    EmptyState {
                        showCreateSheet = true
                    }
                } else if let habit = activeHabit {
                    HabitSwitcher(
                        habitName: habit.name,
                        habitCount: habits.count,
                        onSwitchPress: { showPickerSheet = true }
                    )
                    .padding(.top, 8)

                    Spacer()

                    HabitCarousel(habit: habit)

                    Spacer()
                }
            }
            .padding(.bottom, habits.isEmpty ? 0 : 20)
        }
    }
}

private enum AppTab: Hashable, CaseIterable {
    case habits
    case calendar
    case add

    var title: String {
        switch self {
        case .habits:
            return "Habits"
        case .calendar:
            return "Calendar"
        case .add:
            return "Add"
        }
    }

    var icon: String {
        switch self {
        case .habits:
            return "checklist"
        case .calendar:
            return "calendar"
        case .add:
            return "plus"
        }
    }
}

private struct CalendarPlaceholderView: View {
    var body: some View {
        ZStack {
            AppTheme.Colors.emptyStateBackground
                .ignoresSafeArea()

            VStack(spacing: 12) {
                Image(systemName: "calendar")
                    .font(.system(size: 40, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textSecondary)

                Text("Calendar view coming next")
                    .customFont(.semibold, size: 20, lineHeight: 24, tracking: -0.4)
                    .foregroundColor(AppTheme.Colors.textPrimary)

                Text("The new system tab bar is in place, so we can plug the calendar screen into this tab next.")
                    .customFont(.medium, size: 14, lineHeight: 20, tracking: -0.14)
                    .foregroundColor(AppTheme.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}
