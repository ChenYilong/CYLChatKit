---
name: cylchatkit-objc-naming
description: "Objective-C naming and API compatibility conventions for CYLChatKit. Use when adding or reviewing library classes, protocols, categories, properties, methods, or constants."
---

# CYLChatKit Objective-C naming

Follow the existing public API style; do not rename released symbols as a cleanup.

## Identifiers

- Prefix ChatKit-owned public classes, protocols, enums, and exported constants with `LCCK` (for example, `LCCKMessage` and `LCCKConversationViewController`).
- New class files must begin with the repository's established class prefix, `LCCK`; do not import `CYL` or another unrelated prefix from a different project. If an identifier is copied or adapted from another project, rename the new identifier and file to follow CYLChatKit conventions.
- Use UpperCamelCase for types and enum cases, and lowerCamelCase for properties, parameters, and selector components.
- Use a descriptive `LCCK`-prefixed name for file-scope constants. Keep implementation-private constants `static`.
- Keep third-party and vendored identifiers in their upstream naming style.

## Files and categories

- Name a class header and implementation after the class: `LCCKMessage.h` and `LCCKMessage.m`.
- Name category files `Type+LCCKExtension.h` / `.m`, and use the same category name in the declaration.
- Prefix every new category method with `lcck_` to avoid collisions. Do not use `cyl_` unless CYLChatKit itself adopts that convention in a deliberate, repository-wide API change.
- Place new files in the existing `Model`, `Controller`, `View`, `Tool`, or `Service` hierarchy that matches their responsibility.

## API compatibility

- Do not rename or remove existing public symbols, even when a historical spelling or acronym looks inconsistent.
- Keep public declarations in headers and implementation-only helpers private to `.m` files.
- Add complete HTTPS issue links in comments when a code change is specifically tied to an issue.
- Write new naming guidance, skills, code comments, and project documentation in English.
