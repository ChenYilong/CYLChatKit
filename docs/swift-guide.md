# Using CYLChatKit from Swift

Rules: `AGENTS.md`, "Swift examples and Swift compatibility of core". This guide follows CYLTabBarController's
[Swift guide](https://github.com/ChenYilong/CYLTabBarController/blob/master/docs/Swift-Guide.md).

## Importing

Use CocoaPods with `use_frameworks!` (or `use_modular_headers!`) and `import CYLChatKit`. A mixed project without
modules can import `ChatKitHeaders.h` in its bridging header instead.

## Objective-C → Swift name map

Pattern: Objective-C prepositions (`With...`, `For...`, `At...`, `Of...`) become argument labels, enum cases lose their
type prefix (`CYLMessageMediaTypeText` → `.text`), and `cyl_` category methods keep the prefix. ⌥-click an API in Xcode,
or open a header and choose "Generated Interface", to see its Swift signature. Add a row for every API adapted for
Swift, in the same change.

| Objective-C | Swift | Adaptation in core |
|:---|:---|:---|
| `[CYLChatKit sharedInstance]` (formerly `[LCChatKit sharedInstance]`) | `CYLChatKit.sharedInstance()` | none yet; the class was renamed from `LCChatKit`, see `docs/naming.md` |
| `[[CYLConversationViewController alloc] initWithPeerId:peerId]` | `CYLConversationViewController(peerId:)` | none yet |
| `[[CYLConversationViewController alloc] initWithConversationId:conversationId]` | `CYLConversationViewController(conversationId:)` | none yet |
| `typedef enum : NSUInteger {...} CYLMessageNotificationType` | `CYLMessageNotificationType` with `.message`, `.warning`, `.error`, `.success` | changed to `NS_ENUM` (same values) |
| `CYLMessageHUDActionType`, `CYLContactListMode` | `.show` / `.hide` / `.error` / `.success`; `.normal` / `.singleSelection` / `.multipleSelection` | changed to `NS_ENUM` (same values) |
| `CYLMessageOwnerTypeSelf` | `CYLMessageOwnerType.mine` (`.self` is reserved) | `NS_SWIFT_NAME(mine)` beside the case |
| `CYLLocalizedStrings(key)` (macro) | `CYLLocalizedStringForKey(_:)` | new C function `CYLLocalizedStringForKey` in `CYLChatConstants.h/.m`, same bundle and table |
| `-configureBarButtonItemStyle:action:` | `configureBarButtonItem(style:action:)` | `NS_SWIFT_NAME` beside the declaration |
| `-setBackgroundImage:forConversationId:scaledToSize:` | `setBackgroundImage(_:forConversationId:scaledToSize:)` | `NS_SWIFT_NAME` beside the declaration |
| `-handleSingleSignOnError:callback:` | `handleSingleSignOnError(_:callback:)` | `NS_SWIFT_NAME` beside the declaration |
| `-[CYLUserSystemService getProfileForUserId:error:]` | `getProfile(forUserId:)` (throws) | `NS_SWIFT_NAME` beside the declaration (the automatic name was not found by the macOS 26 build) |
| `CYLLocalizedStringForKey` | returns `String`, not `String?` | `_Nonnull` on the new function |


## TODO

- The Swift demo (`ChatKit-OC/Example`, no Objective-C) builds and runs on GitHub CI (macOS 26) since run 42969177671
  (`00bdead`): `Build demo`, `pod lib lint`, and `Simulator screenshots` with all accessibility checks passed.
- TODO: Verify the Swift demo beyond the CI screens: login with a real LeanCloud client, sending text, voice, image and
  location messages, the conversation detail and settings screens, and a local run on macOS 27 with Xcode 27.
  Names the Swift code guessed at the importer: see the list in `docs/naming.md`-style notes below.
- TODO: `CYLConversationProtocol` and `CYLIMMessageProtocol` declare their getters as methods, so a Swift extension cannot
  make `AVIMConversation` / `AVIMTypedMessage` conform. The demo registers the protocols at runtime
  (`CYLDemoLeanCloudRuntime.registerOnce()`) and exposes `cyl_` members with `@objc(cyl_x)`. Needs a core decision:
  property declarations or underscore-free `cyl` twins per AGENTS.md. Verify that `class_addProtocol` really finds the
  protocol metadata in the binary.
- TODO: Core headers without `NS_ASSUME_NONNULL` (`CYLServiceDefinition.h`, `CYLChatConstants.h` typedefs,
  `CYLUserDelegate.h`, `CYLChatBaseViewController.h`) import as implicitly unwrapped optionals; the demo code is defensive.
  Add nullability only where the Swift demo needs it. `-cacheUsersWithIds:callback:` takes `NSSet<id<CYLUserDelegate>> *`
  but the demo passes client-id strings (`Set<AnyHashable>` conversion in the demo).
- TODO: `CYLContact` has no public `-initWithUserId:name:avatarURL:clientId:` (only the protocol requirement), and
  `CYLContactListViewController -initWithContacts:` takes `NSSet<CYLContact *> *`; the demo converts users to `CYLContact`.
- TODO: Remaining core Swift audit: string constants that should be `NS_TYPED_ENUM`, other plain C enums
  (`CYLChatScrollDirection`), and `cyl_` protocol methods that Swift classes implement (`CYLIMProvider`, model
  protocols): add underscore-free twins with `NS_SWIFT_NAME` as CYLTabBarController does.
- TODO: The demo keeps the folder and scheme name `ChatKit-OC` (CI and docs refer to it).
- TODO: Hard-coded Chinese literals were kept 1:1 in the Swift demo (contacts, login, settings, conversation detail; list in
  `docs/localization.md`), and the contact list and cells still lack accessibility labels (`docs/accessibility.md`).
- TODO: Skipped as dead during the translation (no callers): the three `NSDate` category files, the two `NSFileManager`
  category files, `CYLDemoDataSource`, `CYLDemoCustomAutoCompleteObject`, `TLSettingCell.h`, and unused macros. The
  duplicate `CYLDemoChatKitExample` and `CYLDemoContactManager` copies were deleted. Restore a member from git history
  (`git show 791899d:ChatKit-OC/...`) if a feature needs it.
