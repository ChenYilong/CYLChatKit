---
name: cylchatkit-commit
description: "Commit message rules for CYLChatKit. Use before every commit: Commitizen subject, the required author line, TODO bookkeeping, and the pre-commit checks."
---

# CYLChatKit commits

## Message

- Subject: English Conventional Commit in the Commitizen format `{type}: {emoji} {subject}` (types and emojis in `AGENTS.md`,
  "Commitizen defaults"), 3 to 64 characters.
- Body: concise details and remaining tasks. If the description is longer than 50 characters, put the detail in a `docs/`
  note and link it in the body.
- **Author line (required in every commit body):**

  ```
  By @ChenYilong <luohanchenyilong@163.com>
  ```

  Put it on its own line after the description and before trailers such as `Claude-Session:`. Do not remove it, and do not
  change the name or address. The `commit-msg` hook in `AGENTS.md` only strips `Co-Authored-By:` lines, so it survives.

Example:

```
fix: 🐛 restore voice input in the chat bar

The voice button was hidden since the 2018 chat bar update. Unhide it and
restore its layout and action.

By @ChenYilong <luohanchenyilong@163.com>
Claude-Session: https://claude.ai/code/session_...
```

## Before committing

1. `touch .git/hooks/NO_AUTO_SYNC`, then install the `commit-msg` hook from `AGENTS.md`.
2. Update `.gitignore` against CYLTabBarController's and run `git status --short --ignored`.
3. Run `python3 scripts/check-localizations.py`, `python3 scripts/check-naming.py`, and `shellcheck scripts/*.sh`.
4. Record every unfinished or unverified item as `TODO` in the matching `docs/` file.
5. On a branch other than `master` or `main`, commit and push without asking; on `master` or `main`, ask first.
