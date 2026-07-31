//
//  Color+Theme.swift
//  Calmpal
//
//  Created for clinical grounding and sensory regulation.
//  West Coast minimalist color system extension.
//

import SwiftUI

extension Color {
    /// Redesigned to Pure Black for visual theme
    public static let backgroundDark = Color.black
    
    /// Soft Overcast Gray (#F8FAFC)
    public static let backgroundLight = Color(red: 248/255, green: 250/255, blue: 252/255)
    
    /// Bioluminescent Cyan (#06B6D4)
    public static let hapticGlow = Color(red: 6/255, green: 182/255, blue: 212/255)
    
    /// Sage Green (#84CC16)
    public static let accentHold = Color(red: 132/255, green: 204/255, blue: 22/255)
    
    /// Warm Coral (#FB7185)
    public static let accentRelease = Color(red: 251/255, green: 113/255, blue: 133/255)
    
    // Time Zones Visual Palette matching the uploaded screenshot
    public static let rowGray = Color(red: 28/255, green: 28/255, blue: 30/255)
    public static let rowBlue = Color(red: 10/255, green: 132/255, blue: 255/255)
    public static let rowMagenta = Color(red: 160/255, green: 13/255, blue: 159/255)
    public static let rowPurple = Color(red: 94/255, green: 23/255, blue: 235/255)
    public static let rowDeepPurple = Color(red: 61/255, green: 0/255, blue: 153/255)
}

#if canImport(UIKit)
import UIKit
#else
public struct UIRectCorner: OptionSet, Sendable {
    public let rawValue: UInt
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    public static let topLeft = UIRectCorner(rawValue: 1 << 0)
    public static let topRight = UIRectCorner(rawValue: 1 << 1)
    public static let bottomLeft = UIRectCorner(rawValue: 1 << 2)
    public static let bottomRight = UIRectCorner(rawValue: 1 << 3)
    public static let allCorners: UIRectCorner = [.topLeft, .topRight, .bottomLeft, .bottomRight]
}
#endif

// MARK: - Specific Corner Rounding Extensions
public struct RoundedCorner: Shape {
    public var radius: CGFloat = .infinity
    public var corners: UIRectCorner = .allCorners

    public init(radius: CGFloat, corners: UIRectCorner) {
        self.radius = radius
        self.corners = corners
    }

    public func path(in rect: CGRect) -> Path {
        #if canImport(UIKit)
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
        #else
        var topLeading: CGFloat = 0
        var topTrailing: CGFloat = 0
        var bottomLeading: CGFloat = 0
        var bottomTrailing: CGFloat = 0
        
        if corners.contains(.topLeft) { topLeading = radius }
        if corners.contains(.topRight) { topTrailing = radius }
        if corners.contains(.bottomLeft) { bottomLeading = radius }
        if corners.contains(.bottomRight) { bottomTrailing = radius }
        
        let shape = UnevenRoundedRectangle(
            topLeadingRadius: topLeading,
            bottomLeadingRadius: bottomLeading,
            bottomTrailingRadius: bottomTrailing,
            topTrailingRadius: topTrailing
        )
        return shape.path(in: rect)
        #endif
    }
}

public extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
