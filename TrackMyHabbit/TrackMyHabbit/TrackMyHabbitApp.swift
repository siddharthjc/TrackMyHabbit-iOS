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

    var sharedModelContainer: ModelContainer = Self.makeModelContainer()

    private static func makeModelContainer() -> ModelContainer {
        let schema = Schema([
            Habit.self,
            HabitEntry.self
        ])

        do {
            let persistentConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            return try ModelContainer(for: schema, configurations: [persistentConfig])
        } catch {
            // Avoid hard-crashing the app on launch due to a transient/migration issue.
            // Fallback to in-memory so the app can still run.
            print("⚠️ SwiftData ModelContainer init failed, falling back to in-memory: \(error)")
            do {
                let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try ModelContainer(for: schema, configurations: [inMemoryConfig])
            } catch {
                // If even in-memory fails, crash with context (should be extremely rare).
                fatalError("Could not create in-memory ModelContainer: \(error)")
            }
        }
    }

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
