import React, { useState, useEffect, useRef, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Image,
  PanResponder,
  Linking,
  Platform,
  useWindowDimensions,
  Animated,
  AppState,
  AppStateStatus,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Svg, { Defs, LinearGradient as SvgLinearGradient, RadialGradient, Stop, Rect } from 'react-native-svg';
import {
  SunMaxIcon,
  MoonFillIcon,
  PersonIcon,
  XMarkIcon,
  ChevronLeftIcon,
  ChevronRightIcon,
  MusicNoteIcon,
  PlayFillIcon,
  PauseFillIcon,
  PencilIcon,
  CheckmarkIcon,
} from './SFSymbols';

import { SoundProfile, SOUND_ARTIST_CREDITS } from '../models/SoundProfile';
import { bannerFor, allSoundBanners } from '../models/SoundBannerTheme';
import { formatNoLeadingZeroHours } from '../models/TimeUtils';
import { AudioManager } from '../managers/AudioManager';
import { HapticManager } from '../managers/HapticManager';
import { IMAGE_ASSETS } from '../assets/assetMap';

import { InstagramLogoView } from './InstagramLogoView';
import { FullCircularTimerView } from './FullCircularTimerView';
import { TallFusedMeasuringLinesView } from './TallFusedMeasuringLinesView';
import { RelaxingSoundsFullView } from './RelaxingSoundsFullView';
import { activateKeepAwakeAsync, deactivateKeepAwake } from 'expo-keep-awake';

export type ActiveScreenOverlay = 'none' | 'editTimer' | 'soundSelection';

export const GroundingScreenView: React.FC = () => {
  const { width: screenWidth, height: screenHeight } = useWindowDimensions();
  const insets = useSafeAreaInsets();
  const topInset = Math.max(44.0, insets.top);

  // States matching GroundingScreenView.swift
  const [activeProfile, setActiveProfileState] = useState<SoundProfile>(SoundProfile.nightCrickets);
  const [remainingTimerSeconds, setRemainingTimerSeconds] = useState<number>(600.0); // Default 10 min for timer editor
  const [totalTimerDuration, setTotalTimerDuration] = useState<number>(600.0);
  const [isPlaying, setIsPlaying] = useState<boolean>(false);
  const [activeOverlay, setActiveOverlay] = useState<ActiveScreenOverlay>('none');
  const [isDraggingTimer, setIsDraggingTimer] = useState<boolean>(false);
  const [isZenMode, setIsZenMode] = useState<boolean>(false);
  const [isArtistInfoVisible, setIsArtistInfoVisible] = useState<boolean>(false);
  const [timerEndTimestamp, setTimerEndTimestamp] = useState<number | null>(null);

  const editTimerFadeAnim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (activeOverlay === 'editTimer') {
      Animated.timing(editTimerFadeAnim, {
        toValue: 1,
        duration: 250,
        useNativeDriver: true,
      }).start();
    }
  }, [activeOverlay, editTimerFadeAnim]);

  const audioManager = AudioManager.shared;
  const hapticManager = HapticManager.shared;

  const timerEndTimestampRef = useRef<number | null>(timerEndTimestamp);
  timerEndTimestampRef.current = timerEndTimestamp;

  const totalTimerDurationRef = useRef<number>(totalTimerDuration);
  totalTimerDurationRef.current = totalTimerDuration;

  const isPlayingRef = useRef<boolean>(isPlaying);
  isPlayingRef.current = isPlaying;

  // Sync state with AudioManager singleton
  useEffect(() => {
    const unsubscribe = audioManager.subscribe((state) => {
      setActiveProfileState(state.activeProfile);
      setIsPlaying(state.isPlaying);
      if (!state.isPlaying && timerEndTimestampRef.current !== null && timerEndTimestampRef.current <= Date.now()) {
        const resetDuration = totalTimerDurationRef.current > 0 ? totalTimerDurationRef.current : 600.0;
        setRemainingTimerSeconds(resetDuration);
        setTimerEndTimestamp(null);
      }
    });
    return () => unsubscribe();
  }, [audioManager]);

  // Immediate foreground resync when returning from background or lockscreen
  useEffect(() => {
    if (Platform.OS === 'web' || !AppState || typeof AppState.addEventListener !== 'function') {
      return;
    }

    const subscription = AppState.addEventListener('change', (nextState: AppStateStatus) => {
      if (nextState === 'active') {
        const end = timerEndTimestampRef.current;
        if (end !== null) {
          const now = Date.now();
          if (end <= now) {
            // Timer expired while in background
            const resetDuration = totalTimerDurationRef.current > 0 ? totalTimerDurationRef.current : 600.0;
            setRemainingTimerSeconds(resetDuration);
            setIsPlaying(false);
            setTimerEndTimestamp(null);
            audioManager.setSleepTimerTargetDate(null);
            audioManager.stop();
          } else if (isPlayingRef.current) {
            // Still playing, sync immediately without waiting for 1-second ticker interval
            setRemainingTimerSeconds((end - now) / 1000);
          }
        }
      }
    });

    return () => {
      subscription.remove();
    };
  }, [audioManager]);

  // 1-second countdown ticker when playback is active
  useEffect(() => {
    if (!isPlaying || isDraggingTimer || activeOverlay === 'editTimer' || timerEndTimestamp === null) {
      return;
    }

    const interval = setInterval(() => {
      const leftSec = (timerEndTimestamp - Date.now()) / 1000;
      if (leftSec <= 0) {
        const resetDuration = totalTimerDuration > 0 ? totalTimerDuration : 600.0;
        setRemainingTimerSeconds(resetDuration);
        setIsPlaying(false);
        setTimerEndTimestamp(null);
        audioManager.setSleepTimerTargetDate(null);
        audioManager.stop();
      } else {
        setRemainingTimerSeconds(leftSec);
      }
    }, 1000);

    return () => clearInterval(interval);
  }, [isPlaying, isDraggingTimer, activeOverlay, timerEndTimestamp, totalTimerDuration, audioManager]);

  // Keep screen awake while audio playback is active
  useEffect(() => {
    if (isPlaying) {
      activateKeepAwakeAsync().catch(() => {});
    } else {
      deactivateKeepAwake().catch(() => {});
    }
    return () => {
      deactivateKeepAwake().catch(() => {});
    };
  }, [isPlaying]);

  const togglePlayPause = useCallback(async () => {
    hapticManager.playTransientHeartbeat(0.6, 0.6);
    const willPlay = !isPlaying;
    setIsPlaying(willPlay);

    if (willPlay) {
      const dur = remainingTimerSeconds > 0 ? remainingTimerSeconds : (totalTimerDuration > 0 ? totalTimerDuration : 600.0);
      const end = Date.now() + dur * 1000;
      setRemainingTimerSeconds(dur);
      setTimerEndTimestamp(end);
      audioManager.setSleepTimerTargetDate(new Date(end));
      await audioManager.resume();
    } else {
      if (timerEndTimestamp !== null) {
        setRemainingTimerSeconds(Math.max(0, (timerEndTimestamp - Date.now()) / 1000));
      }
      setTimerEndTimestamp(null);
      audioManager.setSleepTimerTargetDate(null);
      await audioManager.pause();
    }
  }, [isPlaying, remainingTimerSeconds, totalTimerDuration, timerEndTimestamp, audioManager, hapticManager]);

  const selectPreviousSound = useCallback(async () => {
    hapticManager.playTransientHeartbeat(0.5, 0.5);
    const currentIndex = allSoundBanners.findIndex((b) => b.profile === activeProfile);
    const validIndex = currentIndex >= 0 ? currentIndex : 0;
    const totalCount = allSoundBanners.length;
    // Guaranteed wrap-around: index 0 wraps to last sound (totalCount - 1)
    const newIndex = (validIndex - 1 + totalCount) % totalCount;
    const newProfile = allSoundBanners[newIndex].profile;
    setActiveProfileState(newProfile);
    await audioManager.setActiveProfile(newProfile);

    if (!isPlaying) {
      setIsPlaying(true);
    }

    // Always restart timer from the full configured session duration when skipping sections
    const dur = totalTimerDuration > 0 ? totalTimerDuration : 600.0;
    const end = Date.now() + dur * 1000;
    setRemainingTimerSeconds(dur);
    setTimerEndTimestamp(end);
    audioManager.setSleepTimerTargetDate(new Date(end));

    if (!audioManager.isAudioPlaying) {
      await audioManager.start();
    }
  }, [activeProfile, totalTimerDuration, isPlaying, audioManager, hapticManager]);

  const selectNextSound = useCallback(async () => {
    hapticManager.playTransientHeartbeat(0.5, 0.5);
    const currentIndex = allSoundBanners.findIndex((b) => b.profile === activeProfile);
    const validIndex = currentIndex >= 0 ? currentIndex : 0;
    const totalCount = allSoundBanners.length;
    // Guaranteed wrap-around: last sound wraps to first sound (0)
    const newIndex = (validIndex + 1) % totalCount;
    const newProfile = allSoundBanners[newIndex].profile;
    setActiveProfileState(newProfile);
    await audioManager.setActiveProfile(newProfile);

    if (!isPlaying) {
      setIsPlaying(true);
    }

    // Always restart timer from the full configured session duration when skipping sections
    const dur = totalTimerDuration > 0 ? totalTimerDuration : 600.0;
    const end = Date.now() + dur * 1000;
    setRemainingTimerSeconds(dur);
    setTimerEndTimestamp(end);
    audioManager.setSleepTimerTargetDate(new Date(end));

    if (!audioManager.isAudioPlaying) {
      await audioManager.start();
    }
  }, [activeProfile, totalTimerDuration, isPlaying, audioManager, hapticManager]);

  const handleConfirmEditTimer = useCallback(() => {
    hapticManager.playTransientHeartbeat(0.5, 0.6);
    Animated.timing(editTimerFadeAnim, {
      toValue: 0,
      duration: 200,
      useNativeDriver: true,
    }).start(() => {
      if (isPlaying) {
        const dur = remainingTimerSeconds > 0 ? remainingTimerSeconds : (totalTimerDuration > 0 ? totalTimerDuration : 600.0);
        const end = Date.now() + dur * 1000;
        setTimerEndTimestamp(end);
        audioManager.setSleepTimerTargetDate(new Date(end));
      } else {
        setTimerEndTimestamp(null);
        audioManager.setSleepTimerTargetDate(null);
      }
      setActiveOverlay('none');
    });
  }, [editTimerFadeAnim, isPlaying, remainingTimerSeconds, totalTimerDuration, audioManager, hapticManager]);

  // Keep mutable callback refs to avoid stale closures in panResponder
  const togglePlayPauseRef = useRef(togglePlayPause);
  togglePlayPauseRef.current = togglePlayPause;

  const selectNextSoundRef = useRef(selectNextSound);
  selectNextSoundRef.current = selectNextSound;

  const selectPreviousSoundRef = useRef(selectPreviousSound);
  selectPreviousSoundRef.current = selectPreviousSound;

  const isArtistInfoVisibleRef = useRef(isArtistInfoVisible);
  isArtistInfoVisibleRef.current = isArtistInfoVisible;

  // Background PanResponder for Swipe Gestures & Taps
  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: (_, gesture) =>
        Math.abs(gesture.dx) > 10 && Math.abs(gesture.dx) > Math.abs(gesture.dy),
      onMoveShouldSetPanResponderCapture: (_, gesture) =>
        Math.abs(gesture.dx) > 15 && Math.abs(gesture.dx) > Math.abs(gesture.dy),
      onPanResponderRelease: (_, gesture) => {
        const horizontal = gesture.dx;
        const vertical = gesture.dy;
        const vx = gesture.vx;

        // Either enough drag distance (>= 22pt) or quick flick velocity (> 0.25)
        const isHorizontalSwipe =
          (Math.abs(horizontal) >= 22 || Math.abs(vx) > 0.25) &&
          Math.abs(horizontal) > Math.abs(vertical) * 0.65;

        if (isHorizontalSwipe) {
          const isLeft = Math.abs(horizontal) >= 22 ? horizontal < 0 : vx < 0;
          if (isLeft) {
            // Swiped Left -> Bring to Next sound (infinite wrap-around: last -> first)
            selectNextSoundRef.current();
          } else {
            // Swiped Right -> Bring to Previous sound (infinite wrap-around: first -> last)
            selectPreviousSoundRef.current();
          }
        } else {
          // Responsive tap: zero dead zone for micro-movements under 22pt
          if (Math.abs(horizontal) < 22 && Math.abs(vertical) < 22) {
            if (isArtistInfoVisibleRef.current) {
              setIsArtistInfoVisible(false);
            } else {
              togglePlayPauseRef.current();
            }
          }
        }
      },
      onPanResponderTerminate: () => {},
    })
  ).current;

  const activeBanner = bannerFor(activeProfile);
  const artistCredit = SOUND_ARTIST_CREDITS[activeProfile];

  return (
    <View style={[styles.root, { width: screenWidth, height: screenHeight }]}>
      {/* ── Solid Deep Black Base Canvas ── */}
      <View style={StyleSheet.absoluteFill} pointerEvents="none" />

      {/* ── Deep Atmospheric Fullscreen Backdrop ── */}
      {IMAGE_ASSETS[activeBanner.imageName] && (
        <Image
          source={IMAGE_ASSETS[activeBanner.imageName]}
          resizeMode="cover"
          style={[styles.backdropImage, { width: screenWidth, height: screenHeight }]}
        />
      )}

      {/* Backdrop 3-Stop Linear Gradient Overlay */}
      <View style={[StyleSheet.absoluteFill, { width: screenWidth, height: screenHeight }]} pointerEvents="none">
        <Svg width={screenWidth} height={screenHeight}>
          <Defs>
            <SvgLinearGradient id="bgGrad" x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0" stopColor="#000000" stopOpacity="0.35" />
              <Stop offset="0.5" stopColor="#000000" stopOpacity="0" />
              <Stop offset="1" stopColor="#000000" stopOpacity="0.40" />
            </SvgLinearGradient>
          </Defs>
          <Rect x="0" y="0" width={screenWidth} height={screenHeight} fill="url(#bgGrad)" />
        </Svg>
      </View>

      {/* ── Normal Mode: Main Player Interface ── */}
      <View
        style={[styles.mainInterface, { width: screenWidth, height: screenHeight }]}
        pointerEvents={activeOverlay === 'none' ? 'auto' : 'none'}
      >
        {/* Background Gesture Layer */}
        <View style={StyleSheet.absoluteFill} {...panResponder.panHandlers} />

        {/* Top Navigation: Floating Icons (Sun/Moon and Artist Info at Top Center) */}
        <View style={[styles.topNavContainer, { paddingTop: Math.max(14, insets.top - 8) }]} pointerEvents="box-none">
          <View style={styles.topNavCenter}>
            {/* ☀️ / 🌙 Sun & Moon Zen Toggle */}
            {!isArtistInfoVisible && (
              <TouchableOpacity
                activeOpacity={0.7}
                onPress={() => {
                  hapticManager.playTransientHeartbeat(0.4, 0.5);
                  if (isArtistInfoVisible) {
                    setIsArtistInfoVisible(false);
                  }
                  setIsZenMode(!isZenMode);
                }}
                style={[
                  styles.navButton,
                  { opacity: isZenMode ? 0.6 : 1.0 },
                ]}
                accessible={true}
                accessibilityRole="button"
                accessibilityLabel={isZenMode ? "Disable Zen immersion mode" : "Enable Zen immersion mode"}
              >
                {isZenMode ? (
                  <MoonFillIcon size={23.8} color="rgba(255, 255, 255, 0.92)" />
                ) : (
                  <SunMaxIcon size={23.8} color="rgba(255, 255, 255, 0.92)" />
                )}
              </TouchableOpacity>
            )}

            {/* 👤 / ✕ Profile / Exit Icon (Only shown for artist tracks) */}
            {artistCredit && (
              <TouchableOpacity
                activeOpacity={0.7}
                onPress={() => {
                  hapticManager.playTransientHeartbeat(0.4, 0.5);
                  if (isZenMode) {
                    setIsZenMode(false);
                  }
                  const nextVisible = !isArtistInfoVisible;
                  setIsArtistInfoVisible(nextVisible);
                }}
                style={styles.navButton}
                accessible={true}
                accessibilityRole="button"
                accessibilityLabel={isArtistInfoVisible ? "Close artist info" : "View artist profile"}
              >
                {isArtistInfoVisible ? (
                  <XMarkIcon size={23.8} weight="regular" color="rgba(255, 255, 255, 0.92)" shadowType="top" />
                ) : (
                  <PersonIcon size={23.8} weight="regular" color="rgba(255, 255, 255, 0.92)" shadowType="top" />
                )}
              </TouchableOpacity>
            )}
          </View>
        </View>

          {/* Main Center Stage: Circular Timer Ring or Artist Profile */}
          <View style={styles.centerStageContainer} pointerEvents="box-none">
            {!isZenMode && !isArtistInfoVisible && (
              <View pointerEvents="none">
                <FullCircularTimerView
                  remainingSeconds={remainingTimerSeconds}
                  totalDuration={totalTimerDuration}
                  isPlaying={isPlaying}
                  timerEndTimestamp={timerEndTimestamp}
                />
              </View>
            )}

            {isArtistInfoVisible && artistCredit && (
              <View style={styles.artistProfileContainer}>
                {/* Subtle dark radial vignette for optimal outdoor contrast against bright backdrops like snow peaks */}
                <View style={[StyleSheet.absoluteFill, styles.artistVignetteContainer]} pointerEvents="none">
                  <Svg width={340} height={340} viewBox="0 0 340 340">
                    <Defs>
                      <RadialGradient id="artistVignette" cx="50%" cy="50%" rx="50%" ry="50%" fx="50%" fy="50%">
                        <Stop offset="0%" stopColor="#000000" stopOpacity="0.55" />
                        <Stop offset="65%" stopColor="#000000" stopOpacity="0.25" />
                        <Stop offset="100%" stopColor="#000000" stopOpacity="0" />
                      </RadialGradient>
                    </Defs>
                    <Rect x="0" y="0" width={340} height={340} fill="url(#artistVignette)" />
                  </Svg>
                </View>

                <Text style={styles.artistNameText}>{artistCredit.name}</Text>

                <TouchableOpacity
                  activeOpacity={0.8}
                  onPress={() => {
                    Linking.openURL(artistCredit.instagramURL).catch(() => {});
                  }}
                  style={styles.instagramCapsule}
                  accessible={true}
                  accessibilityRole="link"
                  accessibilityLabel={`Open ${artistCredit.name} on Instagram`}
                >
                  <InstagramLogoView size={27.6} />
                  <Text style={styles.instagramHandleText}>{artistCredit.instagramHandle}</Text>
                </TouchableOpacity>
              </View>
            )}
          </View>

          {/* Bottom Action Dock Controls */}
          <View
            style={[
              styles.bottomDock,
              {
                paddingBottom: Math.max(36, insets.bottom + 8),
                opacity: isZenMode || isArtistInfoVisible ? 0 : 1,
              },
            ]}
            pointerEvents={isZenMode || isArtistInfoVisible ? 'none' : 'box-none'}
          >
            {/* ‹ 1. Previous Sound Track */}
            <TouchableOpacity
              activeOpacity={0.7}
              onPress={selectPreviousSound}
              style={styles.dockButton}
              accessible={true}
              accessibilityRole="button"
              accessibilityLabel="Previous soundscape"
            >
              <ChevronLeftIcon size={21.4} weight="semibold" color="#FFFFFF" />
            </TouchableOpacity>

            {/* 🎵 2. Relaxing Sounds Button */}
            <TouchableOpacity
              activeOpacity={0.7}
              onPress={() => {
                hapticManager.playTransientHeartbeat(0.5, 0.6);
                setActiveOverlay('soundSelection');
              }}
              style={styles.dockButton}
              accessible={true}
              accessibilityRole="button"
              accessibilityLabel="Open relaxing sounds library"
            >
              <MusicNoteIcon size={22.5} weight="medium" color="#FFFFFF" />
            </TouchableOpacity>

            {/* ⏵/⏸ 3. Play / Pause Button */}
            <TouchableOpacity
              activeOpacity={0.7}
              onPress={togglePlayPause}
              style={styles.dockButton}
              accessible={true}
              accessibilityRole="button"
              accessibilityLabel={isPlaying ? "Pause soundscape" : "Play soundscape"}
            >
              {isPlaying ? (
                <PauseFillIcon size={28} weight="bold" color="#FFFFFF" />
              ) : (
                <View style={styles.playIconOffset}>
                  <PlayFillIcon size={28} weight="bold" color="#FFFFFF" />
                </View>
              )}
            </TouchableOpacity>

            {/* ✏️ 4. Edit Timer Button */}
            <TouchableOpacity
              activeOpacity={0.7}
              onPress={() => {
                hapticManager.playTransientHeartbeat(0.5, 0.6);
                setActiveOverlay('editTimer');
              }}
              style={styles.dockButton}
              accessible={true}
              accessibilityRole="button"
              accessibilityLabel="Edit session timer"
            >
              <PencilIcon size={21.4} weight="medium" color="#FFFFFF" />
            </TouchableOpacity>

            {/* › 5. Next Sound Track */}
            <TouchableOpacity
              activeOpacity={0.7}
              onPress={selectNextSound}
              style={styles.dockButton}
              accessible={true}
              accessibilityRole="button"
              accessibilityLabel="Next soundscape"
            >
              <ChevronRightIcon size={21.4} weight="semibold" color="#FFFFFF" />
            </TouchableOpacity>
          </View>
        </View>

      {/* ── Edit Mode: Solid Black + Top Timer + Fluid Wave Lines + Bottom Controls ── */}
      {activeOverlay === 'editTimer' && (
        <Animated.View style={[styles.editOverlay, { width: screenWidth, height: screenHeight, opacity: editTimerFadeAnim }]}>
          {/* Full Height Fluid Wave Measuring Lines Canvas */}
          <TallFusedMeasuringLinesView
            remainingSeconds={remainingTimerSeconds}
            totalDuration={totalTimerDuration}
            isDragging={isDraggingTimer}
            onDurationChange={(newDuration) => {
              setTotalTimerDuration(newDuration);
              setRemainingTimerSeconds(newDuration);
            }}
            onDragStateChange={setIsDraggingTimer}
          />

          {/* Top Clean Digital Timer Display */}
          <View style={[styles.editTimerTopDisplay, { top: topInset + 36 }]} pointerEvents="none">
            <Text style={styles.editTimerText}>
              {formatNoLeadingZeroHours(remainingTimerSeconds)}
            </Text>
          </View>

          {/* Bottom Action: Confirm (✓) Button - matched to play button size and position */}
          <TouchableOpacity
            activeOpacity={0.7}
            onPress={handleConfirmEditTimer}
            style={[styles.confirmCheckButton, { bottom: Math.max(36, insets.bottom + 8) }]}
            accessible={true}
            accessibilityRole="button"
            accessibilityLabel="Confirm timer duration"
          >
            <CheckmarkIcon size={28} weight="bold" color="#FFFFFF" shadowType="dock" />
          </TouchableOpacity>
        </Animated.View>
      )}

      {/* ── Relaxing Sounds Selection Library Overlay ── */}
      {activeOverlay === 'soundSelection' && (
        <RelaxingSoundsFullView
          screenWidth={screenWidth}
          screenHeight={screenHeight}
          activeProfile={activeProfile}
          isPlaying={isPlaying}
          onSelectSound={(profile) => {
            setActiveProfileState(profile);
            if (!isPlaying) {
              setIsPlaying(true);
            }
            // Always restart timer from the full configured session duration when selecting a sound
            const dur = totalTimerDuration > 0 ? totalTimerDuration : 600.0;
            const end = Date.now() + dur * 1000;
            setRemainingTimerSeconds(dur);
            setTimerEndTimestamp(end);
            audioManager.setSleepTimerTargetDate(new Date(end));
            setActiveOverlay('none');
            audioManager.setActiveProfile(profile);

            if (!audioManager.isAudioPlaying) {
              audioManager.start();
            }
          }}
          onClose={() => setActiveOverlay('none')}
        />
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  root: {
    ...StyleSheet.absoluteFill,
    backgroundColor: '#000000',
    overflow: 'hidden',
  },
  backdropImage: {
    ...StyleSheet.absoluteFill,
  },
  mainInterface: {
    ...StyleSheet.absoluteFill,
    justifyContent: 'space-between',
  },
  topNavContainer: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    alignItems: 'center',
    zIndex: 100,
  },
  topNavCenter: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 16,
  },
  navButton: {
    width: 47,
    height: 47,
    justifyContent: 'center',
    alignItems: 'center',
  },
  navIcon: {
    textShadowColor: 'rgba(0, 0, 0, 0.45)',
    textShadowOffset: { width: 0, height: 1 },
    textShadowRadius: 4,
  },
  centerStageContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    transform: [{ translateY: 20 }],
  },
  artistProfileContainer: {
    height: 318,
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  artistVignetteContainer: {
    justifyContent: 'center',
    alignItems: 'center',
  },
  artistNameText: {
    fontSize: 36.8,
    fontWeight: '300',
    letterSpacing: 1.7,
    color: '#FFFFFF',
    marginBottom: 18.4,
    ...Platform.select({
      ios: { fontFamily: 'System' },
      web: { fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Rounded", Roboto, sans-serif' },
    }),
    textShadowColor: 'rgba(0, 0, 0, 0.95)',
    textShadowOffset: { width: 0, height: 2.5 },
    textShadowRadius: 10,
  },
  instagramCapsule: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: 23,
    paddingVertical: 11.5,
    borderRadius: 999,
    backgroundColor: 'rgba(255, 255, 255, 0.18)',
    borderColor: 'rgba(255, 255, 255, 0.35)',
    borderWidth: 1.0,
  },
  instagramHandleText: {
    fontSize: 18.4,
    fontWeight: '500',
    color: '#FFFFFF',
    marginLeft: 11.5,
    ...Platform.select({
      ios: { fontFamily: 'System' },
      web: { fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Rounded", Roboto, sans-serif' },
    }),
    textShadowColor: 'rgba(0, 0, 0, 0.65)',
    textShadowOffset: { width: 0, height: 1.5 },
    textShadowRadius: 4,
  },
  bottomDock: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 24,
    width: '100%',
    zIndex: 100,
  },
  dockButton: {
    width: 47,
    height: 47,
    justifyContent: 'center',
    alignItems: 'center',
  },
  playIconOffset: {
    transform: [{ translateX: 1.5 }],
  },
  dockIcon: {
    textShadowColor: 'rgba(0, 0, 0, 0.85)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 6,
  },
  editOverlay: {
    ...StyleSheet.absoluteFill,
    backgroundColor: '#000000',
    zIndex: 50,
  },
  editTimerTopDisplay: {
    position: 'absolute',
    left: 0,
    right: 0,
    alignItems: 'center',
    zIndex: 60,
  },
  editTimerText: {
    fontSize: 44,
    fontWeight: '300',
    color: '#FFFFFF',
    fontVariant: ['tabular-nums'],
    ...Platform.select({
      ios: { fontFamily: 'System' },
      web: { fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Rounded", Roboto, sans-serif' },
    }),
  },
  confirmCheckButton: {
    position: 'absolute',
    alignSelf: 'center',
    width: 47,
    height: 47,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 70,
  },
  confirmIcon: {
    textShadowColor: 'rgba(0, 0, 0, 0.95)',
    textShadowOffset: { width: 0, height: 3 },
    textShadowRadius: 8,
  },
});
