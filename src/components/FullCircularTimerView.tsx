import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, Platform } from 'react-native';
import Svg, { Circle, G } from 'react-native-svg';
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
  const [, setTick] = useState(0);

  // Smooth throttled update only when an active countdown timer is running
  useEffect(() => {
    if (!isPlaying || timerEndTimestamp === null) return;
    const interval = setInterval(() => {
      setTick((prev) => (prev + 1) % 1000000);
    }, 50);

    return () => clearInterval(interval);
  }, [isPlaying, timerEndTimestamp]);

  const currentRemaining = (() => {
    if (isPlaying && timerEndTimestamp !== null) {
      const remaining = (timerEndTimestamp - Date.now()) / 1000;
      const maxAllowed = totalDuration > 0 ? totalDuration : remainingSeconds;
      return Math.max(0.0, Math.min(maxAllowed, remaining));
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
        {progress > 0.005 && (
          <G>
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
          </G>
        )}
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
