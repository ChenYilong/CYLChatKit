# Continuous integration

`.github/workflows/ios.yml` runs on pushes to `master` and `claude/**`, on pull requests, and on manual dispatch.
It is modeled on CYLTabBarController's workflow; jobs that do not apply here (unit tests, Carthage) are omitted
because this repository has no test target and no Carthage support.

| Job | What it checks | Script |
|:---|:---|:---|
| Detect changes | Skips the macOS jobs for pull requests that only touch Markdown, `docs/`, or `.agents/` | inline |
| ShellCheck | Lints `scripts/*.sh` | — |
| Xcode projects | `objectVersion = 46`, `compatibilityVersion = "Xcode 3.2"`, no synchronized folders, every `IPHONEOS_DEPLOYMENT_TARGET` is 15.0, parsing with `xcodeproj`, `xcodebuild -list` for both projects | inline |
| pod lib lint | Compiles `CYLChatKit.podspec` with its dependencies (`--allow-warnings --skip-tests`) | `scripts/pod-lint.sh` |
| Build demo | `pod install` and an unsigned iOS Simulator build of `ChatKit-OC` | `scripts/ci-build-example.sh` |
| Simulator screenshots | Builds, installs, and launches the demo on an iPhone simulator and takes screenshots | `scripts/demo-screenshots.sh` |

The macOS runner is `macos-26` unless the repository variable `MACOS_RUNNER` names another one.

## Screenshots

The demo needs a LeanCloud login to show real data, which CI does not have. For screenshots, `AppDelegate` reads the
launch argument `-LCCKDemoScreen` (an `NSUserDefaults` key):

- no argument: the normal login screen (`login.png`)
- `-LCCKDemoScreen conversations`: the tab bar UI without logging in (`conversations.png`)
- `-LCCKDemoScreen chat`: a conversation view with peer `Jerry` pushed on the first tab (`chat.png`)

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

- TODO: Without a LeanCloud session, the conversation list and chat screens show empty states only. Add a stub
  `CYLIMProvider` for screenshots if populated screens are needed.
- TODO: `ChatKit/ChatKit.xcodeproj` is only parsed and listed, not built, because it is out of sync with disk
  (see leancloud-decoupling.md). `pod lib lint` is the library build check.
