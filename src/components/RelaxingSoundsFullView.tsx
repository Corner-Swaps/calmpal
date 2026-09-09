import React, { useRef, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Image,
  Platform,
} from 'react-native';
import Svg, { Defs, LinearGradient as SvgLinearGradient, Stop, Rect } from 'react-native-svg';
import { SoundProfile } from '../models/SoundProfile';
import { allSoundBanners } from '../models/SoundBannerTheme';
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
  const scrollViewRef = useRef<ScrollView | null>(null);

  // Auto-scroll to active track on appear
  useEffect(() => {
    const activeIndex = allSoundBanners.findIndex((b) => b.profile === activeProfile);
    if (activeIndex >= 0 && scrollViewRef.current) {
      // Calculate target Y so card is roughly centered
      const targetY = Math.max(0, activeIndex * CARD_HEIGHT + 54 - (screenHeight - CARD_HEIGHT) / 2);
      setTimeout(() => {
        scrollViewRef.current?.scrollTo({ y: targetY, animated: false });
      }, 50);
    }
  }, [activeProfile, screenHeight]);

  return (
    <View style={[styles.container, { width: screenWidth, height: screenHeight }]}>
      {/* 1. Vertical Soundscapes Scroll View */}
      <ScrollView
        ref={scrollViewRef}
        showsVerticalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
        style={{ width: screenWidth, height: screenHeight }}
      >
        {allSoundBanners.map((banner) => {
          const isThisActive = banner.profile === activeProfile;
          const thumbSource = THUMB_ASSETS[banner.thumbnailImageName];

          return (
            <TouchableOpacity
              key={banner.id}
              activeOpacity={0.88}
              onPress={() => {
                HapticManager.shared.playTransientHeartbeat(0.5, 0.6);
                onSelectSound(banner.profile);
              }}
              style={[styles.card, { width: screenWidth, height: CARD_HEIGHT }]}
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
        })}
      </ScrollView>

      {/* 2. Top Status Bar Fade Scrim */}
      <View style={[styles.topScrim, { width: screenWidth }]} pointerEvents="none">
        <Svg width={screenWidth} height={60}>
          <Defs>
            <SvgLinearGradient id="topScrimGrad" x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0" stopColor="#000000" stopOpacity="0.85" />
              <Stop offset="0.5" stopColor="#000000" stopOpacity="0.40" />
              <Stop offset="1" stopColor="#000000" stopOpacity="0" />
            </SvgLinearGradient>
          </Defs>
          <Rect x="0" y="0" width={screenWidth} height={60} fill="url(#topScrimGrad)" />
        </Svg>
      </View>

      {/* 3. Ultra-Smooth Bottom Fade Scrim */}
      <View style={[styles.bottomScrim, { width: screenWidth }]} pointerEvents="none">
        <Svg width={screenWidth} height={85}>
          <Defs>
            <SvgLinearGradient id="bottomScrimGrad" x1="0" y1="0" x2="0" y2="1">
              <Stop offset="0" stopColor="#000000" stopOpacity="0" />
              <Stop offset="0.4" stopColor="#000000" stopOpacity="0.35" />
              <Stop offset="0.75" stopColor="#000000" stopOpacity="0.75" />
              <Stop offset="1" stopColor="#000000" stopOpacity="0.95" />
            </SvgLinearGradient>
          </Defs>
          <Rect x="0" y="0" width={screenWidth} height={85} fill="url(#bottomScrimGrad)" />
        </Svg>
      </View>

      {/* 4. Floating Exit (X) Button */}
      <TouchableOpacity
        activeOpacity={0.7}
        onPress={() => {
          HapticManager.shared.playTransientHeartbeat(0.5, 0.6);
          onClose();
        }}
        style={styles.closeButton}
      >
        <XMarkIcon size={21.4} weight="bold" color="#FFFFFF" shadowType="confirm" />
      </TouchableOpacity>
    </View>
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
    bottom: 36,
    alignSelf: 'center',
    width: 44,
    height: 44,
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
