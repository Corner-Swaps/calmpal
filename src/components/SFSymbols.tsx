import React from 'react';
import { Platform, View, StyleSheet } from 'react-native';
import { SymbolView, SymbolWeight } from 'expo-symbols';
import Svg, { Path, Circle, Rect, G } from 'react-native-svg';

interface IconProps {
  size?: number;
  color?: string;
  weight?: SymbolWeight;
  shadowType?: 'dock' | 'confirm' | 'list' | 'top';
}

const styles = StyleSheet.create({
  topShadow: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.45,
    shadowRadius: 4,
  },
  dockShadow: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.85,
    shadowRadius: 6,
  },
  confirmShadow: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 3 },
    shadowOpacity: 0.95,
    shadowRadius: 8,
  },
  listShadow: {
    shadowColor: '#000000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.95,
    shadowRadius: 4,
  },
});

// ☀️ sun.max: regular weight size 22.5 (optically balanced with moon.fill 18.5)
export const SunMaxIcon: React.FC<IconProps> = ({ size = 22.5, color = 'rgba(255, 255, 255, 0.92)', weight = 'regular' }) => {
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="sun.max" size={size} weight={weight} tintColor={color} style={styles.topShadow} />
    );
  }
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx="12" cy="12" r="4.8" stroke={color} strokeWidth="1.8" />
      <Path
        d="M12 2v2.4M12 19.6V22M2 12h2.4M19.6 12H22M4.93 4.93l1.7 1.7M17.37 17.37l1.7 1.7M4.93 19.07l1.7-1.7M17.37 6.63l1.7-1.7"
        stroke={color}
        strokeWidth="1.8"
        strokeLinecap="round"
      />
    </Svg>
  );
};

// 🌙 moon.fill: regular weight size 18.5 (optically balanced with sun.max 22.5)
export const MoonFillIcon: React.FC<IconProps> = ({ size = 18.5, color = 'rgba(255, 255, 255, 0.92)', weight = 'regular' }) => {
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="moon.fill" size={size} weight={weight} tintColor={color} style={styles.topShadow} />
    );
  }
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M20.6 13.2A8.5 8.5 0 1110.8 3.4 6.8 6.8 0 0020.6 13.2z"
        fill={color}
      />
    </Svg>
  );
};

// 👤 person: regular weight size 19
export const PersonIcon: React.FC<IconProps> = ({ size = 19, color = 'rgba(255, 255, 255, 0.92)', weight = 'regular' }) => {
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="person" size={size} weight={weight} tintColor={color} style={styles.topShadow} />
    );
  }
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Circle cx="12" cy="7.5" r="4.2" stroke={color} strokeWidth="1.8" />
      <Path d="M4 20.5c0-4 4-6 8-6s8 2 8 6" stroke={color} strokeWidth="1.8" strokeLinecap="round" />
    </Svg>
  );
};

// ✕ xmark: regular/medium/bold weight size 16-21.4
export const XMarkIcon: React.FC<IconProps> = ({
  size = 16,
  color = 'rgba(255, 255, 255, 0.92)',
  weight = 'regular',
  shadowType = 'top',
}) => {
  const shadowStyle = shadowType === 'confirm' ? styles.confirmShadow : styles.topShadow;
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="xmark" size={size} weight={weight} tintColor={color} style={shadowStyle} />
    );
  }
  return (
    <Svg width={size} height={size} viewBox="0 0 20 20" fill="none">
      <Path
        d="M4.5 15.5L15.5 4.5M4.5 4.5l11 11"
        stroke={color}
        strokeWidth={weight === 'bold' ? 3.2 : 2.2}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
};

// ‹ chevron.left: semibold weight size 21.4 (w: 12, h: 20) with shadow(x: 0, y: 2, radius: 6)
export const ChevronLeftIcon: React.FC<IconProps> = ({ size = 21.4, color = '#FFFFFF', weight = 'semibold' }) => {
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="chevron.left" size={size} weight={weight} tintColor={color} style={styles.dockShadow} />
    );
  }
  const scale = size / 21.4;
  const w = 12 * scale;
  const h = 20 * scale;
  return (
    <Svg width={w} height={h} viewBox="0 0 12 20" fill="none">
      <Path
        d="M9.5 2.5L2.5 10L9.5 17.5"
        stroke={color}
        strokeWidth="3.0"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
};

// › chevron.right: semibold weight size 21.4 (w: 12, h: 20) with shadow(x: 0, y: 2, radius: 6)
export const ChevronRightIcon: React.FC<IconProps> = ({ size = 21.4, color = '#FFFFFF', weight = 'semibold' }) => {
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="chevron.right" size={size} weight={weight} tintColor={color} style={styles.dockShadow} />
    );
  }
  const scale = size / 21.4;
  const w = 12 * scale;
  const h = 20 * scale;
  return (
    <Svg width={w} height={h} viewBox="0 0 12 20" fill="none">
      <Path
        d="M2.5 2.5L9.5 10L2.5 17.5"
        stroke={color}
        strokeWidth="3.0"
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
};

// 🎵 music.note: medium weight size 22.5 (w: 13.7, h: 22.3) with shadow(x: 0, y: 2, radius: 6)
export const MusicNoteIcon: React.FC<IconProps> = ({ size = 22.5, color = '#FFFFFF', weight = 'medium' }) => {
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="music.note" size={size} weight={weight} tintColor={color} style={styles.dockShadow} />
    );
  }
  const scale = size / 22.5;
  const w = 14 * scale;
  const h = 23 * scale;
  const pathD =
    'M 12.00 0.00 L 13.33 0.67 L 13.33 2.33 L 13.33 4.00 L 13.00 5.67 L 11.33 6.00 L 9.67 6.33 L 8.00 6.67 L 7.00 8.00 L 7.00 9.67 L 7.00 11.33 L 7.00 13.00 L 7.00 14.67 L 7.00 16.33 L 7.00 18.00 L 6.67 19.67 L 5.33 21.33 L 3.67 22.00 L 2.00 22.00 L 0.33 20.67 L 0.00 19.00 L 0.67 17.33 L 2.00 16.33 L 3.67 16.00 L 5.33 15.33 L 5.67 13.67 L 5.67 12.00 L 5.67 10.33 L 5.67 8.67 L 5.67 7.00 L 5.67 5.33 L 5.67 3.67 L 5.67 2.00 L 7.33 1.00 L 9.00 0.67 L 10.67 0.33 Z';
  return (
    <Svg width={w} height={h} viewBox="0 0 14 23" fill="none">
      <Path d={pathD} fill={color} />
    </Svg>
  );
};

// ⏵ play.fill: bold weight size 28 (w: 22.3, h: 25) with shadow(x: 0, y: 2, radius: 6)
export const PlayFillIcon: React.FC<IconProps> = ({ size = 28, color = '#FFFFFF', weight = 'bold' }) => {
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="play.fill" size={size} weight={weight} tintColor={color} style={styles.dockShadow} />
    );
  }
  const scale = size / 28;
  const w = 23 * scale;
  const h = 25 * scale;
  const pathD =
    'M 1.00 0.00 L 3.00 0.00 L 5.00 1.00 L 7.00 2.00 L 9.00 3.33 L 11.00 4.33 L 13.00 5.67 L 15.00 6.67 L 17.00 8.00 L 19.00 9.00 L 21.00 10.33 L 22.00 12.33 L 21.00 14.00 L 19.00 15.33 L 17.00 16.67 L 15.00 17.67 L 13.00 19.00 L 11.00 20.00 L 9.00 21.33 L 7.00 22.33 L 5.00 23.67 L 3.00 24.67 L 1.00 24.33 L 0.00 22.33 L 0.00 20.33 L 0.00 18.33 L 0.00 16.33 L 0.00 14.33 L 0.00 12.33 L 0.00 10.33 L 0.00 8.33 L 0.00 6.33 L 0.00 4.33 L 0.00 2.33 L 0.67 0.33 Z';
  return (
    <Svg width={w} height={h} viewBox="0 0 23 25" fill="none">
      <Path d={pathD} fill={color} />
    </Svg>
  );
};

// ⏸ pause.fill: bold weight size 28 (w: 20, h: 25) with shadow(x: 0, y: 2, radius: 6)
export const PauseFillIcon: React.FC<IconProps> = ({ size = 28, color = '#FFFFFF', weight = 'bold' }) => {
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="pause.fill" size={size} weight={weight} tintColor={color} style={styles.dockShadow} />
    );
  }
  const scale = size / 28;
  const w = 20 * scale;
  const h = 25 * scale;
  return (
    <Svg width={w} height={h} viewBox="0 0 20 25" fill="none">
      <Rect x="1" y="0" width="7" height="25" rx="3.5" fill={color} />
      <Rect x="12" y="0" width="7" height="25" rx="3.5" fill={color} />
    </Svg>
  );
};

// ✏️ pencil: medium weight size 21.4 (w: 17.3, h: 17.3) with shadow(x: 0, y: 2, radius: 6)
export const PencilIcon: React.FC<IconProps> = ({ size = 21.4, color = '#FFFFFF', weight = 'medium' }) => {
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="pencil" size={size} weight={weight} tintColor={color} style={styles.dockShadow} />
    );
  }
  const scale = size / 21.4;
  const w = 17.3 * scale;
  const h = 17.3 * scale;
  const tipD =
    'M 15.33 0.00 L 15.67 0.00 L 16.00 0.00 L 16.33 0.33 L 16.67 0.33 L 17.00 0.67 L 17.00 1.00 L 17.00 1.33 L 17.00 1.67 L 17.00 2.00 L 16.67 2.33 L 16.33 2.67 L 16.00 3.00 L 15.67 3.00 L 15.33 3.00 L 15.00 2.67 L 14.67 2.33 L 14.33 2.00 L 14.00 1.67 L 14.00 1.33 L 14.33 1.00 L 14.67 0.67 L 15.00 0.33 Z';
  const bodyD =
    'M 12.67 2.67 L 13.67 3.33 L 14.33 4.33 L 13.67 5.33 L 12.67 6.33 L 11.67 7.33 L 10.67 8.33 L 9.67 9.33 L 8.67 10.33 L 7.67 11.33 L 6.67 12.33 L 5.67 13.33 L 4.67 14.33 L 3.67 15.33 L 2.67 16.00 L 1.67 16.33 L 0.67 16.67 L 0.33 16.33 L 0.67 15.33 L 1.00 14.33 L 2.00 13.33 L 3.00 12.33 L 4.00 11.33 L 5.00 10.33 L 6.00 9.33 L 7.00 8.33 L 8.00 7.33 L 9.00 6.33 L 10.00 5.33 L 11.00 4.33 L 12.00 3.33 Z';
  return (
    <Svg width={w} height={h} viewBox="0 0 17.3 17.3" fill="none">
      <Path d={tipD} fill={color} />
      <Path d={bodyD} fill={color} />
    </Svg>
  );
};

// ✓ checkmark: semibold/bold weight size 17-21.4
export const CheckmarkIcon: React.FC<IconProps> = ({
  size = 21.4,
  color = '#FFFFFF',
  weight = 'bold',
  shadowType = 'confirm',
}) => {
  const shadowStyle = shadowType === 'list' ? styles.listShadow : styles.confirmShadow;
  if (Platform.OS === 'ios') {
    return (
      <SymbolView name="checkmark" size={size} weight={weight} tintColor={color} style={shadowStyle} />
    );
  }
  return (
    <Svg width={size} height={size} viewBox="0 0 24 24" fill="none">
      <Path
        d="M4.5 12.5l5 5L19.5 6.5"
        stroke={color}
        strokeWidth={weight === 'bold' ? 3.4 : 2.6}
        strokeLinecap="round"
        strokeLinejoin="round"
      />
    </Svg>
  );
};
