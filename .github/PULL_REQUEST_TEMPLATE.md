## Description

Please provide a summary of the changes introduced in this pull request and the relevant motivation/context.

Fixes # (issue)

## Type of Change

- [ ] 🐛 Bug fix (non-breaking change which fixes an issue)
- [ ] ✨ New feature (non-breaking change which adds functionality)
- [ ] ⚡ Performance optimization (battery, memory, or rendering efficiency)
- [ ] ♻️ Refactoring (cleanups with no functional behavior changes)
- [ ] 📝 Documentation update (README, API docs, comments)
- [ ] 🧪 Tests (adding or updating test suites)
- [ ] 🔧 Build / Chore / Dependency update

## Quality Gate Verification Checklist

Before submitting this PR, verify that each requirement is satisfied:

- [ ] `npx tsc --noEmit` passes with **0 errors**.
- [ ] `npm test` passes with all tests green.
- [ ] `npm run bundle:ios` builds the Hermes bytecode without errors (if modifying `src/`).
- [ ] Commit messages strictly follow the [Conventional Commits](https://www.conventionalcommits.org/) specification (`feat:`, `fix:`, `perf:`, etc.).
- [ ] No temporary files, `.DS_Store`, `.claude/`, or build artifacts are committed.

## Testing & Visual Verification

Describe how you tested your changes on physical hardware or simulators:
- Device(s) tested:
- Test steps executed:
- Screenshots / Screen recordings (if UI changes):
