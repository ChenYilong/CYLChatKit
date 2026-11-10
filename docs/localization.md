# Localization

Rules: see `AGENTS.md`, "Internationalization and localization".

## Current bundles

| Level | Bundle or folder | Tables | Accessor |
|:---|:---|:---|:---|
| Core | `ChatKit/Class/Resources/Other.bundle` (`en`, `zh-Hans`) | `LCChatKitString` | `CYLLocalizedStrings(key)` |
| Core (vendor) | `ChatKit/Class/Resources/DateTools.bundle` | `DateTools` | `DateToolsLocalizedStrings(key)` |
| Core (vendor) | `ChatKit/Class/Resources/CYLPBLocalizations.bundle` | photo browser strings | photo browser code |
| Core | `ChatKit/Class/Resources/zh-Hans.lproj` (not in a bundle) | `EmojiLocalizable` | — |
| Example | `ChatKit-OC/Example/Class/Module/Other/Base.lproj`, `zh-Hans-CN.lproj` | `LaunchScreen` storyboard (allowed system exception) | — |
| Example | none yet | — | `localize(key, default)` maps to core |

## TODO

- TODO: `ChatKit/Class/Resources/zh-Hans.lproj/EmojiLocalizable.strings` is a loose `.lproj` in core. Move it into a core bundle only together with a compatibility check of every lookup of the `EmojiLocalizable` table (the podspec copies `ChatKit/Class/Resources/*` into the client app), because moving it changes where clients find it.
- TODO: The example's `localize(key, default)` macro (`LCCKExampleConstants.h`) maps to the core macro `CYLLocalizedStrings`, so example code reads core strings, and its `default` argument is ignored. Add an example bundle (for example `LCCKExample.bundle`) with an `LCCKExampleLocalizedString(key)` macro, and move example-only keys there.
- TODO: No check enforces that all languages of a table have the same keys. Consider a CI step that runs `plutil -lint` and compares key sets.
