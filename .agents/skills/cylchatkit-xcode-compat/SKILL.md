---
name: cylchatkit-xcode-compat
description: "CYLChatKit Xcode and CocoaPods compatibility rules. Use when editing either Xcode project, changing deployment targets, or reviewing project build settings."
---

# CYLChatKit Xcode compatibility

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
- Existing target names, schemes, bundle identifiers, signing settings, and resource membership unless the task requires a specific change.

Do not save these projects with a newer Xcode if it rewrites the project format or unrelated sections. Avoid adding `preferredProjectObjectVersion`, top-level `validationLevel`, or folder-synchronization objects.

## Deployment target consistency

iOS 15.0 is the project minimum. Keep all of these aligned:

- Every `IPHONEOS_DEPLOYMENT_TARGET` in both `.pbxproj` files.
- `ChatKit.podspec`.
- `ChatKit/Podfile`.
- `ChatKit-OC/Podfile`.

When changing the minimum, inspect affected APIs and dependencies, update every configuration surface, and explain any intentional compatibility change. Do not silently lower the minimum or leave a target below the podspec requirement.

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

Each project should parse, report the expected targets and schemes, and contain no deployment target below iOS 15.0.
