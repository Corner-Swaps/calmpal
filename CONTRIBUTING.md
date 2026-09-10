# Contributing to Calmpal

Thank you for contributing to Calmpal! We welcome contributions that improve audio fidelity, performance, accessibility, and user experience.

---

## 🏗️ Development Setup

1. **Clone the Repository**:
   ```bash
   git clone https://github.com/Corner-Swaps/calmpal.git
   cd calmpal
   ```

2. **Install Dependencies**:
   ```bash
   npm install
   ```

3. **Verify Local Environment**:
   ```bash
   npx tsc --noEmit
   npm test
   npm run bundle:ios
   ```

---

## 🌿 Branching & Workflow

- **Target Branch**: All pull requests must target the `main` branch.
- **Legacy Branch Protection**: The `legacy-swift` branch holds the historical native Swift implementation. It is locked and must never be modified or merged into `main`.
- **Feature Branches**: Create descriptive branch names from `main`:
  - `feat/smooth-volume-curve`
  - `fix/bluetooth-route-drop`
  - `perf/waveform-render-efficiency`

---

## 📝 Commit Standards

We enforce the [Conventional Commits](https://www.conventionalcommits.org/) specification:

| Prefix | Description |
| :--- | :--- |
| `feat:` | A new user-facing feature or capability |
| `fix:` | A bug fix or behavioral correction |
| `perf:` | A code change that improves performance, battery life, or memory footprint |
| `refactor:` | A code change that neither fixes a bug nor adds a feature |
| `docs:` | Documentation changes only |
| `test:` | Adding missing tests or correcting existing tests |
| `chore:` | Changes to build processes, auxiliary tools, or libraries |

**Example Commit Message**:
```git
feat(audio): add exponential volume curve smoothing for ambient soundscapes
```

---

## 🚦 Pre-Push Quality Gate

Before opening a pull request or pushing to `main`, ensure that the following command succeeds with zero errors:

```bash
npx tsc --noEmit && npm test
```

If you modify files within `src/`, always verify that the Hermes bundle compiles cleanly:
```bash
npm run bundle:ios
```

---

## 📱 Hardware & Xcode Build Guidelines

- When compiling via `xcodebuild`, always run with the multi-core flag: `-jobs 8`.
- Execute build commands asynchronously in background processes without polling loops.
