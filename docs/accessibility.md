# Accessibility

Rules: `AGENTS.md`, "Accessibility", and `.agents/skills/cylchatkit-accessibility/SKILL.md`. They are copied and adapted
from CYLTabBarController. Strings follow the localization rules (`docs/localization.md`): accessibility labels, hints,
values, and action names are localized through `CYLLocalizedStrings` (core) and `CYLDemoExampleLocalizedString` (example).

## What is covered

| Component | Blind users (VoiceOver, Voice Control) | Low vision | Verified in CI |
|:---|:---|:---|:---|
| Chat bar: input field and send button (`CYLChatBar`) | Labels `Message` and `Send` (localized), hint on the send button, identifiers `CYLChatBarTextView` and `CYLChatBarSendButton` | Text view, send button, and record button scale with Dynamic Type (send button capped at 22 pt and shrinks to fit its 60 x 37 pt frame) | Yes: dump with `expect_accessibility` (English and Chinese), `chat-large-text` screenshot |
| Chat bar: voice, emoji, and record buttons | Labels, state (the voice label switches, the emoji button is selected while its panel is up), hints, identifiers | Record button scales | No: these buttons are never shown (see TODO) |
| Message row (`CYLChatMessageCell`, all message types) | One element: sender, content (text, image, voice with duration, video, location, file, system), send and read state; hint to play or open; activation does what a tap on the bubble does; custom actions Resend and Open profile | Not done (see TODO) | No: needs messages |
| Conversation row (`CYLConversationListCell`) | One element: name, unread count (or "unread messages" when muted), muted, last message, time; custom action Open profile | Not done (see TODO) | No: needs conversations |
| Contact row (`CYLContactCell`) | One element: title and subtitle; selected trait when checked; hint in selection mode | Not done (see TODO) | No: needs contacts |
| Chat bar glass input field | The system glass material adapts to Reduce Transparency, Increase Contrast, and Reduce Motion by itself (Apple's guidance; not verified here) | Same | Not verified |
| Demo login screen | Client ID field: label, hint, identifier `CYLDemoLoginClientIdTextField`; the title is localized text | Standard text | Yes: dump with `expect_accessibility` (English and Chinese) |
| Demo tab bar | Tab titles come from the example bundle (localized), which VoiceOver reads | System tab bar | Screenshots only |

## How CI verifies it

`scripts/demo-screenshots.sh` launches the demo with `-CYLDemoAccessibilityDump YES`; the app writes what VoiceOver would
find on the screen (class, label, value, hint, identifier, traits) and the script prints it after each screenshot, between
`===BEGIN ACCESSIBILITY <name>===` and `===END ACCESSIBILITY <name>===`. It fails the job when an expected element is
missing (`expect_accessibility`). Screenshots: `chat-large-text` (Dynamic Type accessibility size 3 with a typed message),
and `login-zh` and `chat-zh` (Simplified Chinese). See `docs/ci.md`.

## TODO

- TODO: Not verified: the labels of message, conversation, and contact rows (no data in CI; they were written from the
  code), VoiceOver reading order, and Voice Control. Test with VoiceOver on a device or the Accessibility Inspector on a
  signed-in demo. Consider adding fake rows to the screenshot mode so CI can check them.
- TODO: The voice and emoji buttons of the chat bar are never shown (`hidden = YES`), and the "more" button is the send
  button, so the emoji panel (`CYLChatFaceView`, `CYLFacePageView`, `CYLEmojiKeyboardView`), the "more" panel
  (`CYLChatMoreView`, `CYLChatMoreItem`, and the plugins `CYLInputViewPlugin*`), and the voice recording HUDs
  (`CYLRecordAudioHUD`, `CYLProgressHUD`) are unreachable. If they are enabled again, give every emoji (an image view with a
  tap gesture) a label and the button trait, make `CYLChatMoreItem` one element that activates on `accessibilityActivate`,
  announce the recording state, and localize their hard-coded Chinese titles (`照片`, `拍摄`, `位置`, `发送`, and the HUD texts).
- TODO: Dynamic Type for message text (MLLabel with custom fonts), the conversation and contact rows, the navigation title
  view, and the time separators. Row heights are cached by the template cell layout, so changing fonts also needs a reload
  on `UIContentSizeCategoryDidChangeNotification`.
- TODO: Message bubbles and the conversation row do not announce new messages; consider
  `UIAccessibilityAnnouncementNotification` for an incoming message while the chat is open.
- TODO: Reduce Motion: the voice recording HUD animations, the send-state spinner, and the bubble animations ignore
  `UIAccessibilityIsReduceMotionEnabled()`.
- TODO: Color contrast of the themed colors (conversation list time stamps, placeholder text, the bubble text on the
  green bubble) has not been measured; run an Accessibility Inspector audit.
- TODO: Touch targets: the avatar in the conversation and message rows is smaller than 44 x 44 pt in the default layout.
  VoiceOver reaches it through the custom action; sighted users still need a larger hit area.
- TODO: The image browser (`CYLPhotoBrowser`), the web view, the location picker, and the contact-list search have no
  accessibility work yet.
- TODO: Demo screens other than login and the tab bar (contact list, conversation detail, settings, group members) have
  no accessibility work and still contain hard-coded Chinese texts.
