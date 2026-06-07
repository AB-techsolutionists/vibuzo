---
tags:
  - opencode
  - mirror-files
  - installer
  - source-of-truth
scope: Management of .opencode/ directory files
when: Needing to update files in the .opencode/ directory
---

# .opencode/ Mirror Files Integrity

**Date:** 2026-06-07
**Status:** Active

## Rule

**Never modify `.opencode/` files directly.** These are Vibuzo framework files managed by the installer — unless they are internal dev commands.

## Details

- `.opencode/agent/core/` and `.opencode/commands/` are **mirror copies** of source files in `agents/` and `commands/`
- The primary way to update them is via `install.ps1 --update` or `install.sh --update`
- Editing `.opencode/` files directly causes drift between source and mirror — the installer will overwrite them on next update
- `.opencode/` is **not git-tracked** — changes there are invisible to version control

## Exception: Internal Dev Commands

**Internal dev commands** (per `internal-commands-convention.md`) ARE manually synced to `.opencode/commands/` even though they are excluded from installer arrays.

Rationale: opencode loads commands from `.opencode/commands/`. For maintainers to use internal dev tools, the file must be present there. Since it's excluded from the installer (to avoid shipping to users), it must be copied manually.

**Rule:** After creating or updating an internal dev command in `commands/`, manually copy it to `.opencode/commands/`:
```powershell
Copy-Item "commands\<name>.md" ".opencode\commands\<name>.md"
```

The installer will NOT overwrite it because the file is not in its array. Manual sync is the only path.

## Workflow

1. Edit source files in `agents/` (agent definitions) or `commands/` (command files)
2. For user-facing commands: run `install.ps1 --update` (or `install.sh --update`) to sync
3. For internal dev commands: manually copy to `.opencode/commands/`

## Related

- [`standards/versioning.md`](versioning.md) — Version tracking convention
