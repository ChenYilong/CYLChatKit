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
- Section banners are the same three-line block with `@name Title` (and `#pragma mark - Title`). Never `///====` lines.
- **Single-line comments of public API use the same block.** A one-sentence comment is still three lines:

  ```objc
  /*!
   * The latitude of the current location.
   */
  @property (nonatomic, readonly) CLLocationDegrees latitude;
  ```

  Never `/*! text */` on one line, and never a trailing `/**< */`, `/*!< */`, `///<`, or `//` after a declaration or an
  enum case. A public API file has one comment format for every comment, short or long.
- A comment that explains private code uses `//` in the `.m` file and is not a doc comment.
- File header (`//  File.h`, creator, copyright) stays a `//` block at the top; it is not a doc comment.
- Delete commented-out code. Never document it.
- Write comments in English. Describe LeanCloud types in words in core.
- Document every new public symbol in the same change. Existing undocumented symbols are tracked in `docs/api-comments.md`.
- Check: `python3 scripts/check-comments.py` (CI job `Naming and comment rules`).

## Swift

- Every public API comment, one line or several, is one `/** ... */` block with Markup (`- Parameter name:`,
  `- Returns:`, `- Throws:`, `- Note:`). Never `///` lines: one format per file.
- Swift code that is not public API (the demo) uses the same shapes but is not checked by the script.

## Other platforms (official documentation tools)

**All comment formats follow the official rules.** Use the doc-comment form that the platform's official documentation
tool and style guide prescribe; if this skill disagrees with the official rule, the official rule wins and this skill is
fixed. On top of it, two project rules hold everywhere: one comment format per public API file, and single-line comments
in the same form as multi-line ones. Summary sentence first.

Block form is official (single-line comments are blocks too):

- Objective-C: `/*! ... */` (Apple / clang doc comments; see above).
- Swift: `/** ... */` with Markup (DocC reads it; chosen so Swift matches the Objective-C headers).
- Kotlin: KDoc `/** ... */` with `@param`, `@return`, `@throws`. Java: Javadoc `/** ... */`.
- TypeScript: TSDoc `/** ... */`. JavaScript: JSDoc `/** ... */` with `@param`, `@returns`.
- Python: a docstring (PEP 257) as the first statement, triple quotes on their own lines even for one sentence.

Line form is official (every public API comment of the file uses it, single-line or multi-line; no block comments mixed in):

- Dart and Flutter: `///` (Effective Dart: "DO use `///` doc comments").
- Go: `//` comments directly above the declaration, starting with its name (Go Doc Comments).
- Rust: `///` outer doc comments (`//!` for the crate or module).
- C#: `///` with XML documentation tags (`<summary>`, `<param>`, `<returns>`).

A language whose tool has only one doc-comment form uses it for every comment in the file.
