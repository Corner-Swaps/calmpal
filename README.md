# Calmpal

[![TypeScript](https://img.shields.io/badge/TypeScript-Strict-blue.svg?logo=typescript)](https://www.typescriptlang.org/)
[![React Native](https://img.shields.io/badge/React%20Native-0.86.3-61dafb.svg?logo=react)](https://reactnative.dev/)
[![Expo SDK](https://img.shields.io/badge/Expo%20SDK-57.0.21-000020.svg?logo=expo)](https://expo.dev/)
[![Tests](https://img.shields.io/badge/Unit%20Tests-15%20Passing-success.svg)](#verification--testing)
[![Offline First](https://img.shields.io/badge/Architecture-Offline--First-teal.svg)](#architecture--security)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

Calmpal is a high-performance, cross-platform relaxation and ambient soundscape app built with **React Native (New Architecture)**, **Expo SDK 57**, and strict **TypeScript**. It offers 100% visual, layout, and sensory parity across **iOS**, **Android**, and **Web**.

> [!NOTE]
> **Legacy Swift Archive**: The original native iOS Swift codebase is preserved in the [`legacy-swift`](https://github.com/Corner-Swaps/calmpal/tree/legacy-swift) branch and archived in `Calmpal-Swift-Backup.zip`. All current and future development continues in this modern cross-platform TypeScript codebase.

---

## Features

- 🎧 **35 Curated Soundscapes**: Sample-accurate, infinite continuous looping across 8 categories (Rain, Ocean, Forest, Wind, Ambient, Meditation, Nature, Music).
- 🌌 **Deep Atmospheric Backdrops**: Fullscreen cinematic visuals with smooth cross-fade transitions tailored to each soundscape.
- ⏱️ **Precision Grounding Circular Timer**: Minimalist progress ring with digital countdown clock, battery-optimized to run at 0% idle CPU overhead.
- 🌊 **Fluid Wave Measuring Lines**: Gesture-driven vertical ruler allowing smooth session duration configuration from 1 minute up to 4 hours.
- 🧘 **Zen Immersion Mode**: One-tap distraction-free interface that dims secondary controls for deep meditation or sleep.
- 🎵 **Artist Spotlight**: Dedicated artist profile integration and verified social links (e.g. Jeff Oster for *Surrender*).
- 📳 **Tactile Haptic Feedback**: Smooth transient heartbeat haptics on physical iOS hardware.
- 📱 **Native Apple SF Symbols**: Native vector iconography on iOS with SVG rendering on Web and Android.
- ⚡ **Instant Cold Launch**: Precompiled Hermes bytecode bundle ensuring instant launch with zero network latency.
- ♿ **Full Screen Reader Accessibility**: Complete VoiceOver and TalkBack support across all screen controls and sound libraries.

---

## Architecture & Security

Calmpal is architected from the ground up to be **completely private, offline-first, and resilient**:

* **Zero External Telemetry**: The app does not transmit data to external servers, track analytics, or collect user metrics.
* **Hermes Bytecode Bundling**: JavaScript is precompiled into Hermes binary bytecode (`ios/main.jsbundle`), eliminating JIT compilation delays and securing code against runtime inspection.
* **App Store Compliant**: Configured to request zero unneeded device permissions (no microphone or location access declared).
* **Sample-Accurate Audio Engine**: Backed by `expo-audio` with custom AVPlayer seek tolerances and background audio mixing policies (`mixWithOthers`, `allowBluetoothA2DP`, `allowAirPlay`).
* **Error Boundary Resilience**: Wrapped in a top-level React Error Boundary that prevents uncaught render exceptions from crashing the native runtime.

---

## Project Structure

```
calmpal/
├── src/
│   ├── components/            # UI components (GroundingScreenView, CircularTimer, ErrorBoundary, etc.)
│   ├── models/                # Data models (SoundProfile, SoundBannerTheme, TimeUtils, Theme)
│   ├── managers/              # Singletons (AudioManager, HapticManager)
│   ├── assets/                # Statically typed asset resolution maps
│   └── __tests__/             # Parity and logic unit test suites
├── assets/
│   ├── sounds/                # 35 high-fidelity MP3 soundscape audio tracks
│   └── images/                # 35 atmospheric visual backgrounds and thumbnails
├── ios/                       # Native iOS harness (Xcode workspace, Podfile, AppDelegate)
├── patches/                   # Version-controlled package patches (expo-audio)
├── .github/workflows/         # Continuous integration pipelines (Type check, Jest)
├── App.tsx                    # Root application component with ErrorBoundary
├── index.ts                   # Application entry point
├── package.json               # Dependencies and build scripts
└── tsconfig.json              # Strict TypeScript configuration
```

---

## Getting Started

### Prerequisites
- **Node.js**: v18 or later
- **Package Manager**: npm or yarn
- **For iOS Development**: macOS with Xcode 15+ and CocoaPods

### Installation
```bash
git clone https://github.com/Corner-Swaps/calmpal.git
cd calmpal
npm install
```

### Verification & Testing
```bash
# Run unit tests
npm test

# Run static TypeScript type check
npx tsc --noEmit

# Compile production Hermes bundle and package assets
npm run bundle:ios
```

### Running Locally

* **iOS (Simulator or Connected Device)**:
  ```bash
  npm run ios
  ```
* **Web (Browser)**:
  ```bash
  npm run web
  ```

---

## Quality Assurance & Verification

The codebase maintains 100% strict verification standards:
1. **Static Type Safety**: Full TypeScript strict mode compliance (`npx tsc --noEmit`) with zero type errors.
2. **Unit Test Parity**: Automated Jest test suite covering audio managers, timing utilities, and theme completeness (`npm test`).
3. **App Store Readiness**: Zero undeclared capabilities or invasive permissions.

---

## Community & Guidelines

- **Contributing**: Please review our [Contributing Guide](CONTRIBUTING.md) for code style, pre-push quality gates, and branching rules.
- **Security**: View our [Security Policy](SECURITY.md) to report vulnerabilities responsibly.
- **Code of Conduct**: We adhere to the [Contributor Covenant](CODE_OF_CONDUCT.md).

---

## License

This project is licensed under the [MIT License](LICENSE). Copyright (c) 2026 Calmpal.
