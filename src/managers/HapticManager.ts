// HapticManager: Cross-platform implementation of Swift HapticManager
import { Platform } from 'react-native';
import * as Haptics from 'expo-haptics';

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
  private tickInterval: any = null;

  private constructor() {
    this.checkHardwareSupport();
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
}
