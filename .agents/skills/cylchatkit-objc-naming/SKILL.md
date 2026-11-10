---
name: cylchatkit-objc-naming
description: "Objective-C naming and API compatibility conventions for CYLChatKit. Use when adding or reviewing library classes, protocols, categories, properties, methods, or constants."
---

# CYLChatKit Objective-C naming

Follow the existing public API style; do not rename released symbols as a cleanup.

## Identifiers

- Prefix core (`ChatKit/`) classes, protocols, typedefs, enums, exported constants, and C functions with `CYL` (for example, `CYLMessage` and `CYLConversationViewController`), following the CYLTabBarController naming rules. Enum cases are the type name plus the case, without a `k` prefix (`CYLMessageMediaTypeText`).
- Core must not contain `LCCK`, `lcck_`, `AVOS`, or `AVIM` (in any letter case); `AVIM` in a name becomes `CYLIM`. If an identifier is copied or adapted from another project, rename it and its file to the `CYL` convention.
- Avoid clashes with `CYLTabBarController` and `CYLDeallocBlockExecutor`: if a class, header, macro, constant, or category selector already exists there, use a `CYLChat` prefix instead (`CYLChatBaseViewController`, `CYLChatConstants.h`).
- Use `Delegate` only for delegates; model protocols end in `Protocol` (`CYLConversationProtocol`).
- The demo (`ChatKit-OC/`) keeps `LCCK` for its own symbols.
- Use UpperCamelCase for types and enum cases, and lowerCamelCase for properties, parameters, and selector components.
- Use a descriptive `CYL`-prefixed name for file-scope constants. Keep implementation-private constants `static`.
- Keep third-party and vendored identifiers in their upstream naming style.

## Files and categories

- Name a class header and implementation after the class: `CYLMessage.h` and `CYLMessage.m`.
- Name category files `Type+CYLExtension.h` / `.m`, and use the same category name in the declaration.
- Prefix every category method and property with `cyl_`; a category property's setter is `setCyl_name:`.
- Place new files in the existing `Model`, `Controller`, `View`, `Tool`, or `Service` hierarchy that matches their responsibility.

## Swift compatibility

- Examples are Swift (`AGENTS.md`, "Swift examples and Swift compatibility of core"). Make every new or touched core
  header import cleanly into Swift: nullability, lightweight generics, `NS_ENUM`/`NS_OPTIONS`, typed string constants,
  designated initializers, and `NS_SWIFT_NAME` only where the automatic name is wrong.
- `cyl_` category methods keep the prefix in Swift, with prepositions turned into labels
  (`-cyl_selectTabBarItemWithIdentifier:` → `cyl_selectTabBarItem(withIdentifier:)`), as in CYLTabBarController's
  `docs/Swift-Guide.md` section 15.
- A `cyl_` protocol method that Swift classes implement gets an underscore-free twin (`-cylFooWithBar:`) carrying the
  `NS_SWIFT_NAME`; the old method becomes `@optional` and core calls the twin first. Never add `NS_SWIFT_NAME` to a
  released method.
- Record each adapted API in the name map in `docs/swift-guide.md`.

## API compatibility

- Do not rename or remove existing public symbols, even when a historical spelling or acronym looks inconsistent.
- Keep public declarations in headers and implementation-only helpers private to `.m` files.
- Add complete HTTPS issue links in comments when a code change is specifically tied to an issue.
- Write new naming guidance, skills, code comments, and project documentation in English.
