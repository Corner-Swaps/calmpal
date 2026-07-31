//
//  TactileSurfaceView.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  UIKit touch capture bridging for high-precision tactile input (fallback for non-UIKit systems).
//

import SwiftUI

#if canImport(UIKit)
import UIKit

/// A protocol that defines delegate methods for receiving raw touch updates.
@MainActor
public protocol TactileSurfaceDelegate: AnyObject {
    /// Called when a touch is active on the tactile surface.
    /// - Parameters:
    ///   - force: The raw physical force of the touch.
    ///   - maxForce: The maximum possible force supported by the screen.
    ///   - radius: The physical major radius of the touch.
    ///   - location: The location of the touch in the view coordinate system.
    func tactileSurfaceDidUpdate(force: CGFloat, maxForce: CGFloat, radius: CGFloat, location: CGPoint)
    
    /// Called when the touch ends or is cancelled.
    func tactileSurfaceDidEnd()
}

/// A SwiftUI view that wraps a high-precision UIKit touch tracking view.
/// This allows extraction of `force` and `majorRadius` which standard SwiftUI gestures do not support.
public struct TactileSurfaceView: UIViewRepresentable {
    
    /// The delegate to receive high-precision touch updates.
    private weak var delegate: TactileSurfaceDelegate?
    
    /// Initializes a new tactile surface view.
    /// - Parameter delegate: The delegate to receive raw touch events.
    public init(delegate: TactileSurfaceDelegate?) {
        self.delegate = delegate
    }
    
    public func makeUIView(context: Context) -> TouchTrackingView {
        let view = TouchTrackingView()
        view.delegate = delegate
        view.isMultipleTouchEnabled = false
        view.backgroundColor = .clear
        return view
    }
    
    public func updateUIView(_ uiView: TouchTrackingView, context: Context) {
        // Keep the delegate reference updated in case of rebuilds
        uiView.delegate = delegate
    }
}

// MARK: - UIKit Touch Tracking View

/// A specialized UIView that intercepts raw touch events to extract force and majorRadius.
public final class TouchTrackingView: UIView {
    
    /// The delegate notified of touch life-cycle updates.
    public weak var delegate: TactileSurfaceDelegate?
    
    private func handleTouch(_ touch: UITouch) {
        let force = touch.force
        let maxForce = touch.maximumPossibleForce
        let radius = touch.majorRadius
        let location = touch.location(in: self)
        
        delegate?.tactileSurfaceDidUpdate(force: force, maxForce: maxForce, radius: radius, location: location)
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
    }
    
    public override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        handleTouch(touch)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.tactileSurfaceDidEnd()
    }
    
    public override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        delegate?.tactileSurfaceDidEnd()
    }
    
    public override func willMove(toWindow newWindow: UIWindow?) {
        super.willMove(toWindow: newWindow)
        if newWindow == nil {
            delegate?.tactileSurfaceDidEnd()
        }
    }
}
#else
/// A protocol that defines delegate methods for receiving raw touch updates.
@MainActor
public protocol TactileSurfaceDelegate: AnyObject {
    func tactileSurfaceDidUpdate(force: CGFloat, maxForce: CGFloat, radius: CGFloat, location: CGPoint)
    func tactileSurfaceDidEnd()
}

public struct TactileSurfaceView: View {
    private weak var delegate: TactileSurfaceDelegate?
    public init(delegate: TactileSurfaceDelegate?) {
        self.delegate = delegate
    }
    public var body: some View {
        Color.clear
    }
}
#endif
