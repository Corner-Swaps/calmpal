//
//  AudioManager.swift
//  Calmpal
//
//  25 Authentic Sound Recordings with single-word titles:
//  Rain · Ocean · Forest · Wind · Ambient
//  High-definition audio player with smooth looping and seamless engine playback.
//

import AVFoundation
import MediaPlayer

// MARK: ── Sound Profile ───────────────────────────────────────────────────────

public enum SoundProfile: String, CaseIterable, Identifiable, Codable, Sendable {

    // ── Rain (5) ──────────────────────────────────────────────────────────────
    case gentleRain      = "Drizzle"
    case rainOnWindow    = "Window"
    case rainCanopy      = "Canopy"
    case heavyRain       = "Downpour"
    case rollingThunder  = "Thunder"

    // ── Ocean (5) ─────────────────────────────────────────────────────────────
    case oceanWaves      = "Waves"
    case waterfall       = "Waterfall"
    case forestRiver     = "River"
    case waterDroplets   = "Droplets"
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

    public var id: String { rawValue }
    public var displayName: String { rawValue }

    // MARK: – Resource File Base Name
    public var resourceFileName: String {
        switch self {
        case .gentleRain:      return "light-rain"
        case .rainOnWindow:    return "rain-on-window"
        case .rainCanopy:      return "rain-on-leaves"
        case .heavyRain:       return "heavy-rain"
        case .rollingThunder:  return "thunder"
        case .oceanWaves:      return "waves"
        case .waterfall:       return "waterfall"
        case .forestRiver:     return "river"
        case .waterDroplets:   return "droplets"
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
        }
    }

    // MARK: – Therapeutic description
    public var explanation: String {
        switch self {
        case .gentleRain:      return "Soft, soothing patter of light rainfall."
        case .rainOnWindow:    return "Calming rain drops tapping against window pane glass."
        case .rainCanopy:      return "Gentle shower falling on forest leaves and foliage."
        case .heavyRain:       return "Deep, comforting downfall of steady summer rain."
        case .rollingThunder:  return "Low, rumbling thunder echoing safely over hills."
        case .oceanWaves:      return "Rhythmic ocean surf swells rolling onto sandy shores."
        case .waterfall:       return "Pure white water cascading into a deep natural pool."
        case .forestRiver:     return "Clear stream water trickling over smooth river stones."
        case .waterDroplets:   return "Crisp, rhythmic water drops falling into a spring."
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
        }
    }

    public var frequencyValue: Double? { nil }

    public var shortName: String {
        switch self {
        case .gentleRain, .rainOnWindow, .rainCanopy, .heavyRain, .rollingThunder:
            return "Rain"
        case .oceanWaves, .waterfall, .forestRiver, .waterDroplets, .coastalSeagulls:
            return "Ocean"
        case .forestBirdsong, .tropicalJungle, .nightCrickets, .eveningFrogs, .catPurring:
            return "Forest"
        case .windInTrees, .cozyCampfire, .duneBreeze, .howlingWind, .walkOnLeaves:
            return "Wind"
        case .warmCafe, .quietLibrary, .nightVillage, .templeSanctuary, .deepUnderwater:
            return "Ambient"
        }
    }
}

// MARK: ── AudioManager ────────────────────────────────────────────────────────

@MainActor
public final class AudioManager {

    public static let shared = AudioManager()
    public static let audioStateDidChangeNotification = Notification.Name("CalmpalAudioStateDidChangeNotification")

    public private(set) var isAudioPlaying: Bool = false

    private let audioEngine = AVAudioEngine()
    private let playerNode  = AVAudioPlayerNode()
    private var fadeTask: Task<Void, Never>?

    public var activeProfile: SoundProfile = .gentleRain {
        didSet {
            guard oldValue != activeProfile else { return }
            bufferCache.removeAll(keepingCapacity: false)
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
            if !playerNode.isPlaying && isAudioPlaying {
                applyBuffer(for: activeProfile)
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
                options: [.allowBluetoothA2DP, .mixWithOthers]
            )
            try AVAudioSession.sharedInstance().setActive(true)
        } catch { print("[AudioManager] Session error: \(error)") }
        #endif
    }

    private func bannerTitle(for profile: SoundProfile) -> String {
        switch profile {
        case .nightCrickets:   return "Crickets Night"
        case .gentleRain:      return "Gentle Rain"
        case .cozyCampfire:    return "Cozy Campfire"
        case .oceanWaves:      return "Peaceful Ocean"
        case .windInTrees:     return "Wind in Trees"
        case .rainOnWindow:    return "Rain on Window"
        case .catPurring:      return "Cat Purring"
        case .waterfall:       return "Forest Waterfall"
        case .quietLibrary:    return "Quiet Library"
        case .rollingThunder:  return "Rolling Thunder"
        case .duneBreeze:      return "Desert Dune Breeze"
        case .forestRiver:     return "Flowing River"
        case .eveningFrogs:    return "Evening Frogs"
        case .heavyRain:       return "Heavy Downpour"
        case .templeSanctuary: return "Sacred Temple"
        case .coastalSeagulls: return "Coastal Seagulls"
        case .howlingWind:     return "Howling Winter Gale"
        case .rainCanopy:      return "Rain on Leaves"
        case .deepUnderwater:  return "Deep Underwater"
        case .tropicalJungle:  return "Tropical Jungle"
        case .nightVillage:    return "Quiet Mountain Village"
        default:               return profile.rawValue
        }
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
                    let standardFormat = AVAudioFormat(standardFormatWithSampleRate: 44100.0, channels: 2)!
                    
                    if fileFormat.sampleRate == standardFormat.sampleRate && fileFormat.channelCount == standardFormat.channelCount {
                        bufferCache[profile] = fileBuffer
                        return fileBuffer
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
                                bufferCache[profile] = convertedBuffer
                                return convertedBuffer
                            }
                        }
                    }
                    bufferCache[profile] = fileBuffer
                    return fileBuffer
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

    private func applyBuffer(for profile: SoundProfile) {
        guard let buf = bufferForProfile(profile) else { return }
        let wasPlaying = isAudioPlaying
        playerNode.stop()
        playerNode.scheduleBuffer(buf, at: nil, options: .loops, completionHandler: nil)
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
                options: [.allowBluetoothA2DP, .mixWithOthers]
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

        if !playerNode.isPlaying {
            applyBuffer(for: activeProfile)
            playerNode.play()
        }

        updateNowPlayingInfo()
    }

    public func stop() {
        isAudioPlaying = false
        playerNode.stop()
        updateNowPlayingInfo()
    }

    private func setupRemoteCommandCenter() {
        #if os(iOS)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        let commandCenter = MPRemoteCommandCenter.shared()
        
        commandCenter.pauseCommand.isEnabled = true
        commandCenter.pauseCommand.removeTarget(nil)
        commandCenter.pauseCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async {
                self?.pause()
            }
            return .success
        }
        
        commandCenter.playCommand.isEnabled = true
        commandCenter.playCommand.removeTarget(nil)
        commandCenter.playCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async {
                self?.resume()
            }
            return .success
        }
        
        commandCenter.togglePlayPauseCommand.isEnabled = true
        commandCenter.togglePlayPauseCommand.removeTarget(nil)
        commandCenter.togglePlayPauseCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async {
                self?.togglePlayPause()
            }
            return .success
        }

        commandCenter.stopCommand.isEnabled = true
        commandCenter.stopCommand.removeTarget(nil)
        commandCenter.stopCommand.addTarget { [weak self] _ in
            DispatchQueue.main.async {
                self?.pause()
            }
            return .success
        }

        commandCenter.changePlaybackPositionCommand.isEnabled = false
        #endif
    }

    private func fadeVolume(to target: Float, duration: Double, completion: (() -> Void)? = nil) {
        fadeTask?.cancel()
        fadeTask = Task { @MainActor in
            let steps = 20
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
