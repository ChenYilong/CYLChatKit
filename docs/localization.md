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

## Checks

`scripts/check-localizations.py` (CI job `Localization tables`) parses every `.strings` file under `ChatKit/` and
`ChatKit-OC/Example/` and requires every language of a table to have the same keys. Vendor tables whose keys
differ by design (DateTools plural variants, photo browser, per-language emoji names) are listed in `LEGACY` in the
script and only produce warnings.

## Done

- The example has its own `LCCKExample.bundle` and `LCCKExampleLocalizedString(key, default)` macro, and no longer
  reads core strings. `localize(key, default)` now honors `default`, so the info message bar shows the real
  title and subtitle instead of the core placeholder `--------`. The `kString...` macros, which called
  `localize` with one argument and could not compile if used, pass `nil` as the default.

## TODO

- TODO: Core has loose `.lproj` folders: `ChatKit/Class/Resources/{en,ar,zh-Hans,zh-Hant}.lproj/EmojiLocalizable.strings` and `ChatKit/Class/Resources/localization/{en,zh-Hans}.lproj/LCChatKitString.strings`. The podspec copies `ChatKit/Class/Resources/*` into the client app's main bundle, so these files land there. Move them into core bundles only with a compatibility check of every lookup (including apps that may read them from the main bundle); the `localization/` copy is not read by core code. Kept unchanged because core resources are updated cautiously.
- TODO: Verify in the demo that `LCCKExample.bundle` is copied into the app and that the message bars show the expected strings in English and Simplified Chinese.
- TODO: Remove the duplicate keys the check reports as warnings (`News`, `Profile` in `LCChatKitString`, several emoji names) after confirming which value each lookup expects.
