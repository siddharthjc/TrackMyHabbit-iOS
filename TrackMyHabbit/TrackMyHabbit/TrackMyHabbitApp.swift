//
//  TrackMyHabbitApp.swift
//  TrackMyHabbit
//
//  Created by Siddharth Chhatpar on 16/03/26.
//

import SwiftUI
import SwiftData

@main
struct TrackMyHabbitApp: App {
    @State private var showSplash = true

    init() {
        FontRegistration.registerBundledFonts()
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Habit.self,
            HabitEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            if showSplash {
                SplashScreenView {
                    showSplash = false
                }
            } else {
                ContentView()
                    .transition(.opacity)
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
