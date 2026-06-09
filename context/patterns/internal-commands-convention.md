---
tags:
  - commands
  - internal
  - installer
  - dev-tools
scope: How to handle commands that are for Vibuzo development only (not user-facing)
when: Creating a command that modifies Vibuzo's own files (VERSION, versioning.md, README.md)
---

# Internal Commands Convention

> Commands for Vibuzo maintainer use only live in `.opencode/commands/` — never in the source repo's `commands/`.

## Rule

If a command modifies Vibuzo's own framework files (VERSION, versioning.md, README.md, installer files), it is an **internal command** — useful only to Vibuzo maintainers developing the framework itself. End users have no use for it.

Internal commands MUST be:

1. **Live only in `.opencode/commands/`** — the file is never added to the source repo's `commands/`. It exists solely in your local `.opencode/` mirror, which is gitignored and stays private to your environment.
2. **Excluded from installer arrays** — not listed in `$CommandFiles` (PowerShell) or `COMMAND_FILES` (Bash)
3. **Updated in place** — when modifying an internal command, edit `.opencode/commands/<name>.md` directly. There is no source repo file to sync. The installer will never overwrite it (excluded from its array).
4. **Excluded from user-facing docs** — not listed in AGENTS.md commands table, README.md commands table, or any command count

## Why Not in Source

Keeping internal commands out of the source repo avoids confusion — the file only exists where it's actually used (your opencode instance). Users never see it, never stumble on it, and never wonder why a command they can't run exists in the codebase.

## Example

`new-release.md` is an internal command:
- Lives only at `.opencode/commands/new-release.md` — not in source repo
- Not in `$CommandFiles` / `COMMAND_FILES` arrays
- Edited directly in `.opencode/commands/` when changes are needed
- Not in AGENTS.md or README.md command tables
