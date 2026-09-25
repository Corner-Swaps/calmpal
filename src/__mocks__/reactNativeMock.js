module.exports = {
  Platform: {
    OS: 'ios',
    select: (obj) => obj.ios || obj.default,
  },
  Image: {
    resolveAssetSource: (source) => {
      if (typeof source === 'string') {
        return { uri: source };
      }
      if (typeof source === 'object' && source?.uri) {
        return source;
      }
      return { uri: 'test-file-stub' };
    },
  },
};
