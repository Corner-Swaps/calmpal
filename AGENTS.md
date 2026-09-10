# Project Guidelines & Build Instructions

## Expo Version Reference
Read the exact versioned docs at https://docs.expo.dev/versions/v57.0.0/ before writing any code.

## Xcode Build Execution Rules
1. **Continuous Build Execution**:
   - Run all `xcodebuild` commands continuously in the background without timer loops, manual sleep commands, or status polling loops.
   - Rely strictly on the system's reactive message wakeup upon task completion.

2. **Multi-Core Parallelization**:
   - Always append the `-jobs 8` flag (using all 8 Mac CPU cores) to any `xcodebuild` invocation to ensure fastest possible compilation.

## Git & GitHub Synchronization Rules

1. **Continuous GitHub Sync**:
   - Always commit and push changes to GitHub (`origin main`) after completing and verifying features, bug fixes, or build updates.
   - Keep the remote repository in continuous sync with the local codebase.

2. **Conventional Commit Standards**:
   - Every commit message must follow the Conventional Commits specification:
     - `feat:` for new features or capabilities
     - `fix:` for bug fixes and functional corrections
     - `perf:` for performance, battery, or memory optimizations
     - `refactor:` for code cleanups with no behavior changes
     - `docs:` for README and documentation updates
     - `test:` for test additions or modifications
     - `chore:` for dependency and build configuration updates
   - Write clear, professional, imperative commit titles (e.g. `feat(audio): add smooth cross-fade duration parameter`).

3. **Pre-Push Quality Gate**:
   - Before pushing any commit to `main`, unconditionally run:
     ```bash
     npx tsc --noEmit && npm test
     ```
   - Only push if both TypeScript validation and unit tests pass with zero errors.

4. **Repository Hygiene**:
   - Never commit build artifacts (`build/`, `dist/`, `.expo/`), OS metadata (`.DS_Store`), or editor-specific config files (`.claude/`).
   - Keep the working tree completely clean after every task.

