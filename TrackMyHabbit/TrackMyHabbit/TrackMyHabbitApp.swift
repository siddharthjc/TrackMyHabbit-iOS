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
    private enum RootPhase {
        case splash
        case liquidIntro
        case main
    }

    @State private var rootPhase: RootPhase = .splash

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
            fatalError("Could not create persistent ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            // Inherits `UIUserInterfaceStyle` from the system (Light / Dark); no forced appearance.
            Group {
                switch rootPhase {
                case .splash:
                    SplashScreenView {
                        if LiquidGlassIntroLaunch.shouldSkipForTesting || LiquidGlassIntroLaunch.hasUserCompletedIntro {
                            rootPhase = .main
                        } else {
                            rootPhase = .liquidIntro
                        }
                    }
                case .liquidIntro:
                    LiquidGlassIntroView(
                        revealBackground: AppTheme.Colors.emptyStateBackground,
                        destination: { ContentView() },
                        onComplete: {
                            // Visual handoff already happened inside the intro;
                            // just commit the phase change without an outer animation.
                            rootPhase = .main
                        }
                    )
                    .transition(.opacity)
                case .main:
                    ContentView()
                        .transition(.opacity)
                }
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
