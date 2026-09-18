# Calmpal Legal Compliance & Asset Licensing Register

This document serves as the formal compliance, intellectual property, and licensing register for **Calmpal** and its operating entity.

---

## 1. Asset Licensing & Intellectual Property

### 1.1 Audio Soundscape Catalog (35 Tracks)

| Category | Tracks | Licensing Status | Notes |
| :--- | :--- | :--- | :--- |
| **Ambient & Nature** (34 Tracks) | Gentle Rain, Rain Canopy, Rolling Thunder, Ocean Waves, Waterfall, Forest River, Coastal Seagulls, Forest Birdsong, Tropical Jungle, Night Crickets, Evening Frogs, Cat Purring, Wind in Trees, Cozy Campfire, Dune Breeze, Howling Wind, Walk on Leaves, Warm Cafe, Quiet Library, Night Village, Temple Sanctuary, Deep Underwater, Singing Bowl, Wind Chimes, Scenic Train, Rain on Tent, Ocean Whale, Rain on Car, Gentle Sailboat, Snowy Forest, Antique Clock, Night Owl, Rowing Boat, Cathedral Chimes | **Royalty-Free / CC0** | Ambient field recordings and soundscapes cleared for commercial use with no residual royalty obligations. |
| **Featured Music** (1 Track) | *Surrender* ("Enlightened Darkness") | **Direct Artist Authorization** | Composed and performed by **Jeff Oster**. Used with express artist permission, featuring prominent in-app artist spotlight attribution and link to `@jeffosterpix`. |

### 1.2 Visual Artwork & Photography
- All visual backdrops and imagery bundled in `assets/images/` are licensed under royalty-free commercial terms (Unsplash Commercial License, Pexels, CC0, or proprietary creative assets).
- No trademarked corporate logos or third-party proprietary designs are present in the visual media.

---

## 2. Regulatory & Statutory Compliance Review

### 2.1 Children's Online Privacy Protection Act (COPPA — 15 U.S.C. §§ 6501–6506)
- **Status**: **Fully Compliant / Exempt from Parental Consent Mandates**
- **Rationale**: Calmpal does not require user accounts, collects zero personal identifying information (no names, emails, addresses, geolocation, or persistent identifiers), and maintains no backend servers or databases.

### 2.2 European GDPR & Remote CDN Fonts (LG München I Ruling, 2022)
- **Status**: **100% Compliant**
- **Rationale**: Calmpal does not load fonts from remote third-party CDNs (such as `fonts.googleapis.com` or `fonts.gstatic.com`). All typography uses local Apple system fonts (`System`, SF Pro) and native platform sans-serif stacks on device. No user IP addresses are leaked to third-party font servers.

### 2.3 California Invasion of Privacy Act (CIPA) & Wiretapping / Session Replay
- **Status**: **100% Compliant**
- **Rationale**: Calmpal contains zero session replay tools (no PostHog, Hotjar, FullStory, LogRocket, Mixpanel, or Datadog RUM). There is no recording of user keystrokes, gestures, or interactions. Apple Privacy Manifest (`PrivacyInfo.xcprivacy`) certifies `NSPrivacyTracking: false`.

### 2.4 CAN-SPAM Act (15 U.S.C. 7701)
- **Status**: **Not Applicable In-App**
- **Rationale**: The application does not collect email addresses, does not send commercial marketing emails, and has no transactional email integrations.

### 2.5 California Automatic Renewal Law (ARL — Cal. Bus. & Prof. Code §§ 17600–17606)
- **Status**: **Not Applicable In-App**
- **Rationale**: Calmpal does not charge recurring subscriptions or implement web paywalls. When monetized on iOS, digital subscriptions are processed exclusively via Apple StoreKit In-App Purchases, where renewal disclosures and cancellation management are handled through native Apple interfaces.

### 2.6 Digital Millennium Copyright Act (DMCA — 17 U.S.C. § 512(c))
- **Status**: **Not Required**
- **Rationale**: The $6 Copyright Office DMCA Designated Agent requirement applies only to online service providers that allow *user-uploaded content* (UGC) and seek safe harbor protection against infringing third-party uploads. Calmpal does not support user uploads.

---

## 3. Disclaimers & Limitation of Liability

### 3.1 Non-Medical & Wellness Disclaimer
Calmpal is designed strictly as a lifestyle, meditation, and relaxation soundscape tool. It is **not** a certified medical device and is not intended to diagnose, treat, cure, or prevent any medical condition, mental health disorder, sleep disorder, or clinical anxiety. Users experiencing severe or chronic sleep or anxiety issues should consult a licensed healthcare professional.

### 3.2 Operating Machinery & Driving Warning
Calmpal includes ambient soundscapes specifically crafted to induce deep relaxation and drowsiness. **Under no circumstances should Calmpal be used while driving, operating a motor vehicle, bicycling, or operating heavy or dangerous machinery.**

### 3.3 Limitation of Liability ("AS IS")
In accordance with the project's [MIT License](LICENSE), the software is provided "AS IS", without warranty of any kind, express or implied, including but not limited to warranties of merchantability, fitness for a particular purpose, and non-infringement.

---

## 4. Technical Privacy Verification

- **Apple Privacy Manifest**: `ios/Calmpal/PrivacyInfo.xcprivacy`
- **Network Requests**: 0 external telemetry or tracking endpoints
- **Data Collection**: None
- **Tracking**: None
