---
title: readme-golden-workflow-release
date: 2026-06-09
tags:
  - readme
  - commands
  - versioning
  - documentation
  - release
status: complete
---

# README Golden Workflow Release

*Session summary — 2026-06-09 | ~35 messages | 6 files touched | 2 commits*

## Session Summary

Restructured the README with a comprehensive 12-row mechanism table, reordered the commands table to start with context commands, and split Quick Start into First-Time Setup and Golden Workflow sections with a continuity chain diagram. Moved What Gets Installed and Commands under Installation for logical flow. Added detailed multi-line release notes format to the `/new-release` command with one-line summary, detailed paragraph, and git diffstat. Migrated commit messages from single `feat:` prefix to conventional commit types with multi-type stacking. Made `/new-release` internal-only by removing it from user-facing docs. Unified `/session-init` output into a single codeblock with linewrapped narrative. Bumped version 0.3.5→0.3.6. Two commits — one pushed (documentation drift fixes + session-init + commit format), one unpushed (README restructure + release).

## Constraints & Preferences

- **No file paths in release notes:** Release descriptions describe functional changes, not file paths. Commas separate items, "and" before the last.
- **Internal commands stay in source only:** `/new-release` lives in `commands/` and `.opencode/commands/` but is excluded from installer arrays and all user-facing docs.
- **Surgical README edits:** Only the sections requested were changed — no adjacent cleanup.

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Release notes use paragraph format** — one-line summary + git diffstat on the first row line, detailed sentence paragraph on the second line, no bullets or categories | Cleaner visual in the version history table; categories didn't render well |
| 2 | **new-release reads latest session file** for release description instead of synthesizing from conversation | Session file has the authoritative summary; conversation-derived was fragile and inaccurate |
| 3 | **Golden Workflow always shown** in Quick Start — continuous cycle diagram (build → context → session → promote → resume) with `/session-init` bridging both memories | Makes the session/context relationship explicit and prevents users from skipping the checkpoint workflow |

## Forward Context

- 1 commit unpushed (34ddd2c — README restructure, new-release detail, version bump)
- The push was rejected by permission gate — needs explicit push approval
- Mirror copies at `.opencode/commands/` are in sync (no installer changes this session)
- Version 0.3.6 on disk, ahead of origin by 1 commit

## Hot Files

| File | Why Hot |
|------|---------|
| `README.md` | Version history updated with 0.3.6 — verify on next push |
| `commands/new-release.md` | Release notes format just changed — verify on next /new-release run |
| `VERSION` | Bumped to 0.3.6 — pending push |
| `context/standards/versioning.md` | 0.3.6 entry added — pending push |

## Timeline Entry

| 2026-06-09 | 16:03 | `readme-golden-workflow-release` | README restructure with Golden Workflow, new-release detail release notes, commit message convention update, session-init output standardization, version 0.3.5→0.3.6 |

## Session Compaction

```
╭─────── Session Compaction ───────────────────────────────────────╮
│                                                                   │
│  Session:    readme-golden-workflow-release                        │
│  Date:       2026-06-09                                            │
│  Messages:   ~35                                                   │
│                                                                   │
├─────── Goal ──────────────────────────────────────────────────────┤
│                                                                   │
│  • Restructure README with expanded mechanisms, Golden Workflow    │
│    quick start, and proper section ordering                        │
│  • Add detailed release notes format to /new-release               │
│  • Make new-release internal-only                                  │
│  • Bump version 0.3.5 → 0.3.6                                     │
│                                                                   │
├─────── Constraints & Preferences ─────────────────────────────────┤
│                                                                   │
│  • No file paths in release notes — describe functional changes   │
│  • Internal commands excluded from installer and user-facing docs │
│  • Surgical edits to README — only requested sections             │
│                                                                   │
├─────── Progress ──────────────────────────────────────────────────┤
│                                                                   │
│  Done:                                                             │
│  • Expanded README mechanism table from 3 to 12 rows              │
│  • Reordered commands table with context commands first           │
│  • Restructured Quick Start into First-Time Setup +               │
│    Golden Workflow with continuity chain diagram                  │
│  • Moved What Gets Installed and Commands under Installation      │
│  • Added detailed multi-line release notes format to              │
│    /new-release (one-line summary + detailed paragraph +          │
│    git diffstat)                                                  │
│  • Made new-release internal-only (removed from mechanism table)  │
│  • Migrated commit messages to conventional types with            │
│    multi-type stacking and Summary section                        │
│  • Unified /session-init output into single codeblock with        │
│    linewrapped narrative                                          │
│  • Corrected Web research row (three invocation modes)            │
│  • Bumped VERSION 0.3.5 → 0.3.6                                  │
│  • 1 commit pushed (6228d96), 1 commit pending (34ddd2c)          │
│                                                                   │
│  In Progress:                                                      │
│  • (none)                                                          │
│                                                                   │
│  Blocked:                                                          │
│  • Push to origin blocked by approval gate — needs explicit       │
│    approval                                                       │
│                                                                   │
├─────── Key Decisions ─────────────────────────────────────────────┤
│                                                                   │
│  • Release notes use paragraph format (one-line + detailed        │
│    sentence), not bullets or categories                           │
│  • new-release reads latest session file for description          │
│  • Golden Workflow includes full continuity chain in Quick Start  │
│  • new-release is internal-only — excluded from installer,        │
│    AGENTS.md, and README mechanism table                          │
│                                                                   │
├─────── Next Steps ────────────────────────────────────────────────┤
│                                                                   │
│  • Push the pending commit (34ddd2c)                              │
│  • Verify new-release format on next release                      │
│  • Continue building — the golden workflow is in place            │
│                                                                   │
├─────── Critical Context ──────────────────────────────────────────┤
│                                                                   │
│  • Git: ahead of origin by 1 commit (34ddd2c), working tree clean │
│  • Version: 0.3.6 on disk, not in origin                          │
│  • 2 commits this session: 1 pushed (docs drift + session-init    │
│    + commit format), 1 pending (README + new-release + bump)      │
│  • All installers are up to date — no installer changes           │
│  • Mirror copies in .opencode/commands/ are in sync               │
│                                                                   │
├─────── Relevant Files ────────────────────────────────────────────┤
│                                                                   │
│  README.md                             │ Latest version history   │
│  VERSION                               │ 0.3.6, pending push     │
│  commands/new-release.md               │ Detailed release notes   │
│  commands/session-init.md              │ Unified codeblock output │
│  context/standards/commit-message-     │ Conventional commit      │
│    format.md                           │ types with multi-stack   │
│  context/standards/versioning.md       │ 0.3.6 entry added        │
│                                                                   │
╰───────────────────────────────────────────────────────────────────╯
```

## Context Candidates

None — the session was primarily restructuring existing documentation and commands, not creating new knowledge worth preserving as standalone context files. The key decisions (release notes format, internal command handling, Golden Workflow) are already captured in the Forward Decisions section and the updated command files themselves.
