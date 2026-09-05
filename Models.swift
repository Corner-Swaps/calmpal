//
//  Models.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  SwiftData schemas for session logging and clinical check-ins.
//

import Foundation

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
