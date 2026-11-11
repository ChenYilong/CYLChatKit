---
name: cylchatkit-localization
description: "Internationalization and localization rules for CYLChatKit: bundle structure, one accessor macro per layer, complete key sets, and the two-macro acceptance criterion. Use when adding or changing a user-visible string, a .strings table, or a resource bundle, in core (ChatKit/) or in an example (ChatKit-OC/)."
---

# CYLChatKit localization

Use this skill before adding or changing any user-visible string, `.strings` table, or resource bundle. `AGENTS.md`
("Internationalization and localization") holds the binding rules; this skill is the working procedure. The acceptance
criteria are adapted from CYLTabBarController (one accessor for library strings, no hard-coded display text, complete
tables); where this repository differs, it is noted below.

## The two layers

A project has at least two different localization macros, one per layer. Each reads from a bundle of its own layer, and
the layers never read each other's bundles.

| Layer | Folder | Bundles | Macro | Defined in |
|:---|:---|:---|:---|:---|
| Core | `ChatKit/` | `ChatKit/Class/Resources/*.bundle` (always kept; clients can override with `CustomizedChatKit.<Name>.bundle`) | `CYLLocalizedStrings(key)` reads table `LCChatKitString` in `Other.bundle` | `ChatKit/Class/Tool/CYLChatConstants.h` |
| Example | `ChatKit-OC/` | `ChatKit-OC/Example/Class/Module/Other/LCCKExample.bundle` | `LCCKExampleLocalizedString(key, defaultValue)` reads table `LCCKExample` in `LCCKExample.bundle` | `ChatKit-OC/Example/Class/Tool/LCCKExampleConstants.h` |

Vendored macros (`DateToolsLocalizedStrings` in `NSDate+CYLDateTools.h`) belong to their vendor bundle and do not count
as a layer macro. A bundle is a folder package; on other platforms the folder form differs (Android `res/values-<lang>/`,
web `locales/<lang>/<namespace>.json`, Flutter `.arb` files) but the rules are the same.

## Add a string

1. Pick the layer: core strings are shown by the library UI, example strings only by the demo app.
2. Add the key to **every** `<lang>.lproj/<Table>.strings` of the table in that layer's bundle, in the same commit.
   Keep `%@` / `%1$@` specifiers identical in every language.
3. Read it only through the layer's macro: `CYLLocalizedStrings(@"key")` in core, `LCCKExampleLocalizedString(@"key",
   @"fallback")` in the example. Use `[NSString stringWithFormat:]` for values.
4. Never hard-code user-visible text, or log, assert, or debug text, that contains non-English characters. Image names
   and documented localization keys are the only exceptions. Accessibility labels, hints, values, and VoiceOver action
   names are user-visible text too (`cylchatkit-accessibility`): they go through the macro with the other strings.
5. Run `python3 scripts/check-localizations.py` and `plutil -lint <file>` (macOS). The script compares the keys and the
   format specifiers (`%@`, `%1$@`, `%d`) of every language, and fails on a key passed to the macro that is not in the
   table, so a typo cannot ship as a raw key on screen.

Keys are stable ASCII identifiers. CYLTabBarController uses the original Chinese text as the key instead; this
repository does not, because its existing tables use ASCII keys. Do not mix the two styles in one table.

## Add a bundle

1. Core: create `ChatKit/Class/Resources/<Name>.bundle/<lang>.lproj/<Table>.strings` (the podspec already copies
   `ChatKit/Class/Resources/*`). Add a macro `CYL<Domain>LocalizedString(key)` next to `CYLLocalizedStrings`, built on
   `+[NSBundle cyl_bundleForName:class:]` so apps can override it. Never delete or rename an existing core bundle,
   table, or key.
2. Example: create `ChatKit-OC/Example/.../<Name>.bundle/<lang>.lproj/<Table>.strings`, add it to the app target with
   explicit file references in `ChatKit-OC.xcodeproj` (resources build phase; keep `objectVersion = 46`), and add a macro
   `LCCK<Domain>LocalizedString(key, defaultValue)` in `LCCKExampleConstants.h`.
3. One macro per bundle and table. The macro body is the only place that names the bundle and table.

## Acceptance checklist

- [ ] Core has a localization macro and the example has a different one (at least two distinct macros).
- [ ] Each macro names its own layer's bundle and table, and no macro reads the other layer's bundle.
- [ ] No new `NSLocalizedString` or `NSLocalizedStringFromTableInBundle` call outside a macro definition.
- [ ] No new hard-coded non-English display text.
- [ ] Every language of every touched table has the same keys and specifiers.
- [ ] Every key passed to a macro exists in its table, and accessibility strings are localized too.
- [ ] `python3 scripts/check-localizations.py` passes (CI job `Localization tables`).
- [ ] Existing deviations and unfinished work are recorded as `TODO` in `docs/localization.md`.

## Swift

Swift cannot import function-like macros. A Swift example therefore defines its own accessor function for its bundle
(one global function per example bundle, named like the Objective-C macro), and core exposes a function form of
`CYLLocalizedStrings` for Swift callers (annotated with `NS_SWIFT_NAME`). Fix this in core, not in the example (see
`AGENTS.md`, "Swift examples and Swift compatibility of core"). Extend `scripts/check-localizations.py` to recognize
the Swift accessors when the first Swift example lands.

## Common mistakes

- Putting example strings in `Other.bundle`, or pointing an example macro at a core bundle.
- Adding a language file to one table and forgetting its sibling languages.
- Moving `EmojiLocalizable` or other core resources into a new bundle without checking how apps look them up.
- Calling `NSLocalizedString` in a view controller, which hides the bundle and table from the one place that defines
  them.
