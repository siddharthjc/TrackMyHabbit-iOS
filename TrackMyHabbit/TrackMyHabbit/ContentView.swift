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
    @State private var selectedTab: AppTab = ProcessInfo.processInfo.arguments.contains("--start-calendar") ? .calendar : .home
    @State private var selectedHabitDate: String?

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
                        .toolbar(selectedHabitDate == nil ? .visible : .hidden, for: .tabBar)
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

    @ViewBuilder
    private func walletChromeRow(for habit: Habit) -> some View {
        HStack {
            OverlayChromeButton(systemName: "xmark") {
                withAnimation(AppTheme.Motion.springWalletUnpin) {
                    selectedHabitDate = nil
                }
            }
            Spacer()
            Menu {
                Button {
                    selectedHabitDate = nil
                    showEditSheet = true
                } label: {
                    Label("Edit habit", systemImage: "pencil")
                }
                if let dateStr = selectedHabitDate,
                   habit.entries.contains(where: { $0.dateString == dateStr && $0.imageUri != nil }) {
                    Button(role: .destructive) {
                        deleteEntry(for: habit, dateStr: dateStr)
                    } label: {
                        Label("Delete entry", systemImage: "trash")
                    }
                }
            } label: {
                Image(systemName: "ellipsis")
                    .font(.system(size: AppTheme.Typography.Size.md, weight: .semibold))
                    .foregroundColor(AppTheme.Colors.textPrimary)
                    .overlayChromeShape()
            }
        }
        .frame(height: AppTheme.Layout.calendarOverlayChromeButton)
    }

    private func deleteEntry(for habit: Habit, dateStr: String) {
        guard let entry = habit.entries.first(where: { $0.dateString == dateStr }) else { return }
        let imageUri = entry.imageUri
        modelContext.delete(entry)
        do {
            try modelContext.save()
            HabitPhotoFileStore.removeFile(at: imageUri)
        } catch {
            modelContext.rollback()
            print("Failed to delete entry for \(habit.name): \(error.localizedDescription)")
        }
    }

    private func savePhoto(for habit: Habit, dateStr: String, data: Data) {
        let dateString = dateStr
        do {
            let fileURL = try HabitPhotoFileStore.persistJPEG(
                data: data,
                habitID: habit.id,
                dateString: dateString
            )
            let existing = habit.entries.first(where: { $0.dateString == dateString })
            let previousImageUri = existing?.imageUri

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
                if previousImageUri != fileURL.absoluteString {
                    HabitPhotoFileStore.removeFile(at: previousImageUri)
                }
            } catch {
                modelContext.rollback()
                HabitPhotoFileStore.removeFile(at: fileURL.absoluteString)
                throw error
            }
        } catch {
            print("Failed to save today's photo for \(habit.name): \(error.localizedDescription)")
        }
    }

    /// Solid backdrop shown behind the pinned wallet card. Matches the home
    /// background so the area reads as a clean flat surface; the layer stays
    /// active to receive tap-to-dismiss while a card is pinned. Fades in on
    /// expand and reverses out on dismiss via the same opacity binding.
    @ViewBuilder
    private var walletBackdrop: some View {
        AppTheme.Colors.emptyStateBackground
            .ignoresSafeArea()
            .opacity(selectedHabitDate != nil ? 1 : 0)
            .allowsHitTesting(selectedHabitDate != nil)
            .onTapGesture {
                withAnimation(AppTheme.Motion.springWalletUnpin) {
                    selectedHabitDate = nil
                }
            }
            .animation(AppTheme.Motion.easeWalletBackdrop, value: selectedHabitDate)
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
        ZStack(alignment: .bottom) {
            AppTheme.Colors.emptyStateBackground
                .ignoresSafeArea()

            walletBackdrop

            if habits.isEmpty {
                EmptyState {
                    presentCreateSheetAfterCTADelay()
                }
            } else if let habit = activeHabit {
                VStack(spacing: 0) {
                    if selectedHabitDate != nil {
                        walletChromeRow(for: habit)
                            .padding(.horizontal, AppTheme.Spacing.sm3)
                            .padding(.top, AppTheme.Spacing.tabBarTopInset)
                    } else {
                        HabitSwitcher(
                            habits: habits,
                            activeHabitId: activeHabitId,
                            onSelect: { id in activeHabitId = id }
                        )
                        .padding(.top, AppTheme.Spacing.tabBarTopInset)
                    }

                    HabitWalletStack(
                        habit: habit,
                        selectedDate: $selectedHabitDate,
                        onPickPhoto: { dateStr in
                            photoSourceController.present { data in
                                savePhoto(for: habit, dateStr: dateStr, data: data)
                            }
                        }
                    )
                    .padding(.top, AppTheme.Spacing.sm3)
                }

                VStack(spacing: 0) {
                    if selectedHabitDate == nil {
                        ProgressiveBlurEdge(
                            edge: .top,
                            height: AppTheme.Layout.walletTopBlurHeight
                        )
                    }
                    Spacer(minLength: 0)
                    if selectedHabitDate == nil {
                        ProgressiveBlurEdge(
                            edge: .bottom,
                            height: AppTheme.Layout.walletBottomBlurHeight
                        )
                    }
                }
                .ignoresSafeArea(edges: [.top, .bottom])
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
