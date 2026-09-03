//
//  GroundingScreenView.swift
//  Calmpal
//
//  Atmospheric Nature & Sleep Player:
//  • Dynamic Fullscreen Scenic Photographic Backdrop (Instant Cut)
//  • Preset Default Timer: 30:00 (1800s)
//  • Bottom Action Dock: [🎵 Sounds] [💧 Theme Droplet] [⏵/⏸ Play] [✏️ Edit Timer] (All 50pt, Subtle Glass)
//  • Center Screen: Clean Pure Title + Full Circular Sleep Timer Ring (Pure Minimal Dot)
//  • In Edit Mode: Solid Black View + Top Clean Digital Timer + Fluid Wave Bottleneck Measuring Lines + Bottom (✓) Checkmark Button (50pt)
//  • In Theme Mode: Dark Ambient Space + Shimmer Particles Interacting with Floating Center Time (No ring container) + Bottom (X) Close Button (50pt)
//  • Full-Bleed Sound Library: [🔊 Preview Left] [Title Center] [▶ Play Right] & Floating Bottom (X) Button (50pt)
//

import SwiftUI
import Combine
import AVFoundation

// MARK: ── Sound Banner Visual Theme ──────────────────────────────────────────

public struct SoundBannerTheme: Identifiable, Equatable {
    public let id: String
    public let profile: SoundProfile
    public let title: String
    public let imageName: String
    public let previewAlignment: Alignment

    public init(
        id: String,
        profile: SoundProfile,
        title: String,
        imageName: String,
        previewAlignment: Alignment = .center
    ) {
        self.id = id
        self.profile = profile
        self.title = title
        self.imageName = imageName
        self.previewAlignment = previewAlignment
    }
}

public let allSoundBanners: [SoundBannerTheme] = [
    SoundBannerTheme(id: "crickets-night", profile: .nightCrickets, title: "Crickets Night", imageName: "crickets-night"),
    SoundBannerTheme(id: "gentle-rain", profile: .gentleRain, title: "Gentle Rain", imageName: "gentle-rain"),
    SoundBannerTheme(id: "ocean-waves", profile: .oceanWaves, title: "Peaceful Ocean", imageName: "ocean-waves"),
    SoundBannerTheme(id: "wind-in-trees", profile: .windInTrees, title: "Wind in Trees", imageName: "gentle-wind"),
    SoundBannerTheme(id: "rain-window", profile: .rainOnWindow, title: "Rain on Window", imageName: "rain-window"),

    SoundBannerTheme(id: "waterfall", profile: .waterfall, title: "Forest Waterfall", imageName: "waterfall"),
    SoundBannerTheme(id: "dune-breeze", profile: .duneBreeze, title: "Desert Dune Breeze", imageName: "dune-breeze", previewAlignment: .bottom), // Below Forest Waterfall, shows bottom of dune
    SoundBannerTheme(id: "cozy-campfire", profile: .cozyCampfire, title: "Cozy Campfire", imageName: "cozy-campfire"),
    SoundBannerTheme(id: "quiet-library", profile: .quietLibrary, title: "Quiet Library", imageName: "quiet-library"),
    SoundBannerTheme(id: "rolling-thunder", profile: .rollingThunder, title: "Rolling Thunder", imageName: "rolling-thunder"),

    SoundBannerTheme(id: "flowing-river", profile: .forestRiver, title: "Flowing River", imageName: "flowing-river"),
    SoundBannerTheme(id: "evening-frogs", profile: .eveningFrogs, title: "Evening Frogs", imageName: "evening-frogs"),
    SoundBannerTheme(id: "cat-purr", profile: .catPurring, title: "Cat Purring", imageName: "cat-purr"), // Under Evening Frogs
    SoundBannerTheme(id: "heavy-rain", profile: .heavyRain, title: "Heavy Downpour", imageName: "heavy-rain"),
    SoundBannerTheme(id: "temple-sanctuary", profile: .templeSanctuary, title: "Sacred Temple", imageName: "temple-sanctuary"),

    SoundBannerTheme(id: "coastal-seagulls", profile: .coastalSeagulls, title: "Coastal Seagulls", imageName: "coastal-seagulls", previewAlignment: .bottom), // Bottom of picture
    SoundBannerTheme(id: "howling-wind", profile: .howlingWind, title: "Howling Winter Gale", imageName: "howling-wind", previewAlignment: .bottom), // Bottom of picture
    SoundBannerTheme(id: "rain-canopy", profile: .rainCanopy, title: "Rain on Leaves", imageName: "rain-canopy"),
    SoundBannerTheme(id: "deep-underwater", profile: .deepUnderwater, title: "Deep Underwater", imageName: "deep-underwater"),
    SoundBannerTheme(id: "tropical-jungle", profile: .tropicalJungle, title: "Tropical Jungle", imageName: "tropical-jungle"),
    SoundBannerTheme(id: "night-village", profile: .nightVillage, title: "Quiet Mountain Village", imageName: "night-village")
]

public func bannerFor(profile: SoundProfile) -> SoundBannerTheme {
    allSoundBanners.first(where: { $0.profile == profile }) ?? allSoundBanners[0]
}

// MARK: ── Main View ──────────────────────────────────────────────────────────

public enum ActiveScreenOverlay: Equatable {
    case none
    case editTimer
    case soundSelection
}

public struct GroundingScreenView: View {

    @State private var activeProfile: SoundProfile = .nightCrickets
    @State private var remainingTimerSeconds: TimeInterval = 600.0 // Default 10 min
    @State private var totalTimerDuration: TimeInterval = 600.0    // Total selected span
    @State private var isPlaying: Bool = false
    @State private var activeOverlay: ActiveScreenOverlay = .none
    @State private var isDraggingTimer: Bool = false
    @State private var isZenMode: Bool = false
    @State private var isVisualizerMode: Bool = false
    @State private var timerEndTimestamp: Date? = nil

    private let timerTicker = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        GeometryReader { screenGeo in
            let screenWidth = screenGeo.size.width
            let screenHeight = screenGeo.size.height

            ZStack(alignment: .bottom) {
                // ── Solid Deep Black Base Canvas ──
                Color.black
                    .ignoresSafeArea()

                // ── Deep Atmospheric Fullscreen Backdrop (Fades out in Particle Visualizer Mode) ──
                let activeBanner = bannerFor(profile: activeProfile)

                Image(activeBanner.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth, height: screenHeight)
                    .clipped()
                    .overlay(
                        LinearGradient(
                            colors: [
                                Color.black.opacity(0.35),
                                Color.clear,
                                Color.black.opacity(0.40)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                        .ignoresSafeArea()
                    )
                    .opacity(isVisualizerMode ? 0.0 : 1.0)
                    .animation(.easeInOut(duration: 0.40), value: isVisualizerMode)

                // ── Normal Mode: Main Player Interface ──
                if activeOverlay == .none {
                    ZStack {
                        // Background tap gesture: Always toggles play/pause (normal, Zen, and Visualizer modes)
                        Color.clear
                            .contentShape(Rectangle())
                            .onTapGesture {
                                togglePlayPause()
                            }

                        // Top Navigation Toolbar just below Dynamic Island
                        // Hosts both the Eye Icon (Zen Mode) and Particle Wave Icon (Audio Visualizer Mode)
                        VStack {
                            HStack(spacing: 8) {
                                // 1. Eye Button (Zen Mode - Fullscreen Image Immersion)
                                Button(action: {
                                    HapticManager.shared.playTransientHeartbeat(intensity: 0.4, sharpness: 0.5)
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        if isVisualizerMode {
                                            isVisualizerMode = false
                                            HapticManager.shared.stop()
                                        }
                                        isZenMode.toggle()
                                    }
                                }) {
                                    Image(systemName: isZenMode ? "eye" : "eye.slash")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(isZenMode ? 0.95 : 0.55))
                                        .shadow(color: Color.black.opacity(0.8), radius: 6, x: 0, y: 2)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Circle())
                                }
                                .buttonStyle(.plain)

                                // 2. Particle Wave Visualizer Button (Audio-Reactive Radial Wave Mode)
                                Button(action: {
                                    HapticManager.shared.playTransientHeartbeat(intensity: 0.4, sharpness: 0.5)
                                    withAnimation(.easeInOut(duration: 0.35)) {
                                        if isZenMode { isZenMode = false }
                                        isVisualizerMode.toggle()
                                        if isVisualizerMode && isPlaying {
                                            HapticManager.shared.start()
                                        } else {
                                            HapticManager.shared.stop()
                                        }
                                    }
                                }) {
                                    Image(systemName: isVisualizerMode ? "waveform.circle.fill" : "waveform.circle")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white.opacity(isVisualizerMode ? 0.95 : 0.55))
                                        .shadow(color: Color.black.opacity(0.8), radius: 6, x: 0, y: 2)
                                        .frame(width: 44, height: 44)
                                        .contentShape(Circle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.top, 38)

                            Spacer()
                        }
                        .zIndex(20)

                        // Main Center Stage & Bottom Controls
                        VStack(spacing: 0) {
                            Spacer()

                            if !isZenMode {
                                if isVisualizerMode {
                                    // ── Circular Audio-Reactive Wave & Particle Visualizer ──
                                    CircularParticleWaveVisualizerView(
                                        isPlaying: isPlaying
                                    )
                                    .frame(width: 320, height: 320)
                                    .offset(y: 20)
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                } else {
                                    // ── Original Clean Circular Timer Ring ──
                                    FullCircularTimerView(
                                        remainingSeconds: $remainingTimerSeconds,
                                        totalDuration: $totalTimerDuration,
                                        isPlaying: isPlaying,
                                        timerEndTimestamp: timerEndTimestamp
                                    )
                                    .frame(width: 318, height: 318)
                                    .offset(y: 20)
                                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
                                }
                            }

                            Spacer()

                            // Bottom Dock Controls: [‹ Prev] [🎵 Sounds] [⏵/⏸ Play/Pause] [✏️ Edit] [› Next] (+7% Size)
                            HStack(spacing: 24) {
                                // ‹ 1. Previous Sound Track
                                Button(action: { selectPreviousSound() }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 21.4, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 47, height: 47)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                // 🎵 2. Relaxing Sounds Button
                                Button(action: {
                                    HapticManager.shared.start()
                                    activeOverlay = .soundSelection
                                }) {
                                    Image(systemName: "music.note")
                                        .font(.system(size: 22.5, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 47, height: 47)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                // ⏵/⏸ 3. Play / Pause Button
                                Button(action: { togglePlayPause() }) {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                        .frame(width: 47, height: 47)
                                        .offset(x: isPlaying ? 0 : 1.5)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                // ✏️ 4. Edit Timer Button
                                Button(action: {
                                    HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.6)
                                    withAnimation(.easeInOut(duration: 0.25)) {
                                        activeOverlay = .editTimer
                                    }
                                }) {
                                    Image(systemName: "pencil")
                                        .font(.system(size: 21.4, weight: .medium))
                                        .foregroundColor(.white)
                                        .frame(width: 47, height: 47)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                // › 5. Next Sound Track
                                Button(action: { selectNextSound() }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 21.4, weight: .semibold))
                                        .foregroundColor(.white)
                                        .frame(width: 47, height: 47)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.bottom, 36)
                            .opacity((isZenMode || isVisualizerMode) ? 0 : 1)
                            .animation(.easeInOut(duration: 0.35), value: isZenMode || isVisualizerMode)
                            .allowsHitTesting(!isZenMode && !isVisualizerMode)
                        }
                    }
                    .frame(width: screenWidth, height: screenHeight)
                    .transition(.identity)
                }

                // ── Edit Mode: Solid Black + Top Timer + Full Height Waves + Bottom Checkmark ──
                if activeOverlay == .editTimer {
                    ZStack(alignment: .bottom) {
                        Color.black
                            .ignoresSafeArea()

                        // Full Height Fluid Wave Measuring Lines (Brought closer to timer & checkmark)
                        TallFusedMeasuringLinesView(
                            remainingSeconds: $remainingTimerSeconds,
                            totalDuration: $totalTimerDuration,
                            isDragging: $isDraggingTimer
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()

                        // Top Clean Digital Timer in Edit Mode (Exact 44pt size matching main screen)
                        VStack {
                            Text(formatNoLeadingZeroHours(remainingTimerSeconds))
                                .font(.system(size: 44, weight: .light, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.90), radius: 8, x: 0, y: 3)
                                .padding(.top, 96)

                            Spacer()
                        }
                        .allowsHitTesting(false) // Let drag touch pass through to the measuring lines

                        // Floating Checkmark Confirmation Button (+7% Size, exact matching 47x47 frame)
                        Button(action: {
                            HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.6)
                            if isPlaying {
                                timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                            }
                            activeOverlay = .none
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 25.7, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.95), radius: 8, x: 0, y: 3)
                                .frame(width: 47, height: 47)
                                .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .padding(.bottom, 36)
                        .zIndex(20)
                    }
                    .frame(width: screenWidth, height: screenHeight)
                    .transition(.identity)
                    .zIndex(50)
                }

                // ── Relaxing Sounds Library Overlay (Static Instant Cut) ──
                if activeOverlay == .soundSelection {
                    RelaxingSoundsFullView(
                        screenWidth: screenWidth,
                        activeProfile: $activeProfile,
                        isPlaying: isPlaying,
                        onSelectSound: { profile in
                            activeProfile = profile
                            isPlaying = true
                            timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                            activeOverlay = .none
                            AudioManager.shared.activeProfile = profile
                            if !AudioManager.shared.isAudioPlaying {
                                AudioManager.shared.start()
                            }
                        },
                        onClose: {
                            activeOverlay = .none
                        }
                    )
                    .frame(width: screenWidth, height: screenHeight)
                    .transition(.identity)
                    .zIndex(100)
                }
            }
            .frame(width: screenWidth, height: screenHeight)
            .clipped()
        }
        .ignoresSafeArea()
        .onReceive(timerTicker) { _ in
            if isPlaying && !isDraggingTimer && activeOverlay != .editTimer {
                if let end = timerEndTimestamp {
                    let left = end.timeIntervalSinceNow
                    if left <= 0 {
                        remainingTimerSeconds = 0
                        isPlaying = false
                        timerEndTimestamp = nil
                        AudioManager.shared.pause()
                    } else {
                        remainingTimerSeconds = left
                    }
                } else {
                    timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: AudioManager.audioStateDidChangeNotification)) { _ in
            let audioPlaying = AudioManager.shared.isAudioPlaying
            if isPlaying != audioPlaying {
                isPlaying = audioPlaying
                if audioPlaying {
                    if remainingTimerSeconds <= 0 {
                        remainingTimerSeconds = totalTimerDuration > 0 ? totalTimerDuration : 600.0
                    }
                    timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                } else {
                    timerEndTimestamp = nil
                }
            }
        }
        .onAppear {
            AudioManager.shared.activeProfile = activeProfile
            if isPlaying {
                timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                AudioManager.shared.start()
            }
        }
    }

    private func togglePlayPause() {
        HapticManager.shared.playTransientHeartbeat(intensity: 0.6, sharpness: 0.6)
        isPlaying.toggle()
        if isPlaying {
            if remainingTimerSeconds <= 0 {
                remainingTimerSeconds = totalTimerDuration > 0 ? totalTimerDuration : 600.0
            }
            timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
        } else {
            timerEndTimestamp = nil
        }
        AudioManager.shared.togglePlayPause()
    }

    private func selectPreviousSound() {
        HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.5)
        guard let currentIndex = allSoundBanners.firstIndex(where: { $0.profile == activeProfile }) else { return }
        let newIndex = (currentIndex - 1 + allSoundBanners.count) % allSoundBanners.count
        let newProfile = allSoundBanners[newIndex].profile
        activeProfile = newProfile
        AudioManager.shared.activeProfile = newProfile
        if !isPlaying {
            isPlaying = true
            timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
        }
        if !AudioManager.shared.isAudioPlaying {
            AudioManager.shared.start()
        }
    }

    private func selectNextSound() {
        HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.5)
        guard let currentIndex = allSoundBanners.firstIndex(where: { $0.profile == activeProfile }) else { return }
        let newIndex = (currentIndex + 1) % allSoundBanners.count
        let newProfile = allSoundBanners[newIndex].profile
        activeProfile = newProfile
        AudioManager.shared.activeProfile = newProfile
        if !isPlaying {
            isPlaying = true
            timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
        }
        if !AudioManager.shared.isAudioPlaying {
            AudioManager.shared.start()
        }
    }
}

// MARK: ── Clean Time Formatter ───────────────────────────────────────────────

private func formatNoLeadingZeroHours(_ seconds: TimeInterval) -> String {
    let total = max(0, Int(ceil(seconds)))
    let hrs = total / 3600
    let mins = (total % 3600) / 60
    let secs = total % 60
    if hrs > 0 {
        return String(format: "%d:%02d:%02d", hrs, mins, secs)
    } else {
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: ── 1. Circular Countdown Timer (Original Smooth Ring & Gliding Dot) ───

private struct FullCircularTimerView: View {
    @Binding var remainingSeconds: TimeInterval
    @Binding var totalDuration: TimeInterval
    let isPlaying: Bool
    let timerEndTimestamp: Date?

    var body: some View {
        if isPlaying {
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                timerBody(at: timeline.date)
            }
        } else {
            timerBody(at: Date())
        }
    }

    @ViewBuilder
    private func timerBody(at now: Date) -> some View {
        let currentRemaining: Double = {
            if isPlaying, let end = timerEndTimestamp {
                return max(0.0, end.timeIntervalSince(now))
            }
            return remainingSeconds
        }()

        let progress: Double = {
            guard totalDuration > 0 else { return 1.0 }
            return max(0.0, min(1.0, currentRemaining / totalDuration))
        }()

        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let radius = size / 2
            let center = CGPoint(x: size / 2, y: size / 2)

            let angle = (progress * 360.0) - 90.0
            let rad = angle * .pi / 180.0
            let tickX = center.x + (radius - 10) * CGFloat(cos(rad))
            let tickY = center.y + (radius - 10) * CGFloat(sin(rad))

            ZStack {
                // Background Track Ring
                Circle()
                    .stroke(Color.white.opacity(0.16), lineWidth: 4.0)
                    .frame(width: (radius - 10) * 2, height: (radius - 10) * 2)

                // Foreground Animated Smooth Flowing Remaining Arc
                Circle()
                    .trim(from: 0.0, to: CGFloat(progress))
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 4.5, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: (radius - 10) * 2, height: (radius - 10) * 2)

                // Minimal Little White Dot (Smooth 60/120fps continuous glide)
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .shadow(color: Color.white.opacity(0.85), radius: 3, x: 0, y: 0)
                    .position(x: tickX, y: tickY)

                // Center Digital Countdown (Exact 44pt rounded light font)
                Text(formatNoLeadingZeroHours(currentRemaining))
                    .font(.system(size: 44, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.90), radius: 8, x: 0, y: 3)
            }
        }
    }
}

// MARK: ── 2. Circular Audio-Reactive Wave & Particle Visualizer ──────────────

private struct CircularParticleWaveVisualizerView: View {
    let isPlaying: Bool
    @State private var lastTransientHapticTime: TimeInterval = 0.0

    var body: some View {
        if isPlaying {
            TimelineView(.animation(minimumInterval: 1.0 / 60.0)) { timeline in
                visualizerBody(at: timeline.date)
            }
        } else {
            visualizerBody(at: Date())
        }
    }

    @ViewBuilder
    private func visualizerBody(at now: Date) -> some View {
        let time = now.timeIntervalSinceReferenceDate
        let audio = AudioManager.shared
        let level = isPlaying ? CGFloat(audio.audioLevel) : 0.0
        let peak = isPlaying ? CGFloat(audio.audioPeak) : 0.0
        let bass = isPlaying ? CGFloat(audio.audioBass) : 0.0
        let mid = isPlaying ? CGFloat(audio.audioMid) : 0.0
        let treble = isPlaying ? CGFloat(audio.audioTreble) : 0.0
        let transient = isPlaying ? CGFloat(audio.audioTransient) : 0.0
        let freqs = isPlaying ? audio.audioFrequencies : Array(repeating: Float(0.0), count: 16)
        let waveform = isPlaying ? audio.audioWaveform : Array(repeating: Float(0.0), count: 64)

        // Real-time tactile vibration driven directly by acoustic energy and transients
        let _ = updateHaptics(now: time, level: level, peak: peak, bass: bass, mid: mid, treble: treble, transient: transient)

        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)
            let baseRadius: CGFloat = size * 0.38

            ZStack {
                // ── 1. Core Luminous Breathing Glow (Reacts directly to Bass and Overall Energy) ──
                let glowScale = 1.0 + Double(bass) * 0.35 + Double(level) * 0.25
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                Color.white.opacity(0.14 + Double(level) * 0.35 + Double(bass) * 0.20),
                                Color(white: 0.70).opacity(0.06 + Double(level) * 0.15),
                                Color.clear
                            ],
                            center: .center,
                            startRadius: 8,
                            endRadius: baseRadius * 1.35 * CGFloat(glowScale)
                        )
                    )
                    .frame(width: baseRadius * 2.8 * CGFloat(glowScale), height: baseRadius * 2.8 * CGFloat(glowScale))

                // ── 2. Canvas: Live Acoustic Waveform, Spectrum Rings & Dynamic Constellations ──
                Canvas { context, canvasSize in
                    let cX = canvasSize.width / 2
                    let cY = canvasSize.height / 2

                    // ── A. Inner Bass & Harmonic Core Ring ──
                    let innerR = baseRadius * 0.62 + bass * 16.0 + level * 8.0
                    var innerPath = Path()
                    let innerSteps = 64
                    for s in 0...innerSteps {
                        let theta = (Double(s) / Double(innerSteps)) * 2.0 * .pi
                        // Subtle harmonic resonance driven by lower mids
                        let harmonic = sin(theta * 2.0) * Double(bass) * 4.0
                        let r = innerR + CGFloat(harmonic)
                        let pX = cX + r * CGFloat(cos(theta))
                        let pY = cY + r * CGFloat(sin(theta))
                        if s == 0 { innerPath.move(to: CGPoint(x: pX, y: pY)) }
                        else { innerPath.addLine(to: CGPoint(x: pX, y: pY)) }
                    }
                    innerPath.closeSubpath()
                    let innerAlpha = 0.35 + Double(bass) * 0.45 + Double(level) * 0.20
                    context.stroke(
                        innerPath,
                        with: .color(Color(white: 0.85, opacity: min(1.0, innerAlpha))),
                        style: StrokeStyle(lineWidth: 1.2 + bass * 2.0, lineCap: .round, lineJoin: .round)
                    )

                    // ── B. Middle Frequency Spectrum Ribbon (16-Band Radial Equalizer) ──
                    var spectrumPath = Path()
                    let specSteps = 96
                    let specBaseR = baseRadius * 0.86 + level * 10.0
                    for s in 0...specSteps {
                        let frac = Double(s) / Double(specSteps)
                        let theta = frac * 2.0 * .pi
                        
                        // Symmetrical frequency mapping across 16 bands
                        let bandFrac = abs(sin(theta)) * 15.0
                        let b0 = Int(bandFrac)
                        let b1 = min(15, b0 + 1)
                        let interp = Float(bandFrac - Double(b0))
                        let bandVal = freqs[b0] * (1.0 - interp) + freqs[b1] * interp
                        
                        let displacement = CGFloat(bandVal) * (26.0 + level * 18.0)
                        let r = specBaseR + displacement
                        let pX = cX + r * CGFloat(cos(theta))
                        let pY = cY + r * CGFloat(sin(theta))
                        if s == 0 { spectrumPath.move(to: CGPoint(x: pX, y: pY)) }
                        else { spectrumPath.addLine(to: CGPoint(x: pX, y: pY)) }
                    }
                    spectrumPath.closeSubpath()
                    let specAlpha = 0.45 + Double(level) * 0.40 + Double(mid) * 0.15
                    context.stroke(
                        spectrumPath,
                        with: .color(Color(white: 0.92, opacity: min(1.0, specAlpha))),
                        style: StrokeStyle(lineWidth: 1.6 + level * 2.2, lineCap: .round, lineJoin: .round)
                    )

                    // ── C. Outer Live Acoustic Waveform Ribbon (Direct Oscilloscope Stream) ──
                    var wavePath = Path()
                    let waveCount = waveform.count // 64 samples
                    let waveBaseR = baseRadius * 1.06
                    for s in 0...waveCount {
                        let idx = s % waveCount
                        let theta = (Double(s) / Double(waveCount)) * 2.0 * .pi
                        let waveSample = CGFloat(waveform[idx])
                        let waveDisplacement = waveSample * (level * 32.0 + peak * 14.0)
                        let r = waveBaseR + waveDisplacement
                        let pX = cX + r * CGFloat(cos(theta))
                        let pY = cY + r * CGFloat(sin(theta))
                        if s == 0 { wavePath.move(to: CGPoint(x: pX, y: pY)) }
                        else { wavePath.addLine(to: CGPoint(x: pX, y: pY)) }
                    }
                    wavePath.closeSubpath()
                    let waveAlpha = 0.55 + Double(level) * 0.45
                    context.stroke(
                        wavePath,
                        with: .color(Color.white.opacity(min(1.0, waveAlpha))),
                        style: StrokeStyle(lineWidth: 1.8 + level * 2.0 + peak * 1.2, lineCap: .round, lineJoin: .round)
                    )

                    // ── D. Audio-Reactive Constellation Particles (36 Acoustic Emitters) ──
                    let numParticles = 36
                    for i in 0..<numParticles {
                        let frac = Double(i) / Double(numParticles)
                        let baseTheta = frac * 2.0 * .pi
                        
                        // Map particle to corresponding frequency band
                        let bandIdx = Int(frac * 15.0) % 16
                        let bandEnergy = CGFloat(freqs[bandIdx])
                        
                        // Particles burst outward when sound / transients hit
                        let burst = bandEnergy * 24.0 + transient * 20.0 + level * 12.0
                        let pR = baseRadius * 1.18 + burst
                        
                        let pX = cX + pR * CGFloat(cos(baseTheta))
                        let pY = cY + pR * CGFloat(sin(baseTheta))
                        
                        let dotSize: CGFloat = 1.6 + bandEnergy * 2.8 + transient * 2.4 + level * 1.4
                        let pAlpha = 0.35 + Double(bandEnergy) * 0.45 + Double(transient) * 0.20 + Double(level) * 0.20
                        
                        let particleRect = CGRect(x: pX - dotSize, y: pY - dotSize, width: dotSize * 2, height: dotSize * 2)
                        context.fill(
                            Path(ellipseIn: particleRect),
                            with: .color(Color.white.opacity(min(1.0, pAlpha)))
                        )
                    }
                }
                .frame(width: size, height: size)
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
        .onAppear {
            if isPlaying {
                HapticManager.shared.start()
            }
        }
        .onDisappear {
            HapticManager.shared.stop()
        }
        .onChange(of: isPlaying) { _, playing in
            if playing {
                HapticManager.shared.start()
            } else {
                HapticManager.shared.stop()
            }
        }
    }

    private func updateHaptics(now: TimeInterval, level: CGFloat, peak: CGFloat, bass: CGFloat, mid: CGFloat, treble: CGFloat, transient: CGFloat) {
        if isPlaying {
            let dynamicIntensity = Float(min(1.0, max(0.0, Double(level) * 0.70 + Double(bass) * 0.50)))
            let dynamicSharpness = Float(min(1.0, max(0.0, 0.10 + Double(treble) * 0.65 + Double(mid) * 0.25)))
            HapticManager.shared.targetIntensity = dynamicIntensity
            HapticManager.shared.targetSharpness = dynamicSharpness

            // Immediate tactile click/tap for transient events (e.g. cricket chirps, fire pops, water drops)
            if transient > 0.35 && (now - lastTransientHapticTime > 0.09) {
                lastTransientHapticTime = now
                HapticManager.shared.playSingleTransient(
                    intensity: Float(min(1.0, transient)),
                    sharpness: Float(min(1.0, 0.45 + Double(treble) * 0.45))
                )
            }
        } else {
            HapticManager.shared.targetIntensity = 0.0
            HapticManager.shared.targetSharpness = 0.0
        }
    }
}

// MARK: ── 3. Tall Interactive Fluid Wave Measuring Lines (Edit Mode) ─────────

private struct TallFusedMeasuringLinesView: View {
    @Binding var remainingSeconds: TimeInterval
    @Binding var totalDuration: TimeInterval
    @Binding var isDragging: Bool

    private let maxTime: TimeInterval = 14400.0 // 4 hours
    @State private var dragOffset: CGFloat = 0.0
    @State private var touchLocation: CGPoint? = nil
    @State private var dragVelocity: CGFloat = 0.0

    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { timeline in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let width = geo.size.width
                let height = geo.size.height
                let midX = width / 2
                let midY = height / 2

                Canvas { context, size in
                    // ── 1. Center Focal Aura Glow ──
                    let glowRect = CGRect(x: 0, y: midY - 80, width: width, height: 160)
                    context.fill(
                        Path(glowRect),
                        with: .radialGradient(
                            Gradient(colors: [
                                Color.white.opacity(0.08),
                                Color.clear
                            ]),
                            center: CGPoint(x: midX, y: midY),
                            startRadius: 10,
                            endRadius: 160
                        )
                    )

                    // ── 2. Floating Shimmer Particles along Center Focal Zone ──
                    let numParticles = 12
                    for i in 0..<numParticles {
                        let seed = Double(i) * 137.5
                        let baseX = (CGFloat(sin(seed)) * 0.5 + 0.5) * (width - 80) + 40
                        let baseY = midY + CGFloat(cos(seed * 1.3)) * 60

                        let driftY = CGFloat(sin(time * 1.8 + seed)) * 14.0 - dragVelocity * 0.45
                        let driftX = CGFloat(cos(time * 1.4 + seed)) * 8.0
                        let pX = max(20, min(width - 20, baseX + driftX))
                        let pY = baseY + driftY

                        let dist = abs(pY - midY)
                        let fade = max(0.0, 1.0 - dist / 65.0)
                        let pulse = 0.5 + 0.5 * sin(time * 2.5 + seed)
                        let pRadius: CGFloat = 1.0 + CGFloat(pulse) * 1.5

                        let particleRect = CGRect(x: pX - pRadius, y: pY - pRadius, width: pRadius * 2, height: pRadius * 2)
                        context.fill(
                            Path(ellipseIn: particleRect),
                            with: .color(Color.white.opacity(0.40 * Double(fade) * pulse))
                        )
                    }

                    // ── 3. Animated Fluid Wave Measuring Lines (Closer to timer & checkmark) ──
                    let lineSpacing: CGFloat = 18.0
                    let numLines = Int(height / lineSpacing) + 6
                    let offsetPx = CGFloat((remainingSeconds * (18.0 / 90.0)).truncatingRemainder(dividingBy: Double(lineSpacing)))

                    // Safe boundaries brought closer to the top timer and bottom checkmark
                    let topSafeFadeStart: CGFloat = 175.0
                    let topSafeFadeEnd: CGFloat = 145.0
                    let bottomSafeFadeStart: CGFloat = height - 155.0
                    let bottomSafeFadeEnd: CGFloat = height - 120.0

                    for i in -2...numLines {
                        let yPos = CGFloat(i) * lineSpacing - offsetPx
                        guard yPos >= topSafeFadeEnd && yPos <= bottomSafeFadeEnd else { continue }

                        let distFromCenter = abs(yPos - midY)
                        let focus = max(0.0, exp(-pow(Double(distFromCenter) / 105.0, 2)))

                        // Smooth gradient fade before touching top timer and bottom checkmark
                        var edgeFade: CGFloat = 1.0
                        if yPos < topSafeFadeStart {
                            edgeFade = max(0.0, min(1.0, (yPos - topSafeFadeEnd) / (topSafeFadeStart - topSafeFadeEnd)))
                        } else if yPos > bottomSafeFadeStart {
                            edgeFade = max(0.0, min(1.0, (bottomSafeFadeEnd - yPos) / (bottomSafeFadeEnd - bottomSafeFadeStart)))
                        }
                        guard edgeFade > 0.005 else { continue }
                        let smoothEdgeFade = sin(Double(edgeFade) * .pi / 2.0)

                        let lineWidth = (65.0 + CGFloat(focus) * 110.0) * (0.4 + 0.6 * CGFloat(smoothEdgeFade))
                        let numPts = 12
                        let xStart = midX - lineWidth / 2

                        var linePath = Path()
                        for p in 0...numPts {
                            let u = CGFloat(p) / CGFloat(numPts)
                            let x = xStart + u * lineWidth
                            let relX = (x - midX) / (lineWidth / 2)
                            let envelope = max(0.0, 1.0 - relX * relX)

                            let wave = CGFloat(sin(time * 2.6 + Double(yPos) * 0.035 + Double(relX) * 2.2)) * (2.0 + CGFloat(focus) * 5.0) * envelope

                            var pointerDeflect: CGFloat = 0.0
                            if let touch = touchLocation {
                                let dx = x - touch.x
                                let dy = yPos - touch.y
                                let distToPoint = hypot(dx, dy)
                                if distToPoint < 110 {
                                    let force = (1.0 - distToPoint / 110.0)
                                    pointerDeflect = force * max(-25.0, min(25.0, touch.y - yPos)) * 0.35 * envelope
                                }
                            }

                            let clampedVel = max(-10.0, min(10.0, dragVelocity))
                            let velocityBow = -clampedVel * CGFloat(focus) * envelope * 2.5
                            let finalY = yPos + wave + pointerDeflect + velocityBow

                            if p == 0 {
                                linePath.move(to: CGPoint(x: x, y: finalY))
                            } else {
                                linePath.addLine(to: CGPoint(x: x, y: finalY))
                            }
                        }

                        let lineAlpha = (0.12 + focus * 0.88) * smoothEdgeFade
                        let strokeW = 1.0 + CGFloat(focus) * 0.7

                        context.stroke(
                            linePath,
                            with: .color(Color.white.opacity(lineAlpha)),
                            style: StrokeStyle(lineWidth: strokeW, lineCap: .round)
                        )
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { val in
                        // Ignore touches near the bottom checkmark area
                        guard val.startLocation.y < geo.size.height - 80 else { return }
                        isDragging = true
                        touchLocation = val.location

                        let dy = val.translation.height - dragOffset
                        dragVelocity = dy
                        dragOffset = val.translation.height

                        let sensitivity: Double = 90.0 / 18.0
                        let secondsDelta = -Double(dy) * sensitivity

                        let currentTotal = totalDuration > 0 ? totalDuration : 600.0
                        let newTotal = max(60.0, min(maxTime, currentTotal + secondsDelta))
                        totalDuration = newTotal
                        remainingSeconds = newTotal
                    }
                    .onEnded { _ in
                        isDragging = false
                        dragOffset = 0.0
                        touchLocation = nil
                        dragVelocity = 0.0
                    }
            )
        }
    }
}

// MARK: ── 2. Full Relaxing Sounds Selection Library (Static Instant Cut) ──────

private struct RelaxingSoundsFullView: View {
    let screenWidth: CGFloat
    @Binding var activeProfile: SoundProfile
    let isPlaying: Bool
    let onSelectSound: (SoundProfile) -> Void
    let onClose: () -> Void

    private let cardHeight: CGFloat = 135.0

    var body: some View {
        ZStack(alignment: .bottom) {
            // Solid Black Backdrop
            Color.black
                .ignoresSafeArea()

            // Vertical Soundscapes Scroll View
            ScrollView(.vertical, showsIndicators: false) {
                LazyVStack(spacing: 0) {
                    ForEach(allSoundBanners) { banner in
                        let isThisActive = (banner.profile == activeProfile)

                        Button(action: {
                            HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.6)
                            onSelectSound(banner.profile)
                        }) {
                            ZStack(alignment: .bottom) {
                                // 1. Sound Scenic Background Picture
                                Image(banner.imageName)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: screenWidth, height: cardHeight, alignment: banner.previewAlignment)
                                    .clipped()

                                // 2. Dark Tint for High Contrast Legibility
                                Rectangle()
                                    .fill(Color.black.opacity(isThisActive ? 0.22 : 0.38))
                                    .frame(width: screenWidth, height: cardHeight)

                                // 3. Content Row (Title on Left, Pure White Checkmark on Right)
                                HStack(spacing: 14) {
                                    Text(banner.title)
                                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black.opacity(0.95), radius: 6, x: 0, y: 2)
                                        .frame(maxWidth: .infinity, alignment: .leading)

                                    if isThisActive {
                                        Image(systemName: "checkmark")
                                            .font(.system(size: 20, weight: .bold))
                                            .foregroundColor(.white)
                                            .shadow(color: Color.black.opacity(0.95), radius: 4, x: 0, y: 2)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .frame(width: screenWidth, height: cardHeight)
                            }
                            .frame(width: screenWidth, height: cardHeight)
                            .contentShape(Rectangle())
                            .clipped()
                        }
                        .buttonStyle(.plain)
                        .contentShape(Rectangle())
                    }
                }
                .padding(.top, 50)
                .padding(.bottom, 84) // Balanced clearance so cards scroll smoothly
            }
            .frame(width: screenWidth)
            .ignoresSafeArea(edges: .bottom)

            // Ultra-Smooth Bottom Fade Scrim & Floating Exit (X) Button
            VStack(spacing: 0) {
                Spacer()
                LinearGradient(
                    stops: [
                        .init(color: .clear, location: 0.0),
                        .init(color: Color.black.opacity(0.35), location: 0.4),
                        .init(color: Color.black.opacity(0.75), location: 0.75),
                        .init(color: Color.black.opacity(0.95), location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: screenWidth, height: 85)
                .allowsHitTesting(false)
            }
            .ignoresSafeArea(edges: .bottom)

            // Floating Exit (X) Button (+7% Size, exact matching 47x47 frame)
            Button(action: {
                HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.6)
                onClose()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 25.7, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.95), radius: 8, x: 0, y: 3)
                    .frame(width: 47, height: 47)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 36)
            .zIndex(20)
        }
        .frame(width: screenWidth)
    }
}
