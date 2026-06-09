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

> Commands for Vibuzo maintainer use only stay in `commands/` but are excluded from user-facing installation and documentation.

## Rule

If a command modifies Vibuzo's own framework files (VERSION, versioning.md, README.md, installer files), it is an **internal command** — useful only to Vibuzo maintainers developing the framework itself. End users have no use for it.

Internal commands MUST be:

1. **Kept in `commands/`** — the file stays in the repo for maintainer use
2. **Excluded from installer arrays** — not listed in `$CommandFiles` (PowerShell) or `COMMAND_FILES` (Bash)
3. **Manually synced to `.opencode/commands/`** — opencode loads commands from `.opencode/commands/`, so internal dev commands must be copied manually to be accessible. Use:
   ```powershell
   Copy-Item "commands\<name>.md" ".opencode\commands\<name>.md"
   ```
   The installer will NOT overwrite it (excluded from its array), so the manual copy persists.
4. **Excluded from user-facing docs** — not listed in AGENTS.md commands table, README.md commands table, or any command count
5. **Marked in the tree** — the `commands/` directory count in user docs reflects user-facing files only, not the repo total

## Impact on Counts

The repo's `commands/` directory will have more files than the user-facing count in AGENTS.md and README.md. This is intentional — the count reflects what users get after installation.

## Example

`commands/new-release.md` is an internal command:
- Present in `commands/` (8 files) but user-facing count is 7
- Not in `$CommandFiles` / `COMMAND_FILES` arrays
- Manually copied to `.opencode/commands/` for maintainer use
- Not in AGENTS.md or README.md command tables
