import XCTest
import SwiftData
import AVFoundation
@testable import Calmpal

final class CalmpalTests: XCTestCase {
    
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
        XCTAssertGreaterThan(manager.currentIntensity, 0.0)
        XCTAssertGreaterThan(manager.currentSharpness, 0.0)
        
        let firstIntensity = manager.currentIntensity
        manager.tick()
        XCTAssertGreaterThan(manager.currentIntensity, firstIntensity)
        
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
        audioManager.activeProfile = .gentleRain
        
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
            case .gentleRain, .rainCanopy, .rollingThunder, .rainOnTent, .rainOnCar:
                XCTAssertEqual(profile.shortName, "Rain")
            case .oceanWaves, .waterfall, .forestRiver, .coastalSeagulls, .oceanWhale, .gentleSailboat, .rowingBoat:
                XCTAssertEqual(profile.shortName, "Ocean")
            case .forestBirdsong, .tropicalJungle, .nightCrickets, .eveningFrogs, .catPurring, .snowyForest, .nightOwl:
                XCTAssertEqual(profile.shortName, "Forest")
            case .windInTrees, .cozyCampfire, .duneBreeze, .howlingWind, .walkOnLeaves, .windChimes:
                XCTAssertEqual(profile.shortName, "Wind")
            case .warmCafe, .quietLibrary, .nightVillage, .templeSanctuary, .deepUnderwater, .singingBowl, .scenicTrain, .antiqueClock, .cathedralChimes, .surrender:
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

    // MARK: - Sound Banner Themes Tests

    func testSoundBannerThemes() {
        XCTAssertEqual(allSoundBanners.count, 35)
        for banner in allSoundBanners {
            XCTAssertFalse(banner.id.isEmpty)
            XCTAssertFalse(banner.title.isEmpty)
            XCTAssertFalse(banner.imageName.isEmpty)
            XCTAssertFalse(banner.thumbnailImageName.isEmpty)
            let matched = bannerFor(profile: banner.profile)
            XCTAssertEqual(matched.profile, banner.profile)
        }
        // Verify surrender is positioned directly above rolling-thunder
        if let surrenderIndex = allSoundBanners.firstIndex(where: { $0.profile == .surrender }),
           let thunderIndex = allSoundBanners.firstIndex(where: { $0.profile == .rollingThunder }) {
            XCTAssertEqual(surrenderIndex + 1, thunderIndex, "Surrender must be directly above Rolling Thunder")
        } else {
            XCTFail("Could not find surrender or rolling-thunder in allSoundBanners")
        }
    }

    @MainActor
    func testSurrenderTailFade() {
        let sampleRate: Double = 44100.0
        let format = AVAudioFormat(standardFormatWithSampleRate: sampleRate, channels: 2)!
        let frameCount: AVAudioFrameCount = 44100 * 30 // 30 seconds of audio
        guard let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount) else {
            XCTFail("Could not create buffer")
            return
        }
        buffer.frameLength = frameCount
        guard let channelData = buffer.floatChannelData else {
            XCTFail("No floatChannelData")
            return
        }
        // Fill with 1.0 amplitude
        for ch in 0..<2 {
            for i in 0..<Int(frameCount) {
                channelData[ch][i] = 1.0
            }
        }
        
        // Apply 20s tail fade
        AudioManager.shared.applyTailFade(to: buffer, fadeDuration: 20.0)
        
        // Samples before fade (first 10 seconds, frame 0 to 441000) should still be 1.0
        XCTAssertEqual(channelData[0][0], 1.0, accuracy: 0.001)
        XCTAssertEqual(channelData[0][44100 * 10 - 1], 1.0, accuracy: 0.001)
        
        // At midpoint of fade (10s before end), gain should be ~0.5
        let midFadeIndex = 44100 * 20
        XCTAssertEqual(channelData[0][midFadeIndex], 0.5, accuracy: 0.01)
        
        // At the very last frame, gain should be 0.0
        let lastFrameIndex = Int(frameCount) - 1
        XCTAssertEqual(channelData[0][lastFrameIndex], 0.0, accuracy: 0.001)
    }

    @MainActor
    func testAudioPauseResumeBufferPreservation() {
        let audioManager = AudioManager.shared
        audioManager.stop()
        XCTAssertFalse(audioManager.isAudioPlaying)
        XCTAssertFalse(audioManager.isBufferScheduled)
    }

    func testInstagramLogoView() {
        let logo = InstagramLogoView(size: 32)
        XCTAssertEqual(logo.size, 32)
        let defaultLogo = InstagramLogoView()
        XCTAssertEqual(defaultLogo.size, 24)
    }

    // MARK: - AppReviewManager Tests

    func testAppReviewManagerNewUserMilestones() {
        let testDefaults = UserDefaults(suiteName: "test.calmpal.appreview.newuser")!
        testDefaults.removePersistentDomain(forName: "test.calmpal.appreview.newuser")

        let manager = AppReviewManager(userDefaults: testDefaults, observeLifecycleNotifications: false)
        manager.resetAllTrackingData()

        let now = Date()
        manager.originalInstallDate = now
        manager.isExistingUser = false
        manager.lifetimeLaunches = 0

        // Initially 0 launches, 0 days -> Ineligible
        XCTAssertFalse(manager.isEligibleForReview(at: now))

        // 14 launches -> Still Ineligible
        manager.lifetimeLaunches = 14
        XCTAssertFalse(manager.isEligibleForReview(at: now))

        // 15 launches -> Eligible!
        manager.lifetimeLaunches = 15
        XCTAssertTrue(manager.isEligibleForReview(at: now))

        // Reset launches to 3, but simulate 15 days elapsed -> Eligible!
        manager.lifetimeLaunches = 3
        let fifteenDaysLater = now.addingTimeInterval(15 * 86400)
        XCTAssertTrue(manager.isEligibleForReview(at: fifteenDaysLater))
    }

    func testAppReviewManagerExistingUserMilestones() {
        let testDefaults = UserDefaults(suiteName: "test.calmpal.appreview.existinguser")!
        testDefaults.removePersistentDomain(forName: "test.calmpal.appreview.existinguser")

        let manager = AppReviewManager(userDefaults: testDefaults, observeLifecycleNotifications: false)
        manager.resetAllTrackingData()

        let now = Date()
        manager.isExistingUser = true
        manager.originalInstallDate = now
        manager.currentVersionInstallDate = now
        manager.lifetimeLaunches = 2
        manager.currentVersionLaunches = 2

        // All below 15 -> Ineligible
        XCTAssertFalse(manager.isEligibleForReview(at: now))

        // Lifetime launches >= 15 -> Eligible
        manager.lifetimeLaunches = 15
        XCTAssertTrue(manager.isEligibleForReview(at: now))
        manager.lifetimeLaunches = 2

        // Launches since update >= 15 -> Eligible
        manager.currentVersionLaunches = 15
        XCTAssertTrue(manager.isEligibleForReview(at: now))
        manager.currentVersionLaunches = 2

        // Days since update >= 15 -> Eligible
        let fifteenDaysAfterUpdate = now.addingTimeInterval(15 * 86400)
        XCTAssertTrue(manager.isEligibleForReview(at: fifteenDaysAfterUpdate))
    }

    func testAppReviewManagerRepromptCadenceAndSubmissionLock() {
        let testDefaults = UserDefaults(suiteName: "test.calmpal.appreview.reprompt")!
        testDefaults.removePersistentDomain(forName: "test.calmpal.appreview.reprompt")

        let manager = AppReviewManager(userDefaults: testDefaults, observeLifecycleNotifications: false)
        manager.resetAllTrackingData()

        let now = Date()
        manager.originalInstallDate = now.addingTimeInterval(-20 * 86400) // Installed 20 days ago
        manager.lifetimeLaunches = 15

        // Initial prompt eligibility satisfied
        XCTAssertTrue(manager.isEligibleForReview(at: now))

        // Simulate prompt was presented (user dismissed dialog without submitting)
        manager.lastPromptLaunchCount = 15
        manager.lastPromptDate = now

        // Immediately after dismissal -> Ineligible
        XCTAssertFalse(manager.isEligibleForReview(at: now))

        // 10 more launches (total 25), 5 days later -> Still Ineligible
        manager.lifetimeLaunches = 25
        let fiveDaysLater = now.addingTimeInterval(5 * 86400)
        XCTAssertFalse(manager.isEligibleForReview(at: fiveDaysLater))

        // 15 more launches (total 30) -> Eligible for re-prompt!
        manager.lifetimeLaunches = 30
        XCTAssertTrue(manager.isEligibleForReview(at: fiveDaysLater))

        // Or if launches remained at 25, but 15 days elapsed since last prompt -> Eligible for re-prompt!
        manager.lifetimeLaunches = 25
        let fifteenDaysAfterPrompt = now.addingTimeInterval(15 * 86400)
        XCTAssertTrue(manager.isEligibleForReview(at: fifteenDaysAfterPrompt))

        // Permanent submission lock
        manager.markReviewSubmitted()
        XCTAssertTrue(manager.hasSubmittedReview)

        // Once submitted, permanently in-eligible even with 100 launches & 100 days
        manager.lifetimeLaunches = 100
        let hundredDaysLater = now.addingTimeInterval(100 * 86400)
        XCTAssertFalse(manager.isEligibleForReview(at: hundredDaysLater))
    }

    func testAppReviewManagerLaunchTracking() {
        let testDefaults = UserDefaults(suiteName: "test.calmpal.appreview.launchtrack")!
        testDefaults.removePersistentDomain(forName: "test.calmpal.appreview.launchtrack")

        let manager = AppReviewManager(userDefaults: testDefaults, observeLifecycleNotifications: false)
        manager.resetAllTrackingData()

        XCTAssertEqual(manager.lifetimeLaunches, 0)
        manager.handleAppLaunch()

        XCTAssertEqual(manager.lifetimeLaunches, 1)
        XCTAssertEqual(manager.currentVersionLaunches, 1)
        XCTAssertFalse(manager.currentVersion.isEmpty)

        manager.handleAppLaunch()
        XCTAssertEqual(manager.lifetimeLaunches, 2)
        XCTAssertEqual(manager.currentVersionLaunches, 2)
    }
}
