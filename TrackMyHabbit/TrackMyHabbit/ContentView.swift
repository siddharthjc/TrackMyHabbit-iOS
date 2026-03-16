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
            tabItem(
                title: "Habits",
                systemImage: "checklist",
                isSelected: true,
                action: nil
            )

            tabItem(
                title: "Calendar",
                systemImage: "calendar",
                isSelected: false,
                action: nil
            )

            tabItem(
                title: "Add",
                systemImage: "plus",
                isSelected: false,
                action: onAddPress
            )
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(Color.white.opacity(0.78))
                .overlay(
                    Capsule(style: .continuous)
                        .stroke(Color.white.opacity(0.9), lineWidth: 1)
                )
                .shadow(color: Color.black.opacity(0.12), radius: 40, x: 0, y: 8)
        )
        .padding(.horizontal, 25)
        .padding(.bottom, 25)
    }

    @ViewBuilder
    private func tabItem(title: String, systemImage: String, isSelected: Bool, action: (() -> Void)?) -> some View {
        let content = VStack(spacing: title == "Habits" ? 1 : 0.5) {
            Image(systemName: systemImage)
                .font(.system(size: title == "Add" ? 18 : 18, weight: .semibold))
            Text(title)
                .customFont(.medium, size: 12, lineHeight: 14.4, tracking: -0.12)
        }
        .foregroundColor(isSelected ? AppTheme.Colors.emptyStateCTAMid : AppTheme.Colors.textPrimary)
        .frame(width: 102)
        .padding(.vertical, 6)
        .background(
            Capsule(style: .continuous)
                .fill(isSelected ? AppTheme.Neutral._300.opacity(0.9) : Color.clear)
        )

        if let action {
            Button(action: action) {
                content
            }
            .buttonStyle(.plain)
        } else {
            content
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Habit.self, inMemory: true)
}
