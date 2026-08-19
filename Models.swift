//
//  Models.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  SwiftData schemas for session logging and clinical check-ins.
//

import Foundation
import SwiftData

/// Persisted record of a tactile grounding session.
@Model
public final class GroundingSession {
    /// Unique identifier.
    public var id: UUID
    
    /// The timestamp when the session occurred.
    public var date: Date
    
    /// The duration of the session in seconds.
    public var duration: TimeInterval
    
    /// The method used (e.g., "Free Touch", "Apnea Hold", "Box Breath").
    public var protocolType: String
    
    /// The average pressure/force value recorded during touch (0.0 to 1.0).
    public var averagePressure: Float
    
    public init(
        id: UUID = UUID(),
        date: Date = Date(),
        duration: TimeInterval,
        protocolType: String,
        averagePressure: Float
    ) {
        self.id = id
        self.date = date
        self.duration = duration
        self.protocolType = protocolType
        self.averagePressure = averagePressure
    }
}

// MARK: - String Control Character Filtering

public extension String {
    func filteringControlCharacters() -> String {
        let allowedControls = CharacterSet(charactersIn: "\n\r\t")
            .union(CharacterSet(charactersIn: "\u{200C}"..."\u{200F}")) // ZWNJ, ZWJ, LTR, RTL markers
            .union(CharacterSet(charactersIn: "\u{FE00}"..."\u{FE0F}")) // Variation selectors
        let filterSet = CharacterSet.controlCharacters.subtracting(allowedControls)
        return String(unicodeScalars.filter { !filterSet.contains($0) })
    }
}

// MARK: - Safe Concurrency Wrappers

public final class TimerWrapper: @unchecked Sendable {
    private let lock = NSRecursiveLock()
    private var timer: Timer?
    
    public init() {}
    
    public func set(_ newTimer: Timer?) {
        lock.lock()
        defer { lock.unlock() }
        timer?.invalidate()
        timer = newTimer
    }
    
    public func invalidate() {
        lock.lock()
        defer { lock.unlock() }
        timer?.invalidate()
        timer = nil
    }
    
    public var value: Timer? {
        lock.lock()
        defer { lock.unlock() }
        return timer
    }
}

import QuartzCore

public final class DisplayLinkWrapper: @unchecked Sendable {
    private let lock = NSRecursiveLock()
    private var displayLink: CADisplayLink?
    
    public init() {}
    
    public func set(_ newDisplayLink: CADisplayLink?) {
        lock.lock()
        defer { lock.unlock() }
        displayLink?.invalidate()
        displayLink = newDisplayLink
    }
    
    public func invalidate() {
        lock.lock()
        defer { lock.unlock() }
        displayLink?.invalidate()
        displayLink = nil
    }
    
    public var value: CADisplayLink? {
        lock.lock()
        defer { lock.unlock() }
        return displayLink
    }
}
