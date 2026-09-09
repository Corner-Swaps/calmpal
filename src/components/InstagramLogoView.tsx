import React from 'react';
import Svg, { Rect, Circle } from 'react-native-svg';
import { View, StyleSheet } from 'react-native';

interface InstagramLogoViewProps {
  size?: number;
}

export const InstagramLogoView: React.FC<InstagramLogoViewProps> = ({ size = 24 }) => {
  const strokeW = size * 0.085;
  const cornerRadius = size * 0.28;
  const lensRadius = (size * 0.48) / 2;
  const flashRadius = (size * 0.11) / 2;
  const center = size / 2;

  return (
    <View style={{ width: size, height: size }}>
      <Svg width={size} height={size} viewBox={`0 0 ${size} ${size}`}>
        {/* Outer squircle outline */}
        <Rect
          x={strokeW / 2}
          y={strokeW / 2}
          width={size - strokeW}
          height={size - strokeW}
          rx={cornerRadius}
          ry={cornerRadius}
          stroke="#FFFFFF"
          strokeWidth={strokeW}
          fill="none"
        />
        {/* Center camera lens */}
        <Circle
          cx={center}
          cy={center}
          r={lensRadius}
          stroke="#FFFFFF"
          strokeWidth={strokeW}
          fill="none"
        />
        {/* Top-right flash dot */}
        <Circle
          cx={center + size * 0.24}
          cy={center - size * 0.24}
          r={flashRadius}
          fill="#FFFFFF"
        />
      </Svg>
    </View>
  );
};
