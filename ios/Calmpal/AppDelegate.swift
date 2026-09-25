internal import Expo
import React
import ReactAppDependencyProvider
import AVFoundation

import ObjectiveC
import MediaPlayer

private func createNowPlayingArtwork() -> MPMediaItemArtwork? {
  let size = CGSize(width: 256, height: 256)
  return MPMediaItemArtwork(boundsSize: size) { requestedSize in
    let width = requestedSize.width > 0 ? requestedSize.width : size.width
    let height = requestedSize.height > 0 ? requestedSize.height : size.height
    let targetSize = CGSize(width: width, height: height)

    let format = UIGraphicsImageRendererFormat.default()
    format.opaque = true
    let renderer = UIGraphicsImageRenderer(size: targetSize, format: format)
    return renderer.image { ctx in
      UIColor.black.setFill()
      ctx.fill(CGRect(origin: .zero, size: targetSize))
    }.withRenderingMode(.alwaysOriginal)
  }
}

// Ensures MPMediaItemPropertyArtwork is NEVER empty or replaced with a generic speaker icon
private func setupNowPlayingArtworkProtection() {
  guard let method = class_getInstanceMethod(MPNowPlayingInfoCenter.self, #selector(setter: MPNowPlayingInfoCenter.nowPlayingInfo)) else {
    return
  }
  let originalImp = method_getImplementation(method)
  typealias SetterFunc = @convention(c) (AnyObject, Selector, NSDictionary?) -> Void
  let originalSetter = unsafeBitCast(originalImp, to: SetterFunc.self)

  let newBlock: @convention(block) (AnyObject, NSDictionary?) -> Void = { center, info in
    guard let infoDict = info as? [String: Any] else {
      originalSetter(center, #selector(setter: MPNowPlayingInfoCenter.nowPlayingInfo), info)
      return
    }
    var updated = infoDict
    if let artwork = createNowPlayingArtwork() {
      updated[MPMediaItemPropertyArtwork] = artwork
    }
    if updated[MPMediaItemPropertyTitle] == nil {
      updated[MPMediaItemPropertyTitle] = "Calmpal"
    }
    if updated[MPMediaItemPropertyArtist] == nil {
      updated[MPMediaItemPropertyArtist] = "Soundscapes"
    }
    let isPlaying = (updated[MPNowPlayingInfoPropertyPlaybackRate] as? Double ?? 0) > 0
    updated[MPNowPlayingInfoPropertyPlaybackRate] = isPlaying ? 1.0 : 0.0
    originalSetter(center, #selector(setter: MPNowPlayingInfoCenter.nowPlayingInfo), updated as NSDictionary)
  }
  let newImp = imp_implementationWithBlock(newBlock)
  method_setImplementation(method, newImp)
}

// Custom UIWindow subclass that completely suppresses the shake-to-open Dev Menu gesture
final class NonShakingWindow: UIWindow {
  override func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
    if motion == .motionShake {
      return
    }
    super.motionEnded(motion, with: event)
  }
}

// Permanently neutralizes RCTDevMenu methods and UIWindow shake swizzling so the Dev Menu can never appear
private func permanentlyDisableDevMenu() {
  let emptyVoidBlock: @convention(block) (AnyObject) -> Void = { _ in }
  let emptyVoidImp = imp_implementationWithBlock(emptyVoidBlock)

  if let devMenuClass = NSClassFromString("RCTDevMenu") {
    let selectors = ["show", "showOnShake", "toggle"]
    for selName in selectors {
      let sel = Selector(selName)
      if let method = class_getInstanceMethod(devMenuClass, sel) {
        method_setImplementation(method, emptyVoidImp)
      }
    }
  }

  let emptyMotionBlock: @convention(block) (AnyObject, UIEvent.EventSubtype, UIEvent?) -> Void = { _, _, _ in }
  let emptyMotionImp = imp_implementationWithBlock(emptyMotionBlock)

  for selName in ["RCT_motionEnded:withEvent:", "motionEnded:withEvent:"] {
    let sel = Selector(selName)
    if let method = class_getInstanceMethod(UIWindow.self, sel) {
      method_setImplementation(method, emptyMotionImp)
    }
  }
}

@main
class AppDelegate: ExpoAppDelegate {
  var window: UIWindow?

  var reactNativeDelegate: ExpoReactNativeFactoryDelegate?
  var reactNativeFactory: RCTReactNativeFactory?

  public override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
  ) -> Bool {
    permanentlyDisableDevMenu()
    setupNowPlayingArtworkProtection()

    let delegate = ReactNativeDelegate()
    let factory = ExpoReactNativeFactory(delegate: delegate)
    delegate.dependencyProvider = RCTAppDependencyProvider()

    reactNativeDelegate = delegate
    #if DEBUG && canImport(React)
    factory.devMenuConfiguration = RCTDevMenuConfiguration(devMenuEnabled: false, shakeGestureEnabled: false, keyboardShortcutsEnabled: false)
    #endif
    reactNativeFactory = factory

#if os(iOS) || os(tvOS)
    window = NonShakingWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .black

    do {
      try AVAudioSession.sharedInstance().setCategory(
        .playback,
        mode: .default,
        options: [.allowBluetoothA2DP, .allowAirPlay]
      )
      try AVAudioSession.sharedInstance().setActive(true)
      UIApplication.shared.beginReceivingRemoteControlEvents()

      if let artwork = createNowPlayingArtwork() {
        var initialInfo = [String: Any]()
        initialInfo[MPMediaItemPropertyTitle] = "Calmpal"
        initialInfo[MPMediaItemPropertyArtwork] = artwork
        MPNowPlayingInfoCenter.default().nowPlayingInfo = initialInfo
      }
    } catch {
      print("[AppDelegate] AudioSession setup error: \(error)")
    }

    factory.startReactNative(
      withModuleName: "main",
      in: window,
      launchOptions: launchOptions)
#endif

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // Linking API
  public override func application(
    _ app: UIApplication,
    open url: URL,
    options: [UIApplication.OpenURLOptionsKey: Any] = [:]
  ) -> Bool {
    return super.application(app, open: url, options: options) || RCTLinkingManager.application(app, open: url, options: options)
  }

  // Universal Links
  public override func application(
    _ application: UIApplication,
    continue userActivity: NSUserActivity,
    restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void
  ) -> Bool {
    let result = RCTLinkingManager.application(application, continue: userActivity, restorationHandler: restorationHandler)
    return super.application(application, continue: userActivity, restorationHandler: restorationHandler) || result
  }
}

class ReactNativeDelegate: ExpoReactNativeFactoryDelegate {
  // Extension point for config-plugins

  override func sourceURL(for bridge: RCTBridge) -> URL? {
    bundleURL()
  }

  override func bundleURL() -> URL? {
    // Load embedded offline precompiled bundle immediately with zero network delay
    if let bundleURL = Bundle.main.url(forResource: "main", withExtension: "jsbundle") {
      return bundleURL
    }
#if DEBUG
    return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: ".expo/.virtual-metro-entry")
#else
    return nil
#endif
  }
}
