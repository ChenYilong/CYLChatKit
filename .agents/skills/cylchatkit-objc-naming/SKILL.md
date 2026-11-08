---
name: cylchatkit-objc-naming
description: "Objective-C naming and API compatibility conventions for CYLChatKit. Use when adding or reviewing library classes, protocols, categories, properties, methods, or constants."
---

# CYLChatKit Objective-C naming

Follow the existing public API style; do not rename released symbols as a cleanup.

## Identifiers

- Prefix ChatKit-owned public classes, protocols, enums, and exported constants with `LCCK` (for example, `LCCKMessage` and `LCCKConversationViewController`).
- Use UpperCamelCase for types and enum cases, and lowerCamelCase for properties, parameters, and selector components.
- Use a descriptive `LCCK`-prefixed name for file-scope constants. Keep implementation-private constants `static`.
- Keep third-party and vendored identifiers in their upstream naming style.

## Files and categories

- Name a class header and implementation after the class: `LCCKMessage.h` and `LCCKMessage.m`.
- Name category files `Type+LCCKExtension.h` / `.m`, and use the same category name in the declaration.
- Place new files in the existing `Model`, `Controller`, `View`, `Tool`, or `Service` hierarchy that matches their responsibility.

## API compatibility

- Do not rename or remove existing public symbols, even when a historical spelling or acronym looks inconsistent.
- Use the `lcck_` prefix for new category methods where needed to avoid collisions with system or dependency APIs.
- Keep public declarations in headers and implementation-only helpers private to `.m` files.
- Add complete HTTPS issue links in comments when a code change is specifically tied to an issue.
