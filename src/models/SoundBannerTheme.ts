import { SoundProfile } from './SoundProfile';

export interface SoundBannerTheme {
  id: string;
  profile: SoundProfile;
  title: string;
  imageName: string;
  previewAlignment?: 'center' | 'bottom' | 'top';
  thumbnailImageName: string;
}

export const allSoundBanners: SoundBannerTheme[] = [
  // Top Priority Sections
  { id: 'crickets-night', profile: SoundProfile.nightCrickets, title: 'Crickets Night', imageName: 'crickets-night', thumbnailImageName: 'crickets-night-thumb' },
  { id: 'dune-breeze', profile: SoundProfile.duneBreeze, title: 'Desert Dune Breeze', imageName: 'dune-breeze', previewAlignment: 'bottom', thumbnailImageName: 'dune-breeze-thumb' },
  { id: 'cozy-campfire', profile: SoundProfile.cozyCampfire, title: 'Cozy Campfire', imageName: 'cozy-campfire', thumbnailImageName: 'cozy-campfire-thumb' },
  { id: 'quiet-library', profile: SoundProfile.quietLibrary, title: 'Quiet Library', imageName: 'quiet-library', thumbnailImageName: 'quiet-library-thumb' },
  { id: 'surrender', profile: SoundProfile.surrender, title: 'Surrender', imageName: 'surrender', thumbnailImageName: 'surrender-thumb' },
  { id: 'rolling-thunder', profile: SoundProfile.rollingThunder, title: 'Rolling Thunder', imageName: 'rolling-thunder', previewAlignment: 'bottom', thumbnailImageName: 'rolling-thunder-thumb' },

  // Rest of Soundscapes
  { id: 'gentle-rain', profile: SoundProfile.gentleRain, title: 'Gentle Rain', imageName: 'gentle-rain', thumbnailImageName: 'gentle-rain-thumb' },
  { id: 'ocean-waves', profile: SoundProfile.oceanWaves, title: 'Peaceful Ocean', imageName: 'ocean-waves', thumbnailImageName: 'ocean-waves-thumb' },
  { id: 'wind-in-trees', profile: SoundProfile.windInTrees, title: 'Wind in Trees', imageName: 'gentle-wind', thumbnailImageName: 'gentle-wind-thumb' },
  { id: 'waterfall', profile: SoundProfile.waterfall, title: 'Forest Waterfall', imageName: 'waterfall', thumbnailImageName: 'waterfall-thumb' },
  { id: 'flowing-river', profile: SoundProfile.forestRiver, title: 'Flowing River', imageName: 'flowing-river', thumbnailImageName: 'flowing-river-thumb' },

  { id: 'evening-frogs', profile: SoundProfile.eveningFrogs, title: 'Evening Frogs', imageName: 'evening-frogs', thumbnailImageName: 'evening-frogs-thumb' },
  { id: 'cat-purr', profile: SoundProfile.catPurring, title: 'Cat Purring', imageName: 'cat-purr', thumbnailImageName: 'cat-purr-thumb' },
  { id: 'temple-sanctuary', profile: SoundProfile.templeSanctuary, title: 'Sacred Temple', imageName: 'temple-sanctuary', thumbnailImageName: 'temple-sanctuary-thumb' },
  { id: 'coastal-seagulls', profile: SoundProfile.coastalSeagulls, title: 'Coastal Seagulls', imageName: 'coastal-seagulls', previewAlignment: 'bottom', thumbnailImageName: 'coastal-seagulls-thumb' },
  { id: 'howling-wind', profile: SoundProfile.howlingWind, title: 'Howling Winter Gale', imageName: 'howling-wind', previewAlignment: 'bottom', thumbnailImageName: 'howling-wind-thumb' },

  { id: 'rain-canopy', profile: SoundProfile.rainCanopy, title: 'Rain on Leaves', imageName: 'rain-canopy', thumbnailImageName: 'rain-canopy-thumb' },
  { id: 'deep-underwater', profile: SoundProfile.deepUnderwater, title: 'Deep Underwater', imageName: 'deep-underwater', thumbnailImageName: 'deep-underwater-thumb' },
  { id: 'tropical-jungle', profile: SoundProfile.tropicalJungle, title: 'Tropical Jungle', imageName: 'tropical-jungle', thumbnailImageName: 'tropical-jungle-thumb' },
  { id: 'night-village', profile: SoundProfile.nightVillage, title: 'Quiet Mountain Village', imageName: 'night-village', thumbnailImageName: 'night-village-thumb' },
  { id: 'forest-birds', profile: SoundProfile.forestBirdsong, title: 'Morning Birds', imageName: 'forest-birds', thumbnailImageName: 'forest-birds-thumb' },
  { id: 'walk-leaves', profile: SoundProfile.walkOnLeaves, title: 'Walk on Leaves', imageName: 'walk-leaves', thumbnailImageName: 'walk-leaves-thumb' },
  { id: 'warm-cafe', profile: SoundProfile.warmCafe, title: 'Warm Coffee House', imageName: 'warm-cafe', thumbnailImageName: 'warm-cafe-thumb' },

  // Additional Serene Soundscapes
  { id: 'singing-bowl', profile: SoundProfile.singingBowl, title: 'Tibetan Singing Bowl', imageName: 'singing-bowl', thumbnailImageName: 'singing-bowl-thumb' },
  { id: 'wind-chimes', profile: SoundProfile.windChimes, title: 'Wind Chimes', imageName: 'wind-chimes', thumbnailImageName: 'wind-chimes-thumb' },
  { id: 'scenic-train', profile: SoundProfile.scenicTrain, title: 'Scenic Train', imageName: 'scenic-train', thumbnailImageName: 'scenic-train-thumb' },
  { id: 'rain-on-tent', profile: SoundProfile.rainOnTent, title: 'Rain on Tent', imageName: 'rain-on-tent', thumbnailImageName: 'rain-on-tent-thumb' },
  { id: 'ocean-whale', profile: SoundProfile.oceanWhale, title: 'Whale Song', imageName: 'ocean-whale', thumbnailImageName: 'ocean-whale-thumb' },
  { id: 'rain-on-car', profile: SoundProfile.rainOnCar, title: 'Rain on Car Window', imageName: 'rain-on-car', thumbnailImageName: 'rain-on-car-thumb' },
  { id: 'gentle-sailboat', profile: SoundProfile.gentleSailboat, title: 'Gentle Sailboat', imageName: 'gentle-sailboat', thumbnailImageName: 'gentle-sailboat-thumb' },
  { id: 'snowy-forest', profile: SoundProfile.snowyForest, title: 'Snowy Forest', imageName: 'snowy-forest', thumbnailImageName: 'snowy-forest-thumb' },
  { id: 'antique-clock', profile: SoundProfile.antiqueClock, title: 'Antique Clock', imageName: 'antique-clock', thumbnailImageName: 'antique-clock-thumb' },
  { id: 'night-owl', profile: SoundProfile.nightOwl, title: 'Night Owl', imageName: 'night-owl', thumbnailImageName: 'night-owl-thumb' },
  { id: 'rowing-boat', profile: SoundProfile.rowingBoat, title: 'Rowing Boat', imageName: 'rowing-boat', thumbnailImageName: 'rowing-boat-thumb' },
  { id: 'cathedral-chimes', profile: SoundProfile.cathedralChimes, title: 'Cathedral Chimes', imageName: 'cathedral-chimes', thumbnailImageName: 'cathedral-chimes-thumb' },
];

export function bannerFor(profile: SoundProfile): SoundBannerTheme {
  return allSoundBanners.find((b) => b.profile === profile) ?? allSoundBanners[0];
}
