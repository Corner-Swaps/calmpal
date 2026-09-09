# Calmpal (Cross-Platform)

Calmpal is a cross-platform relaxation and soundscape grounding app built with **React Native**, **Expo SDK 57**, and **TypeScript**. It offers 100% visual, layout, and functional parity across **iOS**, **Web**, and **Android**.

> [!NOTE]
> **Legacy Swift Archive**: The original native iOS Swift codebase has been preserved in the [`legacy-swift`](https://github.com/Corner-Swaps/calmpal/tree/legacy-swift) branch and archived as `Calmpal-Swift-Backup.zip`. All future development and feature additions continue in this cross-platform TypeScript codebase.

---

## Features

- **35 Immersive Soundscapes**: High-fidelity looping audio tracks across categories (Rain, Water, Nature, Animals, Wind, Atmosphere, Ambient, Music).
- **Deep Atmospheric Visuals**: Fullscreen imagery with smooth cross-fade transitions matching each sound profile.
- **Precision Grounding Circular Timer**: 60 FPS smooth circular timer progress ring with minimal indicator dot and digital countdown.
- **Fluid Wave Measuring Lines**: Smooth gesture-driven full-height vertical ruler for setting custom session timers from 1 minute up to 4 hours.
- **Zen Immersion Mode**: One-tap minimal mode dimming secondary UI elements for deep relaxation.
- **Artist Spotlight**: Dedicated profile and Instagram deep-link support (e.g. Jeff Oster for *Surrender*).
- **Haptic Feedback**: Physics-based transient heartbeat haptics on iOS.
- **Native SF Symbols**: Native Apple SF Symbols integration on iOS with clean SVG fallbacks for Web/Android.
- **Instant Cold Launch**: Precompiled Hermes bytecode bundle with zero network dependency.

---

## Project Structure

```
Calmpal-CrossPlatform/
├── src/
│   ├── components/            # UI components (GroundingScreenView, CircularTimer, SFSymbols, etc.)
│   ├── models/                # Data models (SoundProfile, SoundBannerTheme, TimeUtils)
│   ├── managers/              # Core singletons (AudioManager, HapticManager)
│   ├── assets/                # Statically typed asset resolution maps
│   └── __tests__/             # Unit and parity test suites
├── assets/
│   ├── sounds/                # 35 MP3 audio tracks
│   └── images/                # 35 high-res background & thumbnail images
├── ios/                       # Native iOS project harness (Xcode workspace, Podfile, AppDelegate)
├── App.tsx                    # Root application component
├── index.ts                   # Entry point
└── package.json               # Dependencies and build scripts
```

---

## Getting Started

### Prerequisites
- Node.js (v18+)
- npm or yarn
- For iOS: macOS with Xcode 15+ and CocoaPods

### Installation
```bash
npm install
```

### Running the App

- **iOS (Physical Device or Simulator)**:
  ```bash
  npm run ios
  ```
- **Web (Browser)**:
  ```bash
  npm run web
  ```
- **Tests**:
  ```bash
  npm test
  ```

---

## Future Development

For all day-to-day updates and new features:
- **Edit UI & Screens**: Edit TypeScript files in `src/components/`.
- **Add / Modify Sounds**: Update `src/models/SoundProfile.ts` and add audio/image files to `assets/`.
- **Zero Swift Required**: Changes made in `src/` automatically run on iOS, Web, and Android without modifying native code.
