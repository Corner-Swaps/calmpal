/** @type {import('ts-jest').JestConfigWithTsJest} */
module.exports = {
  preset: 'ts-jest',
  testEnvironment: 'node',
  testMatch: ['**/__tests__/**/*.test.ts'],
  moduleFileExtensions: ['ts', 'tsx', 'js', 'jsx', 'json', 'node'],
  transform: {
    '^.+\\.tsx?$': ['ts-jest', {
      tsconfig: {
        module: 'commonjs',
        target: 'es6',
        jsx: 'react-native',
        allowJs: true,
        esModuleInterop: true,
        types: ['jest', 'node'],
      }
    }]
  },
  moduleNameMapper: {
    '\\.(jpg|jpeg|png|gif|eot|otf|webp|svg|ttf|woff|woff2|mp4|webm|wav|mp3|m4a|aac|oga)$': '<rootDir>/src/__mocks__/fileMock.js',
    '^react-native$': '<rootDir>/src/__mocks__/reactNativeMock.js',
    '^expo-haptics$': '<rootDir>/src/__mocks__/expoHapticsMock.js',
    '^expo-audio$': '<rootDir>/src/__mocks__/expoAudioMock.js',
  }
};
