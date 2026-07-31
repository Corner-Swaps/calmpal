import XCTest
import SwiftData
@testable import Calmpal

final class CalmpalTests: XCTestCase {
    
    // MARK: - GAD-7 Assessment Score Severity Tests
    
    func testGAD7SeverityMinimal() {
        let assessment = GAD7Assessment(score: 3, notes: "Minimal tests")
        XCTAssertEqual(assessment.score, 3)
        XCTAssertEqual(assessment.severityDescription, "Minimal anxiety")
    }
    
    func testGAD7SeverityMild() {
        let assessment = GAD7Assessment(score: 7, notes: "Mild tests")
        XCTAssertEqual(assessment.score, 7)
        XCTAssertEqual(assessment.severityDescription, "Mild anxiety")
    }
    
    func testGAD7SeverityModerate() {
        let assessment = GAD7Assessment(score: 12, notes: "Moderate tests")
        XCTAssertEqual(assessment.score, 12)
        XCTAssertEqual(assessment.severityDescription, "Moderate anxiety")
    }
    
    func testGAD7SeveritySevere() {
        let assessment = GAD7Assessment(score: 18, notes: "Severe tests")
        XCTAssertEqual(assessment.score, 18)
        XCTAssertEqual(assessment.severityDescription, "Severe anxiety")
    }
    
    func testGAD7ScoreClamping() {
        let lowAssessment = GAD7Assessment(score: -5, notes: "Clamping negative")
        XCTAssertEqual(lowAssessment.score, 0)
        
        let highAssessment = GAD7Assessment(score: 30, notes: "Clamping high")
        XCTAssertEqual(highAssessment.score, 21)
    }
    
    // MARK: - SessionViewModel Transition Tests
    
    @MainActor
    func testSessionViewModelInitialState() {
        let viewModel = SessionViewModel()
        XCTAssertEqual(viewModel.currentState, .rest)
        XCTAssertFalse(viewModel.isActive)
        XCTAssertEqual(viewModel.progress, 0.0)
    }
    
    @MainActor
    func testSessionViewModelStartSession() {
        let viewModel = SessionViewModel()
        viewModel.startSession()
        
        XCTAssertTrue(viewModel.isActive)
        XCTAssertEqual(viewModel.currentState, .inhale)
        XCTAssertEqual(viewModel.progress, 0.0)
        
        viewModel.stopSession()
        XCTAssertFalse(viewModel.isActive)
    }
    
    @MainActor
    func testHapticManagerPhysicsSmoothing() {
        let manager = HapticManager.shared
        manager.forceReset()
        
        manager.start()
        manager.targetIntensity = 1.0
        manager.targetSharpness = 0.8
        
        XCTAssertEqual(manager.currentIntensity, 0.0)
        XCTAssertEqual(manager.currentSharpness, 0.0)
        
        manager.tick()
        XCTAssertEqual(manager.currentIntensity, 0.15, accuracy: 0.001)
        XCTAssertEqual(manager.currentSharpness, 0.12, accuracy: 0.001)
        
        manager.tick()
        XCTAssertEqual(manager.currentIntensity, 0.2775, accuracy: 0.001)
        
        manager.stop()
    }
    
    func testStringControlCharacterSanitization() {
        let sourceString = "Hello\u{0000}World\u{0003}Notes\nNewlines\rTabs\tAreAllowed"
        let sanitized = sourceString.filteringControlCharacters()
        
        XCTAssertEqual(sanitized, "HelloWorldNotes\nNewlines\rTabs\tAreAllowed")
    }
    
    // MARK: - AudioManager & Sound Profile Tests
    
    @MainActor
    func testAudioManagerSoundProfiles() {
        let audioManager = AudioManager.shared
        
        // Default profile should be Rain
        XCTAssertEqual(audioManager.activeProfile, .gentleRain)
        XCTAssertEqual(audioManager.activeProfile.shortName, "Rain")
        
        // Iterate over all 25 profiles and verify enum attributes
        for profile in SoundProfile.allCases {
            audioManager.activeProfile = profile
            XCTAssertEqual(audioManager.activeProfile, profile)
            XCTAssertFalse(profile.explanation.isEmpty)
            XCTAssertFalse(profile.id.isEmpty)
            XCTAssertFalse(profile.displayName.isEmpty)
            XCTAssertFalse(profile.resourceFileName.isEmpty)
            XCTAssertNil(profile.frequencyValue)
            
            // Verify single-word title (no spaces in rawValue)
            XCTAssertFalse(profile.rawValue.contains(" "), "Title '\(profile.rawValue)' should be a single word.")
            
            // Verify shortName category mapping
            switch profile {
            case .gentleRain, .rainOnWindow, .rainCanopy, .heavyRain, .rollingThunder:
                XCTAssertEqual(profile.shortName, "Rain")
            case .oceanWaves, .waterfall, .forestRiver, .waterDroplets, .coastalSeagulls:
                XCTAssertEqual(profile.shortName, "Ocean")
            case .forestBirdsong, .tropicalJungle, .nightCrickets, .eveningFrogs, .catPurring:
                XCTAssertEqual(profile.shortName, "Forest")
            case .windInTrees, .cozyCampfire, .duneBreeze, .howlingWind, .walkOnLeaves:
                XCTAssertEqual(profile.shortName, "Wind")
            case .warmCafe, .quietLibrary, .nightVillage, .templeSanctuary, .deepUnderwater:
                XCTAssertEqual(profile.shortName, "Ambient")
            }
        }
    }
    
    @MainActor
    func testHapticManagerImmersiveMode() {
        let hapticManager = HapticManager.shared
        hapticManager.isImmersiveModeActive = false
        XCTAssertFalse(hapticManager.isImmersiveModeActive)
        
        hapticManager.isImmersiveModeActive = true
        XCTAssertTrue(hapticManager.isImmersiveModeActive)
        
        hapticManager.isImmersiveModeActive = false
    }
    
    // MARK: - HapticManager Lifecycle & Reset Tests
    
    @MainActor
    func testHapticManagerForceReset() {
        let manager = HapticManager.shared
        manager.start()
        
        manager.targetIntensity = 0.8
        manager.targetSharpness = 0.5
        manager.tick()
        
        XCTAssertGreaterThan(manager.currentIntensity, 0.0)
        
        manager.forceReset()
        
        XCTAssertEqual(manager.targetIntensity, 0.0)
        XCTAssertEqual(manager.targetSharpness, 0.0)
        XCTAssertEqual(manager.currentIntensity, 0.0)
        XCTAssertEqual(manager.currentSharpness, 0.0)
    }
    
    // MARK: - String Filtering Boundary Tests
    
    func testStringControlCharactersComplex() {
        // Emojis, spaces, symbols, newlines, tabs, and hidden controls
        let input = "🧘‍♀️ Calmpal \u{0007} Haptics\t\n\u{001B} [Box Breathing]"
        let expected = "🧘‍♀️ Calmpal  Haptics\t\n [Box Breathing]"
        
        XCTAssertEqual(input.filteringControlCharacters(), expected)
    }
    
    func testStringControlCharacterPreservesComplexEmojiSequences() {
        let input = "Family: 👨‍👩‍👧‍👦 And Meditating: 🧘‍♀️"
        let sanitized = input.filteringControlCharacters()
        XCTAssertEqual(sanitized, input)
    }
}
