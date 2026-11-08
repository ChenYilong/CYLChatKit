---
name: cylchatkit-xcode-compat
description: "CYLChatKit Xcode and CocoaPods compatibility rules. Use when editing either Xcode project, changing deployment targets, or reviewing project build settings."
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
