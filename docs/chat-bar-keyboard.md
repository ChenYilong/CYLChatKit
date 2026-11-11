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
| `CYLChatFaceView.m`, `AGEmojiKeyBoardView.m` | The emoji panels, which have their own 发送 button and stand in for the keyboard |
| `CYLChatMoreView.m` | The "more" panel (photo, camera, location); height `kFunctionViewHeight` (210 pt) |

To see the keyboard while debugging: open a chat, find the 发送 button, and tap the input field next to it. In CI the demo
does the same: `-LCCKDemoScreen chat -LCCKDemoKeyboard YES` focuses the input field (`-[CYLChatBar beginInputing]`) 1.5 s
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

## TODO

- TODO: Visual Liquid Glass styling of the chat bar is not done. The bar keeps its opaque theme-colored background
  and hairline. Options for a later change, each to be checked against the `chat-keyboard` screenshot: a `UIGlassEffect`
  background behind the bar contents, a glass capsule for the input field, and a glass send button, with the table view
  extending under the bar and a scroll edge effect. Guard it with `#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 260000` and
  `@available(iOS 26.0, *)` so older SDKs still build.
- TODO: The emoji and more panels use a fixed height (`kFunctionViewHeight`, 210 pt) while the keyboard is 291 pt or taller
  on iPhones, so switching between keyboard and panel moves the bar. Make the panels as tall as the last keyboard height.
- TODO: The 发送 title and several other texts in the chat bar are hard-coded Chinese strings (see
  `docs/localization.md`); move them behind `CYLLocalizedStrings`.
- TODO: Verify on devices: the Liquid Glass keyboard on a real iPhone (the CI simulator shows the layout only), a floating
  or undocked keyboard on iPad, and a hardware keyboard with the shortcut bar.
- TODO: The chat view still uses `[[UIApplication sharedApplication] keyWindow]` (deprecated since iOS 13) in several
  places; replace it with the window of the view's scene.
