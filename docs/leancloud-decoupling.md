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
object retained by `self`, a retain cycle; the new block does not. The podspec requirement `~> 1.2.0` resolves to the
published 1.2.0 spec (lockfiles are no longer committed).

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
- Lockfiles were checked with `cocoapods-core` 1.17.0 at the time; they are no longer committed (see `AGENTS.md`).

## CI results

CI (`docs/ci.md`, Xcode 26.6, iOS 26.5 simulator SDK) is the first real macOS build. Fixed and confirmed by
`pod lib lint` passing on the macOS runner (run for `6a077ce`):

- The iOS 7 `UITableViewRowAction` backport (`#error` for iOS 8 or later) is excluded from the pod.
- Duplicate header basenames ("Multiple commands produce ... Headers/NSBundle+CYLExtension.h"): the identical or
  subset copies of `NSString+CYLMD5`, `UIImage+CYLExtension`, and `NSBundle+CYLExtension` under
  `Module/Conversation/Tool/Categories` were removed (the two extra `NSBundle` selectors moved into
  `Tool/Categories`), and the corner-radius category became `UIImageView+CYLCornerRadius`. The `Tool/Categories`
  `UIImage` methods (with customized-bundle lookup) now always apply; before, the runtime winner was undefined.
- `CYLSendImageView.h` imports `CYLChatConstants.h` for `CYLMessageSendState`.
- `CYLPhoto.m` uses the SDWebImage 3.8 API that the podspec pins.
- `CYLTableViewPlaceHolder` is declared (`~> 1.1.0`); the demo pins its latest commit `9d1b8e7` (branch
  `claude/docs-todo-completion-xoef38`) and `scripts/pod-lint.sh` lints against the same commit. Its
  `UIView+CYLExtension.h` and `CYLScrollDirection` clashed with core, so core now uses `UIView+CYLChatExtension` and
  `CYLChatScrollDirection` (selectors unchanged; the enum was unused).
- `-[CYLConversationViewController sendMessage:mentionList:]`, declared but never implemented, forwards to the view
  model.
- `CYLConversationNavigationTitleView` casts the `id<CYLConversationProtocol>` to `NSObject *` for KVO.
- `CYLAlertController (Convenience)` no longer implements the broken, undeclared `+actionWithTitle:handler:`.
- The podspec's `ChatKit/**/*.h` glob also matched `lame.framework/Headers/lame.h`, which put `lame.h` into the
  CYLChatKit umbrella header and broke the module build in the demo app; the framework's files are now excluded from
  the pod's sources (the framework itself is still vendored).
- `lame.framework` has no arm64 simulator slice, so the podspec excludes arm64 from simulator builds.
- `LCChatKit` forwards the two `CYLUserSystemService` members it lacked (`fetchProfilesBlock`,
  `-getCachedProfileIfExists:name:avatarURL:userTye:error:`). Added after that run; the next lint confirms the
  `-Wprotocol` warning is gone.

Fixed in the demo; the `Build demo` and `Simulator screenshots` jobs pass since `560d28c` (see `docs/ci.md`):

- `+[AVIMTypedMessage lcck_messageWithLCCKMessage:]` reads `originPhotoURL.absoluteString` instead of treating
  the `NSURL` as a string (crash on outgoing images with a remote URL).
- AVOSCloud 11.5.2's direct `<netinet6/in6.h>` imports (three files), rejected by the iOS 26 SDK, are removed from the installed pod
  by the demo Podfile's `post_install`.
- The tab bar crashed before the first login (`@[ currentClientID ]` with no saved client ID); it now uses an empty list.
- `CYLChatKit` and `CYLTabBarController` 1.99.72 link together in the demo.
- `FMDB` moved from the podspec to the demo Podfile (`2.6.2`); core does not use it.
- `LCCKUser` came from the 2019 snapshot as an `AVUser` subclass whose API matched none of its callers. It is restored
  from `d110789^` as `NSObject <CYLUserDelegate>` (what `fetchProfilesBlock` returns), with an
  `-initWithUserId:name:avatorURL:` alias for the demo code that uses the misspelled name.
- The demo project did not reference the contact list module (`LCCKContactListController`, `LCCKContactCell` and its
  xib, used by the tab bar) or two group-detail controllers (`LCCKGroupConversationManagementViewController`,
  `LCCKGroupConversationMemberInfoViewController`). They are now explicit file references in the app target. The
  duplicate `Module/ContactList/Tool/LCCKContactManager` stays unreferenced; the project uses `Class/Tool/LCCKContactManager`
  (same interface).
- The demo project's restored files and cleaned references (78 files from `d110789^`, 31 dangling references,
  14 empty groups) parse with `xcodeproj` and `xcodebuild -list`.

## TODO

- TODO: Runtime checks in the demo that CI cannot do: swipe actions in the conversation list (system
  `UITableViewRowAction`), image loading and avatar corners (merged categories), full-screen image preview and
  download progress (SDWebImage 3.8 API), the empty-list placeholder (CYLTableViewPlaceHolder commit), outgoing
  image messages with a remote URL, and the not-joined path (`conversationInvalidedHandler` nil check).
- TODO: Run the demo end to end with the LeanCloud provider: log in, conversation list (unread badge, mention, draft, mute, last-message preview for every media type), send and receive text, image, voice, and location, edit, recall, failed-message resend, auto-join, removed-from-group handling, single sign-on prompt, reconnect, push registration, and badge sync. Compare the UI with the previous release. Needs LeanCloud credentials, which CI does not have.
- TODO: `ChatKit/ChatKit.xcodeproj` is out of sync with disk (83 missing references, 14 unreferenced files) and `ChatKit/Podfile` does not declare several podspec dependencies (for example `CYLDeallocBlockExecutor`, `CYLTableViewPlaceHolder`), so that project cannot build core; CI only parses and lists it. The podspec glob is the effective source list. Aligning both needs `pod install` on macOS to verify, which this environment cannot reach (CocoaPods CDN blocked).
- TODO: `lame.framework` should be replaced by an XCFramework (or built from source) so the arm64 simulator exclusion can be removed; `user_target_xcconfig` affects every app target that uses CYLChatKit, and simulator apps run as x86_64 under Rosetta on Apple silicon.
- TODO: Remove the AVOSCloud `post_install` patch, and switch CYLTableViewPlaceHolder back to a version requirement, once those projects publish fixed releases.
- TODO: Product decision: `mentionList` is never sent; the view model passes nil to keep existing behavior. The provider API supports it, but enabling it makes recipients see mention flags.
- TODO: `docs/api-reference.md` was generated from the public headers by a script that is not in the repository. When a public header changes, update the affected section by hand in the same commit, or add a generator under `scripts/` in a separate change.
- TODO: Release: every public core name changed (`LCCK*` → `CYL*`, `lcck_*` → `cyl_*`, plus `CYLChat*` exceptions including `UIView+CYLChatExtension`, `UIImageView+CYLCornerRadius`, `CYLChatScrollDirection`), and apps that extend the facade services or call the moved LeanCloud categories must copy `ChatKit-OC/Example/Class/LeanCloud` and add `AVOSCloud`, `AVOSCloudIM`, and `FMDB`. Ship it as a major version with the migration table from `docs/api-reference.md`.
