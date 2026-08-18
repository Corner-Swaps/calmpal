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
}

public let allSoundBanners: [SoundBannerTheme] = [
    SoundBannerTheme(id: "crickets-night", profile: .nightCrickets, title: "Crickets Night", imageName: "crickets-night"),
    SoundBannerTheme(id: "ocean-waves", profile: .oceanWaves, title: "Ocean Waves", imageName: "ocean-waves"),
    SoundBannerTheme(id: "gentle-rain", profile: .gentleRain, title: "Gentle Rain", imageName: "gentle-rain"),
    SoundBannerTheme(id: "rain-window", profile: .rainOnWindow, title: "Rain on Window", imageName: "rain-window"),
    SoundBannerTheme(id: "cozy-campfire", profile: .cozyCampfire, title: "Cozy Campfire", imageName: "cozy-campfire"),
    SoundBannerTheme(id: "waterfall", profile: .waterfall, title: "Forest Waterfall", imageName: "waterfall"),
    SoundBannerTheme(id: "flowing-river", profile: .forestRiver, title: "Flowing River", imageName: "flowing-river"),

    SoundBannerTheme(id: "forest-birds", profile: .forestBirdsong, title: "Morning Birds", imageName: "forest-birds"),
    SoundBannerTheme(id: "rolling-thunder", profile: .rollingThunder, title: "Rolling Thunder", imageName: "rolling-thunder"),
    SoundBannerTheme(id: "heavy-rain", profile: .heavyRain, title: "Heavy Downpour", imageName: "heavy-rain"),
    SoundBannerTheme(id: "rain-canopy", profile: .rainCanopy, title: "Rain on Leaves", imageName: "rain-canopy"),
    SoundBannerTheme(id: "tropical-jungle", profile: .tropicalJungle, title: "Tropical Jungle", imageName: "tropical-jungle"),
    SoundBannerTheme(id: "evening-frogs", profile: .eveningFrogs, title: "Evening Frogs", imageName: "evening-frogs"),

    SoundBannerTheme(id: "cat-purr", profile: .catPurring, title: "Cat Purring", imageName: "cat-purr"),
    SoundBannerTheme(id: "howling-wind", profile: .howlingWind, title: "Howling Winter Gale", imageName: "howling-wind"),
    SoundBannerTheme(id: "warm-cafe", profile: .warmCafe, title: "Warm Coffee House", imageName: "warm-cafe"),
    SoundBannerTheme(id: "quiet-library", profile: .quietLibrary, title: "Quiet Library", imageName: "quiet-library"),
    SoundBannerTheme(id: "night-village", profile: .nightVillage, title: "Quiet Mountain Village", imageName: "night-village"),
    SoundBannerTheme(id: "temple-sanctuary", profile: .templeSanctuary, title: "Sacred Temple", imageName: "temple-sanctuary"),
    SoundBannerTheme(id: "deep-underwater", profile: .deepUnderwater, title: "Deep Underwater", imageName: "deep-underwater"),

    SoundBannerTheme(id: "coastal-seagulls", profile: .coastalSeagulls, title: "Coastal Seagulls", imageName: "coastal-seagulls"),
    SoundBannerTheme(id: "walk-leaves", profile: .walkOnLeaves, title: "Walk on Leaves", imageName: "walk-leaves"),
    SoundBannerTheme(id: "water-droplets", profile: .waterDroplets, title: "Water Droplets", imageName: "water-droplets")
]

public func bannerFor(profile: SoundProfile) -> SoundBannerTheme {
    allSoundBanners.first(where: { $0.profile == profile }) ?? allSoundBanners[0]
}

// MARK: ── Main View ──────────────────────────────────────────────────────────

public struct GroundingScreenView: View {

    @State private var activeProfile: SoundProfile = .nightCrickets
    @State private var isPlaying: Bool = true

    // Sleep Timer (Preset default: 30 minutes = 1800s)
    @State private var remainingTimerSeconds: TimeInterval = 1800.0
    @State private var totalTimerDuration: TimeInterval = 1800.0
    @State private var isDraggingTimer: Bool = false
    @State private var isEditingTimer: Bool = false

    // Sound Library View
    @State private var showSoundsSheet: Bool = false

    private let timerTicker = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    public init() {}

    private var activeBanner: SoundBannerTheme {
        bannerFor(profile: activeProfile)
    }

    public var body: some View {
        ZStack {
            // ── Dynamic Fullscreen Scenic Photographic Backdrop ──
            Image(activeBanner.imageName)
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
                .overlay(
                    LinearGradient(
                        colors: [
                            Color.black.opacity(0.15),
                            Color.clear,
                            Color.black.opacity(0.40)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .ignoresSafeArea()
                )

            // ── Normal Mode: Main Player Interface ──
            if !isEditingTimer {
                VStack(spacing: 0) {
                    // Tap anywhere on the main screen (background, title, circular clock) to play / pause
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture {
                            togglePlayPause()
                        }
                        .overlay(
                            VStack(spacing: 0) {
                                Spacer()

                                // Centered Group: Elevated Title + Circular Timer Ring
                                VStack(spacing: 32) {
                                    Text(activeBanner.title)
                                        .font(.system(size: 26, weight: .regular, design: .rounded))
                                        .tracking(0.4)
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black.opacity(0.85), radius: 6, x: 0, y: 2)

                                    FullCircularTimerView(
                                        remainingSeconds: $remainingTimerSeconds,
                                        totalDuration: $totalTimerDuration
                                    )
                                    .frame(width: 240, height: 240)
                                }
                                .offset(y: -16)

                                Spacer()
                            }
                            .allowsHitTesting(false) // Let the tap pass through to the tap handler
                        )

                    // Bottom Dock Controls: [🎵 Sounds] [⏵/⏸ Play/Pause] [✏️ Edit] (All 50pt)
                    HStack(spacing: 26) {
                        // 🎵 1. Relaxing Sounds Button (50pt)
                        Button(action: {
                            HapticManager.shared.start()
                            showSoundsSheet = true
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.35))
                                    .frame(width: 50, height: 50)
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                    .frame(width: 50, height: 50)

                                Image(systemName: "music.note")
                                    .font(.system(size: 19, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)

                        // ⏵/⏸ 2. Play / Pause Button (50pt)
                        Button(action: { togglePlayPause() }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.35))
                                    .frame(width: 50, height: 50)
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                    .frame(width: 50, height: 50)

                                Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundColor(.white)
                                    .offset(x: isPlaying ? 0 : 1.5)
                            }
                        }
                        .buttonStyle(.plain)

                        // ✏️ 3. Edit Timer Button (50pt)
                        Button(action: {
                            HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.6)
                            withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                                isEditingTimer = true
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(Color.black.opacity(0.35))
                                    .frame(width: 50, height: 50)
                                Circle()
                                    .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                    .frame(width: 50, height: 50)

                                Image(systemName: "pencil")
                                    .font(.system(size: 18, weight: .semibold))
                                    .foregroundColor(.white)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 44)
                }
                .transition(.opacity)
            }

            // ── Edit Mode: Solid Black + Top Timer + Fluid Waves + Bottom Checkmark (50pt) ──
            if isEditingTimer {
                ZStack(alignment: .bottom) {
                    Color.black
                        .ignoresSafeArea()

                    VStack(spacing: 0) {
                        // Top Clean Digital Timer in Edit Mode
                        Text(formatNoLeadingZeroHours(remainingTimerSeconds))
                            .font(.system(size: 44, weight: .light, design: .rounded))
                            .monospacedDigit()
                            .foregroundColor(.white)
                            .padding(.top, 64)

                        // Tall Fluid Wave Measuring Lines View
                        TallFusedMeasuringLinesView(
                            remainingSeconds: $remainingTimerSeconds,
                            totalDuration: $totalTimerDuration,
                            isDragging: $isDraggingTimer
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.vertical, 16)

                        Spacer().frame(height: 94)
                    }

                    // Floating Checkmark Confirmation Button (50pt, subtle glass)
                    Button(action: {
                        HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.5)
                        withAnimation(.spring(response: 0.28, dampingFraction: 0.75)) {
                            isEditingTimer = false
                        }
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.black.opacity(0.40))
                                .frame(width: 50, height: 50)
                            Circle()
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                                .frame(width: 50, height: 50)

                            Image(systemName: "checkmark")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
                    }
                    .buttonStyle(.plain)
                    .padding(.bottom, 44)
                }
                .transition(.opacity)
                .zIndex(50)
            }

            // ── Full-Screen Relaxing Sounds Sheet with Floating Bottom (X) Button (50pt) ──
            if showSoundsSheet {
                RelaxingSoundsFullView(
                    activeProfile: $activeProfile,
                    isPlaying: isPlaying,
                    onSelectSound: { selectedProfile in
                        activeProfile = selectedProfile
                        AudioManager.shared.activeProfile = selectedProfile
                        AudioManager.shared.start()
                        isPlaying = true
                        showSoundsSheet = false
                        HapticManager.shared.start()
                    },
                    onClose: {
                        showSoundsSheet = false
                    }
                )
                .transition(.opacity)
                .zIndex(100)
            }
        }
        .onAppear {
            setupInitialPlayback()
        }
        .onReceive(timerTicker) { _ in
            guard isPlaying, !isDraggingTimer, !isEditingTimer else { return }
            if remainingTimerSeconds > 0 {
                remainingTimerSeconds -= 1.0
            } else {
                togglePlayPause(forceStop: true)
            }
        }
    }

    private func setupInitialPlayback() {
        AudioManager.shared.activeProfile = activeProfile
        AudioManager.shared.start()
        isPlaying = true
    }

    private func togglePlayPause(forceStop: Bool = false) {
        HapticManager.shared.playTransientHeartbeat(intensity: 0.6, sharpness: 0.5)
        if forceStop {
            AudioManager.shared.pause()
            isPlaying = false
            return
        }
        if isPlaying {
            AudioManager.shared.pause()
            isPlaying = false
        } else {
            AudioManager.shared.resume()
            isPlaying = true
        }
    }
}

// MARK: ── Clean Time Formatter ───────────────────────────────────────────────

private func formatNoLeadingZeroHours(_ seconds: TimeInterval) -> String {
    let total = max(0, Int(seconds))
    let hrs = total / 3600
    let mins = (total % 3600) / 60
    let secs = total % 60
    if hrs > 0 {
        return String(format: "%d:%02d:%02d", hrs, mins, secs)
    } else {
        return String(format: "%d:%02d", mins, secs)
    }
}

// MARK: ── 1. Full Circle Timer View with Minimal White Dot ───────────────────

private struct FullCircularTimerView: View {
    @Binding var remainingSeconds: TimeInterval
    @Binding var totalDuration: TimeInterval

    private let maxTime: TimeInterval = 14400.0 // 4 hours

    private var progress: Double {
        max(0.0, min(1.0, remainingSeconds / maxTime))
    }

    var body: some View {
        GeometryReader { geo in
            let radius = min(geo.size.width, geo.size.height) / 2
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            let angleRad = (progress * 360.0 - 90.0) * .pi / 180.0
            let tickX = center.x + CGFloat(cos(angleRad)) * (radius - 10)
            let tickY = center.y + CGFloat(sin(angleRad)) * (radius - 10)

            ZStack {
                // Background Track Ring
                Circle()
                    .stroke(Color.white.opacity(0.16), lineWidth: 3.5)
                    .frame(width: (radius - 10) * 2, height: (radius - 10) * 2)

                // White Progress Arc
                Circle()
                    .trim(from: 0, to: CGFloat(progress))
                    .stroke(
                        Color.white,
                        style: StrokeStyle(lineWidth: 4.0, lineCap: .round)
                    )
                    .rotationEffect(.degrees(-90))
                    .frame(width: (radius - 10) * 2, height: (radius - 10) * 2)

                // Minimal Little White Dot
                Circle()
                    .fill(Color.white)
                    .frame(width: 10, height: 10)
                    .shadow(color: Color.white.opacity(0.85), radius: 3, x: 0, y: 0)
                    .position(x: tickX, y: tickY)

                // Center Digital Countdown
                Text(formatNoLeadingZeroHours(remainingSeconds))
                    .font(.system(size: 38, weight: .light, design: .rounded))
                    .monospacedDigit()
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.85), radius: 6, x: 0, y: 2)
            }
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
                    // ── 1. Center Ambient Aura Beam ──
                    let glowRect = CGRect(x: 0, y: midY - 50, width: width, height: 100)
                    context.fill(
                        Path(glowRect),
                        with: .radialGradient(
                            Gradient(colors: [
                                Color.white.opacity(0.14),
                                Color.white.opacity(0.04),
                                Color.clear
                            ]),
                            center: CGPoint(x: midX, y: midY),
                            startRadius: 10,
                            endRadius: 160
                        )
                    )

                    // ── 2. Floating Shimmer Particles Interacting with Scroll (26 particles) ──
                    let numParticles = 26
                    for i in 0..<numParticles {
                        let seed = Double(i) * 137.5
                        let baseX = (CGFloat(sin(seed)) * 0.5 + 0.5) * (width - 80) + 40
                        let baseY = midY + CGFloat(cos(seed * 1.3)) * 60

                        let driftY = CGFloat(sin(time * 1.8 + seed)) * 14.0 - dragVelocity * 0.45
                        let driftX = CGFloat(cos(time * 1.4 + seed)) * 8.0
                        let pX = max(20, min(width - 20, baseX + driftX))
                        let pY = baseY + driftY

                        let dist = abs(pY - midY)
                        let fade = max(0.0, 1.0 - dist / 85.0)
                        let pulse = 0.5 + 0.5 * sin(time * 2.8 + seed)
                        let pRadius: CGFloat = 1.0 + CGFloat(pulse) * 1.2

                        let particleRect = CGRect(x: pX - pRadius, y: pY - pRadius, width: pRadius * 2, height: pRadius * 2)
                        context.fill(
                            Path(ellipseIn: particleRect),
                            with: .color(Color.white.opacity(0.35 * Double(fade) * pulse))
                        )
                    }

                    // ── 3. Hourglass Wavy Lines (Wide at ends ~185pt, Narrow in center waist ~75pt) ──
                    let lineSpacing: CGFloat = 7.0
                    let numLines = Int(height / lineSpacing)

                    for i in 0..<numLines {
                        let yPos = CGFloat(i) * lineSpacing
                        let distToCenter = abs(yPos - midY)
                        let normDist = min(1.0, distToCenter / (height / 2))

                        // Hourglass width profile: sleek waist in center, expanding outward
                        let hourglassCurve = pow(normDist, 1.7)
                        let lineWidth = 75.0 + hourglassCurve * 110.0

                        let wave = sin(time * 2.4 + Double(yPos) * 0.032) * (4.0 * (1.0 - normDist * 0.5) + 2.0)

                        var pointerDeflect: CGFloat = 0.0
                        if let touch = touchLocation {
                            let dy = yPos - touch.y
                            let dx = midX - touch.x
                            let pDist = hypot(dx, dy)
                            if pDist < 130 {
                                let factor = 1.0 - pDist / 130.0
                                pointerDeflect = sin(factor * .pi) * (dx * 0.38)
                            }
                        }

                        let velocityDeflect = dragVelocity * cos(normDist * .pi * 0.5) * 1.4
                        let currentMidX = midX + CGFloat(wave) + pointerDeflect + velocityDeflect

                        let xLeft = currentMidX - lineWidth / 2
                        let xRight = currentMidX + lineWidth / 2

                        let centerFocus = exp(-pow(Double(normDist) * 1.8, 2))
                        let alpha = max(0.16, min(0.95, 0.22 + centerFocus * 0.72))
                        let strokeWidth = 1.0 + CGFloat(centerFocus) * 0.6

                        var linePath = Path()
                        linePath.move(to: CGPoint(x: xLeft, y: yPos))
                        linePath.addLine(to: CGPoint(x: xRight, y: yPos))

                        context.stroke(
                            linePath,
                            with: .color(Color.white.opacity(alpha)),
                            style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round)
                        )
                    }
                }
            }
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { val in
                        isDragging = true
                        touchLocation = val.location
                        let deltaY = -val.translation.height - dragOffset
                        dragOffset = -val.translation.height
                        dragVelocity = deltaY

                        let deltaSeconds = Double(deltaY) * 14.0
                        remainingSeconds = max(60, min(maxTime, remainingSeconds + deltaSeconds))
                        totalDuration = remainingSeconds
                    }
                    .onEnded { _ in
                        isDragging = false
                        touchLocation = nil
                        dragOffset = 0.0
                        dragVelocity = 0.0
                        HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.5)
                    }
            )
        }
    }
}

// MARK: ── Full-Screen Relaxing Sounds View ───────────────────────────────────

private struct RelaxingSoundsFullView: View {
    @Binding var activeProfile: SoundProfile
    let isPlaying: Bool
    let onSelectSound: (SoundProfile) -> Void
    let onClose: () -> Void

    @State private var previewingProfile: SoundProfile? = nil
    @State private var initialProfile: SoundProfile = .nightCrickets
    @State private var wasPlayingInitially: Bool = true

    var body: some View {
        ZStack(alignment: .bottom) {
            Color(red: 0.06, green: 0.06, blue: 0.08)
                .ignoresSafeArea()

            ScrollView(showsIndicators: true) {
                LazyVStack(spacing: 0) {
                    ForEach(allSoundBanners) { banner in
                        let isThisPreviewing = previewingProfile == banner.profile

                        ZStack(alignment: .leading) {
                            Image(banner.imageName)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                                .frame(height: 96)
                                .clipped()

                            LinearGradient(
                                colors: [
                                    Color.black.opacity(0.35),
                                    Color.black.opacity(0.05),
                                    Color.black.opacity(0.35)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )

                            VStack {
                                Spacer()
                                Rectangle()
                                    .fill(Color.black.opacity(0.50))
                                    .frame(height: 1)
                            }

                            HStack(spacing: 14) {
                                Button(action: {
                                    togglePreview(for: banner.profile)
                                }) {
                                    Image(systemName: isThisPreviewing ? "stop.fill" : "speaker.wave.2")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(isThisPreviewing ? .white : .white.opacity(0.75))
                                        .padding(6)
                                }
                                .buttonStyle(.plain)

                                Text(banner.title)
                                    .font(.system(size: 16, weight: .regular))
                                    .foregroundColor(.white)
                                    .shadow(color: Color.black.opacity(0.85), radius: 4, x: 0, y: 1)
                                    .frame(maxWidth: .infinity, alignment: .leading)

                                Button(action: {
                                    previewingProfile = nil
                                    onSelectSound(banner.profile)
                                }) {
                                    Image(systemName: "play.fill")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                        .padding(6)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, 20)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                previewingProfile = nil
                                onSelectSound(banner.profile)
                            }
                        }
                        .frame(height: 96)
                    }
                }
                .padding(.bottom, 94)
            }

            // Floating Circular Exit (X) Button (50pt)
            Button(action: handleClose) {
                ZStack {
                    Circle()
                        .fill(Color.black.opacity(0.40))
                        .frame(width: 50, height: 50)
                    Circle()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                    Image(systemName: "xmark")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                .shadow(color: Color.black.opacity(0.5), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.bottom, 44)
        }
        .onAppear {
            initialProfile = activeProfile
            wasPlayingInitially = isPlaying
        }
    }

    private func togglePreview(for profile: SoundProfile) {
        HapticManager.shared.playTransientHeartbeat(intensity: 0.4, sharpness: 0.6)
        if previewingProfile == profile {
            previewingProfile = nil
            AudioManager.shared.pause()
        } else {
            previewingProfile = profile
            AudioManager.shared.activeProfile = profile
            AudioManager.shared.start()
        }
    }

    private func handleClose() {
        if previewingProfile != nil {
            AudioManager.shared.activeProfile = initialProfile
            if wasPlayingInitially {
                AudioManager.shared.start()
            } else {
                AudioManager.shared.pause()
            }
        }
        onClose()
    }
}
