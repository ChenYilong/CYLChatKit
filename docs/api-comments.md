# Public API comments

Rules: `AGENTS.md` ("Code comments") and `.agents/skills/cylchatkit-comments/SKILL.md`. A public declaration is documented
with one `/*! ... */` block directly above it, so Objective-C and Swift callers get the text from Quick Help and the
generated interface. `scripts/check-comments.py` (CI job `Naming and comment rules`) enforces the format.

## Audit of the core public headers (2026-11)

Checked: all 92 public headers of `ChatKit/` (vendored code excluded).

| Found | Count | Fixed |
|:---|---:|:---|
| Whole-line `///` comments and `///=====` banners | 156 lines | Converted to `/*! ... */` blocks; banners became `/*! @name Title */` |
| Stacked `//` comments directly above a declaration | 123 blocks, 41 files | Converted to `/*! ... */` blocks (commented-out code was left alone) |
| One `/** ... */` doc comment | 1 | Now `/*!` |
| Single-line `/*! text */` | 12 files | Rewritten as the block form |

The conversion was mechanical (text unchanged). Comments that explain moved or deleted code (for example the note after
the last declaration of `CYLMessage.h`) are plain `//` notes, not doc comments, and stay.

## TODO

- TODO: About 538 public declarations have no doc comment (run `python3 scripts/check-comments.py --report`). Document
  them in English with `@param` / `@return` and the callback queue, starting with the types an app implements or calls
  most: `CYLIMProvider`, `CYLChatKit`, the `*Service` protocols, `CYLConversationProtocol`, `CYLIMMessageProtocol`.
- TODO: 447 comment lines in the public headers are Chinese (in 47 files). Translate them to English when the
  declaration is touched, as the rule asks for new and changed code; keep the meaning.
- TODO: Verify the doc comments in Xcode Quick Help for an Objective-C and a Swift caller once the demo builds (the
  conversion could not be checked without Xcode).
- TODO: Add a Swift doc-comment check for the demo and for any Swift API once core ships Swift code.
