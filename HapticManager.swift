//
//  HapticManager.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  Core Haptics Specialist implementation with 60Hz physical filtering.
//

import CoreHaptics
#if canImport(UIKit)
import UIKit
#endif
import Observation
import QuartzCore

/// A singleton manager responsible for initializing the system's Taptic Engine,
/// verifying hardware capability, maintaining a continuous tactile background hum,
/// and filtering high-frequency input touch events to exactly 60Hz.
@Observable
@MainActor
public final class HapticManager: NSObject {
    
    // MARK: - Singleton
    
    /// The shared instance for app-wide access.
    public static let shared = HapticManager()
    
    // MARK: - Observable States
    
    /// True if the physical hardware supports CoreHaptics.
    /// If false, the UI should render visual-only feedback.
    public private(set) var isHardwareSupported: Bool = false
    
    /// True if the haptic engine has successfully started.
    public private(set) var isEngineRunning: Bool = false
    
    /// The smoothed, low-pass filtered intensity value currently sent to the Taptic Engine.
    /// Range: `0.0` (silent) to `1.0` (maximum vibration intensity).
    public private(set) var currentIntensity: Float = 0.0
    
    /// The smoothed, low-pass filtered sharpness value currently sent to the Taptic Engine.
    /// Range: `0.0` (dull, organic hum) to `1.0` (crisp, metallic click).
    public private(set) var currentSharpness: Float = 0.0
    
    /// True if the user has activated fullscreen immersive mode.
    public var isImmersiveModeActive: Bool = false
    
    // MARK: - Dynamic Input Targets
    
    /// The raw target intensity representing immediate touch force/pressure.
    /// This property can be updated rapidly by touch gestures or breath states.
    public var targetIntensity: Float = 0.0
    
    /// The raw target sharpness representing immediate touch radius or breath phase.
    /// This property can be updated rapidly by touch gestures or breath states.
    public var targetSharpness: Float = 0.0
    
    // MARK: - Private State & Engine Components
    
    private var engine: CHHapticEngine?
    private var player: CHHapticPatternPlayer?
    private let displayLinkWrapper = DisplayLinkWrapper()
    private var displayLinkProxy: DisplayLinkProxy?
    private var wasEngineRunningBeforeBackground = false
    
    /// Exponential smoothing factor.
    /// `0.15` offers a heavy, fluid, liquid tactile feel.
    private let alpha: Float = 0.15
    
    /// The persistent smoothed state variables for the low-pass filter.
    private var smoothedIntensity: Float = 0.0
    private var smoothedSharpness: Float = 0.0
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        checkHardwareSupport()
        if isHardwareSupported {
            setupHapticEngine()
            setupDisplayLink()
            registerLifecycleNotifications()
        } else {
            print("[HapticManager] CoreHaptics is not supported on this hardware.")
        }
    }
    
    deinit {
        // Since CADisplayLink holds a strong reference to its target,
        // we invalidate it to avoid memory leaks.
        displayLinkWrapper.invalidate()
    }
    
    private func registerLifecycleNotifications() {
        #if canImport(UIKit)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appDidEnterBackground),
            name: UIApplication.didEnterBackgroundNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appWillEnterForeground),
            name: UIApplication.willEnterForegroundNotification,
            object: nil
        )
        #endif
    }
    
    @objc private func appDidEnterBackground() {
        wasEngineRunningBeforeBackground = isEngineRunning
        if isEngineRunning {
            print("[HapticManager] App backgrounded. Pausing haptic engine and physics ticker.")
            displayLinkWrapper.value?.isPaused = true
            if isHardwareSupported {
                do {
                    try player?.stop(atTime: CHHapticTimeImmediate)
                    engine?.stop()
                } catch {
                    print("[HapticManager] Error stopping engine on background: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @objc private func appWillEnterForeground() {
        if wasEngineRunningBeforeBackground {
            print("[HapticManager] App returned to foreground. Resuming haptic engine and physics ticker.")
            if isHardwareSupported {
                do {
                    try engine?.start()
                    try rebuildContinuousPlayer()
                } catch {
                    print("[HapticManager] Error restarting engine on foreground: \(error.localizedDescription)")
                }
            }
            displayLinkWrapper.value?.isPaused = false
        }
    }
    
    // MARK: - Hardware Verification
    
    private func checkHardwareSupport() {
        let capabilities = CHHapticEngine.capabilitiesForHardware()
        self.isHardwareSupported = capabilities.supportsHaptics
    }
    
    // MARK: - Engine Lifecycle & Resiliency
    
    private func setupHapticEngine() {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTestCase") != nil {
            return
        }
        var attempts = 0
        let maxAttempts = 3
        
        while attempts < maxAttempts {
            do {
                let hapticEngine = try CHHapticEngine()
                
                // Handle cases where the audio/haptic subsystem is stopped by the OS
                // (e.g., incoming call, alarm, Siri, or lock screen change).
                hapticEngine.stoppedHandler = { [weak self] reason in
                    print("[HapticManager] Engine stopped by system. Reason: \(reason.rawValue)")
                    Task { @MainActor [weak self] in
                        self?.isEngineRunning = false
                    }
                }
                
                // Handle recovering from a system-level haptic server crash or reset.
                hapticEngine.resetHandler = { [weak self] in
                    print("[HapticManager] Haptic server reset requested. Rebuilding session...")
                    Task { @MainActor [weak self] in
                        guard let self = self else { return }
                        do {
                            try self.engine?.start()
                            self.isEngineRunning = true
                            try self.rebuildContinuousPlayer()
                            print("[HapticManager] Successfully restarted haptic engine after reset.")
                        } catch {
                            print("[HapticManager] Failed to restart haptic engine: \(error)")
                        }
                    }
                }
                
                self.engine = hapticEngine
                print("[HapticManager] Haptic engine instantiated successfully on attempt \(attempts + 1).")
                return
            } catch {
                attempts += 1
                print("[HapticManager] Failed to instantiate haptic engine on attempt \(attempts): \(error.localizedDescription)")
                if attempts >= maxAttempts {
                    print("[HapticManager] Max initialization attempts reached. Haptic engine unavailable.")
                }
            }
        }
    }
    
    // MARK: - Public Control Interface
    
    /// Starts the haptic engine, spins up the continuous pattern player,
    /// starts background ambient audio, and unpauses the 60Hz physics update loop.
    public func start() {
        guard !isEngineRunning else { return }
        
        // Start background ambient audio to maintain lifecycle
        AudioManager.shared.start()
        
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTestCase") != nil {
            isEngineRunning = true
            return
        }
        
        if isHardwareSupported {
            do {
                try engine?.start()
                try rebuildContinuousPlayer()
                print("[HapticManager] Physical engine started, continuous player active.")
            } catch {
                print("[HapticManager] Error starting haptic engine: \(error)")
            }
        } else {
            print("[HapticManager] CoreHaptics unsupported. Running in visual-only smoothing mode.")
        }
        
        isEngineRunning = true
        displayLinkWrapper.value?.isPaused = false
    }
    
    /// Stops the haptic engine, pauses the 60Hz physics update loop, and stops audio.
    public func stop() {
        guard isEngineRunning else { return }
        
        displayLinkWrapper.value?.isPaused = true
        
        // Stop background ambient audio
        AudioManager.shared.stop()
        
        if isHardwareSupported {
            do {
                try player?.stop(atTime: CHHapticTimeImmediate)
                engine?.stop()
            } catch {
                print("[HapticManager] Error stopping haptic engine: \(error)")
            }
        }
        
        isEngineRunning = false
        print("[HapticManager] Engine stopped.")
    }
    
    /// Safety force reset to recover from any corrupted hardware or timer states.
    public func forceReset() {
        print("[HapticManager] Force resetting haptic engine and audio states...")
        stop()
        targetIntensity = 0.0
        targetSharpness = 0.0
        smoothedIntensity = 0.0
        smoothedSharpness = 0.0
        currentIntensity = 0.0
        currentSharpness = 0.0
        setupHapticEngine()
    }
    
    // MARK: - Continuous Pattern Construction
    
    /// Prepares and runs a continuous haptic hum pattern.
    /// This acts as the physical canvas onto which touch-derived parameters are mapped.
    private func rebuildContinuousPlayer() throws {
        guard let engine = engine else {
            throw CHHapticError(.engineNotRunning)
        }
        
        // Define standard default parameters for continuous tactile feedback
        let intensityParam = CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0)
        let sharpnessParam = CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
        
        // Setup the continuous tactile event with a very long duration (1 hour)
        let continuousEvent = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [intensityParam, sharpnessParam],
            relativeTime: 0.0,
            duration: 3600.0
        )
        
        let pattern = try CHHapticPattern(events: [continuousEvent], parameters: [])
        let continuousPlayer = try engine.makePlayer(with: pattern)
        
        try continuousPlayer.start(atTime: CHHapticTimeImmediate)
        self.player = continuousPlayer
    }
    
    // MARK: - Physics & Throttling Loop (60Hz)
    
    private func setupDisplayLink() {
        #if os(iOS)
        // Instantiate a proxy to avoid a strong retain cycle on 'self'
        let proxy = DisplayLinkProxy(target: self)
        self.displayLinkProxy = proxy
        
        let link = CADisplayLink(target: proxy, selector: #selector(DisplayLinkProxy.tick))
        
        // Clamp updates to exactly 60Hz (helps dynamic refresh rate displays like ProMotion)
        link.preferredFrameRateRange = CAFrameRateRange(minimum: 60, maximum: 60, preferred: 60)
        
        // Add to main run loop
        link.add(to: .main, forMode: .common)
        link.isPaused = true
        
        self.displayLinkWrapper.set(link)
        #endif
    }
    
    /// Invoked at 60Hz by the CADisplayLink.
    /// Performs the low-pass math filter on input target values and pushes them to the Taptic Engine.
    internal func tick() {
        guard isEngineRunning else { return }
        
        // 1. Exponential Smoothing Math Formula:
        // smoothedValue = (alpha * rawValue) + ((1 - alpha) * previousValue)
        smoothedIntensity = (alpha * targetIntensity) + ((1.0 - alpha) * smoothedIntensity)
        smoothedSharpness = (alpha * targetSharpness) + ((1.0 - alpha) * smoothedSharpness)
        
        // Clamp parameters to the strict physical boundaries [0.0...1.0] of CoreHaptics
        let finalIntensity = max(0.0, min(1.0, smoothedIntensity))
        let finalSharpness = max(0.0, min(1.0, smoothedSharpness))
        
        // Update observed outputs for SwiftUI view sync
        self.currentIntensity = finalIntensity
        self.currentSharpness = finalSharpness
        
        // 2. Stream dynamic parameters to the pattern player
        if isHardwareSupported && player != nil {
            updateDynamicParameters(intensity: finalIntensity, sharpness: finalSharpness)
        }
    }
    
    private func updateDynamicParameters(intensity: Float, sharpness: Float) {
        guard let player = player else { return }
        
        let intensityControl = CHHapticDynamicParameter(
            parameterID: .hapticIntensityControl,
            value: intensity,
            relativeTime: 0.0
        )
        
        let sharpnessControl = CHHapticDynamicParameter(
            parameterID: .hapticSharpnessControl,
            value: sharpness,
            relativeTime: 0.0
        )
        
        do {
            try player.sendParameters([intensityControl, sharpnessControl], atTime: CHHapticTimeImmediate)
        } catch {
            print("[HapticManager] Error sending dynamic parameters to player: \(error)")
        }
    }
    
    /// Triggers a double-beat transient haptic pulse (lub-dub) on top of the continuous background hum.
    /// Used for matching breath hold heartbeat intervals.
    public func playTransientHeartbeat(intensity: Float, sharpness: Float) {
        guard isHardwareSupported, isEngineRunning, let engine = engine else { return }
        
        do {
            let lubIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity)
            let lubSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness)
            let lub = CHHapticEvent(eventType: .hapticTransient, parameters: [lubIntensity, lubSharpness], relativeTime: 0.0)
            
            let dubIntensity = CHHapticEventParameter(parameterID: .hapticIntensity, value: intensity * 0.7)
            let dubSharpness = CHHapticEventParameter(parameterID: .hapticSharpness, value: sharpness * 0.8)
            let dub = CHHapticEvent(eventType: .hapticTransient, parameters: [dubIntensity, dubSharpness], relativeTime: 0.15)
            
            let pattern = try CHHapticPattern(events: [lub, dub], parameters: [])
            let heartbeatPlayer = try engine.makePlayer(with: pattern)
            try heartbeatPlayer.start(atTime: CHHapticTimeImmediate)
        } catch {
            print("[HapticManager] Error playing transient heartbeat pulse: \(error.localizedDescription)")
        }
    }
}

// MARK: - DisplayLinkProxy

/// Helper proxy class to prevent retain cycle between CADisplayLink and `@MainActor` HapticManager.
@MainActor
fileprivate final class DisplayLinkProxy: NSObject {
    private weak var target: HapticManager?
    
    init(target: HapticManager) {
        self.target = target
        super.init()
    }
    
    @objc func tick() {
        target?.tick()
    }
}
