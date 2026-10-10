# CalmPal — Release Result Note (Android Google Play & iOS App Store)

**Project**: CalmPal (Grounding, Meditation, Breathing & Ambient Soundscape App)  
**Date**: October 10, 2026  
**Repository**: `/Users/slava/Downloads/Projects/Calmpal-CrossPlatform`  
**Brief Reference**: `04-android-build-for-skipped-projects.md` & `00-master-release-prompt.md`  
**Application ID / Bundle ID**: `com.calmpal.app`  

---

## 1. Application Identifiers & Versions

| Attribute | Android (Google Play Release) | iOS (Apple App Store / TestFlight) |
| :--- | :--- | :--- |
| **Application ID / Bundle ID** | `com.calmpal.app` | `com.calmpal.app` |
| **Version Name / Marketing Version** | `5.6.0` | `5.6.0` |
| **Version Code / Build Number** | `1` | `56` |
| **Target SDK / Deployment Target** | `36` (Android 16 / Google Play Standard) | `iOS 15.1+` |
| **compileSdkVersion / minSdkVersion** | compileSdk: `36`, minSdk: `24` | iOS 15.1+ |
| **Build Artifact** | `deliverables/calmpal-release.aab` (145 MB) | TestFlight Build |
| **Signing Certificate Key / Profile** | RSA 2048-bit (`calmpal` alias) | Cloud Managed Apple Distribution |
| **Certificate Fingerprint SHA-256** | `3A:7F:0C:03:4A:34:A7:29:63:9E:35:17:9A:95:35:FE:13:47:9A:91:49:D3:6E:12:03:F8:A8:D5:3D:0A:E6:E2` | Apple Distribution |
| **Certificate Fingerprint SHA-1** | `78:6A:D4:9A:53:91:73:96:4B:F0:9D:2C:75:8F:F8:B0:CA:05:D4:8C` | Apple Distribution |
| **Release Status** | **Signed Release AAB Delivered to Drive** | **TestFlight** |

---

## 2. Toolchain & Upload Keystore

- **Android Toolchain**: React Native 0.86.3, Expo SDK 57, Gradle 9.3.1, Adoptium OpenJDK 21 LTS.
- **Keystore File**: `android/app/release.keystore`
- **Key Alias**: `calmpal`
- **Signature Algorithm**: `SHA384withRSA`, 2048-bit RSA key
- **Validity**: Until February 25, 2054 (10,000 days)
- **Keystore Backups Saved In**:
  1. `~/.android/calmpal-release.keystore`
  2. `/Users/slava/Downloads/Projects/Calmpal-CrossPlatform/backups/calmpal-release.keystore`
  3. `~/Desktop/calmpal-release.keystore`

---

## 3. Core Flows Verified

1. **5-4-3-2-1 Sensory Grounding Flow (`GroundingScreenView`)**:
   - Sequential sensory awareness stages (5 see, 4 feel, 3 hear, 2 smell, 1 taste) cycle smoothly with interactive tap triggers, dynamic progress indicators, and sensory reset controls.
2. **Ambient Soundscape Mixing (`AudioManager` & `RelaxingSoundsFullView`)**:
   - Offline local ambient loop audio tracks (rain, ocean, forest, stream, crackling fire) playback simultaneously with smooth volume crossfading and low-latency audio buffering.
3. **Breathing Pacing & Meditation Timer (`FullCircularTimerView` & `TallFusedMeasuringLinesView`)**:
   - Paced breath expansion/contraction animations, session duration countdown, tactile haptic cues (`HapticManager`), and clean transition back to the home hub upon completion.

---

## 4. Monetization & Paywall Verification

- **In-App Purchases**: None.
- **Paywall Status**: No StoreKit/Google Play Billing lockouts. All ambient soundscapes, breathing guides, and grounding flows are 100% accessible offline without requiring in-app purchase validation.

---

## 5. Delivery Checklist

- [x] Production Release `.aab` compiled and verified with `jarsigner`.
- [x] Package name confirmed unchanged: `com.calmpal.app`.
- [x] Target SDK verified: `36`.
- [x] Debuggable flag disabled (`debuggable=false`), dev API endpoints absent.
- [x] Delivered to Google Drive `Google Play/deliverables` folder `1wSTEEU2-FKlD3EuFgK-y_mg6_EF8kDQc`.
- [x] Keystore backed up in 3 locations and password safeguarded.
