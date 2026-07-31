//
//  SessionViewModel.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  Structured breathwork state machine coordinating CoreHaptics waveforms.
//

import Foundation
import Observation
import SwiftData

/// The distinct phases of the breathing cycle.
public enum BreathState: String, CaseIterable, Identifiable {
    case inhale = "Inhale"
    case hold = "Hold"
    case exhale = "Exhale"
    case rest = "Rest"
    
    public var id: String { self.rawValue }
    
    /// User-facing descriptive instructions for each state.
    public var instruction: String {
        switch self {
        case .inhale:
            return "Breathe in slowly, feel the expanding tension"
        case .hold:
            return "Hold your breath, focus on the heartbeat"
        case .exhale:
            return "Let go, feel the wave fade away"
        case .rest:
            return "Rest and find your baseline center"
        }
    }
}

/// A ViewModel managing state transitions, durations, and haptic curve mappings
/// for the Apnea and Box Breathing protocols.
@Observable
@MainActor
public final class SessionViewModel {
    
    // MARK: - Observable States
    
    /// The active state of the breathing cycle.
    public private(set) var currentState: BreathState = .rest
    
    /// Value from 0.0 to 1.0 indicating completion of the active state.
    /// Used for smooth layout animations and visual sync.
    public private(set) var progress: Double = 0.0
    
    /// Time remaining in the current state in seconds.
    public private(set) var timeRemainingInState: TimeInterval = 0.0
    
    /// True if a breathwork session is currently active.
    public private(set) var isActive: Bool = false
    
    // MARK: - Configuration
    
    /// Duration of the inhale phase in seconds. Default is 4.0s.
    public var inhaleDuration: TimeInterval = 4.0
    
    /// Duration of the hold phase in seconds. Default is 5.0s (range: 4s-7s).
    public var holdDuration: TimeInterval = 5.0
    
    /// Duration of the exhale phase in seconds. Default is 7.0s (range: 6s-8s).
    public var exhaleDuration: TimeInterval = 7.0
    
    /// Duration of the rest phase in seconds. Default is 4.0s.
    public var restDuration: TimeInterval = 4.0
    
    // MARK: - Private Timing & Loop State
    
    private let timerWrapper = TimerWrapper()
    private let heartbeatTimerWrapper = TimerWrapper()
    private var elapsedInState: TimeInterval = 0.0
    private var sessionStartDate: Date = Date()
    
    // MARK: - Initialization
    
    public init() {}
    
    deinit {
        timerWrapper.invalidate()
        heartbeatTimerWrapper.invalidate()
    }
    
    // MARK: - Session Control
    
    /// Starts the breathwork session, activates haptic engine and schedules tickers.
    public func startSession() {
        guard !isActive else { return }
        
        isActive = true
        currentState = .inhale
        elapsedInState = 0.0
        timeRemainingInState = inhaleDuration
        progress = 0.0
        sessionStartDate = Date()
        
        // Ensure haptic manager is started
        HapticManager.shared.start()
        
        // Instantly apply haptics for the initial frame
        applyStateHaptics()
        
        startTimer()
        print("[SessionViewModel] Breathwork session started.")
    }
    
    /// Stops the breathwork session, stops haptic engine, invalidates tickers, and logs the session.
    public func stopSession(modelContext: ModelContext? = nil) {
        guard isActive else { return }
        
        let sessionDuration = Date().timeIntervalSince(sessionStartDate)
        
        stopTimer()
        stopHeartbeatTimer()
        
        HapticManager.shared.stop()
        
        // Log grounding session if it was active for a substantial period (> 3 seconds)
        if let context = modelContext, sessionDuration > 3.0 {
            let loggedSession = GroundingSession(
                duration: sessionDuration,
                protocolType: "Box Breath (\(AudioManager.shared.activeProfile.shortName))",
                averagePressure: 0.25 // Apnea hold has a baseline ambient intensity
            )
            context.insert(loggedSession)
            do {
                try context.save()
                print("[SessionViewModel] Breathed for \(sessionDuration)s. Saved GroundingSession.")
            } catch {
                print("[SessionViewModel] Error saving GroundingSession: \(error.localizedDescription)")
            }
        }
        
        isActive = false
        currentState = .rest
        progress = 0.0
        timeRemainingInState = 0.0
        elapsedInState = 0.0
        
        print("[SessionViewModel] Breathwork session stopped.")
    }
    
    // MARK: - Timing & State Transitions
    
    private func startTimer() {
        timerWrapper.invalidate()
        // Highly efficient 10Hz frequency (0.1s steps) to update numeric timers.
        // Haptic smoothing at 60Hz and SwiftUI rendering handle fluidity.
        let t = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.tick()
            }
        }
        timerWrapper.set(t)
    }
    
    private func stopTimer() {
        timerWrapper.invalidate()
    }
    
    private func tick() {
        guard isActive else { return }
        
        elapsedInState += 0.1
        let totalDuration = currentDuration
        
        if elapsedInState >= totalDuration {
            transitionToNextState()
        } else {
            progress = min(1.0, max(0.0, elapsedInState / totalDuration))
            timeRemainingInState = max(0.0, totalDuration - elapsedInState)
            applyStateHaptics()
        }
    }
    
    private var currentDuration: TimeInterval {
        switch currentState {
        case .inhale: return inhaleDuration
        case .hold: return holdDuration
        case .exhale: return exhaleDuration
        case .rest: return restDuration
        }
    }
    
    private func transitionToNextState() {
        elapsedInState = 0.0
        progress = 0.0
        
        // Clean up previous state resources
        if currentState == .hold {
            stopHeartbeatTimer()
        }
        
        // Select next state in circular fashion
        switch currentState {
        case .inhale:
            currentState = .hold
            timeRemainingInState = holdDuration
            startHeartbeatTimer()
        case .hold:
            currentState = .exhale
            timeRemainingInState = exhaleDuration
        case .exhale:
            currentState = .rest
            timeRemainingInState = restDuration
        case .rest:
            currentState = .inhale
            timeRemainingInState = inhaleDuration
        }
        
        applyStateHaptics()
        print("[SessionViewModel] Transitioned to \(currentState.rawValue)")
    }
    
    // MARK: - Haptic Parameter Mapping
    
    /// Formulates and updates the target haptic values based on the active breath state and progress.
    private func applyStateHaptics() {
        switch currentState {
        case .inhale:
            // Linear ramp up of sharpness from 0.1 to 0.85 to simulate rising tension
            HapticManager.shared.targetSharpness = Float(0.1 + (progress * 0.75))
            // Moderate intensity ramping up slightly to feel full, but not overwhelming
            HapticManager.shared.targetIntensity = Float(0.3 + (progress * 0.35))
            
        case .hold:
            // Drop sharpness immediately to a soft organic baseline hum
            HapticManager.shared.targetSharpness = 0.05
            // Keep continuous pattern at a quiet rumble so the transient heartbeat dominates
            HapticManager.shared.targetIntensity = 0.15
            
        case .exhale:
            // Smoothly fade haptic intensity and sharpness to zero, creating a receding wave feel
            HapticManager.shared.targetIntensity = Float(0.8 * (1.0 - progress))
            HapticManager.shared.targetSharpness = Float(0.4 * (1.0 - progress))
            
        case .rest:
            // Rest phase is silent, letting the user center themselves
            HapticManager.shared.targetIntensity = 0.0
            HapticManager.shared.targetSharpness = 0.0
        }
    }
    
    // MARK: - Heartbeat Emulation (Hold Phase)
    
    private func startHeartbeatTimer() {
        stopHeartbeatTimer()
        
        // Play the first double-pulse transient heartbeat immediately on transition
        triggerHeartbeat()
        
        // Schedule subsequent heartbeats at exactly 60 BPM (every 1.0 second)
        let t = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.triggerHeartbeat()
            }
        }
        heartbeatTimerWrapper.set(t)
    }
    
    private func stopHeartbeatTimer() {
        heartbeatTimerWrapper.invalidate()
    }
    
    private func triggerHeartbeat() {
        guard currentState == .hold && isActive else { return }
        // High intensity, soft sharpness heartbeat transient pulse
        HapticManager.shared.playTransientHeartbeat(intensity: 0.85, sharpness: 0.3)
    }
}
