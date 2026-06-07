---
tags:
  - session
  - commands
  - architecture
  - minimalism
  - interface-design
scope: Architecture decision for session command surface area
when: Designing command interfaces or restructuring multi-mode commands
---

# Session Command Minimalism

> Architecture decision: strip the session command to 2 modes (report + init) with no subcommands. View, timeline, and find are deleted entirely.

## Context

The session command originally had 5 planned modes:
- **report** — generate a session summary
- **init** — initialize agent context
- **view** — browse past sessions
- **timeline** — list all summaries
- **find** — search across summaries

The /spec pipeline implemented all 5, but the user explicitly rejected view/timeline/find, wanting only report + init.

## Decision

**Keep only 2 modes:**
- `/session` (or `/session report`) — generate a comprehensive session summary
- `/session init` — initialize agent context (read-only, no file created)

**Delete everything else:**
- `session-view.md` and `session-timeline.md` files — deleted from both `commands/` and `.opencode/commands/`
- View, Timeline, Find Mode sections — deleted from `session.md`
- All references in user-facing docs (AGENTS.md, README.md) — removed
- All references in installers — removed from `$CommandFiles` / `COMMAND_FILES` arrays

## Rationale

1. **Minimal surface area** — Fewer commands to discover, learn, and maintain.
2. **Single responsibility** — `/session` generates reports, `/session init` initializes context. No mixing of concerns.
3. **User preference** — Explicit direction from the user trumps comprehensive feature design.
4. **Deletion > deprecation** — Removing code entirely avoids maintenance burden of deprecated paths.

## Consequences

- Users browse past sessions by opening the files manually or using system tools (grep, file explorer)
- The timeline index at `context/sessions/index.md` is still maintained by `/session` but there's no dedicated command to display it
- Future enhancements should focus on the 2-mode surface rather than adding back subcommands

## Related

- `commands/session.md` — The implementation with 2 modes
- `context/patterns/session-init-pattern.md` — The init mode pattern
