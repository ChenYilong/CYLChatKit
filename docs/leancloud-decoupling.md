# LeanCloud decoupling

## Summary

ChatKit (`CYLChatKit.podspec`) no longer depends on LeanCloud. The `AVOSCloud` and
`AVOSCloudIM` dependencies were removed from the podspec, and every LeanCloud-specific
class, category, and call moved to the demo app (`ChatKit-OC/Example/Class/LeanCloud`).
The UI layer now talks to the IM backend only through protocols, so another IM SDK can be
plugged in without changing ChatKit. The UI is meant to look and behave exactly as before.

The full public API, the old → new migration tables, and the rename assessment are in
[api-reference.md](api-reference.md).

## Naming

Core (`ChatKit/`) uses the `CYL` prefix, following the CYLTabBarController naming rules
(its `AGENTS.md`, "Naming: keep the project's prefixes"):

- Every class, protocol, typedef, enum, constant, and C function starts with `CYL`; files are named after their main type.
- Every category method and property starts with `cyl_`; a category property's setter is `setCyl_name:`
  (`cyl_senderId` / `setCyl_senderId:`, `cyl_draft` / `setCyl_draft:`).
- Enum cases are the type name plus the case, declared with `NS_ENUM`, without a `k` prefix
  (`CYLMessageMediaTypeText`, `CYLIMErrorCodeConnectionLost`), like `CYLBadgeStyleRedDot`.
- `Delegate` is reserved for delegates. Model protocols use `Protocol` (`CYLConversationProtocol`,
  `CYLIMMessageProtocol`); role protocols use a role noun (`CYLIMProvider`, `CYLIMSessionProvider`).
- `LCChatKit` (the facade class) and `ChatKitHeaders.h` keep their names; they do not contain `LCCK`.

### Prefix rename (LCCK → CYL)

All of core was renamed mechanically: `LCCK` → `CYL`, `lcck_` → `cyl_`, `Lcck_` → `Cyl_` (setters of
`lcck_` properties, so they still match their getters), `AVOS` → `CYL`, and `AVIM` → `CYLIM` (lower-case `avim` → `cylim`). File, folder, resource bundle,
image, and xib names were renamed the same way, so string lookups (bundle names, image names, nib names)
still match. No `LCCK`, `lcck_`, `Lcck_`, `AVOS`, or `AVIM` (in any letter case) is left under `ChatKit/`.

`AVIM` → `CYLIM` renamed four compatibility names: `-alertAVIMError:` → `-alertCYLIMError:`,
`-filterAVIMError:` → `-filterCYLIMError:`, `+cyl_messagesWithAVIMMessages:` → `+cyl_messagesWithCYLIMMessages:`,
and `kAVIMMessageMediaTypeSystem` → `kCYLIMMessageMediaTypeSystem`; the view model property `avimTypedMessage` became
`cylimTypedMessage`. Comments that named LeanCloud SDK types (client, typed message, signature, member role) now
describe them in words, because `CYLIMClient` and similar names do not exist.

A purely mechanical rename would not build, because core links `CYLDeallocBlockExecutor` and the demo links
`CYLTabBarController`, which already define some of the resulting names. These were resolved first:

| Conflict after a plain rename | Resolution |
|:---|:---|
| Core's vendored `LCCKDeallocBlockExecutor` would become a second `CYLDeallocExecutor` class (duplicate symbol), with the same headers and `-[NSObject cyl_executeAtDealloc:]` as the `CYLDeallocBlockExecutor` pod core already depends on | Deleted the vendored copy; its single user (`UIImageView+CYLExtension.m`) now uses the pod's `cyl_executeAtDealloc:`. |
| `CYLBaseViewController`, `CYLBaseNavigationController`, `CYLBaseTableViewController` exist in CYLTabBarController (duplicate symbols in the demo) | Named `CYLChatBaseViewController`, `CYLChatBaseNavigationController`, `CYLChatBaseTableViewController`. |
| `CYLConstants.h` exists in CYLTabBarController (ambiguous quoted imports in apps using both pods) | Named `CYLChatConstants.h`. |
| `+[UIImage cyl_imageNamed:]` exists in CYLTabBarController (category method replaced at runtime) | ChatKit's `+lcck_imageNamed:` was declared but never implemented or used; the declaration was removed. |
| `CYL_DEPRECATED` is defined by both | No change needed: both definitions are identical, which is a legal redefinition. |
| `ChatKit/LCChatKit.{h,m}`, a stale 2016 copy and the only `AVOS` code | Deleted (it was excluded from the podspec and not in the Xcode project). |

Pre-existing build blocker fixed: core calls `-cyl_willDeallocWithSelfCallback:` (10 call sites, already at
`b730b8d`), but the podspec pinned `CYLDeallocBlockExecutor ~> 1.1.2`, which only declares
`-cyl_executeAtDealloc:`. Under ARC that is a compile error. The dependency is now `~> 1.2.0` (the first version
with that method; `cyl_executeAtDealloc:` still exists there but is deprecated), and the former vendored-copy user
now calls `-cyl_willDeallocWithSelfCallback:` with its `owner` argument. The old block captured `self` inside an
object retained by `self`, a retain cycle; the new block does not. The demo lockfile pins 1.2.0 with the checksum of
the published spec (`1f8e904d…`, from `CocoaPods/Specs`; the same method reproduces the old 1.1.2 checksum).

Runtime string values that contained `LCCK` changed too, because the rename covers string literals:

- Notification names, `userInfo` keys, error domains, and cell identifiers (for example
  `CYLNotificationMessageReceived`). Code that uses the constants is unaffected; code that hard-codes the old
  strings must be updated.
- Persisted keys: the chat background settings (`CYLDefaultConversationViewControllerBackgroundImageName` and
  `CYLCustomConversationViewControllerBackgroundImageNamePrefix`). After upgrading, a user's saved chat background
  falls back to the default once.

The demo (`ChatKit-OC/`) is not core. It keeps the `LCCK` prefix for its own classes and methods
(`LCCKLeanCloudIMProvider`, `LCCKUser`, `lcck_setObject:forKey:`, and so on) and uses the renamed core API.
The demo still has its own `LCCKContactListMode` enum and `LCCKContactCell`; previously they had the same
names as core types, which are now `CYLContactListMode` and `CYLContactCell`.

## Architecture

```
App ──registers──▶ [LCChatKit sharedInstance].IMProvider : id<CYLIMProvider>
                                   ▲
ChatKit UI (view controllers,      │ protocol calls only
view models, cells)  ──▶ facade services (CYLSessionService,
                         CYLConversationService, CYLConversationListService,
                         CYLSettingService)
                                   │
Demo: LCCKLeanCloudIMProvider ─────┘ forwards to LCCKLeanCloudSessionService and
                                     LCCKLeanCloudConversationService (AVIMClient,
                                     AVIMConversation, SQLite caches)
```

- The facade services keep their class names, singletons, UI state (current conversation,
  hooks, reconnect HUD, single sign-on alert) and public methods. IM work is forwarded to
  `-[LCChatKit IMProvider]`.
- The provider is stored on the `LCChatKit` singleton, which is not reset by
  `+[CYLSingleton destroyAllInstance]`, so it survives closing a session. The demo services
  are `CYLSingleton` subclasses and are reset with ChatKit's own services, as before.
- Register the provider before calling `+[LCChatKit setAppId:appKey:]`:

  ```objc
  [LCChatKit sharedInstance].IMProvider = [[LCCKLeanCloudIMProvider alloc] init];
  [LCChatKit setAppId:appId appKey:appKey];
  ```

## New public API (ChatKit)

| Symbol | File | Purpose |
|:---|:---|:---|
| `CYLIMProvider` (composed of `CYLIMSessionProvider`, `CYLIMConversationProvider`, `CYLIMMessageProvider`, `CYLIMRecentConversationProvider`, `CYLIMFailedMessageProvider`, `CYLIMPushProvider`) | `ChatKit/Class/Tool/Service/CYLIMProvider.h` | Everything ChatKit needs from an IM backend, including the notification contract the provider must follow. |
| `CYLConversationProtocol` | `ChatKit/Class/Model/CYLConversationProtocol.h` | Conversation model used by the UI. `AVIMConversation` conforms through the demo category. |
| `CYLIMMessageProtocol` | `ChatKit/Class/Model/CYLIMMessageProtocol.h` | Opaque IM SDK message (custom messages and raw messages kept for paging, editing, recalling). `AVIMTypedMessage` conforms through the demo category. |
| `CYLMessageMediaType` (`CYLMessageMediaTypeText`, …) | `CYLConstants.h` | ChatKit-owned media type: `NS_ENUM(int8_t, …)` with the same raw values as `AVIMMessageMediaType`. |
| `CYLIMErrorCode` (`CYLIMErrorCodeConnectionLost`) | `CYLConstants.h` | Same value (9001) as LeanCloud's `AVIMErrorCodeConnectionLost`. |
| `-[LCChatKit IMProvider]` | `LCChatKit.h` | Provider registration. |
| `-[CYLSessionService isClientOpened]`, `-handleSingleSignOnError:callback:` | `CYLSessionService.h` | Replace `client.status` checks; providers call the latter for session conflicts. |
| `-[CYLConversationService sendMessage:conversation:mentionList:progressBlock:callback:]` | `CYLConversationService.h` | Provider-neutral send. |

Model protocols declare methods instead of properties so that SDK classes can conform through
categories without property attribute conflicts. This was checked with clang against the exact
LeanCloud SDK 11.5.2 declarations (`-Wprotocol -Wmethod-signatures -Wincompatible-pointer-types`):
no warnings.

## Moved to the demo (`ChatKit-OC/Example/Class/LeanCloud`)

| From ChatKit | To the demo |
|:---|:---|
| `AVIMConversation+CYLExtension` | Same name; now conforms to `CYLConversationProtocol`, adds `cyl_unreadCount` and `cyl_mentioned`. |
| `AVIMTypedMessage+CYLExtension` | Same name; now conforms to `CYLIMMessageProtocol`. Declares the SDK's private `_typeDict` itself (it was declared in `CYLConstants.h`). |
| `AVIMMessage+CYLExtension`, `AVIMEmotionMessage` | Same names. |
| `+[CYLMessage messageWithAVIMTypedMessage:]` | `CYLMessage+CYLExtension` (same selector). |
| `+[CYLCommonUtils getPathFromFile:]`, `+isCacheDataAvailableForFile:` | `CYLCommonUtils+CYLExtension` (same selectors). |
| LeanCloud parts of `CYLSessionService` | `LCCKLeanCloudSessionService`. |
| LeanCloud parts of `CYLConversationService` and `CYLConversationListService` (SQLite stores included) | `LCCKLeanCloudConversationService`. |
| LeanCloud push and badge code of `CYLSettingService` | `LCCKLeanCloudIMProvider`. |
| `-[CYLConversationService sendMessage:conversation:options:progressBlock:callback:]` | `-[LCCKLeanCloudConversationService sendMessage:conversation:options:mentionList:progressBlock:callback:]`. |

Removed:

- `AVIMConversation+LCCKAddition`: it redefined `cyl_lastMessage`, `cyl_type`, and other methods
  of `AVIMConversation+CYLExtension`, so the method used at runtime was undefined. Its
  `cyl_unreadCount`/`cyl_mentioned` were never set; the demo category now derives them from
  `unreadMessagesCount`/`unreadMessagesMentioned`, which is what the conversation list already showed.
  `+lcck_groupConversaionDefaultNameForUserIds:` had no callers.
- `AVIMTypedMessage+LCCKExtention` (`+llck_messageWithLCCKMessage:`): it read the nonexistent
  `CYLMessage.messageMediaType` property, so it never compiled.
- The podspec now excludes the stale 2016 copy `ChatKit/LCChatKit.{h,m}`, which duplicated the
  `LCChatKit` class of `ChatKit/Class/LCChatKit.{h,m}` and referenced LeanCloud.

## API compatibility

Source-breaking changes for apps that used LeanCloud types through ChatKit:

- Block and method signatures now use `id<CYLConversationProtocol>` instead of `AVIMConversation *`
  (`CYLConversationResultBlock`, `CYLFetchConversationHandler`, conversation list blocks and delegate,
  `-getConversationIfExists`, `currentConversation`, `insertRecentConversation:`).
- `CYLFilterMessagesBlock` and `CYLSendMessageHookBlock` receive `id<CYLIMMessageProtocol>` messages;
  with the LeanCloud provider these are still `AVIMTypedMessage` objects.
- `sendCustomMessage:` takes `id<CYLIMMessageProtocol>`; `AVIMTypedMessage` subclasses still work.
- `setMemberInfoChangedBlock:` passes `NSUInteger role` (the `AVIMConversationMemberRole` value).
- `CYLGenerateSignatureCompletionHandler` takes `id signature` (an `AVIMSignature` for LeanCloud).
- `client` properties are `id` (an `AVIMClient` for LeanCloud). `CYLMessage.message` is `id`.
- `CYLMessageDelegate.mediaType` and `+[CYLChatMessageCell classMediaType]` use `CYLMessageMediaType`.
  The raw values are unchanged, so behavior is the same, but a custom cell that still declares
  `+ (AVIMMessageMediaType)classMediaType` gets a `-Wmismatched-return-types` warning (not an error).
  Change its return type to `CYLMessageMediaType`; `kAVIMMessageMediaType*` return values still work.
  (Checked with clang: the warning appears whether `CYLMessageMediaType` is an `NS_ENUM` or a plain
  `int8_t` typedef, so the type-safe `NS_ENUM` was chosen.)
- `ChatKitHeaders.h` no longer imports `AVOSCloud`/`AVOSCloudIM`; app files using LeanCloud must import them.

Renamed from compatibility names (see Prefix rename): `kCYLIMMessageMediaTypeSystem`, `alertCYLIMError:`/`filterCYLIMError:`,
`cyl_messagesWithCYLIMMessages:`, and `CYLConversationViewModel.cylimTypedMessage` (provider messages).

## Behavior notes

- Custom message cells are chosen by the registered cell class for the media type; previously ChatKit
  read the LeanCloud SDK's subclass registry. Unregistered custom types still fall back to the text cell.
- The image cell downloads attachments through the provider (`AVFile` for LeanCloud). Providers that do
  not implement `downloadAttachmentOfMessage:completion:` fall back to downloading `originPhotoURL`.
- `-[CYLConversationViewModel messageUpdated:]` compared the loop index with the array pointer
  (`i < self.dataArray`); it now uses `self.dataArray.count`, preventing out-of-bounds access.
- Nil guards were added where a nil SDK result would have been inserted into an array
  (recalled message, invalid queried messages).

## Verification

Done in a Linux container without Xcode or an iOS SDK:

- `grep -i` finds no `LCCK`, `lcck_`, `AVOS`, `AVIM`, or `AVFile` anywhere under `ChatKit/` (code, comments, or paths).
- clang `-fsyntax-only` on the protocol headers with stub Foundation/UIKit: no errors with `-Wall -Wnullability-completeness`.
- clang conformance check of `AVIMConversation`/`AVIMTypedMessage` (exact SDK 11.5.2 declarations) plus the demo categories: no warnings.
- clang with auto-generated UIKit stubs on the rewritten core files: no errors in provider or protocol code. This found three files that had relied on `LCChatKit.h` arriving through the removed `AVIMConversation+CYLExtension.h` import; they now import it directly.
- A selector-level script confirmed every provider call in core is declared, `LCCKLeanCloudIMProvider` implements all 36 required selectors, every forwarded selector exists in the demo services, and the SDK classes plus categories satisfy both model protocols.
- Both `.pbxproj` files parse with `xcodeproj` 1.28.1, keep `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"`, and contain no synchronized groups or newer keys.
- Lockfiles: checksums computed with `cocoapods-core` 1.17.0 (the lockfiles' version); `Lockfile#detect_changes_with_podfile` reports no drift for either project.

## TODO

- TODO: Build `ChatKit/ChatKit.xcodeproj` and the CocoaPods library target on macOS with Xcode. No compiler with an iOS SDK was available, and the stub-based clang checks cannot catch UIKit typing errors.
- TODO: Run `pod install` in `ChatKit/` and `ChatKit-OC/` on macOS. The CocoaPods CDN redirects to `cdn.jsdelivr.net`, which this environment blocks, so the lockfiles were edited by hand with CocoaPods-computed checksums. `pod install` regenerates `Pods/` and the `[CP]` build phases; review that it changes nothing else.
- TODO: Run the demo end to end with the LeanCloud provider: log in, conversation list (unread badge, mention, draft, mute, last-message preview for every media type), send and receive text, image, voice, and location, edit, recall, failed-message resend, auto-join, removed-from-group handling, single sign-on prompt, reconnect, push registration, and badge sync. Compare the UI with the previous release.
- TODO: Pre-existing demo project damage was repaired statically: 78 files deleted in `d110789` were restored (ConversationDetail, Utilities, `LCCKContactManager`, `LCCKExampleConstants.h`, the shared scheme, entitlements, assets), 31 dangling references (Redpacket, VCard, docs) and 14 empty groups were removed from `ChatKit-OC.xcodeproj`, and non-source files left the Sources phase. Confirm with the CI demo build (docs/ci.md) that the demo compiles and links.
- TODO: CI (docs/ci.md) is the first real macOS build of the library and the demo. Record its result here, and fix every compile error it reports before calling the rename verified.
- TODO: First CI run (Xcode 26.6): the only compile error was the pre-existing iOS 7 `UITableViewRowAction` backport (`#error` for deployment targets of iOS 8 or later). The podspec now excludes it; confirm that swipe actions in the conversation list still work with the system class.
- TODO: CI found `CYLPhoto.m` (photo browser) written against the SDWebImage 4 API while the podspec pins `~> 3.8.0`. It now uses the 3.8 API (`diskImageExistsWithKey:`, two-argument progress block). Verify full-screen image preview and download progress in the demo; upgrading SDWebImage is a separate dependency change.
- TODO: CI warns that `LCChatKit` does not implement every `CYLUserSystemService` requirement (-Wprotocol). Identify the missing selectors and forward them, since calling one would crash.
- TODO: CI found two pre-existing gaps: core imports `CYLTableViewPlaceHolder` but the podspec never declared it (now `~> 1.1.0` in the podspec; the demo Podfile pins the latest commit `9d1b8e7` of branch `claude/docs-todo-completion-xoef38` with `:git`/`:commit`, and `scripts/pod-lint.sh` lints against the same commit), and `-[CYLConversationViewController sendMessage:mentionList:]` was declared but never implemented (now forwards to the view model). Both pods shipped a `UIView+CYLExtension.h`, so the placeholder pod compiled against the core header and failed; core renamed its file and category to `UIView+CYLChatExtension` (selectors unchanged). Verify the empty-list placeholder in the demo. When CYLTableViewPlaceHolder publishes a release that contains this commit, switch the Podfile back to a version requirement.
- TODO: The CYLTableViewPlaceHolder commit also defines `CYLScrollDirection` (in its `UIScrollView+CYLExtension.h`), which clashed with the unused core enum of the same name in `CYLChatConstants.h`. The core enum and its cases are now `CYLChatScrollDirection*`. `CYLConversationNavigationTitleView` now casts the `id<CYLConversationProtocol>` to `NSObject *` for KVO; providers must return `NSObject` subclasses that are KVO compliant for `muted`, `name`, and `members`.
- TODO: Pre-existing: `CYLAlertController (Convenience)` implemented an undeclared `+actionWithTitle:handler:` that called the `CYLAlertAction` initializer on the controller class and no longer compiles. It was removed; `+[CYLAlertAction actionWithTitle:handler:]` (declared in the header) is unchanged.
- TODO: `lame.framework` (voice messages) is a fat binary without an arm64 simulator slice, so the podspec now excludes arm64 from simulator builds (`pod_target_xcconfig` and `user_target_xcconfig`). Apps then run in the simulator as x86_64 under Rosetta on Apple silicon. Replace lame with an XCFramework (or build it from source) and remove the exclusion; `user_target_xcconfig` affects every app target that uses CYLChatKit.
- TODO: The demo Podfile downgrades AVOSCloud 11.5.2's `private-header` error (`<netinet6/in6.h>`) to a warning. Revisit when the LeanCloud SDK is upgraded.
- TODO: Fixed while preparing CI: `CYLConversationViewController` called the optional `conversationInvalidedHandler` block without a nil check. Verify the not-joined path in the demo.
- TODO: Pre-existing: `ChatKit.xcodeproj` is out of sync with disk (83 missing references, 14 unreferenced files). The podspec glob is the effective source list.
- TODO: Pre-existing: `mentionList` is never sent; the view model passes nil to keep existing behavior. The provider API now supports it. Decide whether to enable it, because recipients would start seeing mention flags.
- TODO: Pre-existing: `+[AVIMTypedMessage lcck_messageWithLCCKMessage:]` assigns `originPhotoURL` (an `NSURL`) to an `NSString` and calls `hasPrefix:` on it, which crashes when an outgoing image message has a remote URL.
- TODO: Duplicate header basenames broke the CI build ("Multiple commands produce ... Headers/NSBundle+CYLExtension.h"). Fixed: the identical or subset copies of `NSString+CYLMD5`, `UIImage+CYLExtension`, and `NSBundle+CYLExtension` under `Module/Conversation/Tool/Categories` were removed (the two extra `NSBundle` selectors moved into `Tool/Categories`), and the corner-radius `UIImageView` category became `UIImageView+CYLCornerRadius`. Previously the runtime winner between duplicate `UIImage` category methods was undefined; now the `Tool/Categories` versions (with customized-bundle lookup) always apply. Verify image loading and avatar corners in the demo. Apps importing the old corner-radius header by name must import `UIImageView+CYLCornerRadius.h`.
- TODO: `FMDB` is no longer used by ChatKit itself, only by the demo provider's SQLite caches through the pod's transitive dependency. Moving it to the demo Podfile is a separate dependency change.
- TODO: `docs/api-reference.md` was generated from the public headers by a script that is not in the repository. When a public header changes, update the affected section by hand in the same commit, or add a generator under `scripts/` in a separate change. Its rename score (100/100) covers names only; the Xcode build below is still required before calling the rename verified.
- TODO: Prefix rename: every public core name changed (`LCCK*` → `CYL*`, `lcck_*` → `cyl_*`), so every app using ChatKit must update. Ship it as a major version with a migration table (old → new), and call out the `CYLChat*` exceptions and the changed notification and persisted-key strings.
- TODO: Verify on macOS that `CYLChatKit` and `CYLTabBarController` 1.99.72 link together in the demo (no duplicate classes; static checks found none, apart from the identical `CYL_DEPRECATED` macro) and that the `CYLDeallocBlockExecutor` 1.2.0 upgrade builds.
- TODO: Pre-existing: `ChatKit/Podfile` (library Xcode project) does not declare several podspec dependencies such as `CYLDeallocBlockExecutor`, so `ChatKit.xcodeproj` alone cannot build core. Align it with the podspec in a separate change.
- TODO: API risk: apps that subclass or extend the facade services, or call the moved LeanCloud categories, must copy `ChatKit-OC/Example/Class/LeanCloud` and add `AVOSCloud`/`AVOSCloudIM`. Consider a major version bump and a migration note in the release.
