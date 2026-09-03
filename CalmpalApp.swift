//
//  CalmpalApp.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  Main entry point for the iOS application.
//

import SwiftUI
import SwiftData

@main
struct CalmpalApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            GroundingSession.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("[CalmpalApp] SwiftData disk store error, using in-memory fallback: \(error)")
            let inMemoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
            if let container = try? ModelContainer(for: schema, configurations: [inMemoryConfig]) {
                return container
            }
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    init() {
        // Pre-warm sound thumbnail assets in background memory for instant, buttery-smooth scrolling
        DispatchQueue.global(qos: .userInitiated).async {
            for banner in allSoundBanners {
                _ = UIImage(named: banner.thumbnailImageName)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}
