import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import Svg, { Circle } from 'react-native-svg';
import { formatNoLeadingZeroHours } from '../models/TimeUtils';

interface FullCircularTimerViewProps {
  remainingSeconds: number;
  totalDuration: number;
  isPlaying: boolean;
  timerEndTimestamp: number | null; // Date.now() timestamp
}

export const FullCircularTimerView: React.FC<FullCircularTimerViewProps> = ({
  remainingSeconds,
  totalDuration,
  isPlaying,
  timerEndTimestamp,
}) => {
  const [now, setNow] = useState(Date.now());

  // 60Hz TimelineView animation update when playing
  useEffect(() => {
    if (!isPlaying) return;
    let animationFrameId: number;

    const tick = () => {
      setNow(Date.now());
      animationFrameId = requestAnimationFrame(tick);
    };

    animationFrameId = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(animationFrameId);
  }, [isPlaying]);

  const currentRemaining = (() => {
    if (isPlaying && timerEndTimestamp !== null) {
      return Math.max(0.0, (timerEndTimestamp - now) / 1000);
    }
    return remainingSeconds;
  })();

  const progress = (() => {
    if (totalDuration <= 0) return 0.0;
    return Math.max(0.0, Math.min(1.0, currentRemaining / totalDuration));
  })();

  const size = 318;
  const radius = size / 2;
  const trackRadius = radius - 10;
  const circumference = 2 * Math.PI * trackRadius;
  const strokeDashoffset = circumference * (1 - progress);

  const angle = (progress * 360.0 - 90.0) * (Math.PI / 180.0);
  const dotX = radius + trackRadius * Math.cos(angle);
  const dotY = radius + trackRadius * Math.sin(angle);

  return (
    <View style={[styles.container, { width: size, height: size }]}>
      <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        {/* Background Track Ring */}
        <Circle
          cx={radius}
          cy={radius}
          r={trackRadius}
          stroke="rgba(255, 255, 255, 0.16)"
          strokeWidth={4.0}
          fill="none"
        />

        {/* Foreground Animated Flowing Remaining Arc */}
        <Circle
          cx={radius}
          cy={radius}
          r={trackRadius}
          stroke="#FFFFFF"
          strokeWidth={4.5}
          strokeLinecap="round"
          strokeDasharray={`${circumference}`}
          strokeDashoffset={strokeDashoffset}
          fill="none"
          origin={`${radius}, ${radius}`}
          rotation={-90}
        />

        {/* Minimal Little White Dot */}
        <Circle
          cx={dotX}
          cy={dotY}
          r={5}
          fill="#FFFFFF"
        />
      </Svg>

      {/* Center Digital Countdown */}
      <View style={styles.centerTextContainer}>
        <Text style={styles.timerText}>
          {formatNoLeadingZeroHours(currentRemaining)}
        </Text>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    justifyContent: 'center',
    alignItems: 'center',
    position: 'relative',
  },
  centerTextContainer: {
    position: 'absolute',
    justifyContent: 'center',
    alignItems: 'center',
  },
  timerText: {
    fontSize: 44,
    fontWeight: '300',
    color: '#FFFFFF',
    fontVariant: ['tabular-nums'],
    ...Platform.select({
      ios: {
        fontFamily: 'System',
      },
      web: {
        fontFamily: '-apple-system, BlinkMacSystemFont, "SF Pro Rounded", Roboto, sans-serif',
      },
    }),
    textShadowColor: 'rgba(0, 0, 0, 0.90)',
    textShadowOffset: { width: 0, height: 3 },
    textShadowRadius: 8,
  },
});
