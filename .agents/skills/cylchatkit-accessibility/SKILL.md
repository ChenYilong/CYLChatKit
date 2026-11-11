---
name: cylchatkit-accessibility
description: "Accessibility rules and procedure for CYLChatKit: VoiceOver labels, hints, traits and grouping for controls and rows, Dynamic Type, display settings, localized accessibility strings, and the CI accessibility dump. Use before adding or changing any control, text, cell, or screen, in core (ChatKit/) or in an example (ChatKit-OC/)."
---

# CYLChatKit accessibility

Use this skill before you add or change a control, a text, a cell, or a screen. `AGENTS.md` ("Accessibility") holds the
binding rules; this is the working procedure. The rules are copied and adapted from CYLTabBarController's AGENTS.md
("Accessibility is required everywhere") and its UIKit accessibility checklist. Accessibility applies to new code, to code
you change, and to existing code you review: fix what is missing when you meet it.

## The procedure

1. **Make every control and text an element with a label.** Image-only buttons (`UIButton` with a background image and no
   title) have no label until you set `accessibilityLabel`. A `UILabel` or a button with a title reads itself.
2. **Group rows.** A table or message row is one element: set `isAccessibilityElement = YES` on the cell and compute
   `accessibilityLabel` from its parts, so VoiceOver does not stop on every subview. Order the parts as a person would say
   them: sender, content, status. Do not read decorations.
3. **Give state and actions.**
   - Traits: `UIAccessibilityTraitButton`, `UIAccessibilityTraitSelected`, `UIAccessibilityTraitStaticText`, and so on.
   - Values for things that change (`accessibilityValue`); hints only when they add guidance (`accessibilityHint`).
   - What a tap on a sub-view does (avatar, resend, play) becomes `accessibilityActivate` or `accessibilityCustomActions`.
4. **Hide decorations.** `isAccessibilityElement = NO` or `accessibilityElementsHidden = YES` for purely decorative views.
5. **Identifiers.** Every interactive element gets a stable, non-localized `accessibilityIdentifier`, named like the
   existing ones: `CYLChatBarSendButton`, `CYLChatBarTextView`, `LCCKLoginClientIdTextField`.
6. **Localize every accessibility string.** Labels, hints, values, and action names go through the layer's macro
   (`CYLLocalizedStrings` in core, `LCCKExampleLocalizedString` in the example), with keys added to every language of the
   table (`cylchatkit-localization`). The accessibility keys of the chat bar, message rows, and conversation rows are in
   `Other.bundle` (`chatbar.*`, `message.*`, `conversation.*`).
7. **Announce changes.** After a panel or screen changes, post `UIAccessibilityLayoutChangedNotification` (a part of the
   screen) or `UIAccessibilityScreenChangedNotification` (a new screen).

## Visual accessibility

- **Dynamic Type.** Use text styles or `UIFontMetrics` (`scaledFontForFont:` or `scaledFontForFont:maximumPointSize:`) and
  `adjustsFontForContentSizeCategory = YES` (labels, buttons through `titleLabel`, text views). Use a
  `maximumPointSize` only where the layout cannot grow (the 60 x 37 pt send button), and add
  `adjustsFontSizeToFitWidth` there. Check the layout at an accessibility size: CI takes a `chat-large-text` screenshot.
- **Color and contrast.** Never convey state by color alone (add an icon, text, or a trait). Keep text readable on its
  background.
- **Touch targets.** At least 44 x 44 pt where the design allows.
- **Display settings.** Reduce Transparency, Increase Contrast, Bold Text, and Reduce Motion are the user's choice. The
  Liquid Glass material adapts to them by itself (see `cylchatkit-xcode-compat`, "SDK and OS guards for Liquid Glass");
  do not force a material or an animation on top.

## Verify

- **Through accessibility first.** The demo writes the accessibility tree of the screen when it is launched with
  `-LCCKDemoAccessibilityDump YES`. `scripts/demo-screenshots.sh` prints it between `===BEGIN ACCESSIBILITY <name>===` and
  `===END ACCESSIBILITY <name>===` and fails when `expect_accessibility <screen> <identifier> "<label>"` finds no such
  element. Add an expectation for every control a CI screen shows, in English and in Simplified Chinese.
- **Rows without data.** Conversation, message, and contact rows need data, which CI does not have; check their labels by
  reading the code, and record that as not verified in `docs/accessibility.md`.
- **By hand.** Turn VoiceOver on (or use the Accessibility Inspector), and go through the screen: every stop has a label,
  the reading order makes sense, nothing is read twice, and every action can be done without seeing the screen.
- Fall back to coordinates only when no element can be found, then file the missing label as a bug and fix it.

## Checklist

- [ ] Every control and text is an accessibility element with a meaningful label.
- [ ] Image-only buttons have labels; decorations are hidden.
- [ ] Rows are one element; their sub-view taps are activation or custom actions.
- [ ] Traits, values, and hints are right, and the hint adds something.
- [ ] Every interactive element has a stable `accessibilityIdentifier`.
- [ ] Every accessibility string is localized, in every language of its table.
- [ ] Text scales with Dynamic Type and the layout survives an accessibility size.
- [ ] State is not conveyed by color alone; touch targets are large enough.
- [ ] CI shows the screen's accessibility dump, with an `expect_accessibility` line for each new control.
- [ ] Gaps are recorded as `TODO` in `docs/accessibility.md`.
