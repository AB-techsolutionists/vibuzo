---
title: new-release-workflow
date: 2026-06-09
tags:
  - commands
  - new-release
  - workflow
  - documentation
  - review
status: complete
---

# New Release Workflow

*Session summary — 2026-06-09 | ~12 messages | 3 files touched | 0 commits*

## Session Summary

Modified the `/new-release` command's Step 5 to derive release notes from the conversation context instead of reading the latest session file — enabling `/new-release` to run before `/session` without breaking. Ran a Deepviewer documentation drift audit across the codebase, which found 8 files outdated by recent changes (approval gate refactor, agents/deepviewer.md creation, version bump). No fixes were applied this session — the drift findings are pending action.

## Constraints & Preferences

- **Conversation-first:** Release notes come from the current conversation context, not from session files. This decouples release timing from session creation.
- **Review-before-fix:** Deepviewer findings were collected but not acted on — pattern established: audit first, then plan remediation.

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Release notes from conversation** — `/new-release` Step 5 now derives notes from the current conversation context instead of reading session files | Enables running `/new-release` before `/session`; removes file dependency from the release workflow |

## Forward Context

- Deepviewer documentation drift audit found 8 files needing updates — most critically `commands/spec.md` (6 stale `approval_level` references), `AGENTS.md` (contradictory level table), and `README.md` (missing deepviewer.md in file tree)
- None of the drift fixes were applied — the next session should tackle them
- `/new-release` has the updated Step 5 but needs to be tested in a real workflow where `/session` hasn't run yet

## Hot Files

| File | Why Hot |
|------|---------|
| `commands/spec.md` | 6 stale references to removed `approval_level` — highest priority fix |
| `AGENTS.md` | Contradictory old level table + gate prompt template (lines 172-189) |
| `README.md` | Missing deepviewer.md in file tree, wrong command count |
| `commands/new-release.md` | Step 5 just changed — needs real-world verification |
| `context/architecture/agent-restructure.md` | Omits Deepsearcher and Deepviewer |
| `context/architecture/spec-command.md` | Stale approval_level references |

## Timeline Entry

| 2026-06-09 | 12:36 | `new-release-workflow` | Modified /new-release to derive notes from conversation, ran Deepviewer documentation drift audit (8 files found) |

## Session Compaction

```
╭─────── Session Compaction ───────────────────────────────────────╮
│                                                                   │
│  Session:    new-release-workflow                                  │
│  Date:       2026-06-09                                            │
│  Messages:   ~12                                                   │
│                                                                   │
├─────── Goal ──────────────────────────────────────────────────────┤
│                                                                   │
│  • Decouple /new-release from session files so it can run before   │
│    /session; audit documentation drift from recent system changes  │
│                                                                   │
├─────── Constraints & Preferences ─────────────────────────────────┤
│                                                                   │
│  • Release notes come from conversation, not session files        │
│  • Review-before-fix: audit drift findings first, fix later       │
│                                                                   │
├─────── Progress ──────────────────────────────────────────────────┤
│                                                                   │
│  Done:                                                             │
│  • Modified commands/new-release.md Step 5 to derive release      │
│    notes from conversation context                                 │
│  • Ran Deepviewer documentation drift audit                       │
│  • Found 8 files with drift: 3 HIGH, 3 MEDIUM, 2 LOW severity     │
│                                                                   │
│  In Progress:                                                      │
│  • (none)                                                          │
│                                                                   │
│  Blocked:                                                          │
│  • (none)                                                          │
│                                                                   │
├─────── Key Decisions ─────────────────────────────────────────────┤
│                                                                   │
│  • Release notes from conversation, not session files — enables   │
│    /new-release → /session ordering                                │
│                                                                   │
├─────── Next Steps ────────────────────────────────────────────────┤
│                                                                   │
│  • Fix documentation drift across 8 files — start with             │
│    commands/spec.md (6 approval_level references)                  │
│  • Update AGENTS.md and README.md for approval gate refactor      │
│  • Update architecture docs for missing agent definitions         │
│  • Test /new-release before /session to verify new workflow        │
│                                                                   │
├─────── Critical Context ──────────────────────────────────────────┤
│                                                                   │
│  • Git: working tree may be dirty (new-release.md modified)       │
│  • 8 documentation drift findings pending — no fixes applied      │
│  • Approval gate refactor, agents/deepviewer.md creation, and     │
│    0.3.4 bump are all reflected in code but not docs              │
│                                                                   │
├─────── Relevant Files ────────────────────────────────────────────┤
│                                                                   │
│  commands/new-release.md           │ Step 5 changed                │
│  commands/spec.md                  │ 6 stale approval_level refs  │
│  AGENTS.md                         │ Contradictory level table    │
│  README.md                         │ Missing deepviewer.md entry  │
│  context/architecture/agent-       │ Missing agents 3 & 4         │
│    restructure.md                  │                              │
│  context/architecture/spec-        │ Stale approval_level refs    │
│    command.md                      │                              │
│                                                                   │
╰───────────────────────────────────────────────────────────────────╯
```
