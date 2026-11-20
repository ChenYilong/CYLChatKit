# Open GitHub issues of ChenYilong/CYLChatKit

The open issues of this repository, each with its current state in the code and the remaining work. The full UI
assessment of all upstream issues is in `docs/ui-issue-tracker.md`; this file is the work list for this repository's own
issues. Close an issue only after the TODO is done and verified (CI screenshots or a device), and link the fix commit.

- TODO: [#1](https://github.com/ChenYilong/CYLChatKit/issues/1) CocoaPods integration fails next to the old
  `ChatKit-OC` pod (`Redefinition of enumerator 'kAVVerboseShow'`, `Include of non-modular header inside framework
  module`, Swift app, ChatKit 2.1.6). Likely fixed by the LeanCloud decoupling (core no longer imports AVOSCloud, see
  `docs/leancloud-decoupling.md`) and by the module build of the podspec (`pod lib lint` and the `use_frameworks!` Swift
  demo pass on GitHub CI, macOS 26). Remaining: publish a release that contains these changes (the podspec version is
  still 2.3.11), verify a clean Swift app with `pod 'CYLChatKit'` only, answer the "difference from ChatKit-OC" question
  in the README, then close.
- TODO: [#2](https://github.com/ChenYilong/CYLChatKit/issues/2) Is there a Swift demo? Yes since the demo migration:
  `ChatKit-OC/` is Swift only and green on GitHub CI (run 42969177671). Remaining: say so in the README, consider renaming
  the demo folder and scheme (`docs/swift-guide.md`), reply with the link, then close.
- TODO: [#3](https://github.com/ChenYilong/CYLChatKit/issues/3) Recording cannot stop when an alert appears during
  recording (iOS 12). `CYLChatBar.m` cancels on `UIControlEventTouchCancel` and on entering the background, with the issue
  URL beside the code, and voice input is enabled again (`docs/chat-bar-keyboard.md`). Remaining: verify on a device that
  an alert (microphone permission, phone call, system alert) during recording stops the recording and resets the
  button and HUD.
- TODO: [#4](https://github.com/ChenYilong/CYLChatKit/issues/4) Avatar image fitting (stretched avatars in message cells,
  iOS 12). `CYLChatMessageCell` sizes the avatar from the configured dimensions with aspect fill (issue URL beside the
  code). Remaining: a CI screenshot of a conversation with messages (the CI chat screen is empty today), checked with
  non-square avatars, then close.
- TODO: [#5](https://github.com/ChenYilong/CYLChatKit/issues/5) Logout bug (same as
  https://github.com/leancloud/ChatKit-OC/issues/94). Not investigated in this repository. Reproduce logout and login
  with another client ID in the Swift demo (`CYLDemoChatKitExample.signOut`, `invokeThisMethodBeforeLogoutSuccess`), check
  that conversations, caches, and the provider session (`CYLDemoLeanCloudSessionService`) of the previous user are
  cleared, fix, and verify.
- TODO: [#6](https://github.com/ChenYilong/CYLChatKit/issues/6) Image message cell without known width and height: a
  custom cell modeled on the image message cell must redraw with `-cyl_imageByScalingAspectFillWithOriginSize:` every
  time. (`docs/ui-issue-tracker.md` describes #6 wrongly as a contact-list data question; correct it.) Remaining: let
  `CYLChatImageMessageCell` measure the size once when the image loads and cache it on the message (photo width and
  height), document the pattern for custom cells, and answer the question.
