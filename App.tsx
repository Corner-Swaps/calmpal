import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { StyleSheet, View } from 'react-native';
import { SafeAreaProvider } from 'react-native-safe-area-context';
import { GroundingScreenView } from './src/components/GroundingScreenView';

export default function App() {
  return (
    <SafeAreaProvider>
      <View style={styles.container}>
        <StatusBar style="light" hidden={false} />
        <GroundingScreenView />
      </View>
    </SafeAreaProvider>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#000000',
  },
});
