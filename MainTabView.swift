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
    }
}

#Preview {
    MainTabView()
        .modelContainer(for: [GroundingSession.self, GAD7Assessment.self], inMemory: true)
}
