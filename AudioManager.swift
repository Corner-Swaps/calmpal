//
//  AudioManager.swift
//  Calmpal
//
//  35 Authentic Sound Recordings:
//  Rain · Ocean · Forest · Wind · Ambient
//  High-definition audio player with smooth looping and seamless engine playback.
//

@preconcurrency import AVFoundation
import MediaPlayer
import Accelerate

// MARK: ── Sound Profile ───────────────────────────────────────────────────────


public enum SoundProfile: String, CaseIterable, Identifiable, Codable, Sendable {

    // ── Rain (3) ──────────────────────────────────────────────────────────────
    case gentleRain      = "Drizzle"
    case rainCanopy      = "Canopy"
    case rollingThunder  = "Thunder"

    // ── Ocean (4) ─────────────────────────────────────────────────────────────
    case oceanWaves      = "Waves"
    case waterfall       = "Waterfall"
    case forestRiver     = "River"
    case coastalSeagulls = "Seagulls"

    // ── Forest (5) ────────────────────────────────────────────────────────────
    case forestBirdsong  = "Birds"
    case tropicalJungle  = "Jungle"
    case nightCrickets   = "Crickets"
    case eveningFrogs    = "Frogs"
    case catPurring      = "Purr"

    // ── Wind (5) ──────────────────────────────────────────────────────────────
    case windInTrees     = "Trees"
    case cozyCampfire    = "Campfire"
    case duneBreeze      = "Breeze"
    case howlingWind     = "Gale"
    case walkOnLeaves    = "Leaves"

    // ── Ambient (5) ───────────────────────────────────────────────────────────
    case warmCafe        = "Cafe"
    case quietLibrary    = "Library"
    case nightVillage    = "Village"
    case templeSanctuary = "Temple"
    case deepUnderwater  = "Deep"

    // ── Additional Serene Soundscapes (11) ─────────────────────────────────────
    case singingBowl     = "Bowl"
    case windChimes      = "Chimes"
    case scenicTrain     = "Train"
    case rainOnTent      = "Tent"
    case oceanWhale      = "Whale"
    case rainOnCar       = "Car"
    case gentleSailboat  = "Sailboat"
    case snowyForest     = "Snow"
    case antiqueClock    = "Clock"
    case nightOwl        = "Owl"
    case rowingBoat      = "Oars"
    case cathedralChimes = "Bells"
    case surrender       = "Surrender"

    public var id: String { rawValue }
    public var displayName: String { rawValue }

    // MARK: – Resource File Base Name
    public var resourceFileName: String {
        switch self {
        case .gentleRain:      return "light-rain"
        case .rainCanopy:      return "rain-on-leaves"
        case .rollingThunder:  return "thunder"
        case .oceanWaves:      return "waves"
        case .waterfall:       return "waterfall"
        case .forestRiver:     return "river"
        case .coastalSeagulls: return "seagulls"
        case .forestBirdsong:  return "birds"
        case .tropicalJungle:  return "jungle"
        case .nightCrickets:   return "crickets"
        case .eveningFrogs:    return "frog"
        case .catPurring:      return "cat-purring"
        case .windInTrees:     return "wind-in-trees"
        case .cozyCampfire:    return "campfire"
        case .duneBreeze:      return "wind"
        case .howlingWind:     return "howling-wind"
        case .walkOnLeaves:    return "walk-on-leaves"
        case .warmCafe:        return "cafe"
        case .quietLibrary:    return "library"
        case .nightVillage:    return "night-village"
        case .templeSanctuary: return "temple"
        case .deepUnderwater:  return "underwater"
        case .singingBowl:     return "singing-bowl"
        case .windChimes:      return "wind-chimes"
        case .scenicTrain:     return "inside-a-train"
        case .rainOnTent:      return "rain-on-tent"
        case .oceanWhale:      return "whale"
        case .rainOnCar:       return "rain-on-car-roof"
        case .gentleSailboat:  return "sailboat"
        case .snowyForest:     return "walk-in-snow"
        case .antiqueClock:    return "clock"
        case .nightOwl:        return "owl"
        case .rowingBoat:      return "rowing-boat"
        case .cathedralChimes: return "church"
        case .surrender:       return "surrender"
        }
    }

    // MARK: – Therapeutic description
    public var explanation: String {
        switch self {
        case .gentleRain:      return "Soft, soothing patter of light rainfall."
        case .rainCanopy:      return "Gentle shower falling on forest leaves and foliage."
        case .rollingThunder:  return "Low, rumbling thunder echoing safely over hills."
        case .oceanWaves:      return "Rhythmic ocean surf swells rolling onto sandy shores."
        case .waterfall:       return "Pure white water cascading into a deep natural pool."
        case .forestRiver:     return "Clear stream water trickling over smooth river stones."
        case .coastalSeagulls: return "Ocean tides washing coastal rocks with gull calls."
        case .forestBirdsong:  return "Vibrant morning birdsong chorus in woodland canopy."
        case .tropicalJungle:  return "Rich tropical atmosphere with warm birdsong and rustle."
        case .nightCrickets:   return "Quiet evening field silence with gentle cricket chirps."
        case .eveningFrogs:    return "Peaceful twilight pond atmosphere with soft frog croaks."
        case .catPurring:      return "Rhythmic, deep cat purr providing sensory warmth."
        case .windInTrees:     return "Rustling forest canopy breeze sweeping through trees."
        case .cozyCampfire:    return "Warm hearth wood embers crackling and popping softly."
        case .duneBreeze:      return "Smooth, warm whistling breeze blowing across dunes."
        case .howlingWind:     return "Atmospheric high mountain wind blowing over peaks."
        case .walkOnLeaves:    return "Rhythmic crunch of dry autumn leaves beneath steps."
        case .warmCafe:        return "Subtle background coffee shop chatter and cup clinks."
        case .quietLibrary:    return "Peaceful indoor sanctuary air flow for focus."
        case .nightVillage:    return "Serene night atmosphere in a quiet, secluded village."
        case .templeSanctuary: return "Soothing temple sanctuary drone for calm meditation."
        case .deepUnderwater:  return "Deep sub-aquatic ocean pressure swell and resonance."
        case .singingBowl:     return "Harmonic Tibetan brass singing bowl resonance for deep meditation."
        case .windChimes:      return "Gentle bamboo and glass wind chimes swaying in a serene breeze."
        case .scenicTrain:     return "Rhythmic wooden train journey winding through misty mountain valleys."
        case .rainOnTent:      return "Cozy raindrops drumming peacefully against a forest camping tent."
        case .oceanWhale:      return "Majestic humpback whale songs echoing through deep blue waters."
        case .rainOnCar:       return "Soothing rain patter drumming on car glass under twilight streetlights."
        case .gentleSailboat:  return "Calm ripples and creaking wood of a sailboat drifting at golden hour."
        case .snowyForest:     return "Crisp footsteps crunching softly through fresh winter snow among frosted pine trees."
        case .antiqueClock:    return "Rhythmic, reassuring wooden ticks of an antique grandfather clock in a peaceful room."
        case .nightOwl:        return "Peaceful nocturnal owl calls echoing across the quiet moonlit forest canopy."
        case .rowingBoat:      return "Gentle wooden oars dipping and slicing through glassy, tranquil alpine lake water."
        case .cathedralChimes: return "Contemplative stone chapel bells chiming softly across a misty mountain valley."
        case .surrender:       return "Enlightened darkness meditative chant for deep surrender and peace."
        }
    }

    public var frequencyValue: Double? { nil }

    // MARK: – Sound-Specific Sensory Haptic Profiles
    public var hapticProfile: SoundHapticProfile {
        switch self {
        case .nightCrickets:
            return SoundHapticProfile(baseIntensity: 0.36, baseSharpness: 0.78, dynamicGain: 0.85, pulseFrequency: 0.35)
        case .duneBreeze:
            return SoundHapticProfile(baseIntensity: 0.38, baseSharpness: 0.22, dynamicGain: 0.75, pulseFrequency: 0.20)
        case .cozyCampfire:
            return SoundHapticProfile(baseIntensity: 0.44, baseSharpness: 0.52, dynamicGain: 0.90, pulseFrequency: 0.30)
        case .quietLibrary:
            return SoundHapticProfile(baseIntensity: 0.28, baseSharpness: 0.16, dynamicGain: 0.50, pulseFrequency: 0.15)
        case .rollingThunder:
            return SoundHapticProfile(baseIntensity: 0.65, baseSharpness: 0.15, dynamicGain: 1.15, pulseFrequency: 0.18)
        case .oceanWaves:
            return SoundHapticProfile(baseIntensity: 0.52, baseSharpness: 0.22, dynamicGain: 0.95, pulseFrequency: 0.18)
        case .gentleRain:
            return SoundHapticProfile(baseIntensity: 0.35, baseSharpness: 0.54, dynamicGain: 0.80, pulseFrequency: 0.25)
        case .waterfall:
            return SoundHapticProfile(baseIntensity: 0.50, baseSharpness: 0.35, dynamicGain: 0.90, pulseFrequency: 0.22)
        case .forestRiver:
            return SoundHapticProfile(baseIntensity: 0.42, baseSharpness: 0.38, dynamicGain: 0.80, pulseFrequency: 0.25)
        case .catPurring:
            return SoundHapticProfile(baseIntensity: 0.58, baseSharpness: 0.30, dynamicGain: 0.75, pulseFrequency: 24.0)
        case .eveningFrogs:
            return SoundHapticProfile(baseIntensity: 0.40, baseSharpness: 0.48, dynamicGain: 0.80, pulseFrequency: 0.32)
        case .templeSanctuary:
            return SoundHapticProfile(baseIntensity: 0.35, baseSharpness: 0.18, dynamicGain: 0.60, pulseFrequency: 0.16)
        case .coastalSeagulls:
            return SoundHapticProfile(baseIntensity: 0.45, baseSharpness: 0.48, dynamicGain: 0.85, pulseFrequency: 0.20)
        case .howlingWind:
            return SoundHapticProfile(baseIntensity: 0.48, baseSharpness: 0.28, dynamicGain: 0.90, pulseFrequency: 0.22)
        case .rainCanopy:
            return SoundHapticProfile(baseIntensity: 0.40, baseSharpness: 0.58, dynamicGain: 0.82, pulseFrequency: 0.25)
        case .deepUnderwater:
            return SoundHapticProfile(baseIntensity: 0.60, baseSharpness: 0.12, dynamicGain: 0.95, pulseFrequency: 0.15)
        case .tropicalJungle:
            return SoundHapticProfile(baseIntensity: 0.44, baseSharpness: 0.62, dynamicGain: 0.85, pulseFrequency: 0.30)
        case .nightVillage:
            return SoundHapticProfile(baseIntensity: 0.30, baseSharpness: 0.22, dynamicGain: 0.60, pulseFrequency: 0.18)
        case .forestBirdsong:
            return SoundHapticProfile(baseIntensity: 0.38, baseSharpness: 0.72, dynamicGain: 0.80, pulseFrequency: 0.35)
        case .windInTrees:
            return SoundHapticProfile(baseIntensity: 0.38, baseSharpness: 0.32, dynamicGain: 0.80, pulseFrequency: 0.22)
        case .warmCafe:
            return SoundHapticProfile(baseIntensity: 0.35, baseSharpness: 0.38, dynamicGain: 0.70, pulseFrequency: 0.25)
        case .walkOnLeaves:
            return SoundHapticProfile(baseIntensity: 0.42, baseSharpness: 0.68, dynamicGain: 0.85, pulseFrequency: 0.30)
        case .singingBowl:
            return SoundHapticProfile(baseIntensity: 0.40, baseSharpness: 0.18, dynamicGain: 0.65, pulseFrequency: 0.20)
        case .windChimes:
            return SoundHapticProfile(baseIntensity: 0.35, baseSharpness: 0.75, dynamicGain: 0.80, pulseFrequency: 0.30)
        case .scenicTrain:
            return SoundHapticProfile(baseIntensity: 0.48, baseSharpness: 0.32, dynamicGain: 0.75, pulseFrequency: 0.45)
        case .rainOnTent:
            return SoundHapticProfile(baseIntensity: 0.42, baseSharpness: 0.58, dynamicGain: 0.85, pulseFrequency: 0.26)
        case .oceanWhale:
            return SoundHapticProfile(baseIntensity: 0.55, baseSharpness: 0.15, dynamicGain: 0.90, pulseFrequency: 0.16)
        case .rainOnCar:
            return SoundHapticProfile(baseIntensity: 0.42, baseSharpness: 0.56, dynamicGain: 0.82, pulseFrequency: 0.25)
        case .gentleSailboat:
            return SoundHapticProfile(baseIntensity: 0.44, baseSharpness: 0.25, dynamicGain: 0.80, pulseFrequency: 0.18)
        case .snowyForest:
            return SoundHapticProfile(baseIntensity: 0.38, baseSharpness: 0.62, dynamicGain: 0.80, pulseFrequency: 0.32)
        case .antiqueClock:
            return SoundHapticProfile(baseIntensity: 0.34, baseSharpness: 0.45, dynamicGain: 0.70, pulseFrequency: 1.00)
        case .nightOwl:
            return SoundHapticProfile(baseIntensity: 0.36, baseSharpness: 0.22, dynamicGain: 0.75, pulseFrequency: 0.20)
        case .rowingBoat:
            return SoundHapticProfile(baseIntensity: 0.42, baseSharpness: 0.28, dynamicGain: 0.80, pulseFrequency: 0.24)
        case .cathedralChimes:
            return SoundHapticProfile(baseIntensity: 0.45, baseSharpness: 0.32, dynamicGain: 0.85, pulseFrequency: 0.22)
        case .surrender:
            return SoundHapticProfile(baseIntensity: 0.32, baseSharpness: 0.16, dynamicGain: 0.65, pulseFrequency: 0.18)
        }
    }

    public var shortName: String {
        switch self {
        case .gentleRain, .rainCanopy, .rollingThunder, .rainOnTent, .rainOnCar:
            return "Rain"
        case .oceanWaves, .waterfall, .forestRiver, .coastalSeagulls, .oceanWhale, .gentleSailboat, .rowingBoat:
            return "Ocean"
        case .forestBirdsong, .tropicalJungle, .nightCrickets, .eveningFrogs, .catPurring, .snowyForest, .nightOwl:
            return "Forest"
        case .windInTrees, .cozyCampfire, .duneBreeze, .howlingWind, .walkOnLeaves, .windChimes:
            return "Wind"
        case .warmCafe, .quietLibrary, .nightVillage, .templeSanctuary, .deepUnderwater, .singingBowl, .scenicTrain, .antiqueClock, .cathedralChimes, .surrender:
            return "Ambient"
        }
    }
}

public struct SoundHapticProfile: Sendable {
    public let baseIntensity: Float
    public let baseSharpness: Float
    public let dynamicGain: Float
    public let pulseFrequency: Double
    
    public init(baseIntensity: Float, baseSharpness: Float, dynamicGain: Float, pulseFrequency: Double = 0.25) {
        self.baseIntensity = baseIntensity
        self.baseSharpness = baseSharpness
        self.dynamicGain = dynamicGain
        self.pulseFrequency = pulseFrequency
    }
}

// MARK: ── AudioManager ────────────────────────────────────────────────────────

@MainActor
public final class AudioManager {

    public static let shared = AudioManager()
    public static let audioStateDidChangeNotification = Notification.Name("CalmpalAudioStateDidChangeNotification")

    public private(set) var isAudioPlaying: Bool = false

    // Real-time audio energy, spectral bands, transients, and live waveform for visualizers & haptics
    public private(set) var audioLevel: Float = 0.0
    public private(set) var audioPeak: Float = 0.0
    public private(set) var audioBass: Float = 0.0
    public private(set) var audioMid: Float = 0.0
    public private(set) var audioTreble: Float = 0.0
    public private(set) var audioTransient: Float = 0.0
    public private(set) var audioFrequencies: [Float] = Array(repeating: 0.0, count: 16)
    public private(set) var audioWaveform: [Float] = Array(repeating: 0.0, count: 64)

    private let audioEngine = AVAudioEngine()
    private let playerNode  = AVAudioPlayerNode()
    private var fadeTask: Task<Void, Never>?
    public private(set) var isBufferScheduled: Bool = false
    private var lastRemoteCommandTime: TimeInterval = 0

    public var sleepTimerTargetDate: Date? {
        didSet {
            scheduleSleepTimer()
        }
    }
    private var sleepTimerSource: DispatchSourceTimer?
    private var sleepFadeTimerSource: DispatchSourceTimer?

    public func scheduleSleepTimer() {
        sleepTimerSource?.cancel()
        sleepTimerSource = nil
        sleepFadeTimerSource?.cancel()
        sleepFadeTimerSource = nil

        guard let target = sleepTimerTargetDate else { return }
        let interval = target.timeIntervalSinceNow
        if interval <= 0 {
            if isAudioPlaying {
                pause()
            }
            sleepTimerTargetDate = nil
            return
        }
        guard isAudioPlaying else { return }

        let fadeDuration: TimeInterval = 15.0
        let queue = DispatchQueue.global(qos: .userInteractive)

        // 1. Schedule 15-second graceful fade-out before the timer ends
        if interval > fadeDuration {
            let fadeDelay = interval - fadeDuration
            let fadeTimer = DispatchSource.makeTimerSource(queue: queue)
            fadeTimer.schedule(deadline: .now() + fadeDelay)
            fadeTimer.setEventHandler { [weak self] in
                Task { @MainActor [weak self] in
                    guard let self = self, self.isAudioPlaying else { return }
                    self.fadeVolume(to: 0.0, duration: fadeDuration)
                }
            }
            fadeTimer.resume()
            sleepFadeTimerSource = fadeTimer
        } else {
            // Already within the final 15 seconds: fade immediately over remaining time
            Task { @MainActor [weak self] in
                guard let self = self, self.isAudioPlaying else { return }
                self.fadeVolume(to: 0.0, duration: interval)
            }
        }

        // 2. Schedule final stop and volume restore at exact target timestamp
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(deadline: .now() + interval)
        timer.setEventHandler { [weak self] in
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                if self.isAudioPlaying {
                    self.stop()
                }
                self.playerNode.volume = self.volume > 0 ? self.volume : 0.5
                self.sleepTimerTargetDate = nil
            }
        }
        timer.resume()
        sleepTimerSource = timer
    }

    public var activeProfile: SoundProfile = .nightCrickets {
        didSet {
            guard oldValue != activeProfile else { return }
            bufferCache.removeAll(keepingCapacity: false)
            isBufferScheduled = false
            applyBuffer(for: activeProfile)
        }
    }

    public var volume: Float = 0.5 {
        didSet {
            let v = max(0, min(1, volume))
            isAudioPlaying ? fadeVolume(to: v, duration: 0.1) : (playerNode.volume = v)
        }
    }

    private init() {
        setupAudioSession()
        setupAudioEngine()
        setupRemoteCommandCenter()
        registerInterruptionNotification()
    }
    deinit { NotificationCenter.default.removeObserver(self) }

    // MARK: – Session & Engine Setup

    private var wasPlayingBeforeInterruption = false

    private func registerInterruptionNotification() {
        #if os(iOS)
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleInterruption),
            name: AVAudioSession.interruptionNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleRouteChange),
            name: AVAudioSession.routeChangeNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleEngineConfigurationChange),
            name: .AVAudioEngineConfigurationChange, object: audioEngine
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAppForeground),
            name: UIApplication.didBecomeActiveNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleAppForeground),
            name: UIApplication.willEnterForegroundNotification, object: nil
        )
        NotificationCenter.default.addObserver(
            self, selector: #selector(handleMemoryWarning),
            name: UIApplication.didReceiveMemoryWarningNotification, object: nil
        )
        #endif
    }

    #if os(iOS)
    @objc private func handleInterruption(notification: Notification) {
        guard let info = notification.userInfo,
              let typeVal = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeVal) else { return }
        switch type {
        case .began:
            guard isAudioPlaying else { return }
            wasPlayingBeforeInterruption = true
            
            // When another app starts playing (e.g. Spotify, Apple Music, YouTube, videos, or system sounds),
            // iOS may post an interruption event. By immediately re-asserting our mixable audio session,
            // Calmpal continues playing in the background simultaneously alongside the other sound or song!
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                guard let self = self, self.isAudioPlaying else { return }
                self.ensureEngineRunningAndPlaying(forceReschedule: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.30) { [weak self] in
                guard let self = self, self.isAudioPlaying else { return }
                self.ensureEngineRunningAndPlaying(forceReschedule: true)
            }
            
        case .ended:
            if wasPlayingBeforeInterruption {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08) { [weak self] in
                    guard let self = self, self.isAudioPlaying else { return }
                    self.ensureEngineRunningAndPlaying(forceReschedule: true)
                }
            }
            wasPlayingBeforeInterruption = false
        @unknown default: break
        }
    }

    @objc private func handleRouteChange(notification: Notification) {
        guard let info = notification.userInfo,
              let reasonVal = info[AVAudioSessionRouteChangeReasonKey] as? UInt,
              let reason = AVAudioSession.RouteChangeReason(rawValue: reasonVal) else { return }
        if reason == .oldDeviceUnavailable {
            wasPlayingBeforeInterruption = false
            pause()
        } else if isAudioPlaying {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
                guard let self = self, self.isAudioPlaying else { return }
                self.ensureEngineRunningAndPlaying(forceReschedule: true)
            }
        }
    }

    @objc private func handleEngineConfigurationChange(notification: Notification) {
        guard isAudioPlaying else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self = self, self.isAudioPlaying else { return }
            self.ensureEngineRunningAndPlaying(forceReschedule: true)
        }
    }

    @objc private func handleAppForeground(notification: Notification) {
        guard isAudioPlaying else { return }
        ensureEngineRunningAndPlaying(forceReschedule: false)
    }

    @objc private func handleMemoryWarning(notification: Notification) {
        let active = activeProfile
        let currentBuffer = bufferCache[active]
        bufferCache.removeAll(keepingCapacity: false)
        if let currentBuffer = currentBuffer {
            bufferCache[active] = currentBuffer
        }
    }
    #endif

    public func ensureEngineRunningAndPlaying(forceReschedule: Bool = false) {
        #if os(iOS)
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTestCase") != nil {
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioManager] Failed to set active session: \(error)")
        }
        #endif
        guard isAudioPlaying else { return }

        var didRestartEngine = false
        if !audioEngine.isRunning {
            do {
                try audioEngine.start()
                didRestartEngine = true
            } catch {
                print("[AudioManager] Failed to restart engine: \(error)")
                audioEngine.stop()
                audioEngine.reset()
                do {
                    try audioEngine.start()
                    didRestartEngine = true
                } catch {
                    print("[AudioManager] Engine reset start failed: \(error)")
                }
            }
        }

        if forceReschedule || didRestartEngine || !isBufferScheduled || !playerNode.isPlaying {
            applyBuffer(for: activeProfile)
        }
    }

    private func setupAudioSession() {
        #if os(iOS)
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTestCase") != nil {
            return
        }
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("[AudioManager] Session error: \(error)") }
        #endif
    }

    private func bannerTitle(for profile: SoundProfile) -> String {
        bannerFor(profile: profile).title
    }

    private func updateNowPlayingInfo() {
        #if os(iOS)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        #endif
        NotificationCenter.default.post(name: AudioManager.audioStateDidChangeNotification, object: self)
    }

    private var bufferCache = [SoundProfile: AVAudioPCMBuffer]()

    private func setupAudioEngine() {
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTestCase") != nil {
            return
        }
        audioEngine.attach(playerNode)
        let sr: Double = 44100.0
        let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 2)!
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: fmt)
        if let buf = bufferForProfile(activeProfile) {
            playerNode.scheduleBuffer(buf, at: nil, options: .loops, completionHandler: nil)
            isBufferScheduled = true
        }
    }

    // MARK: – Audio Buffer Management

    private func bufferForProfile(_ profile: SoundProfile) -> AVAudioPCMBuffer? {
        if let cached = bufferCache[profile] {
            return cached
        }
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTestCase") != nil {
            return nil
        }
        let resource = profile.resourceFileName

        // 1. Try loading real high-definition audio file from Bundle
        var audioURL: URL? = Bundle.main.url(forResource: resource, withExtension: "mp3")
        if audioURL == nil {
            audioURL = Bundle.main.url(forResource: resource, withExtension: "mp3", subdirectory: "Sounds")
        }

        if let url = audioURL, let file = try? AVAudioFile(forReading: url) {
            let fileFormat = file.processingFormat
            let frameCount = AVAudioFrameCount(file.length)
            if let fileBuffer = AVAudioPCMBuffer(pcmFormat: fileFormat, frameCapacity: frameCount) {
                do {
                    try file.read(into: fileBuffer)

                    // Target standard engine format: 44.1kHz Stereo (2 channels)
                    guard let standardFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2) else {
                        bufferCache[profile] = fileBuffer
                        return fileBuffer
                    }

                    let finalBuffer: AVAudioPCMBuffer
                    if fileFormat.sampleRate == standardFormat.sampleRate && fileFormat.channelCount == standardFormat.channelCount {
                        finalBuffer = fileBuffer
                    } else if let converter = AVAudioConverter(from: fileFormat, to: standardFormat) {
                        let ratio = standardFormat.sampleRate / fileFormat.sampleRate
                        let targetCapacity = AVAudioFrameCount(Double(frameCount) * ratio + 100)
                        if let convertedBuffer = AVAudioPCMBuffer(pcmFormat: standardFormat, frameCapacity: targetCapacity) {
                            var error: NSError? = nil
                            var haveData = true
                            converter.convert(to: convertedBuffer, error: &error) { _, outStatus in
                                if haveData {
                                    haveData = false
                                    outStatus.pointee = .haveData
                                    return fileBuffer
                                } else {
                                    outStatus.pointee = .noDataNow
                                    return nil
                                }
                            }
                            if error == nil && convertedBuffer.frameLength > 0 {
                                finalBuffer = convertedBuffer
                            } else {
                                finalBuffer = fileBuffer
                            }
                        } else {
                            finalBuffer = fileBuffer
                        }
                    } else {
                        finalBuffer = fileBuffer
                    }

                    // For Surrender: Apply smooth 20-second slow fade away before loop restarts
                    if profile == .surrender {
                        applyTailFade(to: finalBuffer, fadeDuration: 20.0)
                    }

                    bufferCache[profile] = finalBuffer
                    return finalBuffer
                } catch {
                    print("[AudioManager] Failed to read audio file: \(error)")
                }
            }
        }

        // 2. Synthesize clean procedural buffer fallback (2.5s loop, 110,250 samples, stereo 2-channels)
        let sr: Double = 44100.0
        let fc = AVAudioFrameCount(sr * 2.5)
        let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 2)!

        guard let buf = AVAudioPCMBuffer(pcmFormat: fmt, frameCapacity: fc) else { return nil }
        buf.frameLength = fc

        if let floatData = buf.floatChannelData {
            let n = Int(fc)
            let left = floatData[0]
            let right = fmt.channelCount > 1 ? floatData[1] : floatData[0]
            for i in 0..<n { left[i] = 0; right[i] = 0 }
            fillBuffer(profile, left, count: n, sampleRate: sr)
            for i in 0..<n { right[i] = left[i] }
            
            var maxAmp: Float = 0.0
            for i in 0..<n {
                let absVal = abs(left[i])
                if absVal > maxAmp { maxAmp = absVal }
            }
            if maxAmp > 0.95 {
                let scale = 0.95 / maxAmp
                for i in 0..<n { left[i] *= scale; right[i] *= scale }
            }
        }
        bufferCache[profile] = buf
        return buf
    }

    /// Applies a smooth half-cosine fade-out to the final seconds of a PCM buffer so it gently fades to zero before looping
    func applyTailFade(to buffer: AVAudioPCMBuffer, fadeDuration: Double) {
        guard let floatData = buffer.floatChannelData else { return }
        let frameLength = Int(buffer.frameLength)
        let sampleRate = buffer.format.sampleRate
        let fadeFrames = Int(fadeDuration * sampleRate)
        guard frameLength > fadeFrames else { return }
        let fadeStart = frameLength - fadeFrames
        let channelCount = Int(buffer.format.channelCount)
        for ch in 0..<channelCount {
            let channel = floatData[ch]
            for i in 0..<fadeFrames {
                let progress = Double(i) / Double(fadeFrames)
                // Half-cosine curve: 1.0 at start of fade -> 0.0 at very end
                let gain = Float(0.5 * (1.0 + cos(.pi * progress)))
                channel[fadeStart + i] *= gain
            }
        }
    }

    private func applyBuffer(for profile: SoundProfile) {
        guard let buf = bufferForProfile(profile) else {
            isBufferScheduled = false
            return
        }
        let wasPlaying = isAudioPlaying
        playerNode.stop()
        playerNode.scheduleBuffer(buf, at: nil, options: .loops, completionHandler: nil)
        isBufferScheduled = true
        if wasPlaying {
            if !audioEngine.isRunning {
                try? audioEngine.start()
            }
            playerNode.play()
        }
    }

    nonisolated private func fillBuffer(_ profile: SoundProfile, _ cd: UnsafeMutablePointer<Float>, count n: Int, sampleRate sr: Double) {
        var last: Float = 0.0
        for i in 0..<n {
            let white = Float.random(in: -1.0...1.0)
            last = (last + 0.02 * white) / 1.02
            cd[i] = last * 0.045
        }
    }

    // MARK: – Public Controls

    public func start() {
        guard !isAudioPlaying else { return }
        resume()
    }

    public func restartFromStart() {
        fadeTask?.cancel()
        fadeTask = nil
        isAudioPlaying = true
        let targetVolume = self.volume > 0 ? self.volume : 0.5
        playerNode.volume = targetVolume

        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTestCase") != nil {
            isBufferScheduled = true
            updateNowPlayingInfo()
            return
        }

        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioManager] restartFromStart session error: \(error)")
        }
        do {
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
        } catch {
            print("[AudioManager] restartFromStart engine error: \(error)")
            return
        }
        #endif

        applyBuffer(for: activeProfile)
        if !playerNode.isPlaying {
            playerNode.play()
        }
        if sleepTimerTargetDate != nil {
            scheduleSleepTimer()
        }
        updateNowPlayingInfo()
    }

    public func togglePlayPause() {
        if isAudioPlaying {
            pause()
        } else {
            resume()
        }
    }

    public func pause() {
        guard isAudioPlaying else { return }
        fadeTask?.cancel()
        fadeTask = nil
        sleepTimerSource?.cancel()
        sleepTimerSource = nil
        sleepFadeTimerSource?.cancel()
        sleepFadeTimerSource = nil
        isAudioPlaying = false
        playerNode.pause()
        playerNode.volume = self.volume > 0 ? self.volume : 0.5
        updateNowPlayingInfo()
    }

    public func resume() {
        guard !isAudioPlaying else { return }
        fadeTask?.cancel()
        fadeTask = nil

        isAudioPlaying = true

        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTestCase") != nil {
            updateNowPlayingInfo()
            return
        }

        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.mixWithOthers, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("[AudioManager] Resume session error: \(error)")
        }
        #endif

        do {
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
        } catch {
            print("[AudioManager] Resume engine error: \(error)")
            return
        }

        let targetVolume = self.volume > 0 ? self.volume : 0.5
        playerNode.volume = targetVolume

        if !isBufferScheduled {
            applyBuffer(for: activeProfile)
        }

        if !playerNode.isPlaying {
            playerNode.play()
        }

        if sleepTimerTargetDate != nil {
            scheduleSleepTimer()
        }

        updateNowPlayingInfo()
    }

    public func stop() {
        isAudioPlaying = false
        playerNode.stop()
        isBufferScheduled = false
        fadeTask?.cancel()
        fadeTask = nil
        sleepTimerSource?.cancel()
        sleepTimerSource = nil
        sleepFadeTimerSource?.cancel()
        sleepFadeTimerSource = nil
        sleepTimerTargetDate = nil
        playerNode.volume = self.volume > 0 ? self.volume : 0.5
        #if os(iOS)
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nil
        #endif
        updateNowPlayingInfo()
    }

    public func selectNextSound() {
        guard let currentIndex = allSoundBanners.firstIndex(where: { $0.profile == activeProfile }) else { return }
        let newIndex = (currentIndex + 1) % allSoundBanners.count
        activeProfile = allSoundBanners[newIndex].profile
        if !isAudioPlaying {
            resume()
        }
    }

    public func selectPreviousSound() {
        guard let currentIndex = allSoundBanners.firstIndex(where: { $0.profile == activeProfile }) else { return }
        let newIndex = (currentIndex - 1 + allSoundBanners.count) % allSoundBanners.count
        activeProfile = allSoundBanners[newIndex].profile
        if !isAudioPlaying {
            resume()
        }
    }

    private func setupRemoteCommandCenter() {
        #if os(iOS)
        if ProcessInfo.processInfo.environment["XCTestConfigurationFilePath"] != nil || NSClassFromString("XCTestCase") != nil {
            return
        }
        let commandCenter = MPRemoteCommandCenter.shared()
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.pauseCommand.isEnabled = false
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.playCommand.isEnabled = false
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.isEnabled = false
        commandCenter.nextTrackCommand.removeTarget(nil)
        commandCenter.nextTrackCommand.isEnabled = false
        commandCenter.previousTrackCommand.removeTarget(nil)
        commandCenter.previousTrackCommand.isEnabled = false
        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.stopCommand.isEnabled = false
        commandCenter.changePlaybackPositionCommand.isEnabled = false
        #endif
    }

    public func fadeVolume(to target: Float, duration: Double, completion: (() -> Void)? = nil) {
        fadeTask?.cancel()
        if duration < 0.05 {
            playerNode.volume = target
            completion?()
            return
        }
        fadeTask = Task { @MainActor in
            let steps = max(10, Int(duration * 30.0))
            let interval = duration / Double(steps)
            let start = playerNode.volume
            let diff  = target - start
            for step in 1...steps {
                if Task.isCancelled { return }
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                playerNode.volume = max(0.0, min(1.0, start + diff * Float(step) / Float(steps)))
            }
            playerNode.volume = target
            completion?()
        }
    }
}
