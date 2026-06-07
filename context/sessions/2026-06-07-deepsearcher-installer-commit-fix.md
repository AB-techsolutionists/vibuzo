# deepsearcher-installer-commit-fix

*Session summary — 2026-06-07 | ~80 messages | 9 files touched | 2 commits*

## Session Summary

Fixed a critical installer bug: `agents/deepsearcher.md` was missing from the repo (only existed in gitignored `.opencode/agent/core/`), causing installer 404s on agent download. Created the file and synced both installers with deepsearcher path-rewriting and Claude Code copy. Restructured AGENTS.md — updated tagline, added `agents/` + installers to directory tree, then reverted to installed-only view per user feedback. Replaced the "How Commands Work" section with a unified 11-command reference table with execution instructions. Extended `/commit` to include README.md as a third bump target (step 9). Fixed `$ARGUMENTS` format from backtick-wrapped to plain text to match working commands. Discovered and fixed an installer AGENTS.md rules duplication bug: fresh downloads that already had marker content got appended again on re-install; added dedup guards to both installers. Two commits pushed: `d5a8f6a` (0.2.3) and `b5ce6f1` (0.2.4).

## Constraints & Preferences

- **No repo internals in AGENTS.md:** AGENTS.md ships to users — must only show installed framework structure, not source directories (`agents/`, installers)
- **Bump process covers README:** `/commit` must update README.md Version History alongside VERSION and versioning.md (3 spots total)
- **`$ARGUMENTS` in plain text:** opencode variable must not be wrapped in backticks — other working commands use plain `$ARGUMENTS`
- **`.opencode/` is installer-managed:** files in `.opencode/` are gitignored and never edited directly (user override for syncing commit.md)
- **Installer fresh download check:** before appending preserved user rules below AGENTS.md marker, verify the fresh download doesn't already have them

## Progress

### Done
- Created `agents/deepsearcher.md` — mirrored from `.opencode/agent/core/deepsearcher.md` (141 lines)
- Updated `install.ps1`: added deepsearcher to path-rewriting + Claude Code copy
- Updated `install.sh`: added deepsearcher to Claude Code copy
- Restructured AGENTS.md: updated tagline, rebuilt directory tree (3 iterations: add agents/ → revert to installed-only), replaced commands section with unified table + execution instructions
- Extended `commands/commit.md`: added step 9 (Update README.md), renumbered 10→14, updated approval gate, commit body, stage, and report box to include README.md
- Fixed `$ARGUMENTS` backtick wrapping → plain text in commit.md
- Synced `.opencode/commands/commit.md` with updated version
- Fixed installer AGENTS.md rules duplication: added fresh-download marker-content check to both installers
- Cleaned duplicate rule from AGENTS.md
- Bumped VERSION: 0.2.1 → 0.2.2 → 0.2.3 → 0.2.4
- Updated `context/standards/versioning.md`: added 0.2.2, 0.2.3, 0.2.4 entries; updated canonical source; expanded bump spots 2→3
- Updated `README.md`: added 0.2.2, 0.2.3, 0.2.4 rows to Version History
- Committed `d5a8f6a` (0.2.3): feat: update AGENTS.md and commit command to include README in bump workflow
- Committed `b5ce6f1` (0.2.4): fix: prevent installer AGENTS.md rules duplication

### In Progress
*(none)*

### Blocked
*(none)*

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **`$ARGUMENTS` in plain text** — must not be inside markdown backticks in command files | Other working commands (spec.md, research.md, add-context.md) use plain text; backtick wrapping may prevent opencode from recognizing the variable |
| 2 | **Installer dedup guard** — before appending preserved user rules below AGENTS.md marker, check if the fresh download already has marker content | Prevents user rules from duplicating on re-install when the repo commit includes them |
| 3 | **Bump = 3 spots** — VERSION + versioning.md + README.md | README Version History must stay in sync; the `/commit` command handles all three |
| 4 | **AGENTS.md shows installed-only view** — no source directories (`agents/`, installers) | AGENTS.md ships to end users; repo internals are irrelevant to them |

## Forward Context

- `.opencode/.vibuzo-version` still shows `0.2.0` — will sync on next installer run (installer-managed, not edited directly)
- Two specs remain queued: `/spec session-management-enhancement` and `/spec spec-workflow-enhancement`
- The `$ARGUMENTS` display issue in user's chat view vs actual file content remains unresolved — likely a rendering artifact, not a file problem

## Next Steps

1. Run `/compact` in opencode TUI (immediately after this summary)
2. Copy the output and paste into **Session Compaction** section below
3. That block becomes starting context for next `/new` session

## Hot Files

| File | Why Hot |
|------|---------|
| `commands/commit.md` | Recently extended with README step — may need further refinement |
| `install.ps1` | Dedup guard just added — may need testing on real re-install |
| `install.sh` | Same dedup guard — test on real re-install |
| `commands/session.md` | If `/spec session-management-enhancement` is next |

## Timeline Entry

| 2026-06-07 | 17:45 | `deepsearcher-installer-commit-fix` | Fixed missing agent file (installer 404), restructured AGENTS.md, extended /commit to README, fixed installer rules duplication bug. 2 commits pushed to 0.2.4. |

## Patterns Detected

| Candidate | Decision |
|-----------|----------|
| `patterns/installer-content-preservation-dedup.md` — Before appending preserved user content, verify fresh download doesn't already have it | ✅ Saved |

## Session Compaction

## Goal
Fixed missing `agents/deepsearcher.md` causing installer 404, updated AGENTS.md structure and commands section, extended `/commit` to cover README in bump workflow, and fixed installer AGENTS.md rules duplication bug.

## Constraints & Preferences
- `.opencode/` files are installer-managed only — never edit directly
- Version format: `0.<minor>.<patch>` semver matching opencode's style — no `v` prefix
- Patch cap: 0→19 rolls to minor; Minor cap: 0→9 rolls to `1.0.0`
- Bump trigger: Every push to GitHub source repo
- Approval level 3 (Full Control) — every action needs approval gate
- `/commit` command must never call `git push` — user pushes manually after reviewing
- `.opencode/` is gitignored — synced `.opencode/commands/commit.md` can't be committed
- AGENTS.md is a user-facing file — should only show installed framework structure, not repo-internal source directories or installers
- `$ARGUMENTS` in command files must be plain text, not inside backtick code formatting — opencode substitutes the raw text
- Installer AGENTS.md marker preservation must check if fresh download already has content below the marker before appending saved rules

## Progress
### Done
- Created `agents/deepsearcher.md` — mirrored `.opencode/agent/core/deepsearcher.md` (141 lines)
- Updated `install.ps1` — added deepsearcher path-rewriting (line 321) and Claude Code copy (line 342)
- Updated `install.sh` — added deepsearcher Claude Code copy (line 355)
- Updated `AGENTS.md` — restructured tree to show repo structure, updated tagline, reworked Commands section with unified table + execution instructions
- Updated `commands/commit.md` — added README.md step (step 9) to bump workflow; stripped backticks from `$ARGUMENTS` (plain text)
- Synced `.opencode/commands/commit.md` with updated version
- Fixed installer AGENTS.md rules duplication — added dedup guard to both installers checking if fresh download already has marker content
- Cleaned duplicate user rule from AGENTS.md
- Bumped VERSION 0.2.1 → 0.2.4 across 3 commits
- Committed and pushed: `d5a8f6a` (feat: update AGENTS.md and commit command), `b5ce6f1` (fix: installer rules duplication)
- Ran `/session` to generate this summary

### In Progress
- (none)

### Blocked
- (none)

## Key Decisions
- `agents/deepsearcher.md` was never committed to git — created only in `.opencode/agent/core/` (gitignored). Root cause: commit `b1bfdf0` architected Deepsearcher without creating the agent file; installer-fix commit `3d36ee4` added array entry without verifying source file existed
- `$ARGUMENTS` in commit.md must be plain text (no backticks) — matching pattern of working commands spec.md, research.md, add-context.md
- Installer AGENTS.md preservation logic now checks if fresh download already has marker content before appending — prevents duplication across re-installs
- AGENTS.md Commands section simplified to a single table + brief "How they work" blurb — avoids over-documenting while keeping execution instructions for the agent

## Next Steps
1. Run `/compact` in opencode TUI to capture full state
2. Paste compaction output into this session file's Session Compaction section
3. Next session: Spec 2 (`/spec session-management-enhancement`) or Spec 3 (`/spec spec-workflow-enhancement`)
4. Verify installer works without 404s by running install.ps1 or install.sh

## Critical Context
- Current version: **0.2.4** (VERSION file at repo root)
- Last commit: `b5ce6f1` — "fix: prevent installer AGENTS.md rules duplication by checking fresh download" (pushed to origin/main)
- `.opencode/.vibuzo-version`: `0.1.5` — outdated, will update on next installer run (installer-managed)
- `.opencode/commands/` has 11 command files including the updated commit.md
- `.opencode/` files are gitignored — synced but not committed
- 3 commits this session: 3d36ee4 (pre-existing), d5a8f6a (pushed), b5ce6f1 (pushed)

## Relevant Files
- `agents/deepsearcher.md`: New — missing agent file fixing installer 404
- `install.ps1`: Updated — deepsearcher path-rewriting + Claude copy + AGENTS.md dedup guard
- `install.sh`: Updated — deepsearcher Claude copy + AGENTS.md dedup guard
- `AGENTS.md`: Restructured — tree, tagline, commands section, cleaned duplicate rule
- `commands/commit.md`: Updated — added README step, stripped $ARGUMENTS backticks
- `VERSION`: 0.2.4
- `context/standards/versioning.md`: Updated — 0.2.2, 0.2.3, 0.2.4 entries
- `README.md`: Updated — 0.2.2, 0.2.3, 0.2.4 rows in Version History