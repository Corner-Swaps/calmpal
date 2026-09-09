import React, { useRef, useEffect, useState, useCallback } from 'react';
import {
  View,
  StyleSheet,
  PanResponder,
  Platform,
  useWindowDimensions,
} from 'react-native';
import Svg, { Path as SvgPath, Circle as SvgCircle, Defs, RadialGradient, Stop, Rect } from 'react-native-svg';
import { HapticManager } from '../managers/HapticManager';

interface TallFusedMeasuringLinesViewProps {
  remainingSeconds: number;
  totalDuration: number;
  isDragging: boolean;
  onDurationChange: (newDuration: number) => void;
  onDragStateChange: (dragging: boolean) => void;
}

const MAX_TIME = 14400.0; // 4 hours

export const TallFusedMeasuringLinesView: React.FC<TallFusedMeasuringLinesViewProps> = ({
  remainingSeconds,
  totalDuration,
  isDragging,
  onDurationChange,
  onDragStateChange,
}) => {
  const { width, height } = useWindowDimensions();
  const webCanvasRef = useRef<HTMLCanvasElement | null>(null);

  // Gesture state refs
  const dragOffsetRef = useRef<number>(0);
  const dragVelocityRef = useRef<number>(0);
  const touchLocationRef = useRef<{ x: number; y: number } | null>(null);
  const remainingSecondsRef = useRef(remainingSeconds);
  remainingSecondsRef.current = remainingSeconds;
  const totalDurationRef = useRef(totalDuration);
  totalDurationRef.current = totalDuration;

  // Native SVG render state
  const [nativeFrame, setNativeFrame] = useState<{
    particles: Array<{ x: number; y: number; r: number; opacity: number }>;
    lines: Array<{ d: string; strokeWidth: number; opacity: number }>;
  }>({ particles: [], lines: [] });

  // PanResponder for drag interactions
  const panResponder = useRef(
    PanResponder.create({
      onStartShouldSetPanResponder: () => true,
      onMoveShouldSetPanResponder: () => true,
      onPanResponderGrant: (evt) => {
        const { locationX, locationY } = evt.nativeEvent;
        // Ignore touches near bottom checkmark area (bottom 80px)
        if (locationY >= height - 80) return;

        onDragStateChange(true);
        touchLocationRef.current = { x: locationX, y: locationY };
        dragOffsetRef.current = 0;
        dragVelocityRef.current = 0;
      },
      onPanResponderMove: (evt, gestureState) => {
        if (gestureState.y0 >= height - 80) return;

        const { moveX, moveY } = gestureState;
        touchLocationRef.current = { x: moveX, y: moveY };

        const dy = gestureState.dy - dragOffsetRef.current;
        dragVelocityRef.current = dy;
        dragOffsetRef.current = gestureState.dy;

        const sensitivity = 90.0 / 18.0; // 5.0 seconds per pixel
        const secondsDelta = -dy * sensitivity;

        const currentTotal = totalDurationRef.current;
        let newTotal = Math.max(0.0, Math.min(MAX_TIME, currentTotal + secondsDelta));
        if (newTotal < 1.0) {
          newTotal = 0.0;
        }
        if (newTotal === 0.0 && currentTotal > 0.0) {
          HapticManager.shared.playTransientHeartbeat(0.4, 0.5);
        }

        onDurationChange(newTotal);
      },
      onPanResponderRelease: () => {
        onDragStateChange(false);
        dragOffsetRef.current = 0;
        touchLocationRef.current = null;
        dragVelocityRef.current = 0;
      },
      onPanResponderTerminate: () => {
        onDragStateChange(false);
        dragOffsetRef.current = 0;
        touchLocationRef.current = null;
        dragVelocityRef.current = 0;
      },
    })
  ).current;

  // Render loop
  useEffect(() => {
    let animId: number;

    const render = (nowMs: number) => {
      const time = nowMs / 1000.0;
      const midX = width / 2;
      const midY = height / 2;
      const currentRemaining = remainingSecondsRef.current;
      const dragVelocity = dragVelocityRef.current;
      const touch = touchLocationRef.current;

      // Dampen velocity over time
      dragVelocityRef.current *= 0.92;

      // Web Canvas branch
      if (Platform.OS === 'web' && webCanvasRef.current) {
        const canvas = webCanvasRef.current;
        const ctx = canvas.getContext('2d');
        if (ctx) {
          ctx.clearRect(0, 0, width, height);

          // 1. Center Focal Aura Glow
          const glowGrad = ctx.createRadialGradient(midX, midY, 10, midX, midY, 180);
          glowGrad.addColorStop(0, 'rgba(255, 255, 255, 0.09)');
          glowGrad.addColorStop(1, 'rgba(255, 255, 255, 0)');
          ctx.fillStyle = glowGrad;
          ctx.fillRect(0, midY - 90, width, 180);

          // 2. Floating Shimmer Particles along Center Focal Zone
          const numParticles = 12;
          for (let i = 0; i < numParticles; i++) {
            const seed = i * 137.5;
            const baseX = (Math.sin(seed) * 0.5 + 0.5) * (width - 80) + 40;
            const baseY = midY + Math.cos(seed * 1.3) * 60;

            const driftY = Math.sin(time * 1.8 + seed) * 14.0 - dragVelocity * 0.45;
            const driftX = Math.cos(time * 1.4 + seed) * 8.0;
            const pX = Math.max(20, Math.min(width - 20, baseX + driftX));
            const pY = baseY + driftY;

            const dist = Math.abs(pY - midY);
            const fade = Math.max(0.0, 1.0 - dist / 65.0);
            const pulse = 0.5 + 0.5 * Math.sin(time * 2.5 + seed);
            const pRadius = 1.0 + pulse * 1.5;

            ctx.fillStyle = `rgba(255, 255, 255, ${0.4 * fade * pulse})`;
            ctx.beginPath();
            ctx.arc(pX, pY, pRadius, 0, Math.PI * 2);
            ctx.fill();
          }

          // 3. Animated Fluid Wave Measuring Lines
          const lineSpacing = 18.0;
          const numLines = Math.floor(height / lineSpacing) + 6;
          const offsetPx = (currentRemaining * (18.0 / 90.0)) % lineSpacing;

          const topSafeFadeStart = 211.0;
          const topSafeFadeEnd = 181.0;
          const bottomSafeFadeStart = height - 155.0;
          const bottomSafeFadeEnd = height - 120.0;

          for (let i = -2; i <= numLines; i++) {
            const yPos = i * lineSpacing - offsetPx;
            if (yPos < topSafeFadeEnd || yPos > bottomSafeFadeEnd) continue;

            const distFromCenter = Math.abs(yPos - midY);
            const focus = Math.max(0.0, Math.exp(-Math.pow(distFromCenter / 115.0, 2)));

            let edgeFade = 1.0;
            if (yPos < topSafeFadeStart) {
              edgeFade = Math.max(0.0, Math.min(1.0, (yPos - topSafeFadeEnd) / (topSafeFadeStart - topSafeFadeEnd)));
            } else if (yPos > bottomSafeFadeStart) {
              edgeFade = Math.max(0.0, Math.min(1.0, (bottomSafeFadeEnd - yPos) / (bottomSafeFadeEnd - bottomSafeFadeStart)));
            }
            if (edgeFade <= 0.005) continue;

            const smoothEdgeFade = 0.62 + 0.38 * Math.sin((edgeFade * Math.PI) / 2.0);
            const baseAlpha = 0.5 + focus * 0.5;

            const lineWidth = (65.0 + focus * 145.0) * (0.4 + 0.6 * smoothEdgeFade);
            const numPts = 12;
            const xStart = midX - lineWidth / 2;

            ctx.beginPath();
            for (let p = 0; p <= numPts; p++) {
              const u = p / numPts;
              const x = xStart + u * lineWidth;
              const relX = (x - midX) / (lineWidth / 2);
              const envelope = Math.max(0.0, 1.0 - relX * relX);

              const wave = Math.sin(time * 2.6 + yPos * 0.035 + relX * 2.2) * (2.0 + focus * 5.5) * envelope;

              let pointerDeflect = 0.0;
              if (touch) {
                const dx = x - touch.x;
                const dy = yPos - touch.y;
                const distToPoint = Math.hypot(dx, dy);
                if (distToPoint < 110) {
                  const force = 1.0 - distToPoint / 110.0;
                  pointerDeflect = force * Math.max(-25.0, Math.min(25.0, touch.y - yPos)) * 0.35 * envelope;
                }
              }

              const clampedVel = Math.max(-10.0, Math.min(10.0, dragVelocity));
              const velocityBow = -clampedVel * focus * envelope * 2.5;
              const finalY = yPos + wave + pointerDeflect + velocityBow;

              if (p === 0) {
                ctx.moveTo(x, finalY);
              } else {
                ctx.lineTo(x, finalY);
              }
            }

            const lineAlpha = baseAlpha * smoothEdgeFade;
            const strokeW = 1.15 + focus * 0.75;
            ctx.strokeStyle = `rgba(255, 255, 255, ${lineAlpha})`;
            ctx.lineWidth = strokeW;
            ctx.lineCap = 'round';
            ctx.stroke();
          }
        }
      } else {
        // Native SVG calculations
        const particleList: Array<{ x: number; y: number; r: number; opacity: number }> = [];
        const numParticles = 12;
        for (let i = 0; i < numParticles; i++) {
          const seed = i * 137.5;
          const baseX = (Math.sin(seed) * 0.5 + 0.5) * (width - 80) + 40;
          const baseY = midY + Math.cos(seed * 1.3) * 60;

          const driftY = Math.sin(time * 1.8 + seed) * 14.0 - dragVelocity * 0.45;
          const driftX = Math.cos(time * 1.4 + seed) * 8.0;
          const pX = Math.max(20, Math.min(width - 20, baseX + driftX));
          const pY = baseY + driftY;

          const dist = Math.abs(pY - midY);
          const fade = Math.max(0.0, 1.0 - dist / 65.0);
          const pulse = 0.5 + 0.5 * Math.sin(time * 2.5 + seed);
          const pRadius = 1.0 + pulse * 1.5;
          particleList.push({ x: pX, y: pY, r: pRadius, opacity: 0.4 * fade * pulse });
        }

        const lineList: Array<{ d: string; strokeWidth: number; opacity: number }> = [];
        const lineSpacing = 18.0;
        const numLines = Math.floor(height / lineSpacing) + 6;
        const offsetPx = (currentRemaining * (18.0 / 90.0)) % lineSpacing;

        const topSafeFadeStart = 211.0;
        const topSafeFadeEnd = 181.0;
        const bottomSafeFadeStart = height - 155.0;
        const bottomSafeFadeEnd = height - 120.0;

        for (let i = -2; i <= numLines; i++) {
          const yPos = i * lineSpacing - offsetPx;
          if (yPos < topSafeFadeEnd || yPos > bottomSafeFadeEnd) continue;

          const distFromCenter = Math.abs(yPos - midY);
          const focus = Math.max(0.0, Math.exp(-Math.pow(distFromCenter / 115.0, 2)));

          let edgeFade = 1.0;
          if (yPos < topSafeFadeStart) {
            edgeFade = Math.max(0.0, Math.min(1.0, (yPos - topSafeFadeEnd) / (topSafeFadeStart - topSafeFadeEnd)));
          } else if (yPos > bottomSafeFadeStart) {
            edgeFade = Math.max(0.0, Math.min(1.0, (bottomSafeFadeEnd - yPos) / (bottomSafeFadeEnd - bottomSafeFadeStart)));
          }
          if (edgeFade <= 0.005) continue;

          const smoothEdgeFade = 0.62 + 0.38 * Math.sin((edgeFade * Math.PI) / 2.0);
          const baseAlpha = 0.5 + focus * 0.5;

          const lineWidth = (65.0 + focus * 145.0) * (0.4 + 0.6 * smoothEdgeFade);
          const numPts = 12;
          const xStart = midX - lineWidth / 2;

          let d = '';
          for (let p = 0; p <= numPts; p++) {
            const u = p / numPts;
            const x = xStart + u * lineWidth;
            const relX = (x - midX) / (lineWidth / 2);
            const envelope = Math.max(0.0, 1.0 - relX * relX);

            const wave = Math.sin(time * 2.6 + yPos * 0.035 + relX * 2.2) * (2.0 + focus * 5.5) * envelope;

            let pointerDeflect = 0.0;
            if (touch) {
              const dx = x - touch.x;
              const dy = yPos - touch.y;
              const distToPoint = Math.hypot(dx, dy);
              if (distToPoint < 110) {
                const force = 1.0 - distToPoint / 110.0;
                pointerDeflect = force * Math.max(-25.0, Math.min(25.0, touch.y - yPos)) * 0.35 * envelope;
              }
            }

            const clampedVel = Math.max(-10.0, Math.min(10.0, dragVelocity));
            const velocityBow = -clampedVel * focus * envelope * 2.5;
            const finalY = yPos + wave + pointerDeflect + velocityBow;

            if (p === 0) {
              d += `M ${x.toFixed(1)} ${finalY.toFixed(1)}`;
            } else {
              d += ` L ${x.toFixed(1)} ${finalY.toFixed(1)}`;
            }
          }

          const lineAlpha = baseAlpha * smoothEdgeFade;
          const strokeW = 1.15 + focus * 0.75;
          lineList.push({ d, strokeWidth: strokeW, opacity: lineAlpha });
        }

        setNativeFrame({ particles: particleList, lines: lineList });
      }

      animId = requestAnimationFrame(render);
    };

    animId = requestAnimationFrame(render);
    return () => cancelAnimationFrame(animId);
  }, [width, height]);

  const midX = width / 2;
  const midY = height / 2;

  return (
    <View style={[styles.container, { width, height }]} {...panResponder.panHandlers}>
      {Platform.OS === 'web' ? (
        // Web Canvas: Hardware-accelerated 60/120fps fluid rendering
        <canvas
          ref={webCanvasRef as any}
          width={width}
          height={height}
          style={{ width, height, display: 'block' }}
        />
      ) : (
        // Native SVG: Exact math rendered via react-native-svg
        <Svg width={width} height={height} viewBox={`0 0 ${width} ${height}`}>
          <Defs>
            <RadialGradient id="focalGlow" cx={midX} cy={midY} rx={180} ry={90} gradientUnits="userSpaceOnUse">
              <Stop offset="0" stopColor="#FFFFFF" stopOpacity="0.09" />
              <Stop offset="1" stopColor="#FFFFFF" stopOpacity="0" />
            </RadialGradient>
          </Defs>

          {/* 1. Center Focal Aura Glow */}
          <Rect x={0} y={midY - 90} width={width} height={180} fill="url(#focalGlow)" />

          {/* 2. Floating Shimmer Particles */}
          {nativeFrame.particles.map((p, idx) => (
            <SvgCircle key={`p-${idx}`} cx={p.x} cy={p.y} r={p.r} fill="#FFFFFF" fillOpacity={p.opacity} />
          ))}

          {/* 3. Fluid Wave Lines */}
          {nativeFrame.lines.map((l, idx) => (
            <SvgPath
              key={`line-${idx}`}
              d={l.d}
              stroke="#FFFFFF"
              strokeWidth={l.strokeWidth}
              strokeOpacity={l.opacity}
              strokeLinecap="round"
              fill="none"
            />
          ))}
        </Svg>
      )}
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    ...StyleSheet.absoluteFill,
    backgroundColor: '#000000',
    overflow: 'hidden',
  },
});
