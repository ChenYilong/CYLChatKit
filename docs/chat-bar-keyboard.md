# Chat bar and the keyboard (iOS 26 Liquid Glass)

The chat bar (`CYLChatBar`, in `ChatKit/Class/Module/Conversation/View/ChatBar/`) sits on top of the keyboard. It is
created by `CYLBaseConversationViewController` (public property `chatBar`), constrained to the bottom of the
controller's view, and moved up by the keyboard height. The table view ends at the top of the bar.

## Finding the components

Search the code for the send button's title, `发送` (Send), and you land on the chat bar:

| Where | What |
|:---|:---|
| `CYLChatBar.m`, `moreButton` getter | The send button, titled 发送, to the right of the input field. The property name `moreButton` is historical: its action (`-buttonAction:`) sends the typed text |
| `CYLChatBar.m`, `textView` getter | The input field beside it; tapping it brings up the system keyboard with the bar on top |
| `CYLChatBar.m`, `-keyboardWillShow:` / `-keyboardWillHide:` / `-keyboardWillChangeFrame:` | Keyboard tracking |
| `CYLChatFaceView.m`, `CYLEmojiKeyboardView.m` | The emoji panels, which have their own 发送 button and stand in for the keyboard |
| `CYLChatMoreView.m` | The "more" panel (photo, camera, location); height `kFunctionViewHeight` (210 pt) |

To see the keyboard while debugging: open a chat, find the 发送 button, and tap the input field next to it. In CI the demo
does the same: `-CYLDemoScreen chat -CYLDemoKeyboard YES` focuses the input field (`-[CYLChatBar beginInputing]`) 1.5 s
after the chat appears, and `scripts/demo-screenshots.sh` takes the `chat-keyboard` screenshot.

## What was adapted for iOS 26

- **The bar follows the keyboard's own animation.** Moving the bar used a fixed 0.25 s animation, but the keyboard
  animates with its own duration and curve (a spring-like private curve, reused through the notification's
  `UIKeyboardAnimationDurationUserInfoKey` and `UIKeyboardAnimationCurveUserInfoKey`), so the bar lagged behind or jumped.
- **Frame changes while the keyboard is up are followed.** Only `UIKeyboardWillShow` and `WillHide` were observed. A
  height change without show or hide (input method switch, prediction bar, iPad docking) left the bar on the old
  position. `-keyboardWillChangeFrame:` now handles it.
- **The bottom spacing no longer depends on the device model.** `CYL_IS_iPHONEX` was "status bar height equals 44",
  which is false on iPhones with a Dynamic Island (taller status bar), so the bar's bottom spacing was not refreshed
  when switching between the keyboard and the emoji or more panel. The spacing is now refreshed on every change, and
  `CYL_IS_iPHONEX` means "the key window has a bottom safe area".
- **Accessibility:** the controls have localized VoiceOver labels and hints and stable identifiers, and the field and send
  button scale with Dynamic Type; see `docs/accessibility.md`.
- **The input field is a Liquid Glass capsule on iOS 26** (`-applyLiquidGlassStyleIfActive` in `CYLChatBar.m`). A
  glass backdrop is placed behind the text view, the text view's own background and border are removed, and its
  horizontal text inset grows to 12 pt so the text clears the rounded ends. The bar itself stays opaque: a glass material
  is capsule shaped by default, which does not suit a full-width bar.

## Voice input (restored)

The chat bar always contained voice recording (`CYLChatBar` voice button, hold-to-talk `voiceRecordButton`,
`CYLRecordAudioHUD`, `CYLMp3Recorder`, `-chatBar:sendVoice:seconds:`), but it was switched off: the 2018 "update IM chatbar"
commit of ChenYilong/Haidilao (5088ba45, the source of this code) hid `voiceButton` and commented out the body of
`-showVoiceView:`. Nothing was missing from this repository, and Haidilao has only that same disabled copy.
It is on again: the voice button sits left of the input field (the text view's left edge follows it), taps switch
between the keyboard and the hold-to-talk button (`-voiceButtonAction:`), and the demo's Info.plist has
`NSMicrophoneUsageDescription`.

## Guards for the Liquid Glass code

All iOS 26 symbols are in `CYLChatLiquidGlass` (`ChatKit/Class/Tool/`), behind two guards, as CYLTabBarController does:

1. Compile time: `#if defined(__IPHONE_26_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_26_0`, so the library still
   builds with an older Xcode. Without it, the class compiles to "always NO".
2. Run time: `if (@available(iOS 26.0, *))`, plus the app's opt-out: on iOS 26 the glass is off when the app's Info.plist sets
   `UIDesignRequiresCompatibility` to YES; on iOS 27 and later it is always on.

`CYLChatBar.m` calls `+[CYLChatLiquidGlass installBackdropBehindView:inContainer:]` and does nothing else when it returns
nil, so on iOS 25 and earlier, with an older SDK, or with the opt-out, the opaque field and its border are exactly as before.
The rule is in `AGENTS.md` ("Guard every Liquid Glass API") and the `cylchatkit-xcode-compat` skill.

## TODO

- TODO: Verify the glass input field in the CI `chat-keyboard` and `chat` screenshots, and the old look with
  `UIDesignRequiresCompatibility` set to YES (the demo's Info.plist does not set it). Not done yet: the code was written
  without an iOS 26 compiler at hand, so the first CI run is also its first compile.
- TODO: More Liquid Glass styling is possible and not done: a glass send button (`UIButtonConfiguration` glass styles), a
  floating glass bar with the table view extending under it, and a scroll edge effect. Each needs the same two guards and
  an entry in `CYLChatLiquidGlass`.
- TODO: The emoji and more panels use a fixed height (`kFunctionViewHeight`, 210 pt) while the keyboard is 291 pt or taller
  on iPhones, so switching between keyboard and panel moves the bar. Make the panels as tall as the last keyboard height.
- TODO: Some chat bar texts are still hard-coded Chinese strings (see `docs/localization.md`): the recording HUD texts
  (`松开手指,取消发送`, `手指上滑,取消发送`), which the code also compares by value with `isEqualToString:` and so need a
  key-based rewrite first, and the emoji panel's send title. The send button and record button titles are localized.
- TODO: Verify on devices: the Liquid Glass keyboard on a real iPhone (the CI simulator shows the layout only), a floating
  or undocked keyboard on iPad, and a hardware keyboard with the shortcut bar.
- TODO: The chat view still uses `[[UIApplication sharedApplication] keyWindow]` (deprecated since iOS 13) in several
  places; replace it with the window of the view's scene.
- TODO: Verify the restored voice input in the CI screenshots (the voice button must appear left of the field) and on a
  device: microphone permission, hold to talk, slide up to cancel, and sending through the provider (the demo's
  `CYLDemoLeanCloudIMProvider` must send the audio message). Add a `chat-voice` screenshot step and an
  `expect_accessibility` for `CYLChatBarVoiceButton` in `scripts/demo-screenshots.sh`.
- TODO: Localize the microphone usage description (`InfoPlist.strings`, zh-Hans) and the hard-coded recording HUD texts.
