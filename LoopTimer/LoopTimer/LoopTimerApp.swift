//
//  LoopTimerApp.swift
//  LoopTimer
//
//  App entry point and lifecycle management
//

import SwiftUI
import SwiftData

@main
struct LoopTimerApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TimerInstance.self,
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
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
