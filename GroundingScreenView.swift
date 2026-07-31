//
//  GroundingScreenView.swift
//  Calmpal
//
//  Pixel-matched to the "Time Zones" screenshot:
//  • VStack-pinned header (top) → scroll rows (middle) → tab bar (bottom)
//  • No List, no ≡ handles, no dashed borders
//  • Rows: left side = name + subtitle tag / right = large number + unit + category
//  • Long-press + drag → reorder rows (system .draggable / .dropDestination)
//  • Double-tap any row → delete with spring animation
//  • Top-left = pause/stop · Top-right = color theme cycle (tinted circle)
//  • Bottom bar = 6 icons exactly matching the screenshot
//

import SwiftUI
import Combine

// MARK: ── Colour Themes ──────────────────────────────────────────────────────

private struct SoundTheme {
    let accent: Color   // tints the top-right button
    let palette: [Color]
}

private let allThemes: [SoundTheme] = [
    // Night – blue / magenta / purple
    SoundTheme(accent: Color(red: 10/255, green: 132/255, blue: 255/255), palette: [
        Color(red: 28/255,  green: 28/255,  blue: 30/255),
        Color(red: 10/255,  green: 132/255, blue: 255/255),
        Color(red: 160/255, green: 13/255,  blue: 159/255),
        Color(red: 94/255,  green: 23/255,  blue: 235/255),
        Color(red: 61/255,  green: 0/255,   blue: 153/255),
    ]),
    // Ember – warm reds
    SoundTheme(accent: Color(red: 0.9, green: 0.35, blue: 0.05), palette: [
        Color(red: 0.28, green: 0.08, blue: 0.03),
        Color(red: 0.55, green: 0.16, blue: 0.04),
        Color(red: 0.72, green: 0.25, blue: 0.02),
        Color(red: 0.60, green: 0.12, blue: 0.08),
        Color(red: 0.42, green: 0.06, blue: 0.14),
    ]),
    // Aurora – teal / ocean
    SoundTheme(accent: Color(red: 0.05, green: 0.75, blue: 0.60), palette: [
        Color(red: 0.04, green: 0.24, blue: 0.24),
        Color(red: 0.04, green: 0.44, blue: 0.34),
        Color(red: 0.02, green: 0.38, blue: 0.56),
        Color(red: 0.10, green: 0.24, blue: 0.50),
        Color(red: 0.04, green: 0.14, blue: 0.40),
    ]),
    // Forest – deep greens
    SoundTheme(accent: Color(red: 0.18, green: 0.62, blue: 0.20), palette: [
        Color(red: 0.07, green: 0.17, blue: 0.07),
        Color(red: 0.09, green: 0.31, blue: 0.11),
        Color(red: 0.17, green: 0.27, blue: 0.09),
        Color(red: 0.19, green: 0.21, blue: 0.07),
        Color(red: 0.14, green: 0.14, blue: 0.05),
    ]),
    // Cosmos – purples / violet
    SoundTheme(accent: Color(red: 0.75, green: 0.30, blue: 0.90), palette: [
        Color(red: 0.11, green: 0.04, blue: 0.27),
        Color(red: 0.27, green: 0.04, blue: 0.44),
        Color(red: 0.44, green: 0.09, blue: 0.54),
        Color(red: 0.34, green: 0.04, blue: 0.49),
        Color(red: 0.20, green: 0.01, blue: 0.39),
    ]),
    // Sunset – coral / orange / magenta
    SoundTheme(accent: Color(red: 255/255, green: 94/255, blue: 98/255), palette: [
        Color(red: 48/255,  green: 27/255,  blue: 63/255),
        Color(red: 255/255, green: 94/255,  blue: 98/255),
        Color(red: 255/255, green: 153/255, blue: 102/255),
        Color(red: 209/255, green: 52/255,  blue: 91/255),
        Color(red: 72/255,  green: 28/255,  blue: 64/255),
    ]),
    // Oceanic Depth – rich blues / turquoise
    SoundTheme(accent: Color(red: 0/255, green: 242/255, blue: 254/255), palette: [
        Color(red: 0/255,   green: 24/255,  blue: 48/255),
        Color(red: 0/255,   green: 114/255, blue: 255/255),
        Color(red: 0/255,   green: 242/255, blue: 254/255),
        Color(red: 0/255,   green: 51/255,  blue: 102/255),
        Color(red: 0/255,   green: 15/255,  blue: 32/255),
    ]),
    // Lavender Mist – lilac / indigo
    SoundTheme(accent: Color(red: 226/255, green: 180/255, blue: 240/255), palette: [
        Color(red: 30/255,  green: 20/255,  blue: 50/255),
        Color(red: 159/255, green: 133/255, blue: 199/255),
        Color(red: 226/255, green: 180/255, blue: 240/255),
        Color(red: 116/255, green: 92/255,  blue: 166/255),
        Color(red: 68/255,  green: 49/255,  blue: 99/255),
    ]),
    // Volcanic Dusk – crimson / magma orange
    SoundTheme(accent: Color(red: 255/255, green: 65/255, blue: 108/255), palette: [
        Color(red: 21/255,  green: 12/255,  blue: 13/255),
        Color(red: 255/255, green: 75/255,  blue: 43/255),
        Color(red: 255/255, green: 65/255,  blue: 108/255),
        Color(red: 138/255, green: 29/255,  blue: 47/255),
        Color(red: 68/255,  green: 24/255,  blue: 31/255),
    ]),
    // Desert Sun – clay / warm beige / terracotta
    SoundTheme(accent: Color(red: 255/255, green: 179/255, blue: 71/255), palette: [
        Color(red: 45/255,  green: 23/255,  blue: 11/255),
        Color(red: 211/255, green: 84/255,  blue: 0/255),
        Color(red: 255/255, green: 179/255, blue: 71/255),
        Color(red: 160/255, green: 64/255,  blue: 0/255),
        Color(red: 94/255,  green: 47/255,  blue: 13/255),
    ]),
    // Cyberpunk – hot pink / neon cyan / bright purple
    SoundTheme(accent: Color(red: 255/255, green: 0/255, blue: 127/255), palette: [
        Color(red: 5/255,   green: 1/255,   blue: 23/255),
        Color(red: 255/255, green: 0/255,   blue: 127/255),
        Color(red: 0/255,   green: 240/255, blue: 255/255),
        Color(red: 123/255, green: 0/255,   blue: 255/255),
        Color(red: 60/255,  green: 0/255,   blue: 128/255),
    ]),
    // Sage Garden – olive / sage green / forest tone
    SoundTheme(accent: Color(red: 142/255, green: 190/255, blue: 138/255), palette: [
        Color(red: 25/255,  green: 35/255,  blue: 25/255),
        Color(red: 91/255,  green: 130/255, blue: 102/255),
        Color(red: 142/255, green: 190/255, blue: 138/255),
        Color(red: 62/255,  green: 92/255,  blue: 70/255),
        Color(red: 37/255,  green: 53/255,  blue: 37/255),
    ]),
    // Plum Wine – rich plum / violet raspberry
    SoundTheme(accent: Color(red: 168/255, green: 63/255, blue: 115/255), palette: [
        Color(red: 34/255,  green: 6/255,   blue: 21/255),
        Color(red: 107/255, green: 17/255,  blue: 61/255),
        Color(red: 168/255, green: 63/255,  blue: 115/255),
        Color(red: 82/255,  green: 12/255,  blue: 50/255),
        Color(red: 51/255,  green: 2/255,   blue: 28/255),
    ]),
    // Glacier Ice – icy blue / frozen cyan
    SoundTheme(accent: Color(red: 127/255, green: 191/255, blue: 207/255), palette: [
        Color(red: 15/255,  green: 23/255,  blue: 29/255),
        Color(red: 79/255,  green: 125/255, blue: 140/255),
        Color(red: 127/255, green: 191/255, blue: 207/255),
        Color(red: 48/255,  green: 76/255,  blue: 85/255),
        Color(red: 26/255,  green: 39/255,  blue: 45/255),
    ]),
    // Midnight Gold – deep navy / metallic gold
    SoundTheme(accent: Color(red: 244/255, green: 196/255, blue: 48/255), palette: [
        Color(red: 11/255,  green: 17/255,  blue: 30/255),
        Color(red: 184/255, green: 134/255, blue: 11/255),
        Color(red: 244/255, green: 196/255, blue: 48/255),
        Color(red: 28/255,  green: 40/255,  blue: 65/255),
        Color(red: 13/255,  green: 19/255,  blue: 33/255),
    ]),
]

// MARK: ── Sound Entry ────────────────────────────────────────────────────────

private struct SoundEntry: Identifiable, Equatable {
    let id: UUID
    let profile: SoundProfile
    init(profile: SoundProfile) { self.id = UUID(); self.profile = profile }
    static func == (l: Self, r: Self) -> Bool { l.id == r.id }
}

// MARK: ── SoundProfile display name ─────────────────────────────────────────

public extension SoundProfile {
    /// Human-readable label: extracts the name in parentheses for solfeggio tones,
    /// or returns the rawValue directly for all ambient/nature/ocean/sleep/focus profiles.
    var displayName: String {
        if let start = rawValue.firstIndex(of: "("),
           let end   = rawValue.lastIndex(of: ")") {
            return String(rawValue[rawValue.index(after: start)..<end])
        }
        return rawValue
    }
}

// MARK: ── Main View ──────────────────────────────────────────────────────────

public struct GroundingScreenView: View {

    @State private var rows: [SoundEntry] = {
        [SoundProfile.gentleRain, .oceanWaves, .forestBirdsong, .windInTrees, .warmCafe]
            .map { SoundEntry(profile: $0) }
    }()
    @State private var themeIdx: Int = 0
    @State private var activeProfile: SoundProfile? = nil
    @State private var isPaused: Bool = false
    @State private var playbackProgress: Double = 0.0
    @State private var elapsedSeconds: Double = 0.0
    @State private var showAddSheet: Bool = false
    @State private var addSheetCategory: Int = 0
    @State private var isEditingList: Bool = false
    @State private var draggingId: UUID? = nil
    @State private var dragOffset: CGFloat = 0.0

    private let tick = Timer.publish(every: 0.05, on: .main, in: .common).autoconnect()
    private var theme: SoundTheme { allThemes[themeIdx] }

    public init() {}

    public var body: some View {
        ZStack {
            VStack(spacing: 0) {

                // ── Top Clearance (Lowered whole metal/circle visualizer section down a bit) ──
                Spacer()
                    .frame(height: 44)

                // ── Giant Circular Timer & Radial Sound Visualizer ──────────────
                GeometryReader { geometry in
                    let size = min(geometry.size.width, geometry.size.height)
                    let centerDiameter: CGFloat = max(200, min(260, size * 0.58))
                    let orbitRadius: CGFloat = centerDiameter / 2 + 54

                    ZStack {
                        // Ambient dark background glow
                        Circle()
                            .fill(
                                RadialGradient(
                                    gradient: Gradient(colors: [
                                        activeThemeColor.opacity(activeProfile != nil ? 0.25 : 0.08),
                                        Color.black.opacity(0.95)
                                    ]),
                                    center: .center,
                                    startRadius: 40,
                                    endRadius: centerDiameter * 0.85
                                )
                            )
                            .frame(width: centerDiameter * 1.5, height: centerDiameter * 1.5)

                        // ── Outer Orbit Ring Guide (passes cleanly behind black node masks) ──
                        Circle()
                            .stroke(Color.white.opacity(0.08), lineWidth: 1.5)
                            .frame(width: orbitRadius * 2, height: orbitRadius * 2)

                        // ── Central Giant Timer Circle ──
                        ZStack {
                            // Base Circle Background
                            Circle()
                                .fill(Color(white: 0.06))

                            // Inner Theme Accent Wash
                            Circle()
                                .fill(activeThemeColor.opacity(activeProfile != nil ? 0.20 : 0.08))

                            // Background Progress Ring Track
                            Circle()
                                .stroke(Color.white.opacity(0.12), lineWidth: 8)
                                .padding(4)

                            // Active Circular Timer Progress Ring (Sweeps continuously around 60s ring)
                            let ringProgress = (elapsedSeconds.truncatingRemainder(dividingBy: 60.0)) / 60.0
                            Circle()
                                .trim(from: 0, to: activeProfile != nil ? CGFloat(ringProgress) : 0.0)
                                .stroke(
                                    LinearGradient(
                                        colors: [activeThemeColor, isPaused ? Color.white.opacity(0.4) : Color.white],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                )
                                .rotationEffect(.degrees(-90))
                                .padding(4)
                                .animation(.linear(duration: 0.05), value: ringProgress)

                            // Center Timer & Sound Info Content (Pauses when clicked, never resets to Tap to Play unless black screen is clicked!)
                            VStack(spacing: 6) {
                                if let active = activeProfile {
                                    Text(active.displayName)
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .lineLimit(1)

                                    // Continuous Digital Elapsed Timer Display
                                    let totalSec = Int(elapsedSeconds)
                                    Text(String(format: "%02d:%02d", totalSec / 60, totalSec % 60))
                                        .font(.system(size: 22, weight: .bold, design: .monospaced))
                                        .foregroundColor(.white.opacity(0.90))
                                        .padding(.top, 2)

                                    if isPaused {
                                        Text("PAUSED")
                                            .font(.system(size: 11, weight: .bold, design: .rounded))
                                            .foregroundColor(.white.opacity(0.60))
                                            .tracking(1.5)
                                    }
                                } else {
                                    // Idle State
                                    Text("Tap to Play")
                                        .font(.system(size: 24, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)

                                    Text("SELECT SOUND")
                                        .font(.system(size: 11, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.45))
                                        .tracking(1.0)
                                }
                            }
                            .padding(20)
                        }
                        .frame(width: centerDiameter, height: centerDiameter)
                        .contentShape(Circle())
                        .onTapGesture {
                            if activeProfile != nil {
                                // Tapping middle circle PAUSES/RESUMES, does NOT reset to Tap to Play!
                                isPaused.toggle()
                                if isPaused {
                                    AudioManager.shared.pause()
                                } else {
                                    AudioManager.shared.resume()
                                }
                            } else if let first = rows.first?.profile {
                                startPlayback(first)
                            }
                        }

                        let count = rows.count
                        ForEach(Array(rows.enumerated()), id: \.element.id) { idx, entry in
                            let angleDegrees = -90.0 + (Double(idx) * (360.0 / Double(max(1, count))))
                            let angleRad = angleDegrees * .pi / 180.0
                            let xOffset = cos(angleRad) * orbitRadius
                            let yOffset = sin(angleRad) * orbitRadius
                            let isActive = activeProfile == entry.profile
                            let nodeColor = uniqueSoundColor(for: entry.profile)

                            Button {
                                if isEditingList {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        if activeProfile == entry.profile {
                                            stopPlayback()
                                        }
                                        rows.removeAll { $0.id == entry.id }
                                    }
                                } else {
                                    startPlayback(entry.profile)
                                }
                            } label: {
                                VStack(spacing: 4) {
                                    ZStack {
                                        if isEditingList {
                                            // Solid black backing mask completely blocks any white line underneath
                                            Circle()
                                                .fill(Color.black)
                                                .frame(width: 58, height: 58)
                                            Circle()
                                                .fill(Color(red: 0.88, green: 0.40, blue: 0.40))
                                                .frame(width: 48, height: 48)
                                            Image(systemName: "minus")
                                                .font(.system(size: 20, weight: .bold))
                                                .foregroundColor(.white)
                                        } else {
                                            Circle()
                                                .fill(isActive ? nodeColor : Color(white: 0.12))
                                                .frame(width: 48, height: 48)
                                            // Active highlight ring hidden behind red edit mode button!
                                            if isActive && !isEditingList {
                                                Circle()
                                                    .stroke(Color.white, lineWidth: 2)
                                                    .frame(width: 52, height: 52)
                                            }
                                            let iconName = categoryIcon(for: entry.profile)
                                            Image(systemName: iconName)
                                                .font(.system(size: iconName == "wind" ? 24 : 20, weight: .bold))
                                                .foregroundColor(isActive ? .white : .white.opacity(0.70))
                                        }
                                    }
                                    Text(entry.profile.displayName)
                                        .font(.system(size: 11, weight: isActive ? .bold : .medium, design: .rounded))
                                        .foregroundColor(isEditingList ? Color(red: 0.95, green: 0.50, blue: 0.50) : (isActive ? .white : .white.opacity(0.60)))
                                }
                            }
                            .buttonStyle(.plain)
                            .offset(x: xOffset, y: yOffset)
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        // Tapping anywhere on the black background resets to Tap to Play!
                        stopPlayback()
                    }
                }
                .background(Color.black)
                bottomTabBar
            }
            .background(Color.black.ignoresSafeArea())

            if showAddSheet {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture { showAddSheet = false }

                TonePickerSheet(initialCategory: addSheetCategory) { profile in
                    let newEntry = SoundEntry(profile: profile)
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        rows.append(newEntry)
                    }
                    showAddSheet = false
                    startPlayback(profile)
                } onDismiss: {
                    showAddSheet = false
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(white: 0.03).ignoresSafeArea())
            }
        }
        .onReceive(tick) { _ in
            guard activeProfile != nil, !isPaused else { return }
            elapsedSeconds += 0.05
        }
        .onReceive(NotificationCenter.default.publisher(for: AudioManager.audioStateDidChangeNotification)) { _ in
            if activeProfile != nil {
                self.isPaused = !AudioManager.shared.isAudioPlaying
            }
        }
    }

    private var activeThemeColor: Color {
        if let active = activeProfile { return uniqueSoundColor(for: active) }
        return theme.accent
    }

    private func categoryIcon(for profile: SoundProfile) -> String {
        switch profile.shortName {
        case "Rain":    return "cloud.rain.fill"
        case "Ocean":   return "wave.3.forward"
        case "Forest":  return "tree.fill"
        case "Wind":    return "wind"
        case "Ambient": return "cup.and.saucer.fill"
        default:        return "leaf.fill"
        }
    }

    private func uniqueSoundColor(for profile: SoundProfile) -> Color {
        switch profile {
        case .gentleRain:      return Color(red: 0.28, green: 0.65, blue: 0.95)
        case .rainOnWindow:    return Color(red: 0.12, green: 0.75, blue: 0.85)
        case .rainCanopy:      return Color(red: 0.05, green: 0.60, blue: 0.65)
        case .heavyRain:       return Color(red: 0.20, green: 0.40, blue: 0.85)
        case .rollingThunder:  return Color(red: 0.45, green: 0.30, blue: 0.85)
        case .oceanWaves:      return Color(red: 0.05, green: 0.52, blue: 1.00)
        case .waterfall:       return Color(red: 0.15, green: 0.70, blue: 0.95)
        case .forestRiver:     return Color(red: 0.10, green: 0.65, blue: 0.70)
        case .waterDroplets:   return Color(red: 0.35, green: 0.80, blue: 0.98)
        case .coastalSeagulls: return Color(red: 0.25, green: 0.75, blue: 0.65)
        case .forestBirdsong:  return Color(red: 0.18, green: 0.68, blue: 0.28)
        case .tropicalJungle:  return Color(red: 0.08, green: 0.55, blue: 0.20)
        case .nightCrickets:   return Color(red: 0.35, green: 0.60, blue: 0.25)
        case .eveningFrogs:    return Color(red: 0.50, green: 0.75, blue: 0.15)
        case .catPurring:      return Color(red: 0.70, green: 0.55, blue: 0.20)
        case .windInTrees:     return Color(red: 0.92, green: 0.56, blue: 0.10)
        case .cozyCampfire:    return Color(red: 0.95, green: 0.38, blue: 0.12)
        case .duneBreeze:      return Color(red: 0.88, green: 0.68, blue: 0.25)
        case .howlingWind:     return Color(red: 0.55, green: 0.60, blue: 0.68)
        case .walkOnLeaves:    return Color(red: 0.82, green: 0.42, blue: 0.18)
        case .warmCafe:        return Color(red: 0.70, green: 0.38, blue: 0.20)
        case .quietLibrary:    return Color(red: 0.55, green: 0.30, blue: 0.70)
        case .nightVillage:    return Color(red: 0.25, green: 0.28, blue: 0.55)
        case .templeSanctuary: return Color(red: 0.80, green: 0.62, blue: 0.18)
        case .deepUnderwater:  return Color(red: 0.10, green: 0.25, blue: 0.60)
        }
    }

    private var bottomTabBar: some View {
        HStack(spacing: 12) {
            Spacer()
            Button {
                addSheetCategory = 0
                showAddSheet = true
            } label: {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: "plus")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isEditingList.toggle()
                }
            } label: {
                ZStack {
                    Circle()
                        .fill(isEditingList ? Color.white.opacity(0.25) : Color.white.opacity(0.12))
                        .frame(width: 44, height: 44)
                    Image(systemName: isEditingList ? "checkmark" : "pencil")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            .buttonStyle(.plain)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .background(Color.clear)
    }

    private func startPlayback(_ profile: SoundProfile) {
        AudioManager.shared.stop()
        activeProfile = profile
        isPaused = false
        elapsedSeconds = 0.0
        AudioManager.shared.activeProfile = profile
        AudioManager.shared.start()
        HapticManager.shared.start()
    }

    private func stopPlayback() {
        activeProfile = nil
        isPaused = false
        elapsedSeconds = 0.0
        AudioManager.shared.stop()
        HapticManager.shared.stop()
    }
}

// MARK: ── Sound Row View ──────────────────────────────────────────────────────

private struct SoundRowView: View {
    let entry: SoundEntry
    let isActive: Bool
    let progress: Double
    let backgroundColor: Color
    let isEditing: Bool
    let isFirst: Bool
    let isLast: Bool
    let onTap: () -> Void
    let onDoubleTap: () -> Void
    let onDelete: () -> Void
    var onDragChanged: ((DragGesture.Value) -> Void)? = nil
    var onDragEnded: ((DragGesture.Value) -> Void)? = nil

    var body: some View {
        ZStack(alignment: .leading) {
            backgroundColor
                .ignoresSafeArea()

            if isActive {
                GeometryReader { geo in
                    Color.white.opacity(0.14)
                        .frame(width: geo.size.width * CGFloat(progress))
                        .animation(.linear(duration: 0.05), value: progress)
                }
            }

            HStack(spacing: 12) {
                if isEditing {
                    Button {
                        onDelete()
                    } label: {
                        ZStack {
                            Color.clear
                                .frame(width: 36, height: 36)
                            Circle()
                                .fill(Color(red: 0.88, green: 0.40, blue: 0.40).opacity(0.85))
                                .frame(width: 22, height: 22)
                            Image(systemName: "minus")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }
                    .transition(.move(edge: .leading).combined(with: .opacity))
                } else {
                    Circle()
                        .fill(isActive ? Color(red: 0.2, green: 0.9, blue: 0.4) : Color.white.opacity(0.35))
                        .frame(width: 8, height: 8)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.profile.displayName)
                        .font(.system(size: 21, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text(entry.profile.shortName)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.65))
                }
                Spacer(minLength: 8)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .contentShape(Rectangle())
        .frame(maxWidth: .infinity)
        .frame(height: 80)
    }
}

// MARK: ── Tone Picker Data ───────────────────────────────────────────────────

private struct SoundCategoryData: Identifiable {
    let id   = UUID()
    let name : String
    let icon : String
    let color: Color
    let description: String
    let sounds: [SoundProfile]
}

private let soundCategories: [SoundCategoryData] = [
    SoundCategoryData(
        name: "Rain", icon: "cloud.rain.fill",
        color: Color(red: 0.15, green: 0.76, blue: 0.75),
        description: "Gentle drizzle drops, window patter & rolling thunder.",
        sounds: [.gentleRain, .rainOnWindow, .rainCanopy, .heavyRain, .rollingThunder]
    ),
    SoundCategoryData(
        name: "Ocean", icon: "wave.3.forward",
        color: Color(red: 0.05, green: 0.52, blue: 1.0),
        description: "Coastal surf, cascading waterfalls & bubbling rivers.",
        sounds: [.oceanWaves, .waterfall, .forestRiver, .waterDroplets, .coastalSeagulls]
    ),
    SoundCategoryData(
        name: "Forest", icon: "tree.fill",
        color: Color(red: 0.18, green: 0.68, blue: 0.28),
        description: "Morning birdsong, jungle canopy & night crickets.",
        sounds: [.forestBirdsong, .tropicalJungle, .nightCrickets, .eveningFrogs, .catPurring]
    ),
    SoundCategoryData(
        name: "Wind", icon: "wind",
        color: Color(red: 0.92, green: 0.56, blue: 0.10),
        description: "Canopy breeze, hearth campfire & howling winds.",
        sounds: [.windInTrees, .cozyCampfire, .duneBreeze, .howlingWind, .walkOnLeaves]
    ),
    SoundCategoryData(
        name: "Ambient", icon: "cup.and.saucer.fill",
        color: Color(red: 0.65, green: 0.25, blue: 0.95),
        description: "Warm café ambience, quiet library & night village.",
        sounds: [.warmCafe, .quietLibrary, .nightVillage, .templeSanctuary, .deepUnderwater]
    ),
]

// MARK: ── Tone Picker Sheet ───────────────────────────────────────────────────

private struct TonePickerSheet: View {
    let onSelect: (SoundProfile) -> Void
    let onDismiss: () -> Void
    let initialCategory: Int
    @State private var selectedCategory: Int = 0
    @State private var previewProfile: SoundProfile? = nil

    init(initialCategory: Int = 0, onSelect: @escaping (SoundProfile) -> Void, onDismiss: @escaping () -> Void) {
        self.initialCategory = initialCategory
        self.onSelect = onSelect
        self.onDismiss = onDismiss
        self._selectedCategory = State(initialValue: initialCategory)
    }

    private func togglePreview(_ profile: SoundProfile) {
        if previewProfile == profile {
            AudioManager.shared.stop()
            previewProfile = nil
        } else {
            AudioManager.shared.stop()
            AudioManager.shared.activeProfile = profile
            AudioManager.shared.start()
            previewProfile = profile
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Lower category title, text & sound options comfortably down towards the middle of the sheet!
            Spacer()
                .frame(height: 84)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    // Category title and description centered in the middle!
                    VStack(alignment: .center, spacing: 6) {
                        Text(soundCategories[selectedCategory].name)
                            .font(.system(size: 28, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text(soundCategories[selectedCategory].description)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.65))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.horizontal, 24)
                    .padding(.top, 24)
                    .padding(.bottom, 28)

                    ForEach(Array(soundCategories[selectedCategory].sounds.enumerated()), id: \.offset) { idx, profile in
                        pickerRow(profile: profile, index: idx,
                                  category: soundCategories[selectedCategory])
                    }
                }
                .padding(.bottom, 12)
                .id(selectedCategory)
            }

            Spacer(minLength: 0)

            // Category Tab Bar at very bottom with Back button on far left next to Rain!
            categoryTabBar
        }
        .background(Color(white: 0.03).ignoresSafeArea())
        .preferredColorScheme(.dark)
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
        .onDisappear {
            if previewProfile != nil {
                AudioManager.shared.stop()
            }
        }
    }

    // MARK: – Category Tab Bar with Back Button on Bottom Left

    private var categoryTabBar: some View {
        HStack(spacing: 10) {
            Spacer(minLength: 4)

            // Back Button on Bottom Left next to Rain!
            Button(action: { onDismiss() }) {
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(0.12))
                            .frame(width: 44, height: 44)
                        Image(systemName: "arrow.left")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                    Text("Back")
                        .font(.system(size: 10, weight: .semibold, design: .rounded))
                        .foregroundColor(.white.opacity(0.50))
                }
                .frame(width: 50)
            }
            .buttonStyle(.plain)

            ForEach(Array(soundCategories.enumerated()), id: \.element.id) { idx, cat in
                Button {
                    selectedCategory = idx
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            Circle()
                                .fill(selectedCategory == idx
                                      ? Color.white.opacity(0.20)
                                      : Color.white.opacity(0.07))
                                .frame(width: 44, height: 44)
                            Image(systemName: cat.icon)
                                .font(.system(size: 18,
                                              weight: selectedCategory == idx ? .bold : .regular))
                                .foregroundColor(
                                    selectedCategory == idx ? .white : .white.opacity(0.40))
                        }
                        Text(cat.name)
                            .font(.system(size: 10, weight: .semibold, design: .rounded))
                            .foregroundColor(
                                selectedCategory == idx ? .white : .white.opacity(0.30))
                    }
                    .frame(width: 50)
                }
                .buttonStyle(.plain)
            }

            Spacer(minLength: 4)
        }
        .padding(.horizontal, 10)
        .padding(.top, 14)
        .padding(.bottom, 32)
        .background(Color.black)
    }

    private func pickerRow(profile: SoundProfile, index: Int, category: SoundCategoryData) -> some View {
        HStack(spacing: 12) {
            // Track numbers (01 02 03) removed per user request!
            // Sound title & explanation
            VStack(alignment: .leading, spacing: 2) {
                Text(profile.displayName)
                    .font(.system(size: 21, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(profile.explanation)
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.65))
                    .lineLimit(1)
            }

            Spacer(minLength: 6)

            // Right side buttons: Preview Play Button AND Plus Add Button!
            HStack(spacing: 10) {
                // 1. Audio Preview Play Button
                Button(action: {
                    togglePreview(profile)
                }) {
                    ZStack {
                        Circle()
                            .fill(Color.white.opacity(previewProfile == profile ? 0.20 : 0.08))
                            .frame(width: 44, height: 44)
                        Image(systemName: previewProfile == profile ? "stop.fill" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)

                // 2. Plus Add Button to add sound to main screen!
                Button(action: {
                    onSelect(profile)
                }) {
                    ZStack {
                        Circle()
                            .fill(category.color.opacity(0.85))
                            .frame(width: 44, height: 44)
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .frame(height: 80)
        .background(Color.white.opacity(index.isMultiple(of: 2) ? 0.04 : 0.02))
    }
}

#Preview {
    GroundingScreenView()
        .modelContainer(for: [GroundingSession.self, GAD7Assessment.self], inMemory: true)
}

fileprivate extension View {
    @ViewBuilder
    func `if`<Content: View>(_ conditional: Bool, transform: (Self) -> Content) -> some View {
        if conditional {
            transform(self)
        } else {
            self
        }
    }
}

struct TransformButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.88 : 1.0)
            .opacity(configuration.isPressed ? 0.75 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
