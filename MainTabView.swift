//
//  MainTabView.swift
//  Calmpal
//
//  Simplified root — shows GroundingScreenView full-screen.
//

import SwiftUI

public struct MainTabView: View {

    public init() {}

    public var body: some View {
        GroundingScreenView()
            .preferredColorScheme(.dark)
            .onAppear {
                AppReviewManager.shared.handleAppLaunch()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                AppReviewManager.shared.handleAppForeground()
            }
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [GroundingSession.self], inMemory: true)
}
