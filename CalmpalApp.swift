//
//  CalmpalApp.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  Main entry point for the iOS application.
//

import SwiftUI

@main
struct CalmpalApp: App {
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
    }
}
