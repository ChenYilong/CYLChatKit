---
name: cylchatkit-comments
description: "Code comment rules for CYLChatKit, above all public API documentation comments for Objective-C and Swift callers. Use when adding or changing a public declaration, a header, or any multi-line comment."
---

# CYLChatKit code comments

## Public API comments (iOS)

A public API comment must reach callers through documentation tools (Xcode Quick Help, DocC, the Swift generated
interface) in both Objective-C and Swift. Stacked `//` or `///` lines are not reliable for that and are hard to maintain,
so a multi-line comment is always one block:

```objc
/*!
 * Sends a text message to the conversation.
 *
 * @param text The message text. Must not be empty.
 * @param callback Called on the main queue. `error` is nil on success.
 * @return Whether the message was queued.
 */
- (BOOL)sendText:(NSString *)text callback:(nullable CYLBooleanResultBlock)callback;
```

Rules:

- Format `/*!` newline ` * text` newline ` */`, placed directly above the declaration it documents (property, method,
  protocol, class, enum, enum case, exported constant). One block per declaration. Use `/*!` only: no `/** */`.
- First line: a one-sentence summary that starts with a verb or a noun phrase, not the declaration's name.
- Use `@param name`, `@return`, `@note`, `@warning`, `@see`, `@code ... @endcode`. State nullability and empty values, the
  queue a callback runs on, threading, ownership, and side effects when they matter.
- Section banners use `/*! @name Title */` as a block (and `#pragma mark - Title`). Never `///====` lines.
- A short trailing note on the same line as a declaration may use `///<`. A comment that explains private code uses `//`
  in the `.m` file and is not a doc comment.
- File header (`//  File.h`, creator, copyright) stays a `//` block at the top; it is not a doc comment.
- Delete commented-out code. Never document it.
- Write comments in English. Describe LeanCloud types in words in core.
- Document every new public symbol in the same change. Existing undocumented symbols are tracked in `docs/api-comments.md`.
- Check: `python3 scripts/check-comments.py` (CI job `Naming and comment rules`).

## Swift

- One-line summary: `///`. Longer documentation: one `/** ... */` block with Markup (`- Parameter name:`, `- Returns:`,
  `- Throws:`, `- Note:`), not stacked `///` lines.
- Swift code that is not public API (the demo) uses the same shapes but is not checked by the script.

## Other platforms (official documentation tools)

Use the platform's own doc comment, one block per declaration, summary sentence first:

- Kotlin: KDoc `/** ... */` with `@param`, `@return`, `@throws`. Java: Javadoc `/** ... */`.
- TypeScript: TSDoc `/** ... */`. JavaScript: JSDoc `/** ... */` with `@param`, `@returns`.
- Dart and Flutter: `///` doc comments (the official Effective Dart style; this is the platform's own convention, so
  stacked `///` is correct there).
- Python: a docstring (PEP 257) as the first statement. Go: a comment directly above the declaration that starts with the
  declaration's name. Rust: `///` or `/** */`. C#: XML documentation comments (`/// <summary>`).
