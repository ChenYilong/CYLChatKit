# Localization

Rules: see `AGENTS.md`, "Internationalization and localization".

## Current bundles

| Level | Bundle or folder | Tables | Accessor |
|:---|:---|:---|:---|
| Core | `ChatKit/Class/Resources/Other.bundle` (`en`, `zh-Hans`) | `LCChatKitString` | `CYLLocalizedStrings(key)` |
| Core (vendor) | `ChatKit/Class/Resources/DateTools.bundle` | `DateTools` | `DateToolsLocalizedStrings(key)` |
| Core (vendor) | `ChatKit/Class/Resources/CYLPBLocalizations.bundle` | photo browser strings | photo browser code |
| Core | `ChatKit/Class/Resources/{en,ar,zh-Hans,zh-Hant}.lproj` (not in a bundle) | `EmojiLocalizable` | — |
| Core | `ChatKit/Class/Resources/localization/{en,zh-Hans}.lproj` (not in a bundle) | `LCChatKitString` (copy of `Other.bundle`) | none in code |
| Example | `ChatKit-OC/Example/Class/Module/Other/Base.lproj`, `zh-Hans-CN.lproj` | `LaunchScreen` storyboard (allowed system exception) | — |
| Example | `ChatKit-OC/Example/Class/Module/Other/LCCKExample.bundle` (`en`, `zh-Hans`) | `LCCKExample` | `LCCKExampleLocalizedString(key, default)`; `localize(key, default)` is an alias |

## Acceptance criteria

Defined in `AGENTS.md` and `.agents/skills/cylchatkit-localization/SKILL.md`. Status of this repository:

| Criterion | Status |
|:---|:---|
| At least two different localization macros, one per layer | Met: core `CYLLocalizedStrings` (`CYLChatConstants.h`, bundle `Other`) and example `LCCKExampleLocalizedString` (`LCCKExampleConstants.h`, bundle `LCCKExample`); enforced by `scripts/check-localizations.py` |
| Each macro names its own layer's bundle, none reads the other layer's | Met; enforced by the script |
| No direct `NSLocalizedString` calls in feature code | Not checked yet; see TODO |
| No hard-coded non-English display text | Not met for existing code; see TODO (the rule applies to new and changed code) |
| Complete tables (same keys in every language) | Met for project-owned tables; vendor tables are warnings only |

## Checks

`scripts/check-localizations.py` (CI job `Localization tables`) parses every `.strings` file under `ChatKit/` and
`ChatKit-OC/Example/` and requires every language of a table to have the same keys and the same format specifiers. Vendor tables whose keys
differ by design (DateTools plural variants, photo browser, per-language emoji names) are listed in `LEGACY` in the
script and only produce warnings.

The script compares the format specifiers (`%@`, `%1$@`, `%d`) of every key between languages, and fails when a string
literal passed to a layer's macro is not a key of the table the macro reads (a typo would show the raw key).

The script also enforces the two-macro criterion. It reads the localization macros (`#define` bodies that call
`NSLocalizedString...` or `localizedStringForKey:`) in core headers (vendored code excluded) and in the example
headers, and fails when a layer has none, when both layers use the same macro name, when a macro does not name a bundle
of its own layer, or when a macro names a bundle of the other layer. It does not yet recognize Swift accessors.

## Done

- Accessibility strings (VoiceOver labels, hints, and action names) and the visible chat bar texts are localized through
  `CYLLocalizedStrings`: the keys `chatbar.*`, `message.*`, `conversation.*`, `contact.*`, and `plugin.*` are in both
  languages of `Other.bundle`. The chat bar's send button and record button titles (hard-coded Chinese before) now come from
  the table. The check also compares format specifiers between languages, so `%@` cannot drift. The demo's tab titles and
  login title are in `LCCKExample.bundle` (`tab.*`, `login.*`). CI takes `login-zh` and `chat-zh` screenshots in Simplified
  Chinese. See `docs/accessibility.md`.
- The example has its own `LCCKExample.bundle` and `LCCKExampleLocalizedString(key, default)` macro, and no longer
  reads core strings. `localize(key, default)` now honors `default`, so the info message bar shows the real
  title and subtitle instead of the core placeholder `--------` (`LCCKUtil` now passes its texts directly, and the unused
  `kStringMessageBarInfo*` macros are gone, since the example table has no such keys). The `kString...` macros, which called
  `localize` with one argument and could not compile if used, pass `nil` as the default.

## TODO

- TODO: Hard-coded Chinese string literals remain in code: about 96 in 29 core files (vendored code excluded) and
  about 170 in 19 example files at the time of this change (counted outside comments, in `.h` / `.m` / `.mm` files).
  Move each into the layer's bundle behind the layer's macro, adding the key to every language of its table. This
  changes user-visible strings, so check each screen. The rule applies to new and changed code now.
- TODO: Direct `NSLocalizedString...` calls outside a macro definition are not detected by `scripts/check-localizations.py`. Today they are all in vendored code (`DateTools/CYLError.m`, `CYLAlertController.m`, `CYLSafariActivity.m`, which read the app's main bundle) except one in the example: `ChatKit-OC/Example/Class/Module/Main/LCChatKitExample.m` calls `NSLocalizedStringFromTable(@"copy", @"LCChatKitString", ...)`, which reads a core table from the example and breaks the layer isolation rule. That file is an unreferenced duplicate of `ChatKit-OC/Example/LCChatKitExample.m` (not in the Xcode project), so it does not affect the build. Remove or fix the duplicate, add the check for non-vendored code (core and example), and then make it fail.
  `scripts/check-localizations.py` to list them (core and example), fix the existing ones, and then make the check fail.
- TODO: Swift cannot import function-like macros, so Swift callers of `CYLLocalizedStrings` need a function form in
  core (for example a class method with `NS_SWIFT_NAME`), and the Swift example needs its own accessor function for
  `LCCKExample.bundle`. Add both when the example is migrated to Swift (`docs/swift-guide.md`), and extend
  `scripts/check-localizations.py` to recognize Swift accessors so the two-macro criterion keeps being enforced.

- TODO: Core has loose `.lproj` folders: `ChatKit/Class/Resources/{en,ar,zh-Hans,zh-Hant}.lproj/EmojiLocalizable.strings` and `ChatKit/Class/Resources/localization/{en,zh-Hans}.lproj/LCChatKitString.strings`. The podspec copies `ChatKit/Class/Resources/*` into the client app's main bundle, so these files land there. Move them into core bundles only with a compatibility check of every lookup (including apps that may read them from the main bundle); the `localization/` copy is not read by core code. Kept unchanged because core resources are updated cautiously.
- TODO: Verify in the demo that `LCCKExample.bundle` is copied into the app and that the message bars show the expected strings in English and Simplified Chinese.
- TODO: Remove the duplicate keys the check reports as warnings (`News`, `Profile` in `LCChatKitString`, several emoji names) after confirming which value each lookup expects.
