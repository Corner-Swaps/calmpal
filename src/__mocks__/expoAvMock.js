class MockSound {
  playAsync = jest.fn().mockResolvedValue({});
  pauseAsync = jest.fn().mockResolvedValue({});
  stopAsync = jest.fn().mockResolvedValue({});
  unloadAsync = jest.fn().mockResolvedValue({});
  setVolumeAsync = jest.fn().mockResolvedValue({});
}

module.exports = {
  Audio: {
    setAudioModeAsync: jest.fn().mockResolvedValue(undefined),
    Sound: {
      createAsync: jest.fn().mockResolvedValue({
        sound: new MockSound(),
        status: { isLoaded: true, isPlaying: true },
      }),
    },
  },
};
