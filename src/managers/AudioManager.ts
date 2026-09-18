// AudioManager: Cross-platform implementation of Swift AudioManager using expo-audio
import { createAudioPlayer, setAudioModeAsync, AudioPlayer } from 'expo-audio';
import { Platform, AppState, AppStateStatus } from 'react-native';
import { SoundProfile, SOUND_PROFILE_RESOURCE_FILES } from '../models/SoundProfile';
import { allSoundBanners } from '../models/SoundBannerTheme';
import { SOUND_ASSETS } from '../assets/assetMap';

export type AudioStateListener = (state: {
  isPlaying: boolean;
  activeProfile: SoundProfile;
  volume: number;
}) => void;

export class AudioManager {
  private static _instance: AudioManager;

  public static get shared(): AudioManager {
    if (!this._instance) {
      this._instance = new AudioManager();
    }
    return this._instance;
  }

  public isAudioPlaying: boolean = false;
  public activeProfile: SoundProfile = SoundProfile.nightCrickets;
  public volume: number = 0.5;
  public sleepTimerTargetDate: Date | null = null;

  private audioPlayer: AudioPlayer | null = null;
  private webAudioElement: HTMLAudioElement | null = null;
  private listeners: Set<AudioStateListener> = new Set();

  private sleepTimerTimeout: ReturnType<typeof setTimeout> | null = null;
  private sleepFadeTimeout: ReturnType<typeof setTimeout> | null = null;
  private fadeInterval: ReturnType<typeof setInterval> | null = null;
  private isAudioConfigured: boolean = false;
  private currentPlayRequestId: number = 0;

  private constructor() {
    this.configureAudioSession();
    if (Platform.OS !== 'web' && AppState && typeof AppState.addEventListener === 'function') {
      AppState.addEventListener('change', (state: AppStateStatus) => {
        if (state === 'active') {
          if (this.sleepTimerTargetDate) {
            if (this.sleepTimerTargetDate.getTime() <= Date.now()) {
              this.stop();
              return;
            } else if (this.isAudioPlaying) {
              // Reschedule timer to guarantee accurate expiration after device sleep
              this.scheduleSleepTimer();
            }
          }
          if (this.isAudioPlaying && this.audioPlayer) {
            try {
              this.audioPlayer.play();
            } catch {}
          }
        }
      });
    }
  }

  private async configureAudioSession() {
    if (this.isAudioConfigured) return;
    if (Platform.OS !== 'web') {
      try {
        await setAudioModeAsync({
          playsInSilentMode: true,
          shouldPlayInBackground: true,
          interruptionMode: 'mixWithOthers',
        });
        this.isAudioConfigured = true;
      } catch (err) {
        console.warn('[AudioManager] Failed to configure audio mode:', err);
      }
    }
  }

  public subscribe(listener: AudioStateListener): () => void {
    this.listeners.add(listener);
    listener({
      isPlaying: this.isAudioPlaying,
      activeProfile: this.activeProfile,
      volume: this.volume,
    });
    return () => {
      this.listeners.delete(listener);
    };
  }

  private notify() {
    for (const listener of this.listeners) {
      listener({
        isPlaying: this.isAudioPlaying,
        activeProfile: this.activeProfile,
        volume: this.volume,
      });
    }
  }

  public setSleepTimerTargetDate(date: Date | null) {
    this.sleepTimerTargetDate = date;
    this.scheduleSleepTimer();
  }

  public scheduleSleepTimer() {
    if (this.sleepTimerTimeout) {
      clearTimeout(this.sleepTimerTimeout);
      this.sleepTimerTimeout = null;
    }
    if (this.sleepFadeTimeout) {
      clearTimeout(this.sleepFadeTimeout);
      this.sleepFadeTimeout = null;
    }

    if (!this.sleepTimerTargetDate) return;
    const intervalMs = this.sleepTimerTargetDate.getTime() - Date.now();

    if (intervalMs <= 0) {
      if (this.isAudioPlaying) {
        this.stop();
      }
      this.sleepTimerTargetDate = null;
      return;
    }

    if (!this.isAudioPlaying) return;

    const fadeDurationMs = 15000;

    // 1. Schedule 15-second graceful fade-out before timer ends
    if (intervalMs > fadeDurationMs) {
      const fadeDelay = intervalMs - fadeDurationMs;
      this.sleepFadeTimeout = setTimeout(() => {
        if (this.isAudioPlaying) {
          this.fadeVolume(0.0, 15);
        }
      }, fadeDelay);
    } else {
      this.fadeVolume(0.0, intervalMs / 1000);
    }

    // 2. Schedule final stop and volume restore at target timestamp
    this.sleepTimerTimeout = setTimeout(() => {
      if (this.isAudioPlaying) {
        this.stop();
      }
      this.setVolumeInternal(this.volume > 0 ? this.volume : 0.5);
      this.sleepTimerTargetDate = null;
    }, intervalMs);
  }

  public async setActiveProfile(profile: SoundProfile) {
    if (this.activeProfile === profile && (this.audioPlayer || this.webAudioElement)) {
      return;
    }
    this.activeProfile = profile;
    const wasPlaying = this.isAudioPlaying;
    await this.unloadCurrentSound();
    if (wasPlaying) {
      await this.loadAndPlay(profile);
    }
    this.notify();
  }

  public setVolume(newVolume: number) {
    this.volume = Math.max(0, Math.min(1, newVolume));
    if (this.isAudioPlaying) {
      this.fadeVolume(this.volume, 0.1);
    } else {
      this.setVolumeInternal(this.volume);
    }
    this.notify();
  }

  private setVolumeInternal(v: number) {
    if (Platform.OS === 'web' && this.webAudioElement) {
      this.webAudioElement.volume = v;
    } else if (this.audioPlayer) {
      try {
        this.audioPlayer.volume = v;
      } catch {}
    }
  }

  private async unloadCurrentSound() {
    this.currentPlayRequestId++;
    if (this.fadeInterval) {
      clearInterval(this.fadeInterval);
      this.fadeInterval = null;
    }
    if (Platform.OS === 'web') {
      if (this.webAudioElement) {
        try {
          this.webAudioElement.pause();
          this.webAudioElement.src = '';
        } catch {}
        this.webAudioElement = null;
      }
    } else {
      if (this.audioPlayer) {
        try {
          this.audioPlayer.pause();
          this.audioPlayer.release();
        } catch {}
        this.audioPlayer = null;
      }
    }
  }

  private async loadAndPlay(profile: SoundProfile) {
    const requestId = ++this.currentPlayRequestId;
    await this.configureAudioSession();
    if (requestId !== this.currentPlayRequestId) return;

    const resourceFile = SOUND_PROFILE_RESOURCE_FILES[profile];
    const asset = SOUND_ASSETS[resourceFile];

    const currentTargetVolume = this.volume > 0 ? this.volume : 0.5;

    if (Platform.OS === 'web') {
      try {
        const AudioConstructor = (typeof window !== 'undefined' && (window as any).Audio) || (globalThis as any).Audio;
        if (AudioConstructor) {
          const audio = new AudioConstructor(asset);
          audio.loop = true;
          audio.volume = currentTargetVolume;
          await audio.play();
          if (requestId !== this.currentPlayRequestId) {
            try {
              audio.pause();
              audio.src = '';
            } catch {}
            return;
          }
          this.webAudioElement = audio;
        }
        this.isAudioPlaying = true;
      } catch (err) {
        console.warn('[AudioManager Web] Audio play error:', err);
        if (requestId !== this.currentPlayRequestId) return;
        this.isAudioPlaying = true;
      }
    } else {
      try {
        const player = createAudioPlayer(asset, {
          keepAudioSessionActive: true,
          updateInterval: 500,
        });
        if (requestId !== this.currentPlayRequestId) {
          try {
            player.release();
          } catch {}
          return;
        }
        player.loop = true;
        player.volume = currentTargetVolume;
        player.play();
        this.audioPlayer = player;
        this.isAudioPlaying = true;
      } catch (err) {
        console.warn('[AudioManager Native] Sound create error:', err);
        if (requestId !== this.currentPlayRequestId) return;
        this.isAudioPlaying = true;
      }
    }

    if (this.sleepTimerTargetDate) {
      this.scheduleSleepTimer();
    }
    this.notify();
  }

  public async start() {
    if (this.isAudioPlaying) return;
    await this.resume();
  }

  public async restartFromStart() {
    this.isAudioPlaying = true;
    await this.unloadCurrentSound();
    await this.loadAndPlay(this.activeProfile);
  }

  public async togglePlayPause() {
    if (this.isAudioPlaying) {
      await this.pause();
    } else {
      await this.resume();
    }
  }

  public async pause() {
    this.currentPlayRequestId++;
    if (!this.isAudioPlaying) return;
    if (this.sleepFadeTimeout) {
      clearTimeout(this.sleepFadeTimeout);
      this.sleepFadeTimeout = null;
    }
    if (this.sleepTimerTimeout) {
      clearTimeout(this.sleepTimerTimeout);
      this.sleepTimerTimeout = null;
    }

    this.isAudioPlaying = false;
    if (Platform.OS === 'web') {
      if (this.webAudioElement) {
        this.webAudioElement.pause();
      }
    } else {
      if (this.audioPlayer) {
        try {
          this.audioPlayer.pause();
        } catch {}
      }
    }
    this.setVolumeInternal(this.volume > 0 ? this.volume : 0.5);
    this.notify();
  }

  public async resume() {
    if (this.isAudioPlaying) return;
    this.isAudioPlaying = true;

    if (Platform.OS === 'web') {
      if (this.webAudioElement) {
        this.webAudioElement.volume = this.volume > 0 ? this.volume : 0.5;
        this.webAudioElement.play().catch(() => {});
      } else {
        await this.loadAndPlay(this.activeProfile);
      }
    } else {
      if (this.audioPlayer) {
        try {
          this.audioPlayer.volume = this.volume > 0 ? this.volume : 0.5;
          this.audioPlayer.play();
        } catch {
          await this.loadAndPlay(this.activeProfile);
        }
      } else {
        await this.loadAndPlay(this.activeProfile);
      }
    }

    if (this.sleepTimerTargetDate) {
      this.scheduleSleepTimer();
    }
    this.notify();
  }

  public async stop() {
    this.isAudioPlaying = false;
    this.sleepTimerTargetDate = null;
    if (this.sleepFadeTimeout) {
      clearTimeout(this.sleepFadeTimeout);
      this.sleepFadeTimeout = null;
    }
    if (this.sleepTimerTimeout) {
      clearTimeout(this.sleepTimerTimeout);
      this.sleepTimerTimeout = null;
    }
    await this.unloadCurrentSound();
    this.notify();
  }

  public async selectNextSound() {
    const currentIndex = allSoundBanners.findIndex((b) => b.profile === this.activeProfile);
    const newIndex = (currentIndex + 1) % allSoundBanners.length;
    await this.setActiveProfile(allSoundBanners[newIndex].profile);
    if (!this.isAudioPlaying) {
      await this.resume();
    }
  }

  public async selectPreviousSound() {
    const currentIndex = allSoundBanners.findIndex((b) => b.profile === this.activeProfile);
    const newIndex = (currentIndex - 1 + allSoundBanners.length) % allSoundBanners.length;
    await this.setActiveProfile(allSoundBanners[newIndex].profile);
    if (!this.isAudioPlaying) {
      await this.resume();
    }
  }

  public fadeVolume(target: number, durationSec: number, completion?: () => void) {
    if (this.fadeInterval) {
      clearInterval(this.fadeInterval);
      this.fadeInterval = null;
    }
    if (durationSec < 0.05) {
      this.setVolumeInternal(target);
      completion?.();
      return;
    }

    const steps = Math.max(10, Math.floor(durationSec * 30));
    const stepIntervalMs = (durationSec / steps) * 1000;
    const startVolume = this.volume;
    const diff = target - startVolume;
    let step = 0;

    this.fadeInterval = setInterval(() => {
      step++;
      const current = Math.max(0, Math.min(1, startVolume + (diff * step) / steps));
      this.setVolumeInternal(current);
      if (step >= steps) {
        if (this.fadeInterval !== null) {
          clearInterval(this.fadeInterval);
          this.fadeInterval = null;
        }
        this.setVolumeInternal(target);
        completion?.();
      }
    }, stepIntervalMs);
  }
}
