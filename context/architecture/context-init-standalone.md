---
tags:
  - context
  - commands
  - architecture
  - consolidation
  - minimalism
  - interface-design
scope: Architecture decision: context-init kept as a standalone file without consolidation into a multi-mode context.md
when: Deciding whether to consolidate a single-command file into a multi-mode command
---

# Context-Init Standalone

> Architecture decision: unlike session (which consolidated 5 modes into `session.md` with report + init), context-init was kept as a standalone file without a consolidated `context.md` wrapper. Related commands (append, harvest, find) were simply deleted rather than merged.

## Context

When the session command was simplified, the approach was:
- Delete session-view.md and session-timeline.md
- Consolidate remaining modes (report + init) into a single `session.md` with mode routing

When the same consolidation was requested for context commands, two approaches were possible:
1. **Session-style** — create a consolidated `context.md` with modes (e.g., `init` + default status), delete the sub-files
2. **Standalone** — keep `context-init.md` as-is, delete the other files, don't create `context.md`

## Decision

**Approach 2: Keep context-init standalone. No consolidated context.md.**

Files deleted: `context-append.md`, `context-harvest.md`, `context-find.md`
Files kept: `context-init.md` (unchanged)
New files created: none

## Rationale

1. **No useful default mode** — For session, `/session` (without args) generates a report — a distinct, useful default. For context, there was no equivalent. `/context` with no args had nothing meaningful to do beyond what `/context init` already does.

2. **/session replaced harvest/append** — The `/session` command already scans session summaries for patterns and presents save candidates. This made `/context harvest` and `/context append` redundant. Deleting them eliminated confusion about which command to use.

3. **Simplicity** — Creating a `context.md` just to wrap a single `context-init` command would have added complexity (mode routing, error handling for unknown modes) with zero benefit. The init command works fine as a standalone file.

## Contrast with Session Consolidation

| Aspect | Session | Context |
|--------|---------|---------|
| Before | session.md + session-view.md + session-timeline.md | context-init.md + context-append.md + context-harvest.md + context-find.md |
| After | session.md (modes: report, init) | context-init.md (unchanged) |
| What happened | 3 files → 1 consolidated file | 4 files → 1 file (3 deleted) |
| Default mode | Report generation | N/A (init must be typed explicitly) |

The key difference: session's default mode (report) is a distinct, frequently used action. Context had no equivalent — init cannot be a useful default because it only needs to run once.

## Related

- `context/architecture/session-minimalism.md` — The parallel session consolidation (session.md with 2 modes)
