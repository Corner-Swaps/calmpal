class MockAudioPlayer {
  loop = false;
  volume = 1.0;
  playing = false;

  play = jest.fn().mockImplementation(() => {
    this.playing = true;
  });
  pause = jest.fn().mockImplementation(() => {
    this.playing = false;
  });
  release = jest.fn();
  remove = jest.fn();
  setActiveForLockScreen = jest.fn();
  clearLockScreenControls = jest.fn();
  listeners = {};
  addListener = jest.fn().mockImplementation((event, cb) => {
    this.listeners[event] = cb;
    return { remove: jest.fn() };
  });
}

module.exports = {
  setAudioModeAsync: jest.fn().mockResolvedValue(undefined),
  createAudioPlayer: jest.fn().mockImplementation(() => new MockAudioPlayer()),
};
