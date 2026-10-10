#!/usr/bin/env bash
set -e

REPO_ROOT="/Users/slava/Downloads/Projects/Calmpal-CrossPlatform"
ANDROID_DIR="$REPO_ROOT/android"

export JAVA_HOME="/Users/slava/.jdk/jdk-21.0.12.1+1/Contents/Home"
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/platform-tools:$PATH"

PASS_FILE="$REPO_ROOT/.keystore_password"
if [ -f "$PASS_FILE" ]; then
  export ANDROID_STORE_PASSWORD=$(cat "$PASS_FILE")
  export ANDROID_KEY_PASSWORD="$ANDROID_STORE_PASSWORD"
  export ANDROID_KEY_ALIAS="calmpal"
fi

echo "========================================================"
echo " CalmPal Android Release AAB Build Engine (Brief 06)"
echo " Package: com.calmpal.app"
echo " Version: 5.6.0 (VersionCode: 2)"
echo " Keystore: $ANDROID_DIR/app/release.keystore"
echo " Asset Pack: sound_assets"
echo "========================================================"

cd "$ANDROID_DIR"
./gradlew bundleRelease --no-daemon --stacktrace

OUTPUT_AAB="$ANDROID_DIR/app/build/outputs/bundle/release/app-release.aab"
if [ -f "$OUTPUT_AAB" ]; then
  echo "✅ AAB built successfully at $OUTPUT_AAB"
  mkdir -p "$REPO_ROOT/deliverables"
  cp "$OUTPUT_AAB" "$REPO_ROOT/deliverables/calmpal-release.aab"
  echo "📦 Copied AAB to $REPO_ROOT/deliverables/calmpal-release.aab"
  ls -lh "$REPO_ROOT/deliverables/calmpal-release.aab"
else
  echo "❌ Error: Output AAB not found at $OUTPUT_AAB"
  exit 1
fi
