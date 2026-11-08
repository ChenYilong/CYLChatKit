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

- Follow the established `LCCK` prefix for ChatKit-owned public classes, protocols, enums, and constants. Keep vendor code and third-party APIs unchanged.
- Preserve existing public names, including historical spellings, to avoid breaking clients. New identifiers should follow the naming skill.
- Keep headers and implementations named after their primary class; category files use `Type+LCCKExtension`.
- Use full HTTPS GitHub issue URLs in code comments that explain issue-specific fixes.
- Write new comments and repository instructions in English.

## Xcode and CocoaPods configuration

- Both Xcode projects use `objectVersion = 46` and `compatibilityVersion = "Xcode 3.2"`. Do not introduce synchronized-folder groups or newer project-format-only keys.
- The library, demo, podspec, and both Podfiles use iOS 15.0 as their minimum deployment target. Keep the values aligned.
- Preserve the existing scheme, target, bundle identifier, signing, and source membership unless the task specifically requires changing them.
- When changing a project file, validate both project parsing and the effective deployment targets. Do not let Xcode rewrite unrelated project sections.
- If dependency declarations change, update the corresponding lockfile with CocoaPods; do not make unrelated dependency upgrades.

## Git changes

- Keep changes scoped to the requested work and do not stage AppleDouble (`._*`) or other generated files.
- Ignore malformed metadata/artifact names such as `..claude/`, `..git/`, `..github/`, `..gitignore`, and `..pullapprove.yml`; the repository `.gitignore` also excludes AppleDouble files such as `._.pullapprove.yml` and `._ChatKit`.
- Before staging, inspect `git status` and confirm no ignored or generated artifacts are included. `.gitignore` does not untrack files already committed; remove only specifically verified artifact paths from the index, preserving all real project content.
- Never run broad deletion commands against `.git/objects` or other Git internals. Do not delete AppleDouble files in Git internals as a cleanup shortcut; leave them untouched unless a specific file is proven corrupt and a safe Git-aware repair is planned.
- Use concise English commit messages. Never commit credentials, signing assets, or local build output.
