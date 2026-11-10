# Continuous integration

`.github/workflows/ios.yml` runs on pushes to `master` and `claude/**`, on pull requests, and on manual dispatch.
It is modeled on CYLTabBarController's workflow; jobs that do not apply here (unit tests, Carthage) are omitted
because this repository has no test target and no Carthage support.

| Job | What it checks | Script |
|:---|:---|:---|
| Detect changes | Skips the macOS jobs for pull requests that only touch Markdown, `docs/`, or `.agents/` | inline |
| ShellCheck | Lints `scripts/*.sh` | — |
| Localization tables | Parses `.strings` files and compares key sets across languages | `scripts/check-localizations.py` |
| Xcode projects | `objectVersion = 46`, `compatibilityVersion = "Xcode 3.2"`, no synchronized folders, every `IPHONEOS_DEPLOYMENT_TARGET` is 15.0, parsing with `xcodeproj`, `xcodebuild -list` for both projects | inline |
| pod lib lint | Compiles `CYLChatKit.podspec` with its dependencies (`--allow-warnings --skip-tests`); CYLTableViewPlaceHolder comes from the commit pinned in `ChatKit-OC/Podfile.lock` | `scripts/pod-lint.sh` |
| Build demo | `pod install` and an unsigned iOS Simulator build of `ChatKit-OC` | `scripts/ci-build-example.sh` |
| Simulator screenshots | Builds, installs, and launches the demo on an iPhone simulator and takes screenshots | `scripts/demo-screenshots.sh` |

The macOS runner is `macos-26` unless the repository variable `MACOS_RUNNER` names another one.

## Screenshots

The demo needs a LeanCloud login to show real data, which CI does not have. For screenshots, `AppDelegate` reads the
launch argument `-LCCKDemoScreen` (an `NSUserDefaults` key):

- no argument: the normal login screen (`login.png`)
- `-LCCKDemoScreen conversations`: the tab bar UI without logging in (`conversations.png`)
- `-LCCKDemoScreen chat`: a conversation view with peer `Jerry` pushed on the first tab (`chat.png`)

Every launch also passes `-LCCKDemoScreenshots YES`, which skips the notification permission request and keeps the
login field from opening the keyboard, so no system overlay covers the app. When a launch crashes, the script prints
the crash report's exception and backtrace in a `Crash details` log group and the job fails.

First green run: `560d28c` (all seven jobs passed; Xcode 26.6, iPhone Air simulator, iOS 26.5). The conversation list
is empty and the chat screen shows the offline banner, because CI has no LeanCloud session.

The screenshots are uploaded as the `demo-screenshots` artifact. Each one is also printed in the job log as base64
JPEG between `===BEGIN SCREENSHOT <name>===` and `===END SCREENSHOT <name>===`.

## Screenshot requirement

Every CI run that builds code must deliver demo screenshots (see `AGENTS.md`, "CI and demo screenshots"). If a
run has none, fix CI so that it produces them and rerun; only when that is not possible, record the reason here as a
`TODO` with the failing job, step, and log excerpt.

## Running locally

```sh
scripts/pod-lint.sh
scripts/ci-build-example.sh ChatKit-OC
scripts/demo-screenshots.sh build/screenshots
```

## TODO

- TODO: `.gitignore` now follows CYLTabBarController and ignores `*.lock` and `*.xcworkspace`, but `ChatKit/Podfile.lock`, `ChatKit-OC/Podfile.lock`, and the existing workspace files are still tracked (`.gitignore` does not untrack files). CI depends on `ChatKit-OC/Podfile.lock`: `scripts/pod-lint.sh` reads the pinned CYLTableViewPlaceHolder commit from it, and `AGENTS.md` asks for lockfile updates when dependencies change. Decide whether to untrack them (then move the pinned commit into `scripts/pod-lint.sh` or read it from the Podfile, and update `AGENTS.md`) or to keep them tracked as an intended difference from CYLTabBarController.

- TODO: Without a LeanCloud session, the conversation list and chat screens show empty states only. Add a stub
  `CYLIMProvider` for screenshots if populated screens are needed.
- TODO: `ChatKit/ChatKit.xcodeproj` is only parsed and listed, not built, because it is out of sync with disk
  and its Podfile misses podspec dependencies (see leancloud-decoupling.md). `pod lib lint` is the library build check
  and passes.
