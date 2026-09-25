// HapticManager: Cross-platform implementation of Swift HapticManager
import { Platform, AppState, AppStateStatus } from 'react-native';
import * as Haptics from 'expo-haptics';
import { SoundProfile, SOUND_HAPTIC_PROFILES } from '../models/SoundProfile';

let ExpoHaptics: any = null;
try {
  // eslint-disable-next-line @typescript-eslint/no-var-requires
  const expo = require('expo');
  if (typeof expo?.requireOptionalNativeModule === 'function') {
    ExpoHaptics = expo.requireOptionalNativeModule('ExpoHaptics');
  }
} catch {}

export class HapticManager {
  private static _instance: HapticManager;

  public static get shared(): HapticManager {
    if (!this._instance) {
      this._instance = new HapticManager();
    }
    return this._instance;
  }

  public isHardwareSupported: boolean = true;
  public isEngineRunning: boolean = false;
  public currentIntensity: number = 0.0;
  public currentSharpness: number = 0.0;
  public isImmersiveModeActive: boolean = false;

  public targetIntensity: number = 0.0;
  public targetSharpness: number = 0.0;

  private readonly alpha: number = 0.38;
  private smoothedIntensity: number = 0.0;
  private smoothedSharpness: number = 0.0;
  private lastSentIntensity: number = -1.0;
  private lastSentSharpness: number = -1.0;
  private tickInterval: ReturnType<typeof setInterval> | null = null;

  // Soundscape-matching tactile vibration state
  private soundHapticTimeout: ReturnType<typeof setTimeout> | null = null;
  private currentSoundProfile: SoundProfile | null = null;
  private isSoundHapticsRunning: boolean = false;
  private hapticStepIndex: number = 0;

  private constructor() {
    this.checkHardwareSupport();
    if (Platform.OS !== 'web' && AppState && typeof AppState.addEventListener === 'function') {
      AppState.addEventListener('change', (state: AppStateStatus) => {
        if (state === 'active' && this.isSoundHapticsRunning && !this.soundHapticTimeout) {
          this.scheduleNextSoundHaptic();
        }
      });
    }
  }

  private checkHardwareSupport() {
    if (Platform.OS === 'web') {
      this.isHardwareSupported = typeof navigator !== 'undefined' && 'vibrate' in navigator;
    } else {
      this.isHardwareSupported = true;
    }
  }

  public start() {
    if (this.isEngineRunning) return;
    this.isEngineRunning = true;
    if (this.tickInterval) {
      clearInterval(this.tickInterval);
    }
    // 60Hz loop (~16.6ms)
    this.tickInterval = setInterval(() => {
      this.tick();
    }, 16.667);
  }

  public stop() {
    if (!this.isEngineRunning) return;
    if (this.tickInterval) {
      clearInterval(this.tickInterval);
      this.tickInterval = null;
    }
    this.isEngineRunning = false;
  }

  public forceReset() {
    this.stop();
    this.targetIntensity = 0.0;
    this.targetSharpness = 0.0;
    this.smoothedIntensity = 0.0;
    this.smoothedSharpness = 0.0;
    this.lastSentIntensity = -1.0;
    this.lastSentSharpness = -1.0;
    this.currentIntensity = 0.0;
    this.currentSharpness = 0.0;
  }

  public tick() {
    if (!this.isEngineRunning) return;

    // Exponential smoothing:
    this.smoothedIntensity = this.alpha * this.targetIntensity + (1.0 - this.alpha) * this.smoothedIntensity;
    this.smoothedSharpness = this.alpha * this.targetSharpness + (1.0 - this.alpha) * this.smoothedSharpness;

    // Snap to target if very close:
    if (Math.abs(this.smoothedIntensity - this.targetIntensity) < 0.001) {
      this.smoothedIntensity = this.targetIntensity;
    }
    if (Math.abs(this.smoothedSharpness - this.targetSharpness) < 0.001) {
      this.smoothedSharpness = this.targetSharpness;
    }

    const finalIntensity = Math.max(0.0, Math.min(1.0, this.smoothedIntensity));
    const finalSharpness = Math.max(0.0, Math.min(1.0, this.smoothedSharpness));

    const deltaIntensity = Math.abs(finalIntensity - this.lastSentIntensity);
    const deltaSharpness = Math.abs(finalSharpness - this.lastSentSharpness);

    if (deltaIntensity > 0.002 || deltaSharpness > 0.002) {
      this.currentIntensity = finalIntensity;
      this.currentSharpness = finalSharpness;
      this.lastSentIntensity = finalIntensity;
      this.lastSentSharpness = finalSharpness;
    }
  }

  public playSingleTransient(intensity: number, sharpness: number) {
    if (Platform.OS === 'web') {
      if (typeof navigator !== 'undefined' && 'vibrate' in navigator) {
        try {
          navigator.vibrate(Math.round(intensity * 30));
        } catch {}
      }
      return;
    }

    try {
      const style = intensity > 0.6 ? Haptics.ImpactFeedbackStyle.Medium : Haptics.ImpactFeedbackStyle.Light;
      Haptics.impactAsync(style).catch(() => {});
    } catch {}
  }

  public playTransientHeartbeat(intensity: number = 0.5, sharpness: number = 0.6) {
    if (Platform.OS === 'web') {
      if (typeof navigator !== 'undefined' && 'vibrate' in navigator) {
        try {
          navigator.vibrate([Math.round(intensity * 35), 150, Math.round(intensity * 25)]);
        } catch {}
      }
      return;
    }

    try {
      const style = intensity > 0.5 ? Haptics.ImpactFeedbackStyle.Medium : Haptics.ImpactFeedbackStyle.Light;
      Haptics.impactAsync(style).catch(() => {});
      setTimeout(() => {
        try {
          Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Light).catch(() => {});
        } catch {}
      }, 150);
    } catch {}
  }

  public startSoundHaptics(profile: SoundProfile) {
    this.currentSoundProfile = profile;
    this.isSoundHapticsRunning = true;
    this.hapticStepIndex = 0;

    // 1. Invoke native background GCD loop (runs in background / Dynamic Island)
    try {
      if (ExpoHaptics && typeof ExpoHaptics.startSoundscapeHaptics === 'function') {
        ExpoHaptics.startSoundscapeHaptics(String(profile));
      } else if (typeof (Haptics as any).startSoundscapeHaptics === 'function') {
        (Haptics as any).startSoundscapeHaptics(String(profile));
      }
    } catch (e) {
      console.warn('[HapticManager] startSoundscapeHaptics error:', e);
    }

    // 2. Also run foreground JavaScript loop (ensures immediate tactile feedback)
    this.scheduleNextSoundHaptic();
  }

  public stopSoundHaptics() {
    this.isSoundHapticsRunning = false;
    this.currentSoundProfile = null;
    this.hapticStepIndex = 0;

    try {
      if (ExpoHaptics && typeof ExpoHaptics.stopSoundscapeHaptics === 'function') {
        ExpoHaptics.stopSoundscapeHaptics();
      } else if (typeof (Haptics as any).stopSoundscapeHaptics === 'function') {
        (Haptics as any).stopSoundscapeHaptics();
      }
    } catch (e) {
      console.warn('[HapticManager] stopSoundscapeHaptics error:', e);
    }

    if (this.soundHapticTimeout) {
      clearTimeout(this.soundHapticTimeout);
      this.soundHapticTimeout = null;
    }
  }

  private scheduleNextSoundHaptic() {
    if (this.soundHapticTimeout) {
      clearTimeout(this.soundHapticTimeout);
      this.soundHapticTimeout = null;
    }

    if (!this.isSoundHapticsRunning || !this.currentSoundProfile) {
      return;
    }

    const profile = this.currentSoundProfile;
    const hapticInfo = SOUND_HAPTIC_PROFILES[profile];
    let nextDelayMs = 500;

    switch (profile) {
      case SoundProfile.gentleRain:
      case SoundProfile.rainOnCar:
      case SoundProfile.rainOnTent:
      case SoundProfile.rainCanopy:
        // Raindrops: distinct tactile raindrop impacts
        this.hapticStepIndex = (this.hapticStepIndex + 1) % 3;
        this.triggerHaptic(this.hapticStepIndex === 0 ? Haptics.ImpactFeedbackStyle.Rigid : Haptics.ImpactFeedbackStyle.Medium);
        nextDelayMs = 200 + Math.random() * 240;
        break;

      case SoundProfile.cozyCampfire:
        // Campfire: crisp tactile crackles & ember snaps
        this.triggerHaptic(Math.random() > 0.4 ? Haptics.ImpactFeedbackStyle.Rigid : Haptics.ImpactFeedbackStyle.Medium);
        nextDelayMs = 220 + Math.random() * 450;
        break;

      case SoundProfile.catPurring:
        // Purr: rhythmic motor pulse that feels like a cat purring in your hand
        this.hapticStepIndex = (this.hapticStepIndex + 1) % 4;
        if (this.hapticStepIndex < 3) {
          this.triggerHaptic(Haptics.ImpactFeedbackStyle.Rigid);
          nextDelayMs = 140;
        } else {
          nextDelayMs = 360;
        }
        break;

      case SoundProfile.antiqueClock:
        // Clock: rhythmic crisp 1.0s tick-tock
        this.hapticStepIndex = (this.hapticStepIndex + 1) % 2;
        this.triggerHaptic(this.hapticStepIndex === 0 ? Haptics.ImpactFeedbackStyle.Rigid : Haptics.ImpactFeedbackStyle.Medium);
        nextDelayMs = 1000;
        break;

      case SoundProfile.rollingThunder:
        // Thunder: deep rumble bursts
        this.hapticStepIndex = (this.hapticStepIndex + 1) % 7;
        if (this.hapticStepIndex === 0) {
          this.triggerHaptic(Haptics.ImpactFeedbackStyle.Heavy);
          nextDelayMs = 180;
        } else if (this.hapticStepIndex === 1) {
          this.triggerHaptic(Haptics.ImpactFeedbackStyle.Heavy);
          nextDelayMs = 220;
        } else if (this.hapticStepIndex === 2) {
          this.triggerHaptic(Haptics.ImpactFeedbackStyle.Medium);
          nextDelayMs = 3200 + Math.random() * 1800;
        } else {
          nextDelayMs = 2800;
        }
        break;

      case SoundProfile.oceanWaves:
      case SoundProfile.deepUnderwater:
      case SoundProfile.oceanWhale:
        // Ocean swells: rhythmic surging wave crests
        this.hapticStepIndex = (this.hapticStepIndex + 1) % 5;
        if (this.hapticStepIndex < 2) {
          this.triggerHaptic(Haptics.ImpactFeedbackStyle.Medium);
          nextDelayMs = 300;
        } else {
          nextDelayMs = 2600 + Math.random() * 700;
        }
        break;

      case SoundProfile.nightCrickets:
      case SoundProfile.forestBirdsong:
      case SoundProfile.eveningFrogs:
        // Nature chirps: distinct double tap chirp then pause
        this.hapticStepIndex = (this.hapticStepIndex + 1) % 3;
        if (this.hapticStepIndex < 2) {
          this.triggerHaptic(Haptics.ImpactFeedbackStyle.Medium);
          nextDelayMs = 150;
        } else {
          nextDelayMs = 1300 + Math.random() * 700;
        }
        break;

      case SoundProfile.singingBowl:
      case SoundProfile.windChimes:
      case SoundProfile.cathedralChimes:
        // Resonant bells & chimes
        this.triggerHaptic(Haptics.ImpactFeedbackStyle.Heavy);
        nextDelayMs = 2200 + Math.random() * 1400;
        break;

      default:
        // Ambient wind, river, library, walk on leaves, etc.
        const intensity = hapticInfo ? hapticInfo.baseIntensity : 0.4;
        const style = intensity > 0.5 ? Haptics.ImpactFeedbackStyle.Heavy : Haptics.ImpactFeedbackStyle.Medium;
        this.triggerHaptic(style);
        const freq = hapticInfo ? hapticInfo.pulseFrequency : 0.25;
        nextDelayMs = Math.max(350, Math.min(2200, Math.round(1000 / Math.max(0.1, freq))));
        break;
    }

    this.soundHapticTimeout = setTimeout(() => {
      this.scheduleNextSoundHaptic();
    }, nextDelayMs);
  }

  private triggerHaptic(style: Haptics.ImpactFeedbackStyle) {
    if (Platform.OS === 'web') return;
    try {
      Haptics.impactAsync(style).catch(() => {});
    } catch {}
  }
}
