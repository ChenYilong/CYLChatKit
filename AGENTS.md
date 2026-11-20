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
  - `.agents/skills/cylchatkit-accessibility/SKILL.md` (before adding or changing any control, text, cell, or screen)
  - `.agents/skills/cylchatkit-commit/SKILL.md` (before every commit)
  - `.agents/skills/cylchatkit-cicd/SKILL.md` (before running a build or test, or changing the workflow)
  - `.agents/skills/cylchatkit-comments/SKILL.md` (before writing or changing a public declaration or its comment)

## Objective-C and API rules

- Core (`ChatKit/`) uses the `CYL` prefix for classes, protocols, typedefs, enums, constants, and C functions, following the CYLTabBarController naming rules. Category methods and properties use `cyl_` (setter `setCyl_name:`). Core contains no `LCCK`, `lcck_`, `AVOS`, or `AVIM` (in any letter case); keep it that way. Comments describe LeanCloud types in words instead of naming them. Keep vendor code and third-party APIs unchanged.
- Each header/implementation filename must match its primary type. Name new category files `Type+CYLExtension.h` / `.m`.
- **Guard every Liquid Glass (iOS 26 and later) API.** Code that uses SDK APIs newer than the iOS 15 deployment target, above all the Liquid Glass material (`UIGlassEffect` and other iOS 26 symbols), sits behind both guards: at compile time `#if defined(__IPHONE_26_0) && __IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_26_0` (the library must still build with an older Xcode), and at run time `if (@available(iOS 26.0, *))`. Core keeps this code in `CYLChatLiquidGlass`, whose `+isActive` also honors the app's `UIDesignRequiresCompatibility` opt-out, as CYLTabBarController's `+[CYLConstants isLiquidGlassActive]` does. Other core files call that class and keep their existing styling when it answers NO or nil, so they contain no guards and no iOS 26 symbols. A Liquid Glass style adaptation only changes the look, never behavior, layout constants, or public API on an older SDK or system.
- Before adding a `CYL` name to core, check that `CYLTabBarController` (the commit pinned in `ChatKit-OC/Podfile`, see "CYLTabBarController dependency") and `CYLDeallocBlockExecutor` (a core dependency) do not already define the same class, header, macro, constant, or category selector. The pinned commit moves, so repeat the check when you work on a name that could clash. Use a `CYLChat` prefix for core names that would collide (for example `CYLChatBaseViewController`, `CYLChatConstants.h`).
- **Naming rule, copied from CYLTabBarController's AGENTS.md.** Every class, protocol, type, function, and constant starts
  with `CYL`. Category methods and properties start with `cyl_` (also for extensions of system types in other languages).
  Name each file after its main type. When code is copied in from another project, remove its foreign prefix (`AG`,
  `JZ`, `XX`, `My`, `QMUI`, `JX`, `LCCK`, and so on), rename its symbols, files, and references, and keep a credit comment
  with the original name and source. The rule applies to sample apps too (CYLTabBarController's is `CYLDemoTheme`).
  Already shipped public names stay (the rule is for new code); see `.agents/skills/cylchatkit-objc-naming/SKILL.md` and
  `docs/naming.md`.
- The facade class is `CYLChatKit` (it was `LCChatKit`; renamed in the naming review recorded in `docs/naming.md`).
  `ChatKitHeaders.h` keeps its name. The core resource names `Other.bundle` and the table `LCChatKitString` also keep their
  names (never rename a core bundle, table, or key).
- The demo (`ChatKit-OC/`) follows the same rule with the `CYLDemo` prefix (`CYLDemoUser`, `CYLDemoChatKitExample`),
  `CYLDEMO_` for macros, and `cyl_demo_` for its category methods, so a demo name never clashes with a core `CYL` name
  or with a `cyl_` selector of core or CYLTabBarController. It uses the core `CYL` API. The demo contains no `LCCK` or
  `lcck_`.
- Vendored libraries keep their upstream identifiers only when they are pre-built binaries or C libraries that cannot be
  renamed (the `lame` framework) and third-party APIs used by name (LeanCloud `AVIM*` types, CYLTabBarController); every vendored Objective-C source file in core or the demo follows the copied-code rule.
- Do not rename released symbols just to normalize naming beyond the changes listed in `docs/naming.md`.
- **Code comments.** Read `.agents/skills/cylchatkit-comments/SKILL.md` before writing or changing a public declaration.
  - A public API comment is a documentation comment that callers see in Quick Help, DocC, and the generated interface,
    so it is written for Objective-C and Swift callers at once. In iOS code (Objective-C headers) use this block, never
    stacked `//` or `///` lines:

    ```objc
    /*!
     * One-sentence summary.
     *
     * @param name What the parameter means, including nil behavior.
     * @return What is returned, including when it is nil.
     */
    ```

    One block per declaration, placed directly above it. Do not use `/** */` (one style only), and do not stack
    `//` or `///` lines to build a multi-line comment.
  - **Single-line public API comments use the same block format.** A one-sentence comment is still written as
    `/*!` / ` * text` / ` */` on its own lines above the declaration: no `/*! text */` on one line, no trailing
    `/**< */`, `/*!< */`, `///<`, or `//` after a declaration (enum cases and properties included). One comment format per
    public API file, for multi-line and single-line comments alike. This applies to every platform and language: pick
    the platform's official doc-comment form below and use it for every public API comment in that file, short or long.
  - Swift: every public API comment, one line or several, is one `/** ... */` block with Markup (`- Parameter`,
    `- Returns`, `- Note`), never `///` lines, so a file has one format.
  - **The official rules decide the format.** Every comment format follows the official documentation rules of its
    platform and language; where this section and the official rule differ, the official rule wins and this section is
    corrected. The two project rules stay on top of it: one comment format per public API file, and single-line comments
    in the same form as multi-line ones.
    - Block form is official, so single-line comments are blocks too: Objective-C (Apple and clang doc comments, `/*! ... */`,
      chosen above), Swift (DocC reads `/** ... */`; this project uses it so Swift matches the Objective-C headers),
      Kotlin (KDoc `/** ... */`), Java (Javadoc `/** ... */`), TypeScript (TSDoc `/** ... */`), JavaScript
      (JSDoc `/** ... */`), Python (PEP 257 docstrings, triple quotes on their own lines even for one sentence).
    - Line form is official: Dart and Flutter (Effective Dart: `///`), Go (Go Doc Comments: `//` directly above the
      declaration, starting with its name), Rust (`///`; the style guide prefers line doc comments), C# (`///` with XML
      tags such as `<summary>`). There every public API comment in the file, single-line or multi-line, uses that line
      form; never mix it with block comments in the same file.
    - A language whose tool has only one doc-comment form uses it for every comment in the file.
  - Comments are English. Describe LeanCloud types in words in core. Do not document commented-out code, and delete it
    instead of keeping it.
  - `scripts/check-comments.py` (CI job `Naming and comment rules`) fails on `///`, stacked `//`, `/** */`, one-line
    `/*! text */`, and trailing `/**<` / `///<` / `//` comments in core headers. Record undocumented public declarations as `TODO` in `docs/api-comments.md`.
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

### Default integration in the examples: PlusButton with a plus child, from a local configuration file

Every example in this project integrates CYLTabBarController the same way unless a task explicitly says otherwise:

- **With a PlusButton that has a `plusChildViewController`.** The tab bar shows a PlusButton, and selecting it shows a page
  of its own (the plus child view controller), not only a tap action. In a configuration this is
  `CYLTabBarControllerPlusButton` with `CYLTabBarItemPageIdentifier` (the plus button's own page), and in code it is
  `+plusChildViewController` with `+indexOfPlusButtonInTabBar` (required when a plus child exists). Do not ship an
  example without a PlusButton, or with a PlusButton that only runs an action, unless asked.
- **Initialized from a local configuration file.** The tab bar is built from a file inside the app bundle with
  `+[CYLTabBarController tabBarControllerWithConfigurationFile:error:]` (Swift: the factory imports as the throwing
  initializer `try CYLTabBarController(configurationFile:)`), not assembled in code with `tabBarItemsAttributes` and view controller arrays. The file holds the tabs,
  titles, images, style, context, and the `CYLTabBarControllerPlusButton` entry; each tab and the plus button name their
  page with `CYLTabBarItemPageIdentifier`, and the app registers those pages with `CYLTabBarPageRegistry`
  (`sharedRegistry`, or its own registry passed as `CYLTabBarControllerPageRegistry`). Use a format the parser supports
  (JSON is the default choice); keep the file next to the example's other resources with an explicit file reference.
  Strings in the file follow the localization rules (keys resolved through the example's bundle, see
  CYLTabBarController's `docs/Configuration-Localization.md`).
- Follow CYLTabBarController's own documentation at the pinned commit: `docs/Configuration-File.md`,
  `docs/Tab-Page-Registry.md`, `docs/PlusButton.md`, and `docs/Plus-Child-Theme-Switching-Test.md`. If its API differs
  from these names, its code wins: update this section and the skill in the same change.
- CI screenshots and the accessibility dump cover the plus child page too (select it, then shoot), and the PlusButton has
  an accessibility label and identifier like every control.
- Record deviations of an existing example as `TODO` in `docs/ci.md` (CYLTabBarController section).

## Swift examples and Swift compatibility of core

- **Every iOS example is written in Swift.** New example code is Swift only. The demo (`ChatKit-OC/`) is
  Swift only and has no Objective-C files; never add one (not even a bridging header). Record remaining work as `TODO` in
  `docs/swift-guide.md`. Examples import only the library module (`import CYLChatKit`)
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
   defines its own macro that reads a string from an example bundle (`CYLDemoExampleLocalizedString(key, defaultValue)` in
   `CYLDemoExampleConstants.h`). Vendored macros (such as `DateToolsLocalizedStrings`) do not count. Where a platform has
   no macros, a single function or helper per layer is the equivalent, with the same rules.
   `scripts/check-localizations.py` (CI job `Localization tables`) fails when a layer has no such macro, when both
   layers use the same name, or when a macro reads a bundle that belongs to the other layer.
2. **A macro names its bundle and table in exactly one place, its own body.** Feature code passes only a key. A new
   bundle gets a new macro (`CYL<Domain>LocalizedString` in core, `CYLDemo<Domain>LocalizedString` in the example); never
   point one macro at several bundles and never call `NSLocalizedString` or `NSLocalizedStringFromTableInBundle`
   directly in feature code.
3. **No hard-coded display text in new or changed code.** Every string literal that is shown to a user, or read to a
   VoiceOver user (accessibility labels, hints, values, and custom action names), or written to a log, assert, or debug
   message, and that contains non-English text goes through the layer's macro, with
   `[NSString stringWithFormat:]` for values. Resource identifiers (image names) and documented localization keys are
   exempt. Existing literals are tracked in `docs/localization.md`.
4. **Tables are complete.** Add every new key to every language of its table in the same commit, with the same `%@` /
   `%1$@` specifiers, so every language of a table has the same key set. Keys are stable ASCII identifiers (this
   repository's tables already use them). Check `.strings` files with `plutil -lint` and
   `scripts/check-localizations.py`, which also compares the format specifiers of each key between languages and fails
   when a literal key passed to a layer's macro is not in its table (a typo).
5. **The two layers stay isolated.** Core never reads an example bundle, the example never puts its strings in a core
   bundle, and the example's macros never read a core bundle. Apps can override core strings with
   `CustomizedChatKit.<Name>.bundle` (see `+[NSBundle cyl_bundleForName:class:]`).

### Structure and bundles

- **iOS structure:** put every localization table in a `.bundle`: `<Name>.bundle/<lang>.lproj/<Table>.strings` (and `.stringsdict` for plurals). Several bundles are allowed, one per feature or vendor domain (for example `Other.bundle`, `DateTools.bundle`, `CYLPBLocalizations.bundle`). Do not add `.lproj` folders outside a bundle. The only exception is what the system reads from the app's main bundle (localized storyboards such as `LaunchScreen`, and `InfoPlist.strings`), which stays in app-level `.lproj` folders.
- **Core bundles (`ChatKit/Class/Resources/*.bundle`) are always kept.** Never delete or rename a core bundle, table, or key: clients depend on them. Update them cautiously: add keys or languages, keep existing keys stable, change existing values only when the task requires it. The podspec copies `ChatKit/Class/Resources/*`, so a new core bundle placed there ships without podspec changes.
- **Example (`ChatKit-OC/`) strings live in example-level bundles**, for example `ChatKit-OC/Example/Class/Module/Other/CYLDemoExample.bundle`, added to the app target with explicit file references. Never put example strings in a core bundle, and core never reads an example bundle.
- **Other platforms** follow the same rules with their own folder package: Android `res/values-<lang>/` in the library or app module, web `locales/<lang>/<namespace>.json`, Flutter `.arb` files per package. Keep one accessor per layer (a function where the platform has no macros), keep the core resources and keys stable, and keep example resources in the example. Swift cannot import function-like macros, so a Swift example defines its own accessor function for its bundle, and core exposes a function form of its macro for Swift callers.
- Record existing deviations and unfinished localization work as `TODO` in `docs/localization.md`.

## Accessibility

Copied and adapted from CYLTabBarController's AGENTS.md ("Accessibility is required everywhere"). Accessibility is
required everywhere in this project: the library (`ChatKit/`, shipped through CocoaPods) and every example fully support
blind and low-vision users (VoiceOver, Voice Control, Switch Control, Dynamic Type, and the system display settings).
This applies to new code, to code you change, and to existing code you review: fix what is missing when you meet it.
Read `.agents/skills/cylchatkit-accessibility/SKILL.md` before touching a control, a text, a cell, or a screen.

- **Blind users (VoiceOver, Voice Control, Switch Control).**
  - Every control and every piece of text is an accessibility element with a meaningful label, and a value, a trait
    (button, selected, static text), a state, and a hint where they help. Image-only buttons always get a label.
  - A list row, a message row, or a contact row is one element (name, content, unread count, status in one label), not a
    dozen stops on avatar, name, bubble, and icons; its taps (avatar, resend, play) are `accessibilityActivate` and
    `accessibilityCustomActions`.
  - Hide purely decorative views from accessibility (`isAccessibilityElement = NO`, `accessibilityElementsHidden`); never
    leave an interactive view without a label.
  - Every interactive element has a stable, non-localized `accessibilityIdentifier` (`CYLChatBarSendButton`) for UI tests.
  - Labels, hints, values, and action names are localized: they go through the layer's localization macro like any other
    text (see the localization criteria), so VoiceOver speaks the app's language.
  - When a panel or screen changes under the user, post `UIAccessibilityLayoutChangedNotification` or
    `UIAccessibilityScreenChangedNotification`.
- **Low-vision users (visual accessibility).**
  - All text scales with Dynamic Type: system text styles or `UIFontMetrics` with `adjustsFontForContentSizeCategory`,
    with a `maximumPointSize` only where the layout cannot grow, and layouts that survive the accessibility sizes.
  - State is never conveyed by color alone; text and controls keep enough contrast; touch targets are at least 44 x 44 pt
    where the design allows.
  - Respect Reduce Transparency, Increase Contrast, Bold Text, and Reduce Motion. The Liquid Glass material (see "Guard
    every Liquid Glass API") adapts to them by itself; never force a material or an animation on top of that.
- **Verify through accessibility first.** Automated checks drive the UI through accessibility: find elements by their
  accessibility label or identifier, and fall back to coordinates only when no element can be found, then file the
  missing label as a bug and fix it. In CI the demo writes the accessibility tree of each screen (`-CYLDemoAccessibilityDump YES`),
  `scripts/demo-screenshots.sh` prints it and fails when an expected element is missing (`expect_accessibility`), and it
  takes a screenshot at a large Dynamic Type size. Add an expectation for every control a CI screen shows.
- **Other platforms** use their own APIs with the same rules: Android `contentDescription`, `importantForAccessibility`,
  `stateDescription` (TalkBack); React Native `accessible`, `accessibilityRole`, `accessibilityLabel`; Flutter
  `Semantics`, `ExcludeSemantics`.
- Record gaps as `TODO` in `docs/accessibility.md`. The convention: every component and every text of this project
  supports accessibility. A change that adds a control or a text without it is not done.

## CI/CD and test environments

Read `.agents/skills/cylchatkit-cicd/SKILL.md` before running a build or test, or changing the workflow.

| Where | System | Xcode | How it runs |
|:---|:---|:---|:---|
| **GitHub CI/CD** (`.github/workflows/ios.yml`, default for iOS; confirm against CYLTabBarController's `ios.yml`) | **macOS 26** (runner label `macos-26`; Linux jobs use `ubuntu-latest`) | the Xcode that the `macos-26` image provides | Every push and pull request; the macOS jobs build the library, the demo, and the podspec, and run the simulator screenshots |
| **Local run** | **macOS 27** | **Xcode 27** | On the user's own Mac, without GitHub CI/CD: build, run the simulator directly, and test with Xcode 27 |

- "Local run" means exactly that: the work happens on the user's Mac with Xcode 27 and the Simulator, and nothing goes
  through GitHub Actions. Use the same scripts as CI (`scripts/ci-build-example.sh`, `scripts/demo-screenshots.sh`,
  `scripts/update-cyltabbarcontroller-commit.sh`) so both environments build the same thing.
- An agent session in the cloud has no Xcode (Linux): it can only run the static checks. Its compile results come from
  GitHub CI/CD (macOS 26); when the user asks for a local run, hand over the commands for macOS 27 and Xcode 27 instead of
  guessing.
- The two environments can differ (SDK, Simulator runtimes, iOS 26 and iOS 27 behavior). Report which one produced a
  result: say "GitHub CI (macOS 26)" or "local (macOS 27, Xcode 27)", and do not treat one as proof for the other. Keep the
  Liquid Glass guards (see "Guard every Liquid Glass API") valid on both SDKs.
- Keep the deployment target at iOS 15.0 in both. Do not raise it because Xcode 27 or macOS 26 allows newer APIs.
- The workflow runs macOS jobs on `${{ vars.MACOS_RUNNER || 'macos-26' }}`; the default stays `macos-26`.
- **Always check the reference workflow first.** Before running or changing anything that depends on the GitHub runner
  (macOS version, Xcode version, runner label), read CYLTabBarController's
  [`.github/workflows/ios.yml`](https://github.com/ChenYilong/CYLTabBarController/blob/master/.github/workflows/ios.yml) at its
  current state to confirm the environment, and keep this repository's workflow in step with it. At the last check
  (CYLTabBarController `4209e37`, 2026-11-10) it used `runs-on: ${{ vars.MACOS_RUNNER || 'macos-26' }}` (macOS 26,
  Apple Silicon, default Xcode 26.x) and documented `xcode-27` as the value of the repository variable `MACOS_RUNNER` for the
  Xcode 27 public preview. For iOS the default GitHub CI/CD environment is **macOS 26** unless that file says otherwise.
- **A local run ignores this restriction.** When the user asks for a local run, do not look up the workflow or the runner:
  the system is macOS 27 with Xcode 27, on the user's own Mac, using the Simulator directly.

## CI and demo screenshots

- `.github/workflows/ios.yml` and `docs/ci.md` define CI. Keep the workflow, its scripts under `scripts/`, and `docs/ci.md` consistent.
- Every CI run that builds code (library, demo, project, podspec, dependency, or workflow changes) must produce screenshots of the running demo (`ChatKit-OC`) from the `Simulator screenshots` job. When you report the result of such a run, show the screenshots: download the `demo-screenshots` artifact, or decode the base64 blocks the job prints between `===BEGIN SCREENSHOT <name>===` and `===END SCREENSHOT <name>===`, and send the images to the user.
- If a run produces no screenshots, first find out why and change CI (workflow, `scripts/demo-screenshots.sh`, or the demo's `-CYLDemoScreen` launch hook) so that later runs do produce them, then run CI again. Only if that still fails, state the exact reason (failing job, step, and log excerpt) and record it as a `TODO` in `docs/ci.md`.
- Never report a build as verified from compilation alone when the screenshots are missing.

## Git changes

- Keep changes scoped to the requested work and do not stage AppleDouble (`._*`) or other generated files.
- Ignore malformed metadata/artifact names such as `..claude/`, `..git/`, `..github/`, `..gitignore`, and `..pullapprove.yml`; the repository `.gitignore` also excludes AppleDouble files such as `._.pullapprove.yml` and `._ChatKit`.
- **Before every commit, update `.gitignore`.** Compare it with CYLTabBarController's `.gitignore` (https://github.com/ChenYilong/CYLTabBarController/blob/master/.gitignore) and add every ignored file and folder pattern it has that this file lacks. Change only project names that do not match (`CYLTabBarController.xcodeproj` becomes `ChatKit/ChatKit.xcodeproj` and `ChatKit-OC/ChatKit-OC.xcodeproj`); leave out paths for folders that exist only in CYLTabBarController and say so in the file header. Keep this repository's own entries. Then run `git status --short --ignored` and confirm no untracked project file became ignored.
- Before staging, inspect `git status` and confirm no ignored or generated artifacts are included. `.gitignore` does not untrack files already committed; remove only specifically verified artifact paths from the index, preserving all real project content.
- Never run broad deletion commands against `.git/objects` or other Git internals. Do not delete AppleDouble files in Git internals as a cleanup shortcut; leave them untouched unless a specific file is proven corrupt and a safe Git-aware repair is planned.
- Use concise English commit messages. Never commit credentials, signing assets, or local build output.
- Before every commit, review the changed scope and relevant documentation for unfinished work. Record every incomplete or unverified item with the literal keyword `TODO` in the most relevant existing document under `docs/`; include remaining implementation details, constraints, known defects, verification steps, and API design or compatibility risks. Do not call an item complete based only on reserved keys, stubs, or compilation.
- **Every commit message body must contain the author line `By @ChenYilong <luohanchenyilong@163.com>`**, on its own
  line, after the description and before any trailers (such as `Claude-Session:`). Commits made by an agent carry it too.
  See `.agents/skills/cylchatkit-commit/SKILL.md`. The `commit-msg` hook below only removes `Co-Authored-By:` lines, so
  this line stays.
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
