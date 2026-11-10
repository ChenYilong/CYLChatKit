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
| `[LCChatKit sharedInstance]` | `LCChatKit.sharedInstance()` | none yet |
| `[[CYLConversationViewController alloc] initWithPeerId:peerId]` | `CYLConversationViewController(peerId:)` | none yet |
| `[[CYLConversationViewController alloc] initWithConversationId:conversationId]` | `CYLConversationViewController(conversationId:)` | none yet |

## TODO

- TODO: Migrate the iOS example (`ChatKit-OC/`, Objective-C) to Swift: app delegate, LeanCloud provider
  (`ChatKit-OC/Example/Class/LeanCloud`), login, contacts, conversation detail, settings, and utilities. Keep the
  screenshot launch hooks (`-LCCKDemoScreen`, `-LCCKDemoScreenshots`) and the CI build and screenshots green after each
  step. Decide whether the migrated demo keeps the `ChatKit-OC` folder and scheme names (CI and docs refer to them).
- TODO: Audit the core public headers for Swift import quality: nullability coverage, untyped collections, string
  constants that should be `NS_TYPED_ENUM`, and enums that are plain C enums (for example `CYLChatScrollDirection`).
  Fix them in core as the Swift example needs them, and add each change to the name map above.
- TODO: Find `cyl_` protocol methods that Swift classes must implement (for example in `CYLIMProvider` and the model
  protocols `CYLConversationProtocol` and `CYLIMMessageProtocol`) and add underscore-free twins with `NS_SWIFT_NAME`
  as CYLTabBarController does; core must call the twin when it is implemented.
