# Project Guidelines & Build Instructions

## Expo Version Reference
Read the exact versioned docs at https://docs.expo.dev/versions/v57.0.0/ before writing any code.

## Xcode Build Execution Rules
1. **Continuous Build Execution**:
   - Run all `xcodebuild` commands continuously in the background without timer loops, manual sleep commands, or status polling loops.
   - Rely strictly on the system's reactive message wakeup upon task completion.

2. **Multi-Core Parallelization**:
   - Always append the `-jobs 8` flag (using all 8 Mac CPU cores) to any `xcodebuild` invocation to ensure fastest possible compilation.

## Git & GitHub Synchronization Rule
- **Continuous GitHub Sync**:
  - Always commit and push changes to GitHub (`origin main`) after completing and verifying features, bug fixes, or build updates.
  - Keep the remote repository in continuous sync with the local codebase.

