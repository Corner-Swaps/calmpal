//
//  GroundingScreenView.swift
//  Calmpal
//
//  Atmospheric Nature & Sleep Player:
//  • Dynamic Fullscreen Scenic Photographic Backdrop (Instant Cut)
//  • Preset Default Timer: 10:00 (600s)
//  • Bottom Action Dock: [‹ Prev] [🎵 Sounds] [⏵/⏸ Play] [✏️ Edit Timer] [› Next]
//  • Center Screen: Clean Minimal Title + Full Circular Sleep Timer Ring (Pure Minimal Dot)
//  • In Edit Mode: Solid Black View + Top Clean Digital Timer + Fluid Wave Bottleneck Measuring Lines + Bottom (X / ✓) Buttons
//  • In Zen Mode: Minimal Immersion with subtle Sun/Moon toggle
//  • Full-Bleed Sound Library: 35 Authentic Soundscapes with auto-scroll to active track
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

    public var thumbnailImageName: String {
        "\(imageName)-thumb"
    }

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
    // Top Priority Sections
    SoundBannerTheme(id: "crickets-night", profile: .nightCrickets, title: "Crickets Night", imageName: "crickets-night"),
    SoundBannerTheme(id: "dune-breeze", profile: .duneBreeze, title: "Desert Dune Breeze", imageName: "dune-breeze", previewAlignment: .bottom),
    SoundBannerTheme(id: "cozy-campfire", profile: .cozyCampfire, title: "Cozy Campfire", imageName: "cozy-campfire"),
    SoundBannerTheme(id: "quiet-library", profile: .quietLibrary, title: "Quiet Library", imageName: "quiet-library"),
    SoundBannerTheme(id: "surrender", profile: .surrender, title: "Surrender", imageName: "surrender"),
    SoundBannerTheme(id: "rolling-thunder", profile: .rollingThunder, title: "Rolling Thunder", imageName: "rolling-thunder", previewAlignment: .bottom),

    // Rest of Soundscapes
    SoundBannerTheme(id: "gentle-rain", profile: .gentleRain, title: "Gentle Rain", imageName: "gentle-rain"),
    SoundBannerTheme(id: "ocean-waves", profile: .oceanWaves, title: "Peaceful Ocean", imageName: "ocean-waves"),
    SoundBannerTheme(id: "wind-in-trees", profile: .windInTrees, title: "Wind in Trees", imageName: "gentle-wind"),
    SoundBannerTheme(id: "waterfall", profile: .waterfall, title: "Forest Waterfall", imageName: "waterfall"),
    SoundBannerTheme(id: "flowing-river", profile: .forestRiver, title: "Flowing River", imageName: "flowing-river"),

    SoundBannerTheme(id: "evening-frogs", profile: .eveningFrogs, title: "Evening Frogs", imageName: "evening-frogs"),
    SoundBannerTheme(id: "cat-purr", profile: .catPurring, title: "Cat Purring", imageName: "cat-purr"),
    SoundBannerTheme(id: "temple-sanctuary", profile: .templeSanctuary, title: "Sacred Temple", imageName: "temple-sanctuary"),
    SoundBannerTheme(id: "coastal-seagulls", profile: .coastalSeagulls, title: "Coastal Seagulls", imageName: "coastal-seagulls", previewAlignment: .bottom),
    SoundBannerTheme(id: "howling-wind", profile: .howlingWind, title: "Howling Winter Gale", imageName: "howling-wind", previewAlignment: .bottom),

    SoundBannerTheme(id: "rain-canopy", profile: .rainCanopy, title: "Rain on Leaves", imageName: "rain-canopy"),
    SoundBannerTheme(id: "deep-underwater", profile: .deepUnderwater, title: "Deep Underwater", imageName: "deep-underwater"),
    SoundBannerTheme(id: "tropical-jungle", profile: .tropicalJungle, title: "Tropical Jungle", imageName: "tropical-jungle"),
    SoundBannerTheme(id: "night-village", profile: .nightVillage, title: "Quiet Mountain Village", imageName: "night-village"),
    SoundBannerTheme(id: "forest-birds", profile: .forestBirdsong, title: "Morning Birds", imageName: "forest-birds"),
    SoundBannerTheme(id: "walk-leaves", profile: .walkOnLeaves, title: "Walk on Leaves", imageName: "walk-leaves"),
    SoundBannerTheme(id: "warm-cafe", profile: .warmCafe, title: "Warm Coffee House", imageName: "warm-cafe"),

    // ── Additional Serene Soundscapes (Placed at the bottom) ──────────────────
    SoundBannerTheme(id: "singing-bowl", profile: .singingBowl, title: "Tibetan Singing Bowl", imageName: "singing-bowl"),
    SoundBannerTheme(id: "wind-chimes", profile: .windChimes, title: "Wind Chimes", imageName: "wind-chimes"),
    SoundBannerTheme(id: "scenic-train", profile: .scenicTrain, title: "Scenic Train", imageName: "scenic-train"),
    SoundBannerTheme(id: "rain-on-tent", profile: .rainOnTent, title: "Rain on Tent", imageName: "rain-on-tent"),
    SoundBannerTheme(id: "ocean-whale", profile: .oceanWhale, title: "Whale Song", imageName: "ocean-whale"),
    SoundBannerTheme(id: "rain-on-car", profile: .rainOnCar, title: "Rain on Car Window", imageName: "rain-on-car"),
    SoundBannerTheme(id: "gentle-sailboat", profile: .gentleSailboat, title: "Gentle Sailboat", imageName: "gentle-sailboat"),
    SoundBannerTheme(id: "snowy-forest", profile: .snowyForest, title: "Snowy Forest", imageName: "snowy-forest"),
    SoundBannerTheme(id: "antique-clock", profile: .antiqueClock, title: "Antique Clock", imageName: "antique-clock"),
    SoundBannerTheme(id: "night-owl", profile: .nightOwl, title: "Night Owl", imageName: "night-owl"),
    SoundBannerTheme(id: "rowing-boat", profile: .rowingBoat, title: "Rowing Boat", imageName: "rowing-boat"),
    SoundBannerTheme(id: "cathedral-chimes", profile: .cathedralChimes, title: "Cathedral Chimes", imageName: "cathedral-chimes")
]

public func bannerFor(profile: SoundProfile) -> SoundBannerTheme {
    allSoundBanners.first(where: { $0.profile == profile }) ?? allSoundBanners[0]
}

// MARK: ── Artist Credits ─────────────────────────────────────────────────────

public struct SoundArtistCredit: Equatable {
    public let name: String
    public let instagramHandle: String
    public let instagramURL: URL

    public init(name: String, instagramHandle: String, instagramURL: URL) {
        self.name = name
        self.instagramHandle = instagramHandle
        self.instagramURL = instagramURL
    }
}

extension SoundProfile {
    public var artistCredit: SoundArtistCredit? {
        switch self {
        case .surrender:
            return SoundArtistCredit(
                name: "Jeff Oster",
                instagramHandle: "@jeffosterpix",
                instagramURL: URL(string: "https://www.instagram.com/jeffosterpix/")!
            )
        default:
            return nil
        }
    }
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
    @State private var isArtistInfoVisible: Bool = false
    @State private var isInstagramGlowing: Bool = false
    @State private var timerEndTimestamp: Date? = nil

    private let timerTicker = Timer.publish(every: 1.0, on: .main, in: .common).autoconnect()

    public init() {}

    public var body: some View {
        GeometryReader { screenGeo in
            let screenWidth = screenGeo.size.width
            let screenHeight = screenGeo.size.height
            let topInset = max(44.0, screenGeo.safeAreaInsets.top)

            ZStack(alignment: .bottom) {
                // ── Solid Deep Black Base Canvas ──
                Color.black
                    .ignoresSafeArea()

                // ── Deep Atmospheric Fullscreen Backdrop ──
                let activeBanner = bannerFor(profile: activeProfile)

                Image(activeBanner.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: screenWidth, height: screenHeight)
                    .clipped()
                    .id(activeBanner.id)
                    .transition(.opacity)
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

                // ── Normal Mode: Main Player Interface ──
                if activeOverlay == .none {
                    ZStack {
                        // Background gestures: Sideways swipe to navigate soundscapes, tap/micro-drag to play/pause or hide artist
                        Color.clear
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture(minimumDistance: 0)
                                    .onEnded { gesture in
                                        let horizontal = gesture.translation.width
                                        let vertical = gesture.translation.height
                                        // Trigger track change if primarily horizontal and sufficient swipe distance (> 35pt)
                                        if abs(horizontal) > abs(vertical) && abs(horizontal) > 35 {
                                            if horizontal < 0 {
                                                // Swiped Left -> Bring to Next sound
                                                selectNextSound()
                                            } else {
                                                // Swiped Right -> Bring to Previous sound
                                                selectPreviousSound()
                                            }
                                        } else {
                                            // Any tap or micro-drag (< 35pt) reliably triggers play/pause
                                            if isArtistInfoVisible {
                                                withAnimation(.easeInOut(duration: 0.65)) {
                                                    isArtistInfoVisible = false
                                                }
                                            } else {
                                                togglePlayPause()
                                            }
                                        }
                                    }
                            )

                        // Top Navigation: Floating Icons (Sun/Moon and Artist Info side by side at top center)
                        VStack {
                            HStack {
                                Spacer()

                                HStack(spacing: 2) {
                                    // ☀️ / 🌙 Sun & Moon Icon (Zen Mode Immersion Toggle)
                                    Button(action: {
                                        HapticManager.shared.playTransientHeartbeat(intensity: 0.4, sharpness: 0.5)
                                        withAnimation(.easeInOut(duration: 0.65)) {
                                            if isArtistInfoVisible {
                                                isArtistInfoVisible = false
                                            }
                                            isZenMode.toggle()
                                        }
                                    }) {
                                        Image(systemName: isZenMode ? "moon.fill" : "sun.max")
                                            .font(.system(size: 20, weight: .regular))
                                            .contentTransition(.symbolEffect(.replace))
                                            .foregroundColor(Color.white.opacity(0.92))
                                            .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 1)
                                            .frame(width: (activeProfile.artistCredit != nil) ? 54 : 72, height: 52)
                                            .background(Color.black.opacity(0.001))
                                            .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                    .contentShape(Rectangle())

                                    // 👤 / ✕ Profile / Exit Icon (Only shown for artist tracks, e.g. Jeff Oster on Surrender)
                                    if let _ = activeProfile.artistCredit {
                                        Button(action: {
                                            HapticManager.shared.playTransientHeartbeat(intensity: 0.4, sharpness: 0.5)
                                            withAnimation(.easeInOut(duration: 0.65)) {
                                                if isZenMode {
                                                    isZenMode = false
                                                }
                                                isArtistInfoVisible.toggle()
                                            }
                                        }) {
                                            Image(systemName: isArtistInfoVisible ? "xmark" : "person")
                                                .font(.system(size: isArtistInfoVisible ? 16 : 19, weight: .regular))
                                                .contentTransition(.symbolEffect(.replace))
                                                .foregroundColor(Color.white.opacity(0.92))
                                                .shadow(color: Color.black.opacity(0.45), radius: 4, x: 0, y: 1)
                                                .frame(width: 54, height: 52)
                                                .background(Color.black.opacity(0.001))
                                                .contentShape(Rectangle())
                                        }
                                        .buttonStyle(.plain)
                                        .contentShape(Rectangle())
                                        .transition(.opacity.combined(with: .scale(scale: 0.9)))
                                    }
                                }
                                .opacity(isZenMode ? 0.60 : 1.0)
                                .animation(.easeInOut(duration: 0.65), value: isZenMode)
                                .animation(.easeInOut(duration: 0.40), value: activeProfile.artistCredit != nil)

                                Spacer()
                            }
                            .padding(.top, topInset + 6)

                            Spacer()
                        }
                        .zIndex(100)

                        // Main Center Stage & Bottom Controls
                        VStack(spacing: 0) {
                            Spacer()

                            // ── Clean Circular Countdown Timer Ring or Artist Profile in Center ──
                            ZStack {
                                FullCircularTimerView(
                                    remainingSeconds: $remainingTimerSeconds,
                                    totalDuration: $totalTimerDuration,
                                    isPlaying: isPlaying,
                                    timerEndTimestamp: timerEndTimestamp
                                )
                                .opacity((!isZenMode && !isArtistInfoVisible) ? 1.0 : 0.0)
                                .animation(.easeInOut(duration: 0.65), value: isZenMode)
                                .animation(.easeInOut(duration: 0.65), value: isArtistInfoVisible)
                                .allowsHitTesting(false)

                                if isArtistInfoVisible, let credit = activeProfile.artistCredit {
                                    // ── Artist Profile & Social Link ──
                                    VStack(spacing: 18.4) {
                                        Text(credit.name)
                                            .font(.system(size: 36.8, weight: .light, design: .rounded))
                                            .tracking(1.7)
                                            .foregroundColor(.white)
                                            .shadow(color: Color.black.opacity(0.85), radius: 8, x: 0, y: 2)

                                        Link(destination: credit.instagramURL) {
                                            HStack(spacing: 11.5) {
                                                InstagramLogoView(size: 27.6)
                                                Text(credit.instagramHandle)
                                                    .font(.system(size: 18.4, weight: .medium, design: .rounded))
                                                    .foregroundColor(.white)
                                                    .shadow(color: Color.black.opacity(0.65), radius: 4, x: 0, y: 1.5)
                                            }
                                            .padding(.horizontal, 23)
                                            .padding(.vertical, 11.5)
                                            .background(Color.white.opacity(isInstagramGlowing ? 0.26 : 0.18))
                                            .clipShape(Capsule())
                                            .overlay(
                                                Capsule()
                                                    .stroke(Color.white.opacity(isInstagramGlowing ? 0.78 : 0.35), lineWidth: isInstagramGlowing ? 1.3 : 1)
                                            )
                                            .shadow(color: Color.white.opacity(isInstagramGlowing ? 0.55 : 0.0), radius: isInstagramGlowing ? 18 : 0, x: 0, y: 0)
                                            .shadow(color: Color.white.opacity(isInstagramGlowing ? 0.32 : 0.0), radius: isInstagramGlowing ? 32 : 0, x: 0, y: 0)
                                            .shadow(color: Color.black.opacity(0.50), radius: 8, x: 0, y: 2)
                                        }
                                        .onAppear {
                                            triggerInstagramGlow()
                                        }
                                    }
                                    .frame(height: 318)
                                    .offset(y: 20)
                                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
                                }
                            }
                            .frame(width: 318, height: 318)
                            .offset(y: 20)

                            Spacer()

                            // Bottom Dock Controls: [‹ Prev] [🎵 Sounds] [⏵/⏸ Play/Pause] [✏️ Edit] [› Next]
                            HStack(spacing: 24) {
                                // ‹ 1. Previous Sound Track
                                Button(action: { selectPreviousSound() }) {
                                    Image(systemName: "chevron.left")
                                        .font(.system(size: 21.4, weight: .semibold))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black.opacity(0.85), radius: 6, x: 0, y: 2)
                                        .frame(width: 47, height: 47)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                // 🎵 2. Relaxing Sounds Button
                                Button(action: {
                                    HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.6)
                                    activeOverlay = .soundSelection
                                }) {
                                    Image(systemName: "music.note")
                                        .font(.system(size: 22.5, weight: .medium))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black.opacity(0.85), radius: 6, x: 0, y: 2)
                                        .frame(width: 47, height: 47)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                // ⏵/⏸ 3. Play / Pause Button
                                Button(action: { togglePlayPause() }) {
                                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                                        .font(.system(size: 28, weight: .bold))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black.opacity(0.85), radius: 6, x: 0, y: 2)
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
                                        .shadow(color: Color.black.opacity(0.85), radius: 6, x: 0, y: 2)
                                        .frame(width: 47, height: 47)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)

                                // › 5. Next Sound Track
                                Button(action: { selectNextSound() }) {
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 21.4, weight: .semibold))
                                        .foregroundColor(.white)
                                        .shadow(color: Color.black.opacity(0.85), radius: 6, x: 0, y: 2)
                                        .frame(width: 47, height: 47)
                                        .contentShape(Rectangle())
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.bottom, 36)
                            .opacity((isZenMode || isArtistInfoVisible) ? 0 : 1)
                            .animation(.easeInOut(duration: 0.65), value: isZenMode)
                            .animation(.easeInOut(duration: 0.65), value: isArtistInfoVisible)
                            .allowsHitTesting(!isZenMode && !isArtistInfoVisible)
                        }
                    }
                    .frame(width: screenWidth, height: screenHeight)
                    .transition(.identity)
                }

                // ── Edit Mode: Solid Black + Top Timer + Full Height Waves + Bottom Controls ──
                if activeOverlay == .editTimer {
                    ZStack(alignment: .bottom) {
                        Color.black
                            .ignoresSafeArea()

                        // Full Height Fluid Wave Measuring Lines
                        TallFusedMeasuringLinesView(
                            remainingSeconds: $remainingTimerSeconds,
                            totalDuration: $totalTimerDuration,
                            isDragging: $isDraggingTimer
                        )
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .ignoresSafeArea()

                        // Top Clean Digital Timer in Edit Mode
                        VStack {
                            Text(formatNoLeadingZeroHours(remainingTimerSeconds))
                                .font(.system(size: 44, weight: .light, design: .rounded))
                                .monospacedDigit()
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.90), radius: 8, x: 0, y: 3)
                                .padding(.top, topInset + 36)

                            Spacer()
                        }
                        .allowsHitTesting(false)

                        // Bottom Action: Confirm (✓) Button
                        Button(action: {
                            HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.6)
                            if isPlaying {
                                if remainingTimerSeconds <= 0 {
                                    isPlaying = false
                                    timerEndTimestamp = nil
                                    AudioManager.shared.sleepTimerTargetDate = nil
                                    AudioManager.shared.pause()
                                } else {
                                    timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                                    AudioManager.shared.sleepTimerTargetDate = timerEndTimestamp
                                }
                            }
                            activeOverlay = .none
                        }) {
                            Image(systemName: "checkmark")
                                .font(.system(size: 21.4, weight: .bold))
                                .foregroundColor(.white)
                                .shadow(color: Color.black.opacity(0.95), radius: 8, x: 0, y: 3)
                                .frame(width: 44, height: 44)
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
                            let wasTimerOver = (remainingTimerSeconds <= 0)
                            if wasTimerOver {
                                let dur = totalTimerDuration > 0 ? totalTimerDuration : 600.0
                                remainingTimerSeconds = dur
                                if totalTimerDuration <= 0 {
                                    totalTimerDuration = dur
                                }
                            }
                            isPlaying = true
                            timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                            AudioManager.shared.sleepTimerTargetDate = timerEndTimestamp
                            activeOverlay = .none
                            AudioManager.shared.activeProfile = profile
                            if wasTimerOver {
                                AudioManager.shared.restartFromStart()
                            } else if !AudioManager.shared.isAudioPlaying {
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
                        AudioManager.shared.sleepTimerTargetDate = nil
                        AudioManager.shared.stop()
                    } else {
                        remainingTimerSeconds = left
                    }
                } else {
                    timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                    AudioManager.shared.sleepTimerTargetDate = timerEndTimestamp
                }
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: AudioManager.audioStateDidChangeNotification)) { _ in
            if activeProfile != AudioManager.shared.activeProfile {
                activeProfile = AudioManager.shared.activeProfile
            }
            let audioPlaying = AudioManager.shared.isAudioPlaying
            if isPlaying != audioPlaying {
                isPlaying = audioPlaying
                if audioPlaying {
                    if remainingTimerSeconds <= 0 {
                        let dur = totalTimerDuration > 0 ? totalTimerDuration : 600.0
                        remainingTimerSeconds = dur
                        if totalTimerDuration <= 0 {
                            totalTimerDuration = dur
                        }
                    }
                    timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                    AudioManager.shared.sleepTimerTargetDate = timerEndTimestamp
                } else {
                    if let end = timerEndTimestamp {
                        remainingTimerSeconds = max(0, end.timeIntervalSinceNow)
                    }
                    timerEndTimestamp = nil
                    AudioManager.shared.sleepTimerTargetDate = nil
                }
            }
        }
        .onAppear {
            AudioManager.shared.activeProfile = activeProfile
            if isPlaying {
                timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
                AudioManager.shared.sleepTimerTargetDate = timerEndTimestamp
                AudioManager.shared.start()
            }
        }
        .onChange(of: activeProfile) { _, _ in
            isArtistInfoVisible = false
            isInstagramGlowing = false
        }
        .onChange(of: isArtistInfoVisible) { _, newValue in
            if newValue {
                triggerInstagramGlow()
            } else {
                isInstagramGlowing = false
            }
        }
    }

    private func triggerInstagramGlow() {
        isInstagramGlowing = false
        withAnimation(.easeOut(duration: 0.55)) {
            isInstagramGlowing = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeInOut(duration: 1.5)) {
                isInstagramGlowing = false
            }
        }
    }

    private func togglePlayPause() {
        HapticManager.shared.playTransientHeartbeat(intensity: 0.6, sharpness: 0.6)
        isPlaying.toggle()
        if isPlaying {
            let wasTimerOver = (remainingTimerSeconds <= 0)
            if wasTimerOver {
                let dur = totalTimerDuration > 0 ? totalTimerDuration : 600.0
                remainingTimerSeconds = dur
                if totalTimerDuration <= 0 {
                    totalTimerDuration = dur
                }
            }
            timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
            AudioManager.shared.sleepTimerTargetDate = timerEndTimestamp
            if wasTimerOver {
                AudioManager.shared.restartFromStart()
            } else {
                AudioManager.shared.togglePlayPause()
            }
        } else {
            if let end = timerEndTimestamp {
                remainingTimerSeconds = max(0, end.timeIntervalSinceNow)
            }
            timerEndTimestamp = nil
            AudioManager.shared.sleepTimerTargetDate = nil
            AudioManager.shared.pause()
        }
    }

    private func selectPreviousSound() {
        HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.5)
        guard let currentIndex = allSoundBanners.firstIndex(where: { $0.profile == activeProfile }) else { return }
        let newIndex = (currentIndex - 1 + allSoundBanners.count) % allSoundBanners.count
        let newProfile = allSoundBanners[newIndex].profile
        withAnimation(.easeInOut(duration: 0.35)) {
            activeProfile = newProfile
        }
        AudioManager.shared.activeProfile = newProfile
        let wasTimerOver = (remainingTimerSeconds <= 0)
        if wasTimerOver {
            let dur = totalTimerDuration > 0 ? totalTimerDuration : 600.0
            remainingTimerSeconds = dur
            if totalTimerDuration <= 0 {
                totalTimerDuration = dur
            }
        }
        if !isPlaying {
            isPlaying = true
        }
        timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
        AudioManager.shared.sleepTimerTargetDate = timerEndTimestamp
        if wasTimerOver {
            AudioManager.shared.restartFromStart()
        } else if !AudioManager.shared.isAudioPlaying {
            AudioManager.shared.start()
        }
    }

    private func selectNextSound() {
        HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.5)
        guard let currentIndex = allSoundBanners.firstIndex(where: { $0.profile == activeProfile }) else { return }
        let newIndex = (currentIndex + 1) % allSoundBanners.count
        let newProfile = allSoundBanners[newIndex].profile
        withAnimation(.easeInOut(duration: 0.35)) {
            activeProfile = newProfile
        }
        AudioManager.shared.activeProfile = newProfile
        let wasTimerOver = (remainingTimerSeconds <= 0)
        if wasTimerOver {
            let dur = totalTimerDuration > 0 ? totalTimerDuration : 600.0
            remainingTimerSeconds = dur
            if totalTimerDuration <= 0 {
                totalTimerDuration = dur
            }
        }
        if !isPlaying {
            isPlaying = true
        }
        timerEndTimestamp = Date().addingTimeInterval(remainingTimerSeconds)
        AudioManager.shared.sleepTimerTargetDate = timerEndTimestamp
        if wasTimerOver {
            AudioManager.shared.restartFromStart()
        } else if !AudioManager.shared.isAudioPlaying {
            AudioManager.shared.start()
        }
    }
}

// MARK: ── Clean Time Formatter ───────────────────────────────────────────────

func formatNoLeadingZeroHours(_ seconds: TimeInterval) -> String {
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
            guard totalDuration > 0 else { return 0.0 }
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
            .frame(width: size, height: size)
        }
    }
}

// MARK: ── 2. Tall Interactive Fluid Wave Measuring Lines (Edit Mode) ─────────

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
                    let glowRect = CGRect(x: 0, y: midY - 90, width: width, height: 180)
                    context.fill(
                        Path(glowRect),
                        with: .radialGradient(
                            Gradient(colors: [
                                Color.white.opacity(0.09),
                                Color.clear
                            ]),
                            center: CGPoint(x: midX, y: midY),
                            startRadius: 10,
                            endRadius: 180
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

                    // ── 3. Animated Fluid Wave Measuring Lines ──
                    let lineSpacing: CGFloat = 18.0
                    let numLines = Int(height / lineSpacing) + 6
                    let offsetPx = CGFloat((remainingSeconds * (18.0 / 90.0)).truncatingRemainder(dividingBy: Double(lineSpacing)))

                    // Safe boundaries: 2 less lines at top next to the timer (shifted down by 36pt)
                    let topSafeFadeStart: CGFloat = 211.0
                    let topSafeFadeEnd: CGFloat = 181.0
                    let bottomSafeFadeStart: CGFloat = height - 155.0
                    let bottomSafeFadeEnd: CGFloat = height - 120.0

                    for i in -2...numLines {
                        let yPos = CGFloat(i) * lineSpacing - offsetPx
                        guard yPos >= topSafeFadeEnd && yPos <= bottomSafeFadeEnd else { continue }

                        let distFromCenter = abs(yPos - midY)
                        // Slightly fuller focal width for bigger middle
                        let focus = max(0.0, exp(-pow(Double(distFromCenter) / 115.0, 2)))

                        // Smooth gradient fade before touching top timer and bottom checkmark
                        var edgeFade: CGFloat = 1.0
                        if yPos < topSafeFadeStart {
                            edgeFade = max(0.0, min(1.0, (yPos - topSafeFadeEnd) / (topSafeFadeStart - topSafeFadeEnd)))
                        } else if yPos > bottomSafeFadeStart {
                            edgeFade = max(0.0, min(1.0, (bottomSafeFadeEnd - yPos) / (bottomSafeFadeEnd - bottomSafeFadeStart)))
                        }
                        guard edgeFade > 0.005 else { continue }

                        // Balanced fade: noticeably faded towards edges while center line shines at 100%
                        let smoothEdgeFade = 0.62 + 0.38 * sin(Double(edgeFade) * .pi / 2.0)
                        let baseAlpha = 0.50 + focus * 0.50

                        // Bigger middle width (expands up to 210pt at center)
                        let lineWidth = (65.0 + CGFloat(focus) * 145.0) * (0.4 + 0.6 * CGFloat(smoothEdgeFade))
                        let numPts = 12
                        let xStart = midX - lineWidth / 2

                        var linePath = Path()
                        for p in 0...numPts {
                            let u = CGFloat(p) / CGFloat(numPts)
                            let x = xStart + u * lineWidth
                            let relX = (x - midX) / (lineWidth / 2)
                            let envelope = max(0.0, 1.0 - relX * relX)

                            let wave = CGFloat(sin(time * 2.6 + Double(yPos) * 0.035 + Double(relX) * 2.2)) * (2.0 + CGFloat(focus) * 5.5) * envelope

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

                        let lineAlpha = baseAlpha * smoothEdgeFade
                        let strokeW = 1.15 + CGFloat(focus) * 0.75

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

                        let currentTotal = totalDuration
                        var newTotal = max(0.0, min(maxTime, currentTotal + secondsDelta))
                        if newTotal < 1.0 {
                            newTotal = 0.0
                        }
                        if newTotal == 0.0 && totalDuration > 0.0 {
                            HapticManager.shared.playTransientHeartbeat(intensity: 0.4, sharpness: 0.5)
                        }
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
    @State private var scrolledID: String?

    init(
        screenWidth: CGFloat,
        activeProfile: Binding<SoundProfile>,
        isPlaying: Bool,
        onSelectSound: @escaping (SoundProfile) -> Void,
        onClose: @escaping () -> Void
    ) {
        self.screenWidth = screenWidth
        self._activeProfile = activeProfile
        self.isPlaying = isPlaying
        self.onSelectSound = onSelectSound
        self.onClose = onClose
        self._scrolledID = State(initialValue: activeProfile.wrappedValue.rawValue)
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Solid Black Backdrop
            Color.black
                .ignoresSafeArea()

            // Vertical Soundscapes Scroll View
            ScrollViewReader { scrollProxy in
                ScrollView(.vertical, showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        ForEach(allSoundBanners) { banner in
                            let isThisActive = (banner.profile == activeProfile)

                            Button(action: {
                                HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.6)
                                onSelectSound(banner.profile)
                            }) {
                                ZStack(alignment: .bottom) {
                                    // 1. Sound Scenic Background Picture (Ultra-fast pre-cached thumbnail)
                                    Image(banner.thumbnailImageName)
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
                            .id(banner.profile.rawValue)
                        }
                    }
                    .scrollTargetLayout()
                    .padding(.top, 54)
                    .padding(.bottom, 94) // Balanced clearance so cards scroll smoothly
                }
                .scrollPosition(id: $scrolledID, anchor: .center)
                .frame(width: screenWidth)
                .ignoresSafeArea(edges: .bottom)
                .onAppear {
                    scrollProxy.scrollTo(activeProfile.rawValue, anchor: .center)
                }
            }

            // Top Status Bar Fade Scrim
            VStack(spacing: 0) {
                LinearGradient(
                    stops: [
                        .init(color: Color.black.opacity(0.85), location: 0.0),
                        .init(color: Color.black.opacity(0.40), location: 0.5),
                        .init(color: .clear, location: 1.0)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(width: screenWidth, height: 60)
                .allowsHitTesting(false)
                Spacer()
            }
            .ignoresSafeArea(edges: .top)

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

            // Floating Exit (X) Button (Matching bottom icons size & alignment)
            Button(action: {
                HapticManager.shared.playTransientHeartbeat(intensity: 0.5, sharpness: 0.6)
                onClose()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 21.4, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: Color.black.opacity(0.95), radius: 8, x: 0, y: 3)
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.bottom, 36)
            .zIndex(20)
        }
        .frame(width: screenWidth)
    }
}

// MARK: ── Pure White Instagram Logo Glyph ────────────────────────────────────

public struct InstagramLogoView: View {
    public var size: CGFloat

    public init(size: CGFloat = 24) {
        self.size = size
    }

    public var body: some View {
        ZStack {
            // Outer squircle outline
            RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                .stroke(Color.white, lineWidth: size * 0.085)
                .frame(width: size, height: size)

            // Center camera lens
            Circle()
                .stroke(Color.white, lineWidth: size * 0.085)
                .frame(width: size * 0.48, height: size * 0.48)

            // Top-right flash dot
            Circle()
                .fill(Color.white)
                .frame(width: size * 0.11, height: size * 0.11)
                .offset(x: size * 0.24, y: -size * 0.24)
        }
        .frame(width: size, height: size)
    }
}

