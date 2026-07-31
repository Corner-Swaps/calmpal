//
//  TactileTestView.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  Minimalist SwiftUI surface test panel visualizing raw/filtered haptic parameters.
//

import SwiftUI
import Observation
import SwiftData

/// A coordinator class that receives touch data from the TactileSurfaceView,
/// handles normalization with fallback logic, and streams it to the HapticManager.
@Observable
@MainActor
public final class TestCoordinator: TactileSurfaceDelegate {
    
    // MARK: - SwiftData Context Reference
    
    /// Optional reference to model context to persist logged sessions.
    public var modelContext: ModelContext?
    
    // MARK: - Properties
    
    /// The current raw force of the active touch.
    public private(set) var rawForce: CGFloat = 0.0
    
    /// The maximum possible force supported by the screen.
    public private(set) var rawMaxForce: CGFloat = 0.0
    
    /// The physical radius of the touch area in points.
    public private(set) var rawRadius: CGFloat = 0.0
    
    /// The location of the touch in the view coordinate system.
    public private(set) var touchLocation: CGPoint = .zero
    
    /// True if a touch is currently active on the surface.
    public private(set) var isTouching: Bool = false
    
    // MARK: - Local Stats tracking for Database Logs
    
    private var touchStartDate: Date?
    private var pressureSum: Float = 0.0
    private var pressureSamplesCount: Int = 0
    
    public init() {}
    
    public func tactileSurfaceDidUpdate(force: CGFloat, maxForce: CGFloat, radius: CGFloat, location: CGPoint) {
        // Track the session start timestamp when a touch begins
        if !isTouching {
            touchStartDate = Date()
            pressureSum = 0.0
            pressureSamplesCount = 0
        }
        
        self.rawForce = force
        self.rawMaxForce = maxForce
        self.rawRadius = radius
        self.touchLocation = location
        self.isTouching = true
        
        // Normalize touch force to 0.0...1.0
        let intensity: Float
        if maxForce > 0 {
            intensity = Float(force / maxForce)
        } else {
            // Fallback for non-3D Touch screens (e.g. Haptic Touch):
            // Map typical major radius (10.0 to 60.0 points) to intensity range (0.0 to 1.0)
            let minR: CGFloat = 10.0
            let maxR: CGFloat = 60.0
            let clampedR = max(minR, min(maxR, radius))
            intensity = Float((clampedR - minR) / (maxR - minR))
        }
        
        // Normalize major radius to 0.0...1.0 for haptic sharpness
        let minR: CGFloat = 10.0
        let maxR: CGFloat = 60.0
        let clampedR = max(minR, min(maxR, radius))
        let sharpness = Float((clampedR - minR) / (maxR - minR))
        
        // Track stats for database logs
        pressureSum += intensity
        pressureSamplesCount += 1
        
        // Push target parameters to the physics engine for 60Hz filtering
        HapticManager.shared.targetIntensity = intensity
        HapticManager.shared.targetSharpness = sharpness
    }
    
    public func tactileSurfaceDidEnd() {
        // If the session was active for a substantial period (> 3 seconds), log it in SwiftData
        if isTouching, let startDate = touchStartDate {
            let sessionDuration = Date().timeIntervalSince(startDate)
            if let context = modelContext, sessionDuration > 3.0 {
                let avgPressure = pressureSamplesCount > 0 ? (pressureSum / Float(pressureSamplesCount)) : 0.0
                
                let session = GroundingSession(
                    duration: sessionDuration,
                    protocolType: "Free Touch (\(AudioManager.shared.activeProfile.shortName))",
                    averagePressure: avgPressure
                )
                context.insert(session)
                try? context.save()
                print("[TestCoordinator] Grounding session saved. Duration: \(sessionDuration)s. Avg Pressure: \(avgPressure)")
            }
        }
        
        self.rawForce = 0.0
        self.rawMaxForce = 0.0
        self.rawRadius = 0.0
        self.touchLocation = .zero
        self.isTouching = false
        
        // Gracefully reset target variables to 0
        HapticManager.shared.targetIntensity = 0.0
        HapticManager.shared.targetSharpness = 0.0
    }
}

/// A test panel interface for evaluating the haptic filtering system.
public struct TactileTestView: View {
    
    /// Local coordinator state managing touch translation.
    @State private var coordinator = TestCoordinator()
    
    /// Access shared haptic manager instance to display filtered parameters.
    private var hapticManager = HapticManager.shared
    
    public init() {}
    
    public var body: some View {
        ZStack {
            // Dark ocean slate canvas background
            Color.backgroundDark
                .ignoresSafeArea()
            
            // Full-screen touch tracking surface
            TactileSurfaceView(delegate: coordinator)
                .ignoresSafeArea()
            
            // Bioluminescent glow circle reacting to haptic parameters
            if coordinator.isTouching {
                Circle()
                    .fill(Color.hapticGlow.opacity(Double(hapticManager.currentIntensity) * 0.5 + 0.15))
                    .frame(
                        width: CGFloat(hapticManager.currentSharpness * 260.0 + 80.0),
                        height: CGFloat(hapticManager.currentSharpness * 260.0 + 80.0)
                    )
                    .blur(radius: 35)
                    .transition(.opacity)
            }
            
            // Metrics and controller overlays
            VStack(spacing: 24) {
                // Header block
                VStack(spacing: 6) {
                    Text("Calmpal")
                        .font(.system(.largeTitle, design: .default, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Tactile Surface Test Panel")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.top, 40)
                
                Spacer()
                
                // Real-time telemetry monitoring panel
                VStack(spacing: 16) {
                    Text(coordinator.isTouching ? "TOUCH ACTIVE" : "TOUCH CANVAS")
                        .font(.system(.subheadline, design: .rounded, weight: .bold))
                        .foregroundColor(coordinator.isTouching ? .hapticGlow : .white.opacity(0.3))
                    
                    VStack(alignment: .leading, spacing: 10) {
                        MetricRow(label: "Raw Force", value: String(format: "%.2f", coordinator.rawForce))
                        MetricRow(label: "Max Force", value: String(format: "%.2f", coordinator.rawMaxForce))
                        MetricRow(label: "Touch Radius", value: String(format: "%.1f pt", coordinator.rawRadius))
                        
                        Divider()
                            .background(Color.white.opacity(0.15))
                            .padding(.vertical, 4)
                        
                        MetricRow(label: "Filtered Intensity", value: String(format: "%.3f", hapticManager.currentIntensity), isHighlighted: true)
                        MetricRow(label: "Filtered Sharpness", value: String(format: "%.3f", hapticManager.currentSharpness), isHighlighted: true)
                    }
                    .padding(20)
                    .background(.ultraThinMaterial)
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.15), lineWidth: 1)
                    )
                }
                .frame(maxWidth: 320)
                .animation(.spring(response: 0.3, dampingFraction: 0.8), value: coordinator.isTouching)
                
                Spacer()
                
                // Engine start/stop action controller
                VStack(spacing: 16) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(hapticManager.isEngineRunning ? Color.accentHold : Color.accentRelease)
                            .frame(width: 8, height: 8)
                        
                        Text(hapticManager.isEngineRunning ? "Haptic Engine Active" : "Haptic Engine Stopped")
                            .font(.system(.footnote, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Button(action: {
                        if hapticManager.isEngineRunning {
                            hapticManager.stop()
                        } else {
                            hapticManager.start()
                        }
                    }) {
                        Text(hapticManager.isEngineRunning ? "Stop Haptic Loop" : "Start Haptic Loop")
                            .font(.system(.callout, design: .rounded, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 36)
                            .padding(.vertical, 14)
                            .background(hapticManager.isEngineRunning ? Color.accentRelease : Color.hapticGlow)
                            .cornerRadius(28)
                            .shadow(color: (hapticManager.isEngineRunning ? Color.accentRelease : Color.hapticGlow).opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                }
                .padding(.bottom, 50)
            }
            .padding(.horizontal, 24)
        }
    }
}

// MARK: - Metric Row Component

fileprivate struct MetricRow: View {
    let label: String
    let value: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(.body, design: .default))
                .foregroundColor(.white.opacity(0.6))
            Spacer()
            Text(value)
                .font(.system(.body, design: .rounded).monospacedDigit())
                .bold(isHighlighted)
                .foregroundColor(isHighlighted ? .hapticGlow : .white)
        }
    }
}
