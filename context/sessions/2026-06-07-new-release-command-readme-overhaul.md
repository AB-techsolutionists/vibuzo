# new-release-command-readme-overhaul

*Session summary — 2026-06-07 | ~45 messages | 14 files touched | 1 commit*

## Session Summary

Ran the full `/spec` pipeline to create a `/new-release` command that extracts version bump logic from `/commit`. Later decided `/new-release` is an internal-only dev tool for building Vibuzo (not user-facing), removed `/commit` entirely, and updated all documentation, installers, and command counts accordingly. Also overhauled the README intro section to match AGENTS.md style — replaced numbered bullets with a scannable table using the AGENTS.md tagline. Bumped 0.2.4 → 0.2.5 and committed (`a7e719e`).

## Constraints & Preferences

- **new-release is internal-only:** The command bumps Vibuzo's own VERSION file — users don't need it. Kept in `commands/` but excluded from installer arrays, `.opencode/commands/`, and all user-facing docs.
- **/commit removed completely:** No longer needed — version bump flow lives in `/new-release` (internal), and users commit manually. All references cleaned up.
- **README intro mirrors AGENTS.md:** Uses the exact tagline from AGENTS.md ("orchestrates three specialized agents through research → plan → execute → review") and structures the three mechanisms as a table matching AGENTS.md's "Three-Agent System" table.
- **No user-facing commit command:** After /new-release and /commit removal, there is no command for users to auto-commit. Users handle git manually.

## Progress

### Done
- Bumped VERSION 0.2.4 → 0.2.5, committed `a7e719e`, pushed
- Overhauled README intro: replaced 3 numbered bullets with a table (Mechanism | What it does), used AGENTS.md tagline verbatim
- Restructured table rows: renamed "Persistent context system" → "Full engineering pipeline", moved context pipeline description under it
- Ran full `/spec` pipeline for `new-release-command`: created spec.md, plan.md, tasks.md, review.md, commands/new-release.md
- Updated `/new-release` to also update versioning.md and README.md (full release pipeline: bump + docs)
- Removed `commands/commit.md` and `.opencode/commands/commit.md`
- Made `/new-release` internal-only: removed from installer arrays, removed from `.opencode/commands/`, removed from AGENTS.md and README.md commands tables
- Updated all command counts: AGENTS.md tree (10), AGENTS.md commands header (10), README.md tree (10)
- Updated installer command arrays: removed "commit", never added "new-release" to user-facing list
- Synced `.opencode/commands/` to 10 user-facing files

### In Progress
*(none)*

### Blocked
*(none)*

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **new-release is internal-only** — `commands/new-release.md` stays in repo but is excluded from installer arrays, `.opencode/commands/`, and user-facing docs | Bumps Vibuzo's own VERSION file — only relevant to Vibuzo maintainers, not end users |
| 2 | **No user-facing commit command** — `/commit` deleted, `/new-release` is internal. Users commit manually. | The auto-commit flow was over-engineered for what users need; manual git push is simpler and more transparent |
| 3 | **READNE intro matches AGENTS.md style** — table-based mechanism overview with exact tagline from AGENTS.md | Consistency between the two key entry points (AGENTS.md for agents, README.md for humans) |

## Forward Context

- `commands/new-release.md` exists but is NOT synced to `.opencode/commands/` — it's a dev-only tool for Vibuzo maintainers. Use it by running `/new-release` directly while Vibuzo is the active agent in this project.
- `.opencode/.vibuzo-version` still shows `0.2.0` — will sync on next installer run.
- User-facing command count is 10. The repo's `commands/` directory has 11 files (10 user + 1 internal new-release).
- The `/spec` pipeline created full artifacts at `specs/new-release-command/` — spec, plan, tasks, review all reflect the final state.

## Next Steps

1. Run `/compact` in opencode TUI (immediately after this summary)
2. Copy the output and paste into **Session Compaction** section below
3. That block becomes starting context for next `/new` session

## Hot Files

| File | Why Hot |
|------|---------|
| `commands/new-release.md` | Internal dev tool — may need refinement on first real use |
| `install.ps1` | Modified command array — verify clean install works without errors |
| `install.sh` | Modified command array — verify clean install works without errors |
| `AGENTS.md` | Commands table and tree updated to 10 — verify consistency with actual files |
| `README.md` | Intro section, commands table, tree count all updated |

## Timeline Entry

| 2026-06-07 | 19:17 | `new-release-command-readme-overhaul` | Created /new-release command via /spec pipeline, removed /commit, made new-release internal-only, overhauled README intro to match AGENTS.md style. 1 commit to 0.2.5. |

## Patterns Detected

| Candidate | Decision |
|-----------|----------|
| `patterns/internal-commands-convention.md` — Commands in commands/ but excluded from installer and user-facing docs | ✅ Saved |

## Session Compaction

## Goal

Fulfilled all feature requests: ran `/commit` to bump 0.2.4→0.2.5, restructured README intro with concise table-based design, ran full `/spec` pipeline to create `/new-release` command, removed `/commit` completely, and separated internal dev tooling from user-facing install.

## Constraints & Preferences

- **Version rollover scheme:** patch 0→9 rolls to minor, minor 0→19 rolls to major — used by `/new-release`
- **`/new-release` is internal only:** stays in `commands/` for Vibuzo dev work, excluded from installer arrays and user-facing docs (AGENTS.md, README.md)
- **Commands table is user-facing:** only shows the 10 commands users actually get after installation
- **Full pipeline is automatic for `/new-release`:** no user prompts — agent reads VERSION, auto-calculates patch, writes it, auto-generates release description from session context, updates versioning.md and README.md
- **`/commit` command removed entirely:** no longer shipped to users or referenced in any live docs
- **Approval level 3 (Full Control):** gates active for all pipeline phases

## Progress

### Done
- Ran `/commit` — bumped VERSION from 0.2.4→0.2.5 (patch), updated versioning.md and README.md, committed with `a7e719e`, pushed
- Restructured README intro section: replaced three numbered paragraphs with compact table matching AGENTS.md style (Full engineering pipeline, Persistent context system, Session reports)
- Fixed README mechanism descriptions to match their names (Full engineering pipeline → pipeline workflow, Persistent context system → context operations)
- Ran full `/spec new-release-command` pipeline — created spec.md, plan.md, tasks.md, review.md
- Created `commands/new-release.md`: auto-bumps VERSION (patch 0→9, minor 0→19), writes file, auto-generates release description from latest session, updates versioning.md and README.md, reports
- Removed `commands/commit.md` and `.opencode/commands/commit.md` — deleted entirely
- Removed `/commit` from README.md commands table, AGENTS.md commands table, Quick Start step 4, Full engineering pipeline description
- Removed `/new-release` from installer arrays (install.ps1, install.sh) and `.opencode/commands/` — internal dev tool, not user-facing
- Removed `/new-release` from AGENTS.md and README.md commands tables
- Updated command counts everywhere: 12→10 (user-facing)
- Synced `commands/new-release.md` stayed in repo; `.opencode/commands/` has 10 files

### In Progress
*(none)*

### Blocked
*(none)*

## Key Decisions

- **`/new-release` is internal Vibuzo dev tooling:** stays in `commands/` for maintainer use, excluded from installer arrays — users never download it
- **`/commit` command removed entirely:** bump logic lives in `/new-release` (internal); users have no shipped release command
- **`/new-release` is fully automatic:** no user prompts for bump type, description, or anything — agent derives everything from context and auto-proceeds
- **Command counts split:** `commands/` = 11 (10 user + 1 internal), `.opencode/commands/` = 10 (user-facing only) — AGENTS.md and README.md document the user-facing count
- **Version counting scheme for `/new-release`:** patch 0→9 (rolls to minor), minor 0→19 (rolls to major) — different from upstream versioning.md's 0→19/0→9 approach

## Next Steps

1. Run `/compact` in opencode TUI to capture full session state
2. Paste compaction output into this session file's Session Compaction section
3. Verify `.opencode/commands/` has exactly 10 files — no stray commit.md or new-release.md
4. Fix upstream `versioning.md` if `/new-release`'s rollover scheme should replace the existing one (currently patch 0→19, now using 0→9 in /new-release)

## Critical Context

- Current version: **0.2.5** (VERSION file at repo root)
- Last commit: `a7e719e` — "fix: Finalize session documentation and save installer-content-preservation-dedup pattern" (pushed to origin/main)
- User-facing commands directory: `.opencode/commands/` has **10 files** (spec, research, add-context, context-*, session*, session-view, session-timeline)
- Internal dev commands: `commands/new-release.md` exists in repo but not shipped — excluded from installer arrays
- `commands/commit.md` deleted from both `commands/` and `.opencode/commands/` — no trace in live docs
- Two specs remain queued from earlier sessions: `/spec session-management-enhancement` and `/spec spec-workflow-enhancement`
- `/new-release` uses a different rollover scheme (patch cap 9) than `context/standards/versioning.md` (patch cap 19) — potential inconsistency to resolve

## Relevant Files

- `commands/new-release.md`: Created — auto-bump command, internal dev tool
- `commands/commit.md`: Deleted — no longer exists
- `install.ps1`: Updated — removed new-release from command array
- `install.sh`: Updated — removed new-release from command array
- `AGENTS.md`: Updated — removed /commit and /new-release, 10 commands
- `README.md`: Updated — restructured intro section, removed /commit and /new-release from table and Quick Start, 10 command templates
- `specs/new-release-command/`: Created — spec.md, plan.md, tasks.md, review.md
- `.opencode/commands/`: Has 10 files — excludes commit.md and new-release.md
- `VERSION`: 0.2.5