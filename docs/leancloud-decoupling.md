# LeanCloud decoupling

## Summary

ChatKit (`CYLChatKit.podspec`) no longer depends on LeanCloud. The `AVOSCloud` and
`AVOSCloudIM` dependencies were removed from the podspec, and every LeanCloud-specific
class, category, and call moved to the demo app (`ChatKit-OC/Example/Class/LeanCloud`).
The UI layer now talks to the IM backend only through protocols, so another IM SDK can be
plugged in without changing ChatKit. The UI is meant to look and behave exactly as before.

## Naming

New symbols follow the CYLTabBarController naming rules (its `AGENTS.md`, "Naming: keep the project's
prefixes"), applied with this repository's prefix `LCCK` as CYLChatKit's `AGENTS.md` requires:

- Every new class, protocol, typedef, enum, and constant starts with `LCCK`; files are named after their main type.
- Enum cases are the type name plus the case, declared with `NS_ENUM`, without a `k` prefix
  (`LCCKMessageMediaTypeText`, `LCCKIMErrorCodeConnectionLost`), like `CYLBadgeStyleRedDot`.
- `Delegate` is reserved for delegates. Protocols describing a model use `Protocol`
  (`LCCKConversationProtocol`, `LCCKIMMessageProtocol`, like `CYLBadgeProtocol`); role protocols use a role noun
  (`LCCKIMProvider`, `LCCKIMSessionProvider`, like `CYLTabBarItemAnimationService`).
- Every new category method and property starts with `lcck_`; a category property's setter is
  `setLcck_name:` (`lcck_senderId` / `setLcck_senderId:`, like the existing `lcck_draft` / `setLcck_draft:`).
- Names of already shipped APIs are kept (`+messageWithAVIMTypedMessage:`, `lcck_messagesWithAVIMMessages:`,
  `alertAVIMError:`, `kAVIMMessageMediaTypeSystem`).

## Architecture

```
App ──registers──▶ [LCChatKit sharedInstance].IMProvider : id<LCCKIMProvider>
                                   ▲
ChatKit UI (view controllers,      │ protocol calls only
view models, cells)  ──▶ facade services (LCCKSessionService,
                         LCCKConversationService, LCCKConversationListService,
                         LCCKSettingService)
                                   │
Demo: LCCKLeanCloudIMProvider ─────┘ forwards to LCCKLeanCloudSessionService and
                                     LCCKLeanCloudConversationService (AVIMClient,
                                     AVIMConversation, SQLite caches)
```

- The facade services keep their class names, singletons, UI state (current conversation,
  hooks, reconnect HUD, single sign-on alert) and public methods. IM work is forwarded to
  `-[LCChatKit IMProvider]`.
- The provider is stored on the `LCChatKit` singleton, which is not reset by
  `+[LCCKSingleton destroyAllInstance]`, so it survives closing a session. The demo services
  are `LCCKSingleton` subclasses and are reset with ChatKit's own services, as before.
- Register the provider before calling `+[LCChatKit setAppId:appKey:]`:

  ```objc
  [LCChatKit sharedInstance].IMProvider = [[LCCKLeanCloudIMProvider alloc] init];
  [LCChatKit setAppId:appId appKey:appKey];
  ```

## New public API (ChatKit)

| Symbol | File | Purpose |
|:---|:---|:---|
| `LCCKIMProvider` (composed of `LCCKIMSessionProvider`, `LCCKIMConversationProvider`, `LCCKIMMessageProvider`, `LCCKIMRecentConversationProvider`, `LCCKIMFailedMessageProvider`, `LCCKIMPushProvider`) | `ChatKit/Class/Tool/Service/LCCKIMProvider.h` | Everything ChatKit needs from an IM backend, including the notification contract the provider must follow. |
| `LCCKConversationProtocol` | `ChatKit/Class/Model/LCCKConversationProtocol.h` | Conversation model used by the UI. `AVIMConversation` conforms through the demo category. |
| `LCCKIMMessageProtocol` | `ChatKit/Class/Model/LCCKIMMessageProtocol.h` | Opaque IM SDK message (custom messages and raw messages kept for paging, editing, recalling). `AVIMTypedMessage` conforms through the demo category. |
| `LCCKMessageMediaType` (`LCCKMessageMediaTypeText`, …) | `LCCKConstants.h` | ChatKit-owned media type: `NS_ENUM(int8_t, …)` with the same raw values as `AVIMMessageMediaType`. |
| `LCCKIMErrorCode` (`LCCKIMErrorCodeConnectionLost`) | `LCCKConstants.h` | Same value (9001) as LeanCloud's `AVIMErrorCodeConnectionLost`. |
| `-[LCChatKit IMProvider]` | `LCChatKit.h` | Provider registration. |
| `-[LCCKSessionService isClientOpened]`, `-handleSingleSignOnError:callback:` | `LCCKSessionService.h` | Replace `client.status` checks; providers call the latter for session conflicts. |
| `-[LCCKConversationService sendMessage:conversation:mentionList:progressBlock:callback:]` | `LCCKConversationService.h` | Provider-neutral send. |

Model protocols declare methods instead of properties so that SDK classes can conform through
categories without property attribute conflicts. This was checked with clang against the exact
LeanCloud SDK 11.5.2 declarations (`-Wprotocol -Wmethod-signatures -Wincompatible-pointer-types`):
no warnings.

## Moved to the demo (`ChatKit-OC/Example/Class/LeanCloud`)

| From ChatKit | To the demo |
|:---|:---|
| `AVIMConversation+LCCKExtension` | Same name; now conforms to `LCCKConversationProtocol`, adds `lcck_unreadCount` and `lcck_mentioned`. |
| `AVIMTypedMessage+LCCKExtension` | Same name; now conforms to `LCCKIMMessageProtocol`. Declares the SDK's private `_typeDict` itself (it was declared in `LCCKConstants.h`). |
| `AVIMMessage+LCCKExtension`, `AVIMEmotionMessage` | Same names. |
| `+[LCCKMessage messageWithAVIMTypedMessage:]` | `LCCKMessage+LCCKExtension` (same selector). |
| `+[LCCKCommonUtils getPathFromFile:]`, `+isCacheDataAvailableForFile:` | `LCCKCommonUtils+LCCKExtension` (same selectors). |
| LeanCloud parts of `LCCKSessionService` | `LCCKLeanCloudSessionService`. |
| LeanCloud parts of `LCCKConversationService` and `LCCKConversationListService` (SQLite stores included) | `LCCKLeanCloudConversationService`. |
| LeanCloud push and badge code of `LCCKSettingService` | `LCCKLeanCloudIMProvider`. |
| `-[LCCKConversationService sendMessage:conversation:options:progressBlock:callback:]` | `-[LCCKLeanCloudConversationService sendMessage:conversation:options:mentionList:progressBlock:callback:]`. |

Removed:

- `AVIMConversation+LCCKAddition`: it redefined `lcck_lastMessage`, `lcck_type`, and other methods
  of `AVIMConversation+LCCKExtension`, so the method used at runtime was undefined. Its
  `lcck_unreadCount`/`lcck_mentioned` were never set; the demo category now derives them from
  `unreadMessagesCount`/`unreadMessagesMentioned`, which is what the conversation list already showed.
  `+lcck_groupConversaionDefaultNameForUserIds:` had no callers.
- `AVIMTypedMessage+LCCKExtention` (`+llck_messageWithLCCKMessage:`): it read the nonexistent
  `LCCKMessage.messageMediaType` property, so it never compiled.
- The podspec now excludes the stale 2016 copy `ChatKit/LCChatKit.{h,m}`, which duplicated the
  `LCChatKit` class of `ChatKit/Class/LCChatKit.{h,m}` and referenced LeanCloud.

## API compatibility

Source-breaking changes for apps that used LeanCloud types through ChatKit:

- Block and method signatures now use `id<LCCKConversationProtocol>` instead of `AVIMConversation *`
  (`LCCKConversationResultBlock`, `LCCKFetchConversationHandler`, conversation list blocks and delegate,
  `-getConversationIfExists`, `currentConversation`, `insertRecentConversation:`).
- `LCCKFilterMessagesBlock` and `LCCKSendMessageHookBlock` receive `id<LCCKIMMessageProtocol>` messages;
  with the LeanCloud provider these are still `AVIMTypedMessage` objects.
- `sendCustomMessage:` takes `id<LCCKIMMessageProtocol>`; `AVIMTypedMessage` subclasses still work.
- `setMemberInfoChangedBlock:` passes `NSUInteger role` (the `AVIMConversationMemberRole` value).
- `LCCKGenerateSignatureCompletionHandler` takes `id signature` (an `AVIMSignature` for LeanCloud).
- `client` properties are `id` (an `AVIMClient` for LeanCloud). `LCCKMessage.message` is `id`.
- `LCCKMessageDelegate.mediaType` and `+[LCCKChatMessageCell classMediaType]` use `LCCKMessageMediaType`.
  The raw values are unchanged, so behavior is the same, but a custom cell that still declares
  `+ (AVIMMessageMediaType)classMediaType` gets a `-Wmismatched-return-types` warning (not an error).
  Change its return type to `LCCKMessageMediaType`; `kAVIMMessageMediaType*` return values still work.
  (Checked with clang: the warning appears whether `LCCKMessageMediaType` is an `NS_ENUM` or a plain
  `int8_t` typedef, so the type-safe `NS_ENUM` was chosen.)
- `ChatKitHeaders.h` no longer imports `AVOSCloud`/`AVOSCloudIM`; app files using LeanCloud must import them.

Kept for compatibility: `kAVIMMessageMediaTypeSystem`, `alertAVIMError:`/`filterAVIMError:`,
`lcck_messagesWithAVIMMessages:`, and `LCCKConversationViewModel.avimTypedMessage` (now provider messages).

## Behavior notes

- Custom message cells are chosen by the registered cell class for the media type; previously ChatKit
  read the LeanCloud SDK's subclass registry. Unregistered custom types still fall back to the text cell.
- The image cell downloads attachments through the provider (`AVFile` for LeanCloud). Providers that do
  not implement `downloadAttachmentOfMessage:completion:` fall back to downloading `originPhotoURL`.
- `-[LCCKConversationViewModel messageUpdated:]` compared the loop index with the array pointer
  (`i < self.dataArray`); it now uses `self.dataArray.count`, preventing out-of-bounds access.
- Nil guards were added where a nil SDK result would have been inserted into an array
  (recalled message, invalid queried messages).

## Verification

Done in a Linux container without Xcode or an iOS SDK:

- `grep` finds no `AVIM*`/`AVOSCloud`/`AVFile` code references in `ChatKit/Class` (only comments and the compatibility constant).
- clang `-fsyntax-only` on the protocol headers with stub Foundation/UIKit: no errors with `-Wall -Wnullability-completeness`.
- clang conformance check of `AVIMConversation`/`AVIMTypedMessage` (exact SDK 11.5.2 declarations) plus the demo categories: no warnings.
- clang with auto-generated UIKit stubs on the rewritten core files: no errors in provider or protocol code. This found three files that had relied on `LCChatKit.h` arriving through the removed `AVIMConversation+LCCKExtension.h` import; they now import it directly.
- A selector-level script confirmed every provider call in core is declared, `LCCKLeanCloudIMProvider` implements all 36 required selectors, every forwarded selector exists in the demo services, and the SDK classes plus categories satisfy both model protocols.
- Both `.pbxproj` files parse with `xcodeproj` 1.28.1, keep `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"`, and contain no synchronized groups or newer keys.
- Lockfiles: checksums computed with `cocoapods-core` 1.17.0 (the lockfiles' version); `Lockfile#detect_changes_with_podfile` reports no drift for either project.

## TODO

- TODO: Build `ChatKit/ChatKit.xcodeproj` and the CocoaPods library target on macOS with Xcode. No compiler with an iOS SDK was available, and the stub-based clang checks cannot catch UIKit typing errors.
- TODO: Run `pod install` in `ChatKit/` and `ChatKit-OC/` on macOS. The CocoaPods CDN redirects to `cdn.jsdelivr.net`, which this environment blocks, so the lockfiles were edited by hand with CocoaPods-computed checksums. `pod install` regenerates `Pods/` and the `[CP]` build phases; review that it changes nothing else.
- TODO: Run the demo end to end with the LeanCloud provider: log in, conversation list (unread badge, mention, draft, mute, last-message preview for every media type), send and receive text, image, voice, and location, edit, recall, failed-message resend, auto-join, removed-from-group handling, single sign-on prompt, reconnect, push registration, and badge sync. Compare the UI with the previous release.
- TODO: Pre-existing: the demo project cannot build as checked in. `ChatKit-OC.xcodeproj` references about 30 missing files (Redpacket, ConversationDetail, VCard, Utilities, and `README.md` in Sources), and `LCChatKitExample+Setting.m` imports missing headers such as `LCCKExampleConstants.h`. Restore or remove those references in a separate change.
- TODO: Pre-existing: `ChatKit.xcodeproj` is out of sync with disk (83 missing references, 14 unreferenced files). The podspec glob is the effective source list.
- TODO: Pre-existing: `mentionList` is never sent; the view model passes nil to keep existing behavior. The provider API now supports it. Decide whether to enable it, because recipients would start seeing mention flags.
- TODO: Pre-existing: `+[AVIMTypedMessage lcck_messageWithLCCKMessage:]` assigns `originPhotoURL` (an `NSURL`) to an `NSString` and calls `hasPrefix:` on it, which crashes when an outgoing image message has a remote URL.
- TODO: Pre-existing: header basenames are duplicated (for example two `NSBundle+LCCKExtension.h` with different methods), so the header CocoaPods picks depends on search order.
- TODO: `FMDB` is no longer used by ChatKit itself, only by the demo provider's SQLite caches through the pod's transitive dependency. Moving it to the demo Podfile is a separate dependency change.
- TODO: API risk: apps that subclass or extend the facade services, or call the moved LeanCloud categories, must copy `ChatKit-OC/Example/Class/LeanCloud` and add `AVOSCloud`/`AVOSCloudIM`. Consider a major version bump and a migration note in the release.
