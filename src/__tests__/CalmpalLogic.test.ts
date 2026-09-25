import {
  SoundProfile,
  SOUND_PROFILE_RESOURCE_FILES,
  SOUND_PROFILE_EXPLANATIONS,
  SOUND_PROFILE_CATEGORIES,
  SOUND_HAPTIC_PROFILES,
  SOUND_ARTIST_CREDITS,
} from '../models/SoundProfile';
import { allSoundBanners, bannerFor } from '../models/SoundBannerTheme';
import { formatNoLeadingZeroHours } from '../models/TimeUtils';
import { HapticManager } from '../managers/HapticManager';
import { AudioManager } from '../managers/AudioManager';

describe('Calmpal Logic & Data Model Parity Tests', () => {
  describe('Sound Banner Completeness', () => {
    it('has exactly 35 sound banners', () => {
      expect(allSoundBanners.length).toBe(35);
    });

    it('has 35 unique sound profiles represented', () => {
      const profiles = new Set(allSoundBanners.map((b) => b.profile));
      expect(profiles.size).toBe(35);
    });

    it('bannerFor returns appropriate banner for profile', () => {
      const banner = bannerFor(SoundProfile.duneBreeze);
      expect(banner.id).toBe('dune-breeze');
      expect(banner.title).toBe('Desert Dune Breeze');
      expect(banner.previewAlignment).toBe('bottom');
    });
  });

  describe('SoundProfile Attributes', () => {
    it('every sound profile has valid resource file, explanation, and category', () => {
      const allProfiles = Object.values(SoundProfile);
      expect(allProfiles.length).toBe(35);

      for (const profile of allProfiles) {
        expect(SOUND_PROFILE_RESOURCE_FILES[profile]).toBeDefined();
        expect(SOUND_PROFILE_RESOURCE_FILES[profile].length).toBeGreaterThan(0);

        expect(SOUND_PROFILE_EXPLANATIONS[profile]).toBeDefined();
        expect(SOUND_PROFILE_EXPLANATIONS[profile].length).toBeGreaterThan(0);

        const category = SOUND_PROFILE_CATEGORIES[profile];
        expect(['Rain', 'Ocean', 'Forest', 'Wind', 'Ambient']).toContain(category);

        expect(SOUND_HAPTIC_PROFILES[profile]).toBeDefined();
        expect(SOUND_HAPTIC_PROFILES[profile].baseIntensity).toBeGreaterThan(0);
      }
    });

    it('Surrender profile contains Jeff Oster artist credit', () => {
      const credit = SOUND_ARTIST_CREDITS[SoundProfile.surrender];
      expect(credit).toBeDefined();
      expect(credit?.name).toBe('Jeff Oster');
      expect(credit?.instagramHandle).toBe('@jeffosterpix');
      expect(credit?.instagramURL).toBe('https://www.instagram.com/jeffosterpix/');
    });
  });

  describe('TimeUtils: formatNoLeadingZeroHours', () => {
    it('formats 0 seconds as 0:00', () => {
      expect(formatNoLeadingZeroHours(0)).toBe('0:00');
    });

    it('formats 10 minutes (600s) as 10:00', () => {
      expect(formatNoLeadingZeroHours(600)).toBe('10:00');
    });

    it('formats 1 hour (3600s) as 1:00:00 without leading zero on hours', () => {
      expect(formatNoLeadingZeroHours(3600)).toBe('1:00:00');
    });

    it('formats 1 hour, 1 minute, 5 seconds (3665s) as 1:01:05', () => {
      expect(formatNoLeadingZeroHours(3665)).toBe('1:01:05');
    });

    it('formats 4 hours max (14400s) as 4:00:00', () => {
      expect(formatNoLeadingZeroHours(14400)).toBe('4:00:00');
    });

    it('safely handles NaN, Infinity, and negative numbers without crashing', () => {
      expect(formatNoLeadingZeroHours(NaN)).toBe('0:00');
      expect(formatNoLeadingZeroHours(Infinity)).toBe('0:00');
      expect(formatNoLeadingZeroHours(-10)).toBe('0:00');
    });
  });

  describe('HapticManager Physics Smoothing', () => {
    it('smoothes target intensity and sharpness via 60Hz tick', () => {
      const manager = HapticManager.shared;
      manager.forceReset();
      manager.start();

      manager.targetIntensity = 1.0;
      manager.targetSharpness = 0.8;

      expect(manager.currentIntensity).toBe(0.0);
      expect(manager.currentSharpness).toBe(0.0);

      manager.tick();
      expect(manager.currentIntensity).toBeGreaterThan(0.0);
      expect(manager.currentSharpness).toBeGreaterThan(0.0);

      const firstIntensity = manager.currentIntensity;
      manager.tick();
      expect(manager.currentIntensity).toBeGreaterThan(firstIntensity);

      manager.stop();
    });
  });

  describe('AudioManager State & Controls', () => {
    it('initializes with default profile and volume', () => {
      const audio = AudioManager.shared;
      expect(audio.activeProfile).toBe(SoundProfile.nightCrickets);
      expect(audio.volume).toBe(0.5);
      expect(audio.isAudioPlaying).toBe(false);
    });

    it('cycles next and previous soundscapes correctly', async () => {
      const audio = AudioManager.shared;
      await audio.setActiveProfile(allSoundBanners[0].profile);
      expect(audio.activeProfile).toBe(allSoundBanners[0].profile);

      await audio.selectNextSound();
      expect(audio.activeProfile).toBe(allSoundBanners[1].profile);

      await audio.selectPreviousSound();
      expect(audio.activeProfile).toBe(allSoundBanners[0].profile);

      await audio.stop();
    });

    it('handles sleep timer countdown scheduling', () => {
      const audio = AudioManager.shared;
      const future = new Date(Date.now() + 600000);
      audio.setSleepTimerTargetDate(future);
      expect(audio.sleepTimerTargetDate).toBe(future);

      audio.setSleepTimerTargetDate(null);
      expect(audio.sleepTimerTargetDate).toBeNull();
    });

    it('stops playback immediately when scheduled timer is in the past', () => {
      const audio = AudioManager.shared;
      audio.isAudioPlaying = true;
      const past = new Date(Date.now() - 1000);
      audio.setSleepTimerTargetDate(past);
      expect(audio.isAudioPlaying).toBe(false);
      expect(audio.sleepTimerTargetDate).toBeNull();
    });

    it('handles remote controls (play, pause, next, prev) without spurious playing:false cancelation', async () => {
      const audio = AudioManager.shared;
      await audio.start();
      expect(audio.isAudioPlaying).toBe(true);

      const player = (audio as any).audioPlayer;
      expect(player).toBeDefined();
      const statusCallback = player.listeners?.['playbackStatusUpdate'];
      expect(typeof statusCallback).toBe('function');

      // 1. Spurious initial status update with playing: false (e.g. while buffering) should NOT cancel playback!
      statusCallback({ isLoaded: true, playing: false });
      expect(audio.isAudioPlaying).toBe(true);

      // 2. Remote pause from AirPods / Lock Screen pauses playback
      statusCallback({ remotePause: true });
      expect(audio.isAudioPlaying).toBe(false);

      // 3. Remote play from AirPods / Lock Screen resumes playback
      statusCallback({ remotePlay: true });
      expect(audio.isAudioPlaying).toBe(true);

      // 4. Remote next track switches sound
      const current = audio.activeProfile;
      statusCallback({ remoteNext: true });
      expect(audio.activeProfile).not.toBe(current);

      await audio.stop();
    });
  });
});
