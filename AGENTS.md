# CYLChatKit agent instructions

CYLChatKit is a legacy Objective-C chat UI framework and demo. The README marks the project as deprecated. Preserve existing behavior and public APIs unless a requested issue fix requires a change.

## Project layout and source of truth

- `ChatKit/` contains the library, its Xcode project, and library Podfile.
- `ChatKit-OC/` contains the demo, its Xcode project, and demo Podfile.
- `CYLChatKit.podspec` defines the published library target.
- For behavior, code is authoritative; keep related project configuration and documentation consistent with it.
- Read the applicable project skill before changing Xcode settings, introducing public Objective-C symbols, or touching localized strings:
  - `.agents/skills/cylchatkit-xcode-compat/SKILL.md`
  - `.agents/skills/cylchatkit-objc-naming/SKILL.md`
  - `.agents/skills/cylchatkit-localization/SKILL.md` (before adding or changing localized strings, tables, or bundles)

## Objective-C and API rules

- Core (`ChatKit/`) uses the `CYL` prefix for classes, protocols, typedefs, enums, constants, and C functions, following the CYLTabBarController naming rules. Category methods and properties use `cyl_` (setter `setCyl_name:`). Core contains no `LCCK`, `lcck_`, `AVOS`, or `AVIM` (in any letter case); keep it that way. Comments describe LeanCloud types in words instead of naming them. Keep vendor code and third-party APIs unchanged.
- Each header/implementation filename must match its primary type. Name new category files `Type+CYLExtension.h` / `.m`.
- Before adding a `CYL` name to core, check that `CYLTabBarController` (the commit pinned in `ChatKit-OC/Podfile`, see "CYLTabBarController dependency") and `CYLDeallocBlockExecutor` (a core dependency) do not already define the same class, header, macro, constant, or category selector. The pinned commit moves, so repeat the check when you work on a name that could clash. Use a `CYLChat` prefix for core names that would collide (for example `CYLChatBaseViewController`, `CYLChatConstants.h`).
- The demo (`ChatKit-OC/`) keeps the `LCCK` prefix for its own symbols and uses the core `CYL` API.
- `LCChatKit` and `ChatKitHeaders.h` keep their names. Do not rename released symbols to normalize naming beyond this repository-wide change.
- Write repository instructions, skills, comments, and user-facing documentation in English.
- Preserve existing public names, including historical spellings, to avoid breaking clients. New identifiers should follow the naming skill.
- Use full HTTPS GitHub issue URLs in code comments that explain issue-specific fixes.

## Xcode and CocoaPods configuration

- Both Xcode projects use `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"`. Do not introduce synchronized-folder groups or newer project-format-only keys.
- Keep all project- and target-level iOS deployment settings at iOS 15.0, aligned with the podspec and both Podfiles. Check every build configuration, not just the first matching setting.
- Preserve explicit file references and target membership. Do not add `PBXFileSystemSynchronizedRootGroup` or `PBXFileSystemSynchronizedBuildFileExceptionSet`, `preferredProjectObjectVersion`, or top-level `validationLevel`.
- Preserve the existing scheme, target, bundle identifier, signing, and source membership unless the task specifically requires changing them.
- When changing a project file, validate both project parsing and the effective deployment targets. Do not let Xcode rewrite unrelated project sections.
- Lockfiles (`Podfile.lock` and other `*.lock` files) are not committed, as in CYLTabBarController; `.gitignore` ignores them. Declare every dependency the demo or library needs with an explicit version (or a `:git`/`:commit` pin) in the Podfile or podspec, so `pod install` resolves the same versions without a lockfile. Do not make unrelated dependency upgrades.
- Before committing Xcode project changes, verify both `.pbxproj` files retain the required format, parse them with `xcodeproj`, and run `xcodebuild -list` for both projects. Report any build failure separately from project parsing.

## CYLTabBarController dependency

This project always integrates CYLTabBarController (https://github.com/ChenYilong/CYLTabBarController) through
CocoaPods, never by copying its sources, and never by a released version number.

- **The version is the newest commit, on any branch.** The newest commit may sit on a branch other than `master` or
  `main` (a feature or fix branch). Decide by the commit (committer) timestamp across the tip of every branch of the
  repository, not by tag, release, or default branch. Pin it as a commit:
  `pod 'CYLTabBarController', :git => 'https://github.com/ChenYilong/CYLTabBarController.git', :commit => '<40-character sha>'`.
  The Podfile line is rewritten, never edited by hand.
- **Find it before every build.** Run `scripts/update-cyltabbarcontroller-commit.sh` before each build, local or CI. It
  fetches the tip of every branch, picks the newest commit by timestamp, checks that the commit has
  `CYLTabBarController.podspec` in its root, rewrites the `pod 'CYLTabBarController'` line in `ChatKit-OC/Podfile`, and
  prints the commit, its branch, and its UTC time. `scripts/ci-build-example.sh` and `scripts/demo-screenshots.sh`
  call it themselves. In CI the job `Resolve CYLTabBarController commit` resolves it once per run and passes it to the
  build jobs in `CYLTABBARCONTROLLER_COMMIT`, so all jobs of a run build the same commit, and prints it in the job
  summary. Also run the script before committing a change that touches the Podfile, and commit the line it writes.
- **Only if this project is itself named CYLTabBarController** (it is not: this project is CYLChatKit), depend on it
  locally instead: `pod 'CYLTabBarController', :path => '<relative path to the folder that contains CYLTabBarController.podspec>'`,
  with no commit lookup. Every other project, this one included, uses the commit form.
- **Report breakage by commit.** The newest commit can be work in progress. If it breaks the build, report the commit,
  its branch, and the error, and fix what this project can fix. Do not pin an older commit to get green unless the user
  asks for it.
- **Name clashes are checked against that commit.** Compare headers, types, macros, constants, and category selectors
  (same class and selector) of core with the pinned commit's `CYLTabBarController/` folder. Record open clashes as `TODO`
  in `docs/ci.md`.

## Swift examples and Swift compatibility of core

- **Every iOS example is written in Swift.** New example code is Swift only. The existing Objective-C demo
  (`ChatKit-OC/`) is migrated to Swift; until that is done, do not add Objective-C files to it, and record the
  remaining work as `TODO` in `docs/swift-guide.md`. Examples import only the library module (`import CYLChatKit`)
  and follow CYLTabBarController's Swift demos (CocoaPods with `use_frameworks!`, Swift 5).
- **Fix Objective-C interop problems in core, not in the example.** When Swift example code meets an Objective-C API
  that imports badly (implicitly unwrapped optionals, `Any` collections, awkward names, prefixed enum cases, untyped
  string constants), change the core header so it imports cleanly, following the Swift API Design Guidelines:
  - nullability: `NS_ASSUME_NONNULL_BEGIN`/`END` with explicit `nullable` (block parameters included);
  - lightweight generics on collections (`NSArray<NSString *> *`, `NSDictionary<NSString *, id> *`);
  - `NS_ENUM` / `NS_OPTIONS` for enums and `NS_TYPED_ENUM` / `NS_TYPED_EXTENSIBLE_ENUM` for string constants, so cases
    import without their type prefix (`CYLMessageMediaTypeText` → `.text`);
  - `NS_DESIGNATED_INITIALIZER`, `NS_SWIFT_NAME` for a better Swift name, `NS_REFINED_FOR_SWIFT` or
    `NS_SWIFT_UNAVAILABLE` where a Swift-only shape is needed.
  Do not add Swift wrapper extensions in an example to hide a core API problem.
- **`cyl_` methods follow CYLTabBarController's Swift rules.** Read its
  [Swift guide](https://github.com/ChenYilong/CYLTabBarController/blob/master/docs/Swift-Guide.md) (section 15,
  "Objective-C → Swift name map") and the "Swift-friendly names for underscored protocol methods" rule in its
  [AGENTS.md](https://github.com/ChenYilong/CYLTabBarController/blob/master/AGENTS.md):
  - Category methods keep the `cyl_` prefix in Swift; Objective-C prepositions (`With`, `For`, `At`, `Of`) become
    argument labels (`-cyl_selectTabBarItemWithIdentifier:` → `cyl_selectTabBarItem(withIdentifier:)`). Use
    `NS_SWIFT_NAME` only when the automatic name is wrong.
  - Swift method names must not contain underscores, and a Swift class implementing an Objective-C protocol method
    must use its imported name. So for a `cyl_` **protocol** method that Swift code implements, add a new method with
    the same name minus the underscore, keeping the `cyl` prefix (`-cyl_fooWithBar:` → `-cylFooWithBar:`), give only
    the new method an `NS_SWIFT_NAME`, make the old one `@optional`, and have core call the new one when it is
    implemented, otherwise the old one. Never add `NS_SWIFT_NAME` to an already released method: that changes a
    released Swift API.
- Every adapted API gets a row in the Objective-C → Swift name map in `docs/swift-guide.md`, in the same change.
- CI must build the Swift example and produce its screenshots (see "CI and demo screenshots").

## Internationalization and localization

Localized resources are always several files (one per language and table), so they must be organized in a folder
package, never as loose files. On iOS that package is a `.bundle`; other platforms use their own folder form (see
below). Read `.agents/skills/cylchatkit-localization/SKILL.md` before adding or changing any user-visible string, table,
or bundle.

### Acceptance criteria

These follow CYLTabBarController's localization rules (a single accessor for library strings, no hard-coded display
text, complete tables). A localization change is accepted only when all of them hold:

1. **At least two different localization macros exist, one per layer.** Core (`ChatKit/`) defines a macro that reads a
   string from a core bundle (`CYLLocalizedStrings(key)` in `CYLChatConstants.h`), and the example (`ChatKit-OC/`)
   defines its own macro that reads a string from an example bundle (`LCCKExampleLocalizedString(key, defaultValue)` in
   `LCCKExampleConstants.h`). Vendored macros (such as `DateToolsLocalizedStrings`) do not count. Where a platform has
   no macros, a single function or helper per layer is the equivalent, with the same rules.
   `scripts/check-localizations.py` (CI job `Localization tables`) fails when a layer has no such macro, when both
   layers use the same name, or when a macro reads a bundle that belongs to the other layer.
2. **A macro names its bundle and table in exactly one place, its own body.** Feature code passes only a key. A new
   bundle gets a new macro (`CYL<Domain>LocalizedString` in core, `LCCK<Domain>LocalizedString` in the example); never
   point one macro at several bundles and never call `NSLocalizedString` or `NSLocalizedStringFromTableInBundle`
   directly in feature code.
3. **No hard-coded display text in new or changed code.** Every string literal that is shown to a user, or written to a
   log, assert, or debug message, and that contains non-English text goes through the layer's macro, with
   `[NSString stringWithFormat:]` for values. Resource identifiers (image names) and documented localization keys are
   exempt. Existing literals are tracked in `docs/localization.md`.
4. **Tables are complete.** Add every new key to every language of its table in the same commit, with the same `%@` /
   `%1$@` specifiers, so every language of a table has the same key set. Keys are stable ASCII identifiers (this
   repository's tables already use them). Check `.strings` files with `plutil -lint` and
   `scripts/check-localizations.py`.
5. **The two layers stay isolated.** Core never reads an example bundle, the example never puts its strings in a core
   bundle, and the example's macros never read a core bundle. Apps can override core strings with
   `CustomizedChatKit.<Name>.bundle` (see `+[NSBundle cyl_bundleForName:class:]`).

### Structure and bundles

- **iOS structure:** put every localization table in a `.bundle`: `<Name>.bundle/<lang>.lproj/<Table>.strings` (and `.stringsdict` for plurals). Several bundles are allowed, one per feature or vendor domain (for example `Other.bundle`, `DateTools.bundle`, `CYLPBLocalizations.bundle`). Do not add `.lproj` folders outside a bundle. The only exception is what the system reads from the app's main bundle (localized storyboards such as `LaunchScreen`, and `InfoPlist.strings`), which stays in app-level `.lproj` folders.
- **Core bundles (`ChatKit/Class/Resources/*.bundle`) are always kept.** Never delete or rename a core bundle, table, or key: clients depend on them. Update them cautiously: add keys or languages, keep existing keys stable, change existing values only when the task requires it. The podspec copies `ChatKit/Class/Resources/*`, so a new core bundle placed there ships without podspec changes.
- **Example (`ChatKit-OC/`) strings live in example-level bundles**, for example `ChatKit-OC/Example/Class/Module/Other/LCCKExample.bundle`, added to the app target with explicit file references. Never put example strings in a core bundle, and core never reads an example bundle.
- **Other platforms** follow the same rules with their own folder package: Android `res/values-<lang>/` in the library or app module, web `locales/<lang>/<namespace>.json`, Flutter `.arb` files per package. Keep one accessor per layer (a function where the platform has no macros), keep the core resources and keys stable, and keep example resources in the example. Swift cannot import function-like macros, so a Swift example defines its own accessor function for its bundle, and core exposes a function form of its macro for Swift callers.
- Record existing deviations and unfinished localization work as `TODO` in `docs/localization.md`.

## CI and demo screenshots

- `.github/workflows/ios.yml` and `docs/ci.md` define CI. Keep the workflow, its scripts under `scripts/`, and `docs/ci.md` consistent.
- Every CI run that builds code (library, demo, project, podspec, dependency, or workflow changes) must produce screenshots of the running demo (`ChatKit-OC`) from the `Simulator screenshots` job. When you report the result of such a run, show the screenshots: download the `demo-screenshots` artifact, or decode the base64 blocks the job prints between `===BEGIN SCREENSHOT <name>===` and `===END SCREENSHOT <name>===`, and send the images to the user.
- If a run produces no screenshots, first find out why and change CI (workflow, `scripts/demo-screenshots.sh`, or the demo's `-LCCKDemoScreen` launch hook) so that later runs do produce them, then run CI again. Only if that still fails, state the exact reason (failing job, step, and log excerpt) and record it as a `TODO` in `docs/ci.md`.
- Never report a build as verified from compilation alone when the screenshots are missing.

## Git changes

- Keep changes scoped to the requested work and do not stage AppleDouble (`._*`) or other generated files.
- Ignore malformed metadata/artifact names such as `..claude/`, `..git/`, `..github/`, `..gitignore`, and `..pullapprove.yml`; the repository `.gitignore` also excludes AppleDouble files such as `._.pullapprove.yml` and `._ChatKit`.
- **Before every commit, update `.gitignore`.** Compare it with CYLTabBarController's `.gitignore` (https://github.com/ChenYilong/CYLTabBarController/blob/master/.gitignore) and add every ignored file and folder pattern it has that this file lacks. Change only project names that do not match (`CYLTabBarController.xcodeproj` becomes `ChatKit/ChatKit.xcodeproj` and `ChatKit-OC/ChatKit-OC.xcodeproj`); leave out paths for folders that exist only in CYLTabBarController and say so in the file header. Keep this repository's own entries. Then run `git status --short --ignored` and confirm no untracked project file became ignored.
- Before staging, inspect `git status` and confirm no ignored or generated artifacts are included. `.gitignore` does not untrack files already committed; remove only specifically verified artifact paths from the index, preserving all real project content.
- Never run broad deletion commands against `.git/objects` or other Git internals. Do not delete AppleDouble files in Git internals as a cleanup shortcut; leave them untouched unless a specific file is proven corrupt and a safe Git-aware repair is planned.
- Use concise English commit messages. Never commit credentials, signing assets, or local build output.
- Before every commit, review the changed scope and relevant documentation for unfinished work. Record every incomplete or unverified item with the literal keyword `TODO` in the most relevant existing document under `docs/`; include remaining implementation details, constraints, known defects, verification steps, and API design or compatibility risks. Do not call an item complete based only on reserved keys, stubs, or compilation.
- Use an English Conventional Commit subject compatible with Commitizen. The subject summarizes the completed work; use the body for concise details and remaining tasks. If the detailed description exceeds 50 characters, create or update a suitable `docs/` note and include its link in the commit body. Do not create duplicate tracking documents.

## Commitizen defaults

- **Before every Commitizen-style (`git cz`) commit**, run this first in the repository root, so the vault's auto sync does not commit or push in the middle of it:

  ```sh
  touch .git/hooks/NO_AUTO_SYNC
  ```

- **On any branch other than `master` or `main`, commit and push as soon as the work is written, without asking
  for confirmation.** On `master` or `main`, ask first.

- Use the Commitizen format `{type}{scope}: {emoji}{subject}` with emojis enabled. Omit the scope when none is needed; no scopes are preconfigured. Keep the message between 3 and 64 characters, as configured. In readable commit subjects, separate the emoji and subject with a space as shown in the examples below.
- The interactive type choices, in order, are `test`, `feat`, `fix`, `chore`, `docs`, `refactor`, `style`, `ci`, and `perf`. `release` has a configured type definition but is not in the interactive list; reserve it for an intentional release commit.
- Default type meanings and emojis are: `chore` (build or auxiliary-tool changes, 🤖), `ci` (CI changes, 🎡), `docs` (documentation only, ✏️), `feat` (new feature, 🎸), `fix` (bug fix, 🐛), `perf` (performance improvement, ⚡️), `refactor` (code change that is neither a feature nor a fix, 💡), `style` (markup or formatting only, 💄), `test` (adding missing tests, 💍), and `release` (release commit, 🏹).
- The question sequence is `type`, `scope`, `subject`, `body`, `breaking`, `issues`, and `lerna`. Their prompts ask for the change type, optional component scope, a short imperative subject, longer description, breaking changes, issues closed (for example `#123`), and affected packages; the final confirmation names the affected packages.
- Follow established repository history when it intentionally uses a project-specific emoji instead of the default (for example, CYLTabBarController uses `feat: ✨`, `fix: 🐛`, `docs: 📝`, `chore: 🔧`, and `refactor: ♻️`). Keep commit text in English and the subject concise.

### Commit-message hook before Commitizen commits

Before a Commitizen-style commit, run the following from the repository root:

```sh
cat > .git/hooks/commit-msg << 'HOOKEOF'
#!/bin/sh
tmpfile="$1"
if grep -qi "Co-Authored-By:" "$tmpfile" 2>/dev/null; then
  tmp_clean=$(mktemp)
  grep -vi "Co-Authored-By:" "$tmpfile" > "$tmp_clean"
  cat "$tmp_clean" > "$tmpfile"
  rm -f "$tmp_clean"
fi
HOOKEOF
chmod +x .git/hooks/commit-msg
```

This overwrites the existing `commit-msg` hook and removes every line containing
`Co-Authored-By:`, case-insensitively, including other authors' attribution.
Inspect any existing hook before replacing it. The command assumes `.git` is
a directory and Git uses its default hooks path; linked worktrees and custom
`core.hooksPath` require the appropriate hooks path instead.
