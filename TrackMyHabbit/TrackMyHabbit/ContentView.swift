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
    
    @State private var showCreateSheet = false
    @State private var showPickerSheet = false
    
    var activeHabit: Habit? {
        // Fallback to the first habit if active is not set or not found
        habits.first(where: { $0.id == activeHabitId }) ?? habits.first
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            (habits.isEmpty ? AppTheme.Colors.emptyStateBackground : AppTheme.Colors.bgPrimary)
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
                    .padding(.top, 24)
                    
                    Spacer()
                    
                    HabitCarousel(habit: habit)
                    
                    Spacer(minLength: 40)
                }
            }
            .padding(.bottom, habits.isEmpty ? 0 : 100)
            
            if !habits.isEmpty {
                CustomTabBar {
                    showCreateSheet = true
                }
            }
        }
        .onAppear {
            if activeHabitId == nil, let first = habits.first {
                activeHabitId = first.id
            }
        }
        .onChange(of: habits) { _, newHabits in
            // If the active habit was deleted, or newly added
            if activeHabitId == nil || !newHabits.contains(where: { $0.id == activeHabitId }) {
                activeHabitId = newHabits.last?.id // default to newest
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
}

// MARK: - Custom Tab Bar
struct CustomTabBar: View {
    let onAddPress: () -> Void
    var body: some View {
        HStack(spacing: 0) {
            // Habits Tab
            VStack(spacing: 4) {
                Image(systemName: "checklist")
                    .font(.system(size: 20, weight: .semibold))
                Text("Habits")
                    .customFont(.medium, size: 12)
            }
            .foregroundColor(AppTheme.Colors.systemBlue)
            .frame(maxWidth: .infinity)
            
            // Calendar Tab
            VStack(spacing: 4) {
                Image(systemName: "calendar")
                    .font(.system(size: 20, weight: .semibold))
                Text("Calendar")
                    .customFont(.medium, size: 12)
            }
            .foregroundColor(AppTheme.Colors.textPrimary)
            .frame(maxWidth: .infinity)
            
            // Add Tab
            Button(action: onAddPress) {
                VStack(spacing: 4) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                    Text("Add")
                        .customFont(.medium, size: 12)
                }
                .foregroundColor(AppTheme.Colors.textPrimary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 25)
        .padding(.horizontal, 24)
        .background(
            RoundedRectangle(cornerRadius: 100)
                .fill(AppTheme.Neutral._0.opacity(0.85))
                .shadow(color: Color.black.opacity(0.12), radius: 40, x: 0, y: 8)
        )
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}
