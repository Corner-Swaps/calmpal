//
//  AudioManager.swift
//  Calmpal
//
//  25 Authentic Sound Recordings with single-word titles:
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
    private let analyzer = AudioSpectrumAnalyzer()
    private var fadeTask: Task<Void, Never>?
    public private(set) var isBufferScheduled: Bool = false
    private var lastRemoteCommandTime: TimeInterval = 0

    public var activeProfile: SoundProfile = .gentleRain {
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
        #endif
    }

    #if os(iOS)
    @objc private func handleInterruption(notification: Notification) {
        guard let info = notification.userInfo,
              let typeVal = info[AVAudioSessionInterruptionTypeKey] as? UInt,
              let type = AVAudioSession.InterruptionType(rawValue: typeVal) else { return }
        switch type {
        case .began:
            wasPlayingBeforeInterruption = isAudioPlaying
            if isAudioPlaying {
                pause()
            }
        case .ended:
            if wasPlayingBeforeInterruption {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                    self?.resume()
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
            ensureEngineRunningAndPlaying()
        }
    }

    @objc private func handleEngineConfigurationChange(notification: Notification) {
        guard isAudioPlaying else { return }
        ensureEngineRunningAndPlaying()
    }

    @objc private func handleAppForeground(notification: Notification) {
        guard isAudioPlaying else { return }
        ensureEngineRunningAndPlaying()
    }
    #endif

    public func ensureEngineRunningAndPlaying() {
        #if os(iOS)
        setupAudioSession()
        #endif
        do {
            if !audioEngine.isRunning {
                try audioEngine.start()
            }
            if !isBufferScheduled {
                applyBuffer(for: activeProfile)
            }
            if !playerNode.isPlaying && isAudioPlaying {
                playerNode.play()
            }
        } catch {
            print("[AudioManager] Failed to ensure engine running: \(error)")
        }
    }

    private func setupAudioSession() {
        #if os(iOS)
        do {
            try AVAudioSession.sharedInstance().setCategory(
                .playback,
                mode: .default,
                options: [.allowBluetoothHFP, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
        } catch { print("[AudioManager] Session error: \(error)") }
        #endif
    }

    private func bannerTitle(for profile: SoundProfile) -> String {
        bannerFor(profile: profile).title
    }

    private func updateNowPlayingInfo() {
        #if os(iOS)
        let playing = self.isAudioPlaying
        var info = [String: Any]()
        info[MPMediaItemPropertyTitle] = bannerTitle(for: activeProfile)
        info[MPMediaItemPropertyArtist] = "Calmpal"
        info[MPMediaItemPropertyPlaybackDuration] = 86400.0
        info[MPNowPlayingInfoPropertyPlaybackRate] = playing ? 1.0 : 0.0
        info[MPNowPlayingInfoPropertyDefaultPlaybackRate] = 1.0
        info[MPNowPlayingInfoPropertyElapsedPlaybackTime] = 0.0
        info[MPNowPlayingInfoPropertyMediaType] = MPNowPlayingInfoMediaType.audio.rawValue

        // Universal Crisp White Sound Playing Icon for Dynamic Island (Pure black background, no gray box, no emojis)
        let artworkSize = CGSize(width: 128, height: 128)
        let artwork = MPMediaItemArtwork(boundsSize: artworkSize) { targetSize in
            let renderer = UIGraphicsImageRenderer(size: targetSize)
            return renderer.image { ctx in
                // Pure black background seamlessly blends into the Dynamic Island hardware pill
                UIColor.black.setFill()
                ctx.fill(CGRect(origin: .zero, size: targetSize))

                let config = UIImage.SymbolConfiguration(pointSize: targetSize.width * 0.52, weight: .medium)
                if let icon = UIImage(systemName: "speaker.wave.2.fill", withConfiguration: config)?.withTintColor(.white, renderingMode: .alwaysOriginal) {
                    let iconRect = CGRect(
                        x: (targetSize.width - icon.size.width) / 2,
                        y: (targetSize.height - icon.size.height) / 2,
                        width: icon.size.width,
                        height: icon.size.height
                    )
                    icon.draw(in: iconRect)
                }
            }
        }
        info[MPMediaItemPropertyArtwork] = artwork
        MPNowPlayingInfoCenter.default().nowPlayingInfo = info
        MPNowPlayingInfoCenter.default().playbackState = playing ? .playing : .paused
        #endif
        NotificationCenter.default.post(name: AudioManager.audioStateDidChangeNotification, object: self)
    }

    private var bufferCache = [SoundProfile: AVAudioPCMBuffer]()

    private func setupAudioEngine() {
        audioEngine.attach(playerNode)
        let sr: Double = 44100.0
        let fmt = AVAudioFormat(standardFormatWithSampleRate: sr, channels: 2)!
        audioEngine.connect(playerNode, to: audioEngine.mainMixerNode, format: fmt)
        if let buf = bufferForProfile(activeProfile) {
            playerNode.scheduleBuffer(buf, at: nil, options: .loops, completionHandler: nil)
            isBufferScheduled = true
        }
        setupAudioTap()
    }

    private func setupAudioTap() {
        let mixer = audioEngine.mainMixerNode
        mixer.removeTap(onBus: 0)
        let bufferSize: AVAudioFrameCount = 1024
        mixer.installTap(onBus: 0, bufferSize: bufferSize, format: nil) { [weak self] buffer, time in
            guard let self = self, self.isAudioPlaying else {
                DispatchQueue.main.async {
                    self?.audioLevel = 0.0
                    self?.audioPeak = 0.0
                    self?.audioBass = 0.0
                    self?.audioMid = 0.0
                    self?.audioTreble = 0.0
                    self?.audioTransient = 0.0
                    self?.audioFrequencies = Array(repeating: 0.0, count: 16)
                    self?.audioWaveform = Array(repeating: 0.0, count: 64)
                }
                return
            }
            guard let channelData = buffer.floatChannelData?[0] else { return }
            let frameLength = Int(buffer.frameLength)
            guard frameLength > 0 else { return }

            let res = self.analyzer.analyze(channelData: channelData, frameLength: frameLength)

            DispatchQueue.main.async {
                self.audioLevel = self.audioLevel * 0.20 + res.level * 0.80
                self.audioPeak = self.audioPeak * 0.15 + res.peak * 0.85
                self.audioBass = self.audioBass * 0.25 + res.bass * 0.75
                self.audioMid = self.audioMid * 0.25 + res.mid * 0.75
                self.audioTreble = self.audioTreble * 0.25 + res.treble * 0.75
                self.audioTransient = res.transient
                for b in 0..<16 {
                    self.audioFrequencies[b] = self.audioFrequencies[b] * 0.30 + res.frequencies[b] * 0.70
                }
                self.audioWaveform = res.waveform
            }
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
        isAudioPlaying = false
        playerNode.pause()
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
                options: [.allowBluetoothHFP, .allowBluetoothA2DP]
            )
            try AVAudioSession.sharedInstance().setActive(true)
            UIApplication.shared.beginReceivingRemoteControlEvents()
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

        updateNowPlayingInfo()
    }

    public func stop() {
        isAudioPlaying = false
        playerNode.stop()
        isBufferScheduled = false
        #if os(iOS)
        MPNowPlayingInfoCenter.default().playbackState = .stopped
        #endif
        updateNowPlayingInfo()
    }

    private func setupRemoteCommandCenter() {
        #if os(iOS)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            let now = ProcessInfo.processInfo.systemUptime
            guard now - self.lastRemoteCommandTime > 0.35 else { return .success }
            self.lastRemoteCommandTime = now
            DispatchQueue.main.async {
                self.pause()
            }
            return .success
        }
        
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.addTarget { [weak self] _ in
            guard let self = self else { return .commandFailed }
            let now = ProcessInfo.processInfo.systemUptime
            guard now - self.lastRemoteCommandTime > 0.35 else { return .success }
            self.lastRemoteCommandTime = now
            DispatchQueue.main.async {
                self.resume()
            }
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            let now = ProcessInfo.processInfo.systemUptime
            guard let self = self, now - self.lastRemoteCommandTime > 0.35 else {
                return .success
            }
            self.lastRemoteCommandTime = now
            DispatchQueue.main.async {
                self.togglePlayPause()
            }
            return .success
        }

        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async {
                self?.stop()
            }
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = false
        #endif
    }

    private func fadeVolume(to target: Float, duration: Double, completion: (() -> Void)? = nil) {
        fadeTask?.cancel()
        if duration < 0.05 {
            playerNode.volume = target
            completion?()
            return
        }
        fadeTask = Task { @MainActor in
            let steps = max(4, min(20, Int(duration * 20.0)))
            let interval = duration / Double(steps)
            let start = playerNode.volume
            let diff  = target - start
            for step in 1...steps {
                if Task.isCancelled { return }
                try? await Task.sleep(nanoseconds: UInt64(interval * 1_000_000_000))
                playerNode.volume = start + diff * Float(step) / Float(steps)
            }
            completion?()
        }
    }
}

// MARK: ── Audio Spectrum & Waveform Analyzer (Accelerate FFT & DSP) ──────────

private final class AudioSpectrumAnalyzer: @unchecked Sendable {
    private let fftSize: Int = 1024
    private let log2n: vDSP_Length
    private let fftSetup: FFTSetup?
    private var window: [Float]
    private var realp: [Float]
    private var imagp: [Float]
    private var magnitudes: [Float]
    private var previousLevel: Float = 0.0

    init() {
        self.log2n = vDSP_Length(10) // 2^10 = 1024
        self.fftSetup = vDSP_create_fftsetup(log2n, FFTRadix(kFFTRadix2))
        self.window = [Float](repeating: 0, count: 1024)
        vDSP_hann_window(&window, 1024, Int32(vDSP_HANN_NORM))
        
        let halfSize = 512
        self.realp = [Float](repeating: 0, count: halfSize)
        self.imagp = [Float](repeating: 0, count: halfSize)
        self.magnitudes = [Float](repeating: 0, count: halfSize)
    }

    deinit {
        if let setup = fftSetup {
            vDSP_destroy_fftsetup(setup)
        }
    }

    struct AnalysisResult {
        let level: Float
        let peak: Float
        let bass: Float
        let mid: Float
        let treble: Float
        let transient: Float
        let frequencies: [Float] // 16 logarithmic frequency bands
        let waveform: [Float]    // 64 live time-domain samples
    }

    func analyze(channelData: UnsafePointer<Float>, frameLength: Int) -> AnalysisResult {
        let count = min(frameLength, fftSize)
        guard count >= 64 else {
            return AnalysisResult(
                level: 0, peak: 0, bass: 0, mid: 0, treble: 0, transient: 0,
                frequencies: Array(repeating: 0, count: 16),
                waveform: Array(repeating: 0, count: 64)
            )
        }

        // 1. RMS Amplitude & Peak
        var sumSquares: Float = 0
        var peakVal: Float = 0
        vDSP_measqv(channelData, 1, &sumSquares, vDSP_Length(count))
        vDSP_maxmgv(channelData, 1, &peakVal, vDSP_Length(count))
        let rms = sqrt(sumSquares)
        let normalizedLevel = min(1.0, max(0.0, rms * 5.5))
        let normalizedPeak = min(1.0, max(0.0, peakVal * 4.0))

        // 2. Subsample 64-point live waveform for oscilloscope rendering
        var wave64 = [Float](repeating: 0, count: 64)
        let step = max(1, count / 64)
        for i in 0..<64 {
            let idx = min(count - 1, i * step)
            wave64[i] = max(-1.0, min(1.0, channelData[idx] * 3.5))
        }

        // 3. FFT or Chunked Energy Fallback
        guard let setup = fftSetup, count == fftSize else {
            var fallbackBands = [Float](repeating: 0, count: 16)
            let chunkSize = max(1, count / 16)
            for b in 0..<16 {
                let s = b * chunkSize
                let e = min(count, s + chunkSize)
                var bSum: Float = 0
                for i in s..<e { bSum += abs(channelData[i]) }
                fallbackBands[b] = min(1.0, (bSum / Float(chunkSize)) * 4.5)
            }
            let bass = (fallbackBands[0] + fallbackBands[1]) / 2.0
            let mid = (fallbackBands[4] + fallbackBands[5]) / 2.0
            let treble = (fallbackBands[12] + fallbackBands[13]) / 2.0
            let delta = max(0.0, normalizedLevel - previousLevel)
            previousLevel = normalizedLevel
            return AnalysisResult(
                level: normalizedLevel,
                peak: normalizedPeak,
                bass: bass,
                mid: mid,
                treble: treble,
                transient: min(1.0, delta * 3.0),
                frequencies: fallbackBands,
                waveform: wave64
            )
        }

        // Apply Hann window
        var windowedInput = [Float](repeating: 0, count: fftSize)
        vDSP_vmul(channelData, 1, window, 1, &windowedInput, 1, vDSP_Length(fftSize))

        let halfSize = fftSize / 2
        realp.withUnsafeMutableBufferPointer { rPtr in
            imagp.withUnsafeMutableBufferPointer { iPtr in
                var splitComplex = DSPSplitComplex(realp: rPtr.baseAddress!, imagp: iPtr.baseAddress!)
                windowedInput.withUnsafeBufferPointer { wPtr in
                    wPtr.baseAddress!.withMemoryRebound(to: DSPComplex.self, capacity: halfSize) { complexPtr in
                        vDSP_ctoz(complexPtr, 2, &splitComplex, 1, vDSP_Length(halfSize))
                    }
                }

                vDSP_fft_zrip(setup, &splitComplex, 1, log2n, FFTDirection(FFT_FORWARD))
                vDSP_zvmags(&splitComplex, 1, &magnitudes, 1, vDSP_Length(halfSize))
            }
        }
        var norm: Float = 2.0 / Float(fftSize)
        vDSP_vsmul(magnitudes, 1, &norm, &magnitudes, 1, vDSP_Length(halfSize))
        var sqrtMags = [Float](repeating: 0, count: halfSize)
        vvsqrtf(&sqrtMags, magnitudes, [Int32(halfSize)])

        // Group into 16 perceptual frequency bands
        var bands16 = [Float](repeating: 0, count: 16)
        for b in 0..<16 {
            let startBin = Int(pow(Double(halfSize), Double(b) / 16.0))
            let endBin = max(startBin + 1, Int(pow(Double(halfSize), Double(b + 1) / 16.0)))
            let sBin = min(halfSize - 1, startBin)
            let eBin = min(halfSize, endBin)
            var bSum: Float = 0
            for k in sBin..<eBin {
                bSum += sqrtMags[k]
            }
            let avg = bSum / Float(max(1, eBin - sBin))
            bands16[b] = min(1.0, avg * 14.0)
        }

        let bass = (bands16[0] + bands16[1] + bands16[2] + bands16[3]) / 4.0
        let mid = (bands16[4] + bands16[5] + bands16[6] + bands16[7] + bands16[8] + bands16[9]) / 6.0
        let treble = (bands16[10] + bands16[11] + bands16[12] + bands16[13] + bands16[14] + bands16[15]) / 6.0

        // Transient energy detection
        let delta = max(0.0, normalizedLevel - previousLevel)
        let highBurst = max(0.0, treble - 0.20)
        let transient = min(1.0, delta * 3.5 + highBurst * 1.5)
        previousLevel = normalizedLevel

        return AnalysisResult(
            level: normalizedLevel,
            peak: normalizedPeak,
            bass: min(1.0, bass),
            mid: min(1.0, mid),
            treble: min(1.0, treble),
            transient: transient,
            frequencies: bands16,
            waveform: wave64
        )
    }
}
