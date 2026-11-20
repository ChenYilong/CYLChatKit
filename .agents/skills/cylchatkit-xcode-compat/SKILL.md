---
name: cylchatkit-xcode-compat
description: "CYLChatKit Xcode and CocoaPods compatibility rules, including how CYLTabBarController is pinned to its newest commit and integrated by default in examples (PlusButton with a plus child, from a local configuration file). Use when editing either Xcode project, a Podfile or podspec, changing deployment targets, or reviewing project build settings."
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

## SDK and OS guards for Liquid Glass

The deployment target is iOS 15.0 and CI builds with the newest Xcode, so any API newer than iOS 15, above all the iOS 26
Liquid Glass material (`UIGlassEffect`), needs both guards (`AGENTS.md`, "Guard every Liquid Glass API"):

```objc
#if defined(__IPHONE_26_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_26_0
    if (@available(iOS 26.0, *)) {
        // iOS 26 API here
    }
#endif
```

- The compile-time check keeps the library building with an older Xcode; the run-time check keeps it working on an older
  system. Neither is enough alone.
- Put the iOS 26 code in `CYLChatLiquidGlass` (`ChatKit/Class/Tool/CYLChatLiquidGlass.{h,m}`). Its `+isActive` also returns
  NO when the app sets `UIDesignRequiresCompatibility` on iOS 26, which is the app's opt-out of Liquid Glass. Other
  files call it and keep their old styling when it answers NO or nil.
- Check that a change leaves the old look untouched: with the guards false, the code path must be the one that existed
  before. Verify with the CI screenshots, and with `UIDesignRequiresCompatibility` set when you can.

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

## Default CYLTabBarController integration in examples

Unless a task says otherwise, every example integrates CYLTabBarController (pinned commit, CocoaPods) like this:

1. **PlusButton with a plus child.** A PlusButton whose selection shows its own page (`plusChildViewController`), not only
   an action. Configuration: `CYLTabBarControllerPlusButton` with `CYLTabBarItemTitle`, `CYLTabBarItemImage`, and
   `CYLTabBarItemPageIdentifier`. Code equivalent: `+plusChildViewController` plus `+indexOfPlusButtonInTabBar`.
2. **Local configuration file.** Build the tab bar from a bundled file (JSON by default) with
   `+[CYLTabBarController tabBarControllerWithConfigurationFile:error:]` (Swift: `try CYLTabBarController(configurationFile:)`), not with `tabBarItemsAttributes` and view
   controller arrays in code. Every tab and the plus button name their page with `CYLTabBarItemPageIdentifier`; register the
   pages with `CYLTabBarPageRegistry` before the file is loaded. A tab whose page is not registered is skipped, so check
   the registry when a tab is missing.
3. Minimal file shape (keys from CYLTabBarController's `docs/Configuration-File.md`):

   ```json
   {
     "CYLTabBarControllerContext": "Demo",
     "CYLTabBarControllerStyleType": "liquidGlass",
     "CYLTabBarControllerTabBarItemsAttributes": [
       { "CYLTabBarItemTitle": "Messages", "CYLTabBarItemImage": "tab_chat", "CYLTabBarItemPageIdentifier": "conversations" },
       { "CYLTabBarItemTitle": "Contacts", "CYLTabBarItemImage": "tab_contacts", "CYLTabBarItemPageIdentifier": "contacts" }
     ],
     "CYLTabBarControllerPlusButton": {
       "CYLTabBarItemTitle": "New", "CYLTabBarItemImage": "tab_plus", "CYLTabBarItemPageIdentifier": "compose"
     }
   }
   ```

4. Read the pinned commit's `docs/Configuration-File.md`, `docs/Tab-Page-Registry.md`, and `docs/PlusButton.md` before
   writing the code; if an API name differs, the library wins and this skill is updated.
5. Localize the titles (example bundle), give the PlusButton an accessibility label and identifier, and take a CI
   screenshot of the plus child page.
