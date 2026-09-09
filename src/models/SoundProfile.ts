// SoundProfile model matching Swift SoundProfile enum exactly

export enum SoundProfile {
  // Rain (3)
  gentleRain = 'Drizzle',
  rainCanopy = 'Canopy',
  rollingThunder = 'Thunder',

  // Ocean (4)
  oceanWaves = 'Waves',
  waterfall = 'Waterfall',
  forestRiver = 'River',
  coastalSeagulls = 'Seagulls',

  // Forest (5)
  forestBirdsong = 'Birds',
  tropicalJungle = 'Jungle',
  nightCrickets = 'Crickets',
  eveningFrogs = 'Frogs',
  catPurring = 'Purr',

  // Wind (5)
  windInTrees = 'Trees',
  cozyCampfire = 'Campfire',
  duneBreeze = 'Breeze',
  howlingWind = 'Gale',
  walkOnLeaves = 'Leaves',

  // Ambient (5)
  warmCafe = 'Cafe',
  quietLibrary = 'Library',
  nightVillage = 'Village',
  templeSanctuary = 'Temple',
  deepUnderwater = 'Deep',

  // Additional Serene Soundscapes (11)
  singingBowl = 'Bowl',
  windChimes = 'Chimes',
  scenicTrain = 'Train',
  rainOnTent = 'Tent',
  oceanWhale = 'Whale',
  rainOnCar = 'Car',
  gentleSailboat = 'Sailboat',
  snowyForest = 'Snow',
  antiqueClock = 'Clock',
  nightOwl = 'Owl',
  rowingBoat = 'Oars',
  cathedralChimes = 'Bells',
  surrender = 'Surrender',
}

export interface SoundHapticProfile {
  baseIntensity: number;
  baseSharpness: number;
  dynamicGain: number;
  pulseFrequency: number;
}

export interface SoundArtistCredit {
  name: string;
  instagramHandle: string;
  instagramURL: string;
}

export const SOUND_PROFILE_RESOURCE_FILES: Record<SoundProfile, string> = {
  [SoundProfile.gentleRain]: 'light-rain',
  [SoundProfile.rainCanopy]: 'rain-on-leaves',
  [SoundProfile.rollingThunder]: 'thunder',
  [SoundProfile.oceanWaves]: 'waves',
  [SoundProfile.waterfall]: 'waterfall',
  [SoundProfile.forestRiver]: 'river',
  [SoundProfile.coastalSeagulls]: 'seagulls',
  [SoundProfile.forestBirdsong]: 'birds',
  [SoundProfile.tropicalJungle]: 'jungle',
  [SoundProfile.nightCrickets]: 'crickets',
  [SoundProfile.eveningFrogs]: 'frog',
  [SoundProfile.catPurring]: 'cat-purring',
  [SoundProfile.windInTrees]: 'wind-in-trees',
  [SoundProfile.cozyCampfire]: 'campfire',
  [SoundProfile.duneBreeze]: 'wind',
  [SoundProfile.howlingWind]: 'howling-wind',
  [SoundProfile.walkOnLeaves]: 'walk-on-leaves',
  [SoundProfile.warmCafe]: 'cafe',
  [SoundProfile.quietLibrary]: 'library',
  [SoundProfile.nightVillage]: 'night-village',
  [SoundProfile.templeSanctuary]: 'temple',
  [SoundProfile.deepUnderwater]: 'underwater',
  [SoundProfile.singingBowl]: 'singing-bowl',
  [SoundProfile.windChimes]: 'wind-chimes',
  [SoundProfile.scenicTrain]: 'inside-a-train',
  [SoundProfile.rainOnTent]: 'rain-on-tent',
  [SoundProfile.oceanWhale]: 'whale',
  [SoundProfile.rainOnCar]: 'rain-on-car-roof',
  [SoundProfile.gentleSailboat]: 'sailboat',
  [SoundProfile.snowyForest]: 'walk-in-snow',
  [SoundProfile.antiqueClock]: 'clock',
  [SoundProfile.nightOwl]: 'owl',
  [SoundProfile.rowingBoat]: 'rowing-boat',
  [SoundProfile.cathedralChimes]: 'church',
  [SoundProfile.surrender]: 'surrender',
};

export const SOUND_PROFILE_EXPLANATIONS: Record<SoundProfile, string> = {
  [SoundProfile.gentleRain]: 'Soft, soothing patter of light rainfall.',
  [SoundProfile.rainCanopy]: 'Gentle shower falling on forest leaves and foliage.',
  [SoundProfile.rollingThunder]: 'Low, rumbling thunder echoing safely over hills.',
  [SoundProfile.oceanWaves]: 'Rhythmic ocean surf swells rolling onto sandy shores.',
  [SoundProfile.waterfall]: 'Pure white water cascading into a deep natural pool.',
  [SoundProfile.forestRiver]: 'Clear stream water trickling over smooth river stones.',
  [SoundProfile.coastalSeagulls]: 'Ocean tides washing coastal rocks with gull calls.',
  [SoundProfile.forestBirdsong]: 'Vibrant morning birdsong chorus in woodland canopy.',
  [SoundProfile.tropicalJungle]: 'Rich tropical atmosphere with warm birdsong and rustle.',
  [SoundProfile.nightCrickets]: 'Quiet evening field silence with gentle cricket chirps.',
  [SoundProfile.eveningFrogs]: 'Peaceful twilight pond atmosphere with soft frog croaks.',
  [SoundProfile.catPurring]: 'Rhythmic, deep cat purr providing sensory warmth.',
  [SoundProfile.windInTrees]: 'Rustling forest canopy breeze sweeping through trees.',
  [SoundProfile.cozyCampfire]: 'Warm hearth wood embers crackling and popping softly.',
  [SoundProfile.duneBreeze]: 'Smooth, warm whistling breeze blowing across dunes.',
  [SoundProfile.howlingWind]: 'Atmospheric high mountain wind blowing over peaks.',
  [SoundProfile.walkOnLeaves]: 'Rhythmic crunch of dry autumn leaves beneath steps.',
  [SoundProfile.warmCafe]: 'Subtle background coffee shop chatter and cup clinks.',
  [SoundProfile.quietLibrary]: 'Peaceful indoor sanctuary air flow for focus.',
  [SoundProfile.nightVillage]: 'Serene night atmosphere in a quiet, secluded village.',
  [SoundProfile.templeSanctuary]: 'Soothing temple sanctuary drone for calm meditation.',
  [SoundProfile.deepUnderwater]: 'Deep sub-aquatic ocean pressure swell and resonance.',
  [SoundProfile.singingBowl]: 'Harmonic Tibetan brass singing bowl resonance for deep meditation.',
  [SoundProfile.windChimes]: 'Gentle bamboo and glass wind chimes swaying in a serene breeze.',
  [SoundProfile.scenicTrain]: 'Rhythmic wooden train journey winding through misty mountain valleys.',
  [SoundProfile.rainOnTent]: 'Cozy raindrops drumming peacefully against a forest camping tent.',
  [SoundProfile.oceanWhale]: 'Majestic humpback whale songs echoing through deep blue waters.',
  [SoundProfile.rainOnCar]: 'Soothing rain patter drumming on car glass under twilight streetlights.',
  [SoundProfile.gentleSailboat]: 'Calm ripples and creaking wood of a sailboat drifting at golden hour.',
  [SoundProfile.snowyForest]: 'Crisp footsteps crunching softly through fresh winter snow among frosted pine trees.',
  [SoundProfile.antiqueClock]: 'Rhythmic, reassuring wooden ticks of an antique grandfather clock in a peaceful room.',
  [SoundProfile.nightOwl]: 'Peaceful nocturnal owl calls echoing across the quiet moonlit forest canopy.',
  [SoundProfile.rowingBoat]: 'Gentle wooden oars dipping and slicing through glassy, tranquil alpine lake water.',
  [SoundProfile.cathedralChimes]: 'Contemplative stone chapel bells chiming softly across a misty mountain valley.',
  [SoundProfile.surrender]: 'Enlightened darkness meditative chant for deep surrender and peace.',
};

export const SOUND_PROFILE_CATEGORIES: Record<SoundProfile, string> = {
  [SoundProfile.gentleRain]: 'Rain',
  [SoundProfile.rainCanopy]: 'Rain',
  [SoundProfile.rollingThunder]: 'Rain',
  [SoundProfile.rainOnTent]: 'Rain',
  [SoundProfile.rainOnCar]: 'Rain',

  [SoundProfile.oceanWaves]: 'Ocean',
  [SoundProfile.waterfall]: 'Ocean',
  [SoundProfile.forestRiver]: 'Ocean',
  [SoundProfile.coastalSeagulls]: 'Ocean',
  [SoundProfile.oceanWhale]: 'Ocean',
  [SoundProfile.gentleSailboat]: 'Ocean',
  [SoundProfile.rowingBoat]: 'Ocean',

  [SoundProfile.forestBirdsong]: 'Forest',
  [SoundProfile.tropicalJungle]: 'Forest',
  [SoundProfile.nightCrickets]: 'Forest',
  [SoundProfile.eveningFrogs]: 'Forest',
  [SoundProfile.catPurring]: 'Forest',
  [SoundProfile.snowyForest]: 'Forest',
  [SoundProfile.nightOwl]: 'Forest',

  [SoundProfile.windInTrees]: 'Wind',
  [SoundProfile.cozyCampfire]: 'Wind',
  [SoundProfile.duneBreeze]: 'Wind',
  [SoundProfile.howlingWind]: 'Wind',
  [SoundProfile.walkOnLeaves]: 'Wind',
  [SoundProfile.windChimes]: 'Wind',

  [SoundProfile.warmCafe]: 'Ambient',
  [SoundProfile.quietLibrary]: 'Ambient',
  [SoundProfile.nightVillage]: 'Ambient',
  [SoundProfile.templeSanctuary]: 'Ambient',
  [SoundProfile.deepUnderwater]: 'Ambient',
  [SoundProfile.singingBowl]: 'Ambient',
  [SoundProfile.scenicTrain]: 'Ambient',
  [SoundProfile.antiqueClock]: 'Ambient',
  [SoundProfile.cathedralChimes]: 'Ambient',
  [SoundProfile.surrender]: 'Ambient',
};

export const SOUND_HAPTIC_PROFILES: Record<SoundProfile, SoundHapticProfile> = {
  [SoundProfile.nightCrickets]: { baseIntensity: 0.36, baseSharpness: 0.78, dynamicGain: 0.85, pulseFrequency: 0.35 },
  [SoundProfile.duneBreeze]: { baseIntensity: 0.38, baseSharpness: 0.22, dynamicGain: 0.75, pulseFrequency: 0.20 },
  [SoundProfile.cozyCampfire]: { baseIntensity: 0.44, baseSharpness: 0.52, dynamicGain: 0.90, pulseFrequency: 0.30 },
  [SoundProfile.quietLibrary]: { baseIntensity: 0.28, baseSharpness: 0.16, dynamicGain: 0.50, pulseFrequency: 0.15 },
  [SoundProfile.rollingThunder]: { baseIntensity: 0.65, baseSharpness: 0.15, dynamicGain: 1.15, pulseFrequency: 0.18 },
  [SoundProfile.oceanWaves]: { baseIntensity: 0.52, baseSharpness: 0.22, dynamicGain: 0.95, pulseFrequency: 0.18 },
  [SoundProfile.gentleRain]: { baseIntensity: 0.35, baseSharpness: 0.54, dynamicGain: 0.80, pulseFrequency: 0.25 },
  [SoundProfile.waterfall]: { baseIntensity: 0.50, baseSharpness: 0.35, dynamicGain: 0.90, pulseFrequency: 0.22 },
  [SoundProfile.forestRiver]: { baseIntensity: 0.42, baseSharpness: 0.38, dynamicGain: 0.80, pulseFrequency: 0.25 },
  [SoundProfile.catPurring]: { baseIntensity: 0.58, baseSharpness: 0.30, dynamicGain: 0.75, pulseFrequency: 24.0 },
  [SoundProfile.eveningFrogs]: { baseIntensity: 0.40, baseSharpness: 0.48, dynamicGain: 0.80, pulseFrequency: 0.32 },
  [SoundProfile.templeSanctuary]: { baseIntensity: 0.35, baseSharpness: 0.18, dynamicGain: 0.60, pulseFrequency: 0.16 },
  [SoundProfile.coastalSeagulls]: { baseIntensity: 0.45, baseSharpness: 0.48, dynamicGain: 0.85, pulseFrequency: 0.20 },
  [SoundProfile.howlingWind]: { baseIntensity: 0.48, baseSharpness: 0.28, dynamicGain: 0.90, pulseFrequency: 0.22 },
  [SoundProfile.rainCanopy]: { baseIntensity: 0.40, baseSharpness: 0.58, dynamicGain: 0.82, pulseFrequency: 0.25 },
  [SoundProfile.deepUnderwater]: { baseIntensity: 0.60, baseSharpness: 0.12, dynamicGain: 0.95, pulseFrequency: 0.15 },
  [SoundProfile.tropicalJungle]: { baseIntensity: 0.44, baseSharpness: 0.62, dynamicGain: 0.85, pulseFrequency: 0.30 },
  [SoundProfile.nightVillage]: { baseIntensity: 0.30, baseSharpness: 0.22, dynamicGain: 0.60, pulseFrequency: 0.18 },
  [SoundProfile.forestBirdsong]: { baseIntensity: 0.38, baseSharpness: 0.72, dynamicGain: 0.80, pulseFrequency: 0.35 },
  [SoundProfile.windInTrees]: { baseIntensity: 0.38, baseSharpness: 0.32, dynamicGain: 0.80, pulseFrequency: 0.22 },
  [SoundProfile.warmCafe]: { baseIntensity: 0.35, baseSharpness: 0.38, dynamicGain: 0.70, pulseFrequency: 0.25 },
  [SoundProfile.walkOnLeaves]: { baseIntensity: 0.42, baseSharpness: 0.68, dynamicGain: 0.85, pulseFrequency: 0.30 },
  [SoundProfile.singingBowl]: { baseIntensity: 0.40, baseSharpness: 0.18, dynamicGain: 0.65, pulseFrequency: 0.20 },
  [SoundProfile.windChimes]: { baseIntensity: 0.35, baseSharpness: 0.75, dynamicGain: 0.80, pulseFrequency: 0.30 },
  [SoundProfile.scenicTrain]: { baseIntensity: 0.48, baseSharpness: 0.32, dynamicGain: 0.75, pulseFrequency: 0.45 },
  [SoundProfile.rainOnTent]: { baseIntensity: 0.42, baseSharpness: 0.58, dynamicGain: 0.85, pulseFrequency: 0.26 },
  [SoundProfile.oceanWhale]: { baseIntensity: 0.55, baseSharpness: 0.15, dynamicGain: 0.90, pulseFrequency: 0.16 },
  [SoundProfile.rainOnCar]: { baseIntensity: 0.42, baseSharpness: 0.56, dynamicGain: 0.82, pulseFrequency: 0.25 },
  [SoundProfile.gentleSailboat]: { baseIntensity: 0.44, baseSharpness: 0.25, dynamicGain: 0.80, pulseFrequency: 0.18 },
  [SoundProfile.snowyForest]: { baseIntensity: 0.38, baseSharpness: 0.62, dynamicGain: 0.80, pulseFrequency: 0.32 },
  [SoundProfile.antiqueClock]: { baseIntensity: 0.34, baseSharpness: 0.45, dynamicGain: 0.70, pulseFrequency: 1.00 },
  [SoundProfile.nightOwl]: { baseIntensity: 0.36, baseSharpness: 0.22, dynamicGain: 0.75, pulseFrequency: 0.20 },
  [SoundProfile.rowingBoat]: { baseIntensity: 0.42, baseSharpness: 0.28, dynamicGain: 0.80, pulseFrequency: 0.24 },
  [SoundProfile.cathedralChimes]: { baseIntensity: 0.45, baseSharpness: 0.32, dynamicGain: 0.85, pulseFrequency: 0.22 },
  [SoundProfile.surrender]: { baseIntensity: 0.32, baseSharpness: 0.16, dynamicGain: 0.65, pulseFrequency: 0.18 },
};

export const SOUND_ARTIST_CREDITS: Partial<Record<SoundProfile, SoundArtistCredit>> = {
  [SoundProfile.surrender]: {
    name: 'Jeff Oster',
    instagramHandle: '@jeffosterpix',
    instagramURL: 'https://www.instagram.com/jeffosterpix/',
  },
};
