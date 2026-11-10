# CYLChatKit agent instructions

CYLChatKit is a legacy Objective-C chat UI framework and demo. The README marks the project as deprecated. Preserve existing behavior and public APIs unless a requested issue fix requires a change.

## Project layout and source of truth

- `ChatKit/` contains the library, its Xcode project, and library Podfile.
- `ChatKit-OC/` contains the demo, its Xcode project, and demo Podfile.
- `CYLChatKit.podspec` defines the published library target.
- For behavior, code is authoritative; keep related project configuration and documentation consistent with it.
- Read the applicable project skill before changing Xcode settings or introducing public Objective-C symbols:
  - `.agents/skills/cylchatkit-xcode-compat/SKILL.md`
  - `.agents/skills/cylchatkit-objc-naming/SKILL.md`

## Objective-C and API rules

- Core (`ChatKit/`) uses the `CYL` prefix for classes, protocols, typedefs, enums, constants, and C functions, following the CYLTabBarController naming rules. Category methods and properties use `cyl_` (setter `setCyl_name:`). Core contains no `LCCK`, `lcck_`, `AVOS`, or `AVIM` (in any letter case); keep it that way. Comments describe LeanCloud types in words instead of naming them. Keep vendor code and third-party APIs unchanged.
- Each header/implementation filename must match its primary type. Name new category files `Type+CYLExtension.h` / `.m`.
- Before adding a `CYL` name to core, check that `CYLTabBarController` (linked by the demo) and `CYLDeallocBlockExecutor` (a core dependency) do not already define the same class, header, macro, constant, or category selector. Use a `CYLChat` prefix for core names that would collide (for example `CYLChatBaseViewController`, `CYLChatConstants.h`).
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
- If dependency declarations change, update the corresponding lockfile with CocoaPods; do not make unrelated dependency upgrades.
- Before committing Xcode project changes, verify both `.pbxproj` files retain the required format, parse them with `xcodeproj`, and run `xcodebuild -list` for both projects. Report any build failure separately from project parsing.

## Git changes

- Keep changes scoped to the requested work and do not stage AppleDouble (`._*`) or other generated files.
- Ignore malformed metadata/artifact names such as `..claude/`, `..git/`, `..github/`, `..gitignore`, and `..pullapprove.yml`; the repository `.gitignore` also excludes AppleDouble files such as `._.pullapprove.yml` and `._ChatKit`.
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
