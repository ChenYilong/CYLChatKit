# Continuous integration

`.github/workflows/ios.yml` runs on pushes to `master` and `claude/**`, on pull requests, and on manual dispatch.
It is modeled on CYLTabBarController's workflow; jobs that do not apply here (unit tests, Carthage) are omitted
because this repository has no test target and no Carthage support.

| Job | What it checks | Script |
|:---|:---|:---|
| Detect changes | Skips the macOS jobs for pull requests that only touch Markdown, `docs/`, or `.agents/` | inline |
| ShellCheck | Lints `scripts/*.sh` | — |
| Resolve CYLTabBarController commit | Finds the newest commit of CYLTabBarController on any branch (by commit time) once per run, passes it to the build jobs in `CYLTABBARCONTROLLER_COMMIT`, and lists it in the job summary | `scripts/update-cyltabbarcontroller-commit.sh` |
| Localization tables | Parses `.strings` files, compares key sets across languages, and checks that core and the example each define their own localization macro (at least two different macros) | `scripts/check-localizations.py` |
| Xcode projects | `objectVersion = 46`, `compatibilityVersion = "Xcode 3.2"`, no synchronized folders, every `IPHONEOS_DEPLOYMENT_TARGET` is 15.0, parsing with `xcodeproj`, `xcodebuild -list` for both projects | inline |
| pod lib lint | Compiles `CYLChatKit.podspec` with its dependencies (`--allow-warnings --skip-tests`); CYLTableViewPlaceHolder comes from the commit pinned in `ChatKit-OC/Podfile` | `scripts/pod-lint.sh` |
| Build demo | Pins CYLTabBarController, runs `pod install`, and builds `ChatKit-OC` unsigned for the iOS Simulator | `scripts/ci-build-example.sh` |
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
A screenshot taken before the app drew its first frame is black (the first launch runs under Rosetta and can be
slow), so the script retakes each screenshot while the screen is black, up to eight times four seconds apart, and fails
the job if a screenshot never gets content. The log line `<name>: screenshot taken after N retries` shows how long the
app needed. In run `26d0cef` the login and conversations screenshots needed no retries and the chat screenshot needed
four (about 16 seconds more), so the black login frame seen in run `1c8a9aa` was a slow first frame, not a layout bug.

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

## CYLTabBarController

The demo depends on CYLTabBarController as a commit: the newest commit on any branch of its repository, chosen by commit
timestamp (`AGENTS.md`, "CYLTabBarController dependency"). `scripts/update-cyltabbarcontroller-commit.sh` finds it and
rewrites the `pod 'CYLTabBarController'` line of `ChatKit-OC/Podfile`. Both build scripts call it, and CI resolves it
once per run so that all jobs build the same commit. The commit, its branch, and its time are in the summary of the job
`Resolve CYLTabBarController commit`. When the newest commit breaks the build, the failure is reported with that commit;
no older commit is pinned to hide it.

When this was set up (commit `0f9b56e`, branch `feat/cross-platform-components`, version 1.100.0, default subspec
`Core`), every CYLTabBarController symbol the demo uses was present in its headers.

## TODO

- TODO: Name clashes between core and the pinned CYLTabBarController commit, checked for `0f9b56e` (headers, types,
  macros, constants, and category selectors of the same class): (1) the header basename `CYLBadgeView.h` exists in both
  (core: `ChatKit/Class/View/CYLBadgeView.h`, a class `CYLBadgeView`; CYLTabBarController: the umbrella header of its
  `CYLBadgeView` subspec); run `26d0cef` built, linked, and ran the demo against `0f9b56e` with both headers present, so there is no
  symptom yet; if a later commit breaks the build or the module maps, rename the core class and file with the `CYLChat`
  prefix (`CYLChatBadgeView`), which is a public API change; (2) the macro `CYL_DEPRECATED` is defined identically in both, which is legal. The category method
  `+[UIImage cyl_imageNamed:]` was defined by both and is fixed: core's copy was dead code and is removed. Because the
  pinned commit moves, add a CI step that fails on new clashes (compare the headers in `ChatKit-OC/Pods/CYLTabBarController`
  with core).
- TODO: Visible in the screenshots after the launch screen fix (run for `1c8a9aa`): the status bar text (time and battery)
  is white on the white navigation bar of the conversation list and chat screens, so only part of the battery shows. Check
  the status bar style the demo's navigation controllers return, and set it for iOS 15 and later.

- TODO: Lockfiles are no longer committed, so `pod install` on CI resolves dependencies fresh within the version
  requirements of `CYLChatKit.podspec` and the Podfiles. Unpinned requirements (for example `MJRefresh`,
  `UITableView+FDTemplateLayoutCell`) can move to a newer release between runs; pin them if a run breaks for that reason.

- TODO: Without a LeanCloud session, the conversation list and chat screens show empty states only. Add a stub
  `CYLIMProvider` for screenshots if populated screens are needed.
- TODO: `ChatKit/ChatKit.xcodeproj` is only parsed and listed, not built, because it is out of sync with disk
  and its Podfile misses podspec dependencies (see leancloud-decoupling.md). `pod lib lint` is the library build check
  and passes.
