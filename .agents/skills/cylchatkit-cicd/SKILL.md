---
name: cylchatkit-cicd
description: "CYLChatKit CI/CD and test environments: GitHub CI/CD runs on macOS 26, a local run uses the user's Mac with macOS 27 and Xcode 27. Use before running a build, a simulator test, or screenshots, and when editing the workflow."
---

# CYLChatKit CI/CD and test environments

## Environments

| Where | System | Xcode |
|:---|:---|:---|
| GitHub CI/CD (`.github/workflows/ios.yml`) | macOS 26 (`macos-26`; Linux jobs: `ubuntu-latest`) | the version of the `macos-26` image |
| Local run | macOS 27 | Xcode 27 |

**Local run** means running directly on the user's own Mac, not through GitHub CI/CD: build with Xcode 27, launch the
Simulator, and test there. **GitHub CI/CD** means the workflow on GitHub's macOS 26 runners.

## Check the reference workflow first

For GitHub CI/CD, always read CYLTabBarController's workflow before you rely on or change the runner:
https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml

- It decides the environment: at the last check (CYLTabBarController `4209e37`, 2026-11-10) it used
  `runs-on: ${{ vars.MACOS_RUNNER || 'macos-26' }}`, i.e. macOS 26 with Apple Silicon and the default Xcode 26.x, and named
  `xcode-27` as the `MACOS_RUNNER` value for the Xcode 27 public preview. The iOS default is therefore macOS 26.
- Fetch it with `git clone --depth 1 https://github.com/ChenYilong/CYLTabBarController.git <new empty dir>` (or the
  GitHub file view) and `grep -n 'runs-on\|MACOS_RUNNER\|xcode' .github/workflows/ios.yml`. Keep this repository's
  `.github/workflows/ios.yml` and `docs/ci.md` in step with what it says.
- **Local runs are exempt:** if the user asks for a local run, skip this check. The system is macOS 27 with Xcode 27 on the
  user's Mac, and the Simulator is used directly.

## Rules

- Use the repository scripts in both environments, so they build the same thing:
  `scripts/update-cyltabbarcontroller-commit.sh` (first), then `scripts/ci-build-example.sh` and
  `scripts/demo-screenshots.sh`. For a local run, also run `pod install` in `ChatKit-OC/` (the Podfile uses
  `use_frameworks! :linkage => :static`).
- Local run commands (macOS 27, Xcode 27), from the repository root:

  ```sh
  scripts/update-cyltabbarcontroller-commit.sh
  (cd ChatKit-OC && pod install)
  scripts/ci-build-example.sh
  scripts/demo-screenshots.sh   # boots a simulator, launches the demo, writes screenshots
  ```

  Or open `ChatKit-OC/ChatKit-OC.xcworkspace` in Xcode 27 and run the `ChatKit-OC` scheme on a Simulator.
- A cloud agent session runs on Linux without Xcode: it runs only the static checks (`scripts/check-localizations.py`,
  `scripts/check-naming.py`, `scripts/check-comments.py`, `shellcheck`) and reads compile results from GitHub CI/CD. It does
  not claim a build is verified before the macOS job passed and the screenshots exist (`AGENTS.md`, "CI and demo screenshots").
- Always say which environment produced a result: "GitHub CI (macOS 26)" or "local (macOS 27, Xcode 27)". One does not prove
  the other: SDKs, Simulator runtimes, and iOS 26 / iOS 27 behavior differ.
- Keep every Liquid Glass call behind the compile-time and run-time guards so the code builds on both SDKs and on iOS 15.
  The deployment target stays iOS 15.0 everywhere.
- The workflow's macOS runner is `${{ vars.MACOS_RUNNER || 'macos-26' }}`: keep `macos-26` as the default and document any
  change of it in `docs/ci.md`.
- A push cancels the in-flight run of the same branch: wait for the macOS jobs before pushing again when you need their
  compile errors.
