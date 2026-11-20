# Naming review (2026-11)

The rule is the one in CYLTabBarController's AGENTS.md, copied into this repository's `AGENTS.md` ("Objective-C and API
rules") and the `cylchatkit-objc-naming` skill: every class, protocol, type, function, and constant starts with `CYL`;
category methods and properties start with `cyl_`; files are named after their main type; copied-in code loses its
foreign prefix and keeps a credit comment; already shipped public names stay. `scripts/check-naming.py` (CI job
`Naming rules`) enforces the part that can be checked mechanically.

## What changed

| Old | New | Notes |
|:---|:---|:---|
| `LCChatKit` (facade), `LCChatKit.h/.m`, `LCChatKit_Internal.h`, `LCChatKit (CYLServices)` | `CYLChatKit`, `CYLChatKit.h/.m`, `CYLChatKit_Internal.h` | Public. Apps rewrite `[LCChatKit ...]` to `[CYLChatKit ...]`. The umbrella header `ChatKitHeaders.h` keeps its name |
| `AGEmojiKeyBoardView`, `AGEmojiPageView`, folder `AGEmojiKeyboard/`, their delegate, data source, and category-image enum | `CYLEmojiKeyboardView`, `CYLEmojiPageView`, folder `CYLEmojiKeyboard/` | Copied-in code; credit comments added |
| `Mp3Recorder`, `Mp3RecorderDelegate` | `CYLMp3Recorder`, `CYLMp3RecorderDelegate` | Copied-in code; credit comment added |
| `JZTableViewRowAction` (internal class), file `UITableViewRowAction.m` | `CYLTableViewRowAction`, `CYLTableViewRowAction.m` | Copied-in code (MIT, Jazys); credit comment added |
| Demo `LCCK*` (classes, protocols, constants, files, xibs) | `CYLDemo*` | Includes `LCChatKitExample` → `CYLDemoChatKitExample`, `LCCKExample.bundle` → `CYLDemoExample.bundle` (table `CYLDemoExample`), `LCCKExampleLocalizedString` → `CYLDemoExampleLocalizedString`, `LCCKExampleConstants.h` → `CYLDemoExampleConstants.h` |
| Demo `LCCK_*` macros | `CYLDEMO_*` | `LCCK_KEY_USERID` and `LCCK_KEY_USERNAME` also changed their stored string values, so the demo forgets a login saved by an older build once |
| Demo `lcck_` category methods | `cyl_demo_` | Starts with `cyl_`, and cannot clash with a core or CYLTabBarController `cyl_` selector |
| Demo launch flags `-LCCKDemo*` | `-CYLDemo*` | `scripts/demo-screenshots.sh` and the accessibility identifiers (`CYLDemoLoginClientIdTextField`) changed with them |
| Demo `AVIMEmotionMessage`, `DEMOCustomAutoCompleteObject`, `DEMODataSource`, `LCIM*` macros, `kAVIMEmotionPath` | `CYLDemoEmotionMessage`, `CYLDemoCustomAutoCompleteObject`, `CYLDemoDataSource`, `CYLDemoDS*`, `kCYLDemoEmotionPath` | |

Kept on purpose: the core resource names `Other.bundle` and the table `LCChatKitString` (never rename a core bundle,
table, or key), the image asset `lcck_conversation_placeholder_avatar` (a resource name), the pre-built `lame.framework`,
and LeanCloud's own `AVIM*` types, which the demo uses by name.

Name clashes: none of the new names exists in CYLTabBarController (checked against its sources, which use `CYLDemo`
only for `CYLDemoAppearanceTheme*` and `CYLDemoApplyTheme*`; no demo class here shares those names). Repeat the check
when the pin moves (`AGENTS.md`).

Build note: the podspec excludes the row-action backport by file name (it has an `#error` for iOS 8+ SDKs), so renaming
`UITableViewRowAction.m` to `CYLTableViewRowAction.m` needs the same change in `exclude_files`. The first CI run of the
rename (run 42935160587, jobs `Build demo` and `pod lib lint`) failed exactly there; the `CYLEmoji*` and `CYLMp3Recorder`
renames compiled without errors in that run.

## TODO

- TODO: Verify the rename with the CI build. It was done mechanically on Linux without a compiler: xib `customClass`
  values, `project.pbxproj` file references, and the localization bundle rename are the likely failure points. Check the
  `Examples` and `Simulator screenshots` jobs, and the accessibility identifiers in `scripts/demo-screenshots.sh`.
- TODO: Core macros and constants without the `CYL` prefix, all in released public headers (so only a compatibility
  step can rename them: add `CYL`-prefixed names, keep the old ones as deprecated aliases for one release):
  `SCREENWIDTH`, `SYSTEM_VERSION_*`, `XCODE_VERSION_*`, `kFaceIDKey` / `kFaceClickKey` / `kFaceImageNameKey` (in
  `CYLFaceManager.h`), `kFunctionViewHeight` (in `CYLChatMoreView.h`), `kAvatarImageViewHeight/Width`,
  `BACKSPACE_BUTTON_TAG`, `BUTTON_FONT_SIZE`, `ButtonHeight`, `ButtonWidth`, `DefaultRecentEmojisMaintainedCount`,
  `isUIKitFlatMode`.
- TODO: Vendored DateTools code in core keeps `DTDateComponent`, `DateAgoFormat`, `DateAgoValues`, `DT*Exception`, and the
  `SECONDS_IN_*` constants. Rename them to `CYL` names with credit comments, and rename the `lame` wrapper only if it
  is ever replaced (the framework is a pre-built C library).
- TODO: Category members in core without `cyl_`: the `UIImageView (CYLCornerRadius)` initializers, the `UIColor` hex
  helper `CJ_16_Color`, and the misspelled selectors of `CYLConversationService (CYLDeprecated)`. Each needs a `cyl_`
  twin and a deprecated alias.
- TODO: The demo's vendored DateTools copy still has `D_DAY`-style macros and `CURRENT_CALENDAR`, and the demo has
  `HEIGHT_SETTING_*` macros and the `UITableViewRowActionHandler` block type. Rename them to `CYLDEMO_` / `CYLDemo`.
- TODO: `docs/api-reference.md` is the pre-review reference: its left-hand "old name" columns correctly keep `LCCK`
  names, but the per-file sections for the demo-facing facade were only updated by hand (`CYLChatKit`). Regenerate it
  with the next API pass.
