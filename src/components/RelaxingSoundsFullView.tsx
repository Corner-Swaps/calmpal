import React, { useRef, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  Image,
  Platform,
  ListRenderItemInfo,
  Animated,
} from 'react-native';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import Svg, { Defs, LinearGradient as SvgLinearGradient, Stop, Rect } from 'react-native-svg';
import { SoundProfile } from '../models/SoundProfile';
import { allSoundBanners, SoundBannerTheme } from '../models/SoundBannerTheme';
import { THUMB_ASSETS } from '../assets/assetMap';
import { HapticManager } from '../managers/HapticManager';
import { CheckmarkIcon, XMarkIcon } from './SFSymbols';

interface RelaxingSoundsFullViewProps {
  screenWidth: number;
  screenHeight: number;
  activeProfile: SoundProfile;
  isPlaying: boolean;
  onSelectSound: (profile: SoundProfile) => void;
  onClose: () => void;
}

const CARD_HEIGHT = 135.0;

export const RelaxingSoundsFullView: React.FC<RelaxingSoundsFullViewProps> = ({
  screenWidth,
  screenHeight,
  activeProfile,
  onSelectSound,
  onClose,
}) => {
  const insets = useSafeAreaInsets();
  const topPadding = Math.max(54, insets.top + 8);
  // Match exact bottom offset of Play button in bottomDock: Math.max(36, insets.bottom + 8)
  const bottomButtonOffset = Math.max(36, insets.bottom + 8);
  const topScrimHeight = Math.max(60, insets.top + 24);
  const bottomScrimHeight = Math.max(85, insets.bottom + 55);

  const flatListRef = useRef<FlatList<SoundBannerTheme> | null>(null);
  const fadeAnim = useRef(new Animated.Value(0)).current;

  // Ultra-smooth fade in on mount
  useEffect(() => {
    Animated.timing(fadeAnim, {
      toValue: 1,
      duration: 250,
      useNativeDriver: true,
    }).start();
  }, [fadeAnim]);

  // Smooth dismiss when closing
  const handleClose = useCallback(() => {
    HapticManager.shared.playTransientHeartbeat(0.5, 0.6);
    Animated.timing(fadeAnim, {
      toValue: 0,
      duration: 200,
      useNativeDriver: true,
    }).start(() => {
      onClose();
    });
  }, [fadeAnim, onClose]);

  // Smooth dismiss when selecting a soundscape
  const handleSelectSound = useCallback(
    (profile: SoundProfile) => {
      HapticManager.shared.playTransientHeartbeat(0.5, 0.6);
      Animated.timing(fadeAnim, {
        toValue: 0,
        duration: 180,
        useNativeDriver: true,
      }).start(() => {
        onSelectSound(profile);
      });
    },
    [fadeAnim, onSelectSound]
  );

  const activeIndex = allSoundBanners.findIndex((b) => b.profile === activeProfile);
  const initialIndex = activeIndex >= 0 ? activeIndex : 0;

  const renderItem = useCallback(
    ({ item: banner }: ListRenderItemInfo<SoundBannerTheme>) => {
      const isThisActive = banner.profile === activeProfile;
      const thumbSource = THUMB_ASSETS[banner.thumbnailImageName];

      return (
        <TouchableOpacity
          activeOpacity={0.88}
          onPress={() => handleSelectSound(banner.profile)}
          style={[styles.card, { width: screenWidth, height: CARD_HEIGHT }]}
          accessible={true}
          accessibilityRole="button"
          accessibilityLabel={`${banner.title} soundscape${isThisActive ? ', currently playing' : ''}`}
          accessibilityHint="Double tap to play this soundscape"
        >
          {/* Sound Scenic Background Thumbnail */}
          {thumbSource && (
            <Image
              source={thumbSource}
              resizeMode="cover"
              style={[styles.cardImage, { width: screenWidth, height: CARD_HEIGHT }]}
            />
          )}

          {/* Dark Tint for High Contrast Legibility */}
          <View
            style={[
              styles.cardTint,
              {
                width: screenWidth,
                height: CARD_HEIGHT,
                backgroundColor: isThisActive ? 'rgba(0, 0, 0, 0.22)' : 'rgba(0, 0, 0, 0.38)',
              },
            ]}
          />

          {/* Content Row: Title on Left, Pure White Checkmark on Right */}
          <View style={[styles.cardContent, { width: screenWidth, height: CARD_HEIGHT }]}>
            <Text style={styles.cardTitle}>{banner.title}</Text>

            {isThisActive && (
              <CheckmarkIcon size={20} weight="bold" color="#FFFFFF" shadowType="list" />
            )}
          </View>
        </TouchableOpacity>
      );
    },
    [activeProfile, screenWidth, handleSelectSound]
  );

  return (
    <Animated.View style={[styles.container, { width: screenWidth, height: screenHeight, opacity: fadeAnim }]}>
      {/* 1. Virtualized Vertical Soundscapes FlatList */}
      <FlatList
        ref={flatListRef}
        data={allSoundBanners}
        renderItem={renderItem}
        keyExtractor={(item) => item.id}
        initialScrollIndex={initialIndex}
        initialNumToRender={6}
        maxToRenderPerBatch={6}
        windowSize={5}
        getItemLayout={(_, index) => ({
          length: CARD_HEIGHT,
          offset: CARD_HEIGHT * index,
          index,
        })}
        onScrollToIndexFailed={(info) => {
          setTimeout(() => {
            flatListRef.current?.scrollToIndex({
              index: info.index,
              animated: false,
              viewPosition: 0.5,
            });
          }, 100);
        }}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={[styles.scrollContent, { paddingTop: topPadding, paddingBottom: bottomButtonOffset + 58 }]}
        style={{ width: screenWidth, height: screenHeight }}
      />

      {/* 2. Top Status Bar Fade Scrim */}
      <View style={[styles.topScrim, { width: screenWidth, height: topScrimHeight }]} pointerEvents="none">
        <Svg width={screenWidth} height={topScrimHeight}>
          <Defs>
            <SvgLinearGradient id="topScrimGrad" x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0" stopColor="#000000" stopOpacity="0.85" />
              <Stop offset="0.5" stopColor="#000000" stopOpacity="0.40" />
              <Stop offset="1" stopColor="#000000" stopOpacity="0" />
            </SvgLinearGradient>
          </Defs>
          <Rect x="0" y="0" width={screenWidth} height={topScrimHeight} fill="url(#topScrimGrad)" />
        </Svg>
      </View>

      {/* 3. Ultra-Smooth Bottom Fade Scrim */}
      <View style={[styles.bottomScrim, { width: screenWidth, height: bottomScrimHeight }]} pointerEvents="none">
        <Svg width={screenWidth} height={bottomScrimHeight}>
          <Defs>
            <SvgLinearGradient id="bottomScrimGrad" x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0" stopColor="#000000" stopOpacity="0" />
              <Stop offset="0.4" stopColor="#000000" stopOpacity="0.35" />
              <Stop offset="0.75" stopColor="#000000" stopOpacity="0.75" />
              <Stop offset="1" stopColor="#000000" stopOpacity="0.95" />
            </SvgLinearGradient>
          </Defs>
          <Rect x="0" y="0" width={screenWidth} height={bottomScrimHeight} fill="url(#bottomScrimGrad)" />
        </Svg>
      </View>

      {/* 4. Floating Exit (X) Button - matched to play button size and position */}
      <TouchableOpacity
        activeOpacity={0.7}
        onPress={handleClose}
        style={[styles.closeButton, { bottom: bottomButtonOffset }]}
        accessible={true}
        accessibilityRole="button"
        accessibilityLabel="Close relaxing sounds library"
      >
        <XMarkIcon size={28} weight="bold" color="#FFFFFF" shadowType="dock" />
      </TouchableOpacity>
    </Animated.View>
  );
};

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFill,
    backgroundColor: '#000000',
    zIndex: 100,
  },
  scrollContent: {
    paddingTop: 54,
    paddingBottom: 94,
  },
  card: {
    position: 'relative',
    overflow: 'hidden',
  },
  cardImage: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
  cardTint: {
    position: 'absolute',
    top: 0,
    left: 0,
  },
  cardContent: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingHorizontal: 24,
  },
  cardTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: '#FFFFFF',
    ...Platform.select({
      ios: { fontFamily: 'System' },
      web: { fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Rounded", Roboto, sans-serif' },
    }),
    textShadowColor: 'rgba(0, 0, 0, 0.95)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 6,
    flex: 1,
  },
  checkmarkIcon: {
    textShadowColor: 'rgba(0, 0, 0, 0.95)',
    textShadowOffset: { width: 0, height: 2 },
    textShadowRadius: 4,
  },
  topScrim: {
    position: 'absolute',
    top: 0,
    left: 0,
    height: 60,
  },
  bottomScrim: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    height: 85,
  },
  closeButton: {
    position: 'absolute',
    alignSelf: 'center',
    width: 47,
    height: 47,
    justifyContent: 'center',
    alignItems: 'center',
    zIndex: 120,
  },
  closeIcon: {
    textShadowColor: 'rgba(0, 0, 0, 0.95)',
    textShadowOffset: { width: 0, height: 3 },
    textShadowRadius: 8,
  },
});
