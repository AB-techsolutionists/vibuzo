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

**Never modify `.opencode/` files directly.** These are Vibuzo framework files managed exclusively by the installer.

## Details

- `.opencode/agent/core/` and `.opencode/commands/` are **mirror copies** of source files in `agents/` and `commands/`
- The only way to update them is via `install.ps1 --update` or `install.sh --update`
- Editing `.opencode/` files directly causes drift between source and mirror — the installer will overwrite them on next update
- `.opencode/` is **not git-tracked** — changes there are invisible to version control

## Workflow

1. Edit source files in `agents/` (agent definitions) or `commands/` (command files)
2. Run `install.ps1 --update` (or `install.sh --update`) to sync changes to `.opencode/`

## Related

- [`standards/versioning.md`](versioning.md) — Version tracking convention
