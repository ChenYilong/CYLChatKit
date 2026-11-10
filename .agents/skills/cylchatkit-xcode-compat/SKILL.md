---
name: cylchatkit-xcode-compat
description: "CYLChatKit Xcode and CocoaPods compatibility rules, including how CYLTabBarController is pinned to its newest commit. Use when editing either Xcode project, a Podfile or podspec, changing deployment targets, or reviewing project build settings."
---

# CYLChatKit Xcode compatibility

Use this skill before creating or editing either Xcode project, changing deployment targets, or reviewing Xcode build settings. These rules are adapted from the CYLTabBarController Xcode compatibility skill; CYLChatKit's project values and targets below are authoritative for this repository.

## Project files

The repository contains two independent Xcode projects:

| Purpose | Project |
|:---|:---|
| Objective-C library | `ChatKit/ChatKit.xcodeproj` |
| Demo application | `ChatKit-OC/ChatKit-OC.xcodeproj` |

Both projects must retain:

- `objectVersion = 46;`
- `compatibilityVersion = "Xcode 3.2";`
- Explicit file references and build-phase membership; do not use synchronized-folder groups.
- No `preferredProjectObjectVersion` or top-level `validationLevel`.
- Existing target names, schemes, bundle identifiers, signing settings, and resource membership unless the task requires a specific change.

Do not save these projects with a newer Xcode if it rewrites the project format or unrelated sections.

## Deployment target consistency

iOS 15.0 is the project minimum. Set and verify every project-level and target-level Debug/Release configuration; keep all of these aligned:

- Every `IPHONEOS_DEPLOYMENT_TARGET` in both `.pbxproj` files.
- `CYLChatKit.podspec`.
- `ChatKit/Podfile`.
- `ChatKit-OC/Podfile`.

When changing the minimum, inspect affected APIs and dependencies, update every configuration surface, and explain any intentional compatibility change. Do not silently lower the minimum or leave a target below the podspec requirement.

## CYLTabBarController dependency

The demo integrates CYLTabBarController through CocoaPods as a commit, never as a version number (`AGENTS.md`,
"CYLTabBarController dependency"). The commit is the newest one on any branch of
https://github.com/ChenYilong/CYLTabBarController, chosen by commit timestamp, so it can be on a feature branch rather
than `master` or `main`.

1. Before every build, run `scripts/update-cyltabbarcontroller-commit.sh`. It fetches the tip of every branch, takes the
   newest committer timestamp, checks that the commit has `CYLTabBarController.podspec` in its root, and rewrites the
   `pod 'CYLTabBarController'` line of `ChatKit-OC/Podfile` to
   `:git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '<sha>'`. Use `--print` to look
   without rewriting. Never edit that line by hand.
2. Run it again before committing a change that touches the Podfile, and commit the line it wrote.
3. In CI, the job `Resolve CYLTabBarController commit` resolves the commit once and passes it to the build jobs in
   `CYLTABBARCONTROLLER_COMMIT`; the job summary shows the commit, branch, and time. A build script run on its own
   (without that variable) resolves the newest commit itself.
4. If this project were named CYLTabBarController, the dependency would be local instead:
   `pod 'CYLTabBarController', :path => '<relative path to the folder that holds CYLTabBarController.podspec>'`. This
   project is CYLChatKit, so it always uses the commit form.
5. If the newest commit breaks the build, report the commit, its branch, and the error. Do not pin an older commit to get
   green unless the user asks.
6. Check name clashes between core and the pinned commit (headers, types, macros, constants, and category selectors of
   the same class); see `cylchatkit-objc-naming`. Record open clashes as `TODO` in `docs/ci.md`.

Lockfiles (`Podfile.lock`) are not committed, so every dependency needs an explicit version or a `:git`/`:commit` pin.

## Project structure

- Keep all source and resource membership explicit in `PBXGroup`, `PBXFileReference`, and `PBXBuildFile` entries.
- Do not add `PBXFileSystemSynchronizedRootGroup` or `PBXFileSystemSynchronizedBuildFileExceptionSet`.
- Keep `Info.plist` out of Copy Bundle Resources when it is already processed by the build setting.
- Do not alter workspace references, shared schemes, signing, bundle identifiers, or resource membership unless the task requires it.
- If Xcode rewrites unrelated sections, retain only the intended changes and restore the required format values.

## Validation

Run these checks after Xcode or deployment-target changes:

```sh
for f in ChatKit/ChatKit.xcodeproj/project.pbxproj ChatKit-OC/ChatKit-OC.xcodeproj/project.pbxproj; do
  grep -E 'objectVersion =|compatibilityVersion =|IPHONEOS_DEPLOYMENT_TARGET =|PBXFileSystemSynchronized|preferredProjectObjectVersion|validationLevel' "$f"
done
ruby -rxcodeproj -e 'ARGV.each { |path| Xcodeproj::Project.open(path) }' \
  ChatKit/ChatKit.xcodeproj ChatKit-OC/ChatKit-OC.xcodeproj
xcodebuild -list -project ChatKit/ChatKit.xcodeproj
xcodebuild -list -project ChatKit-OC/ChatKit-OC.xcodeproj
```

Each project should parse, report its expected target and scheme, and contain only iOS 15.0 deployment targets. Also inspect the project files for forbidden format keys and synchronized-folder objects:

```sh
grep -E 'objectVersion =|compatibilityVersion =|IPHONEOS_DEPLOYMENT_TARGET =|PBXFileSystemSynchronized|preferredProjectObjectVersion|validationLevel' \
  ChatKit/ChatKit.xcodeproj/project.pbxproj \
  ChatKit-OC/ChatKit-OC.xcodeproj/project.pbxproj
```

Do not claim a successful build when `xcodebuild -list` or the project parser is the only check performed. Report known build blockers separately.
