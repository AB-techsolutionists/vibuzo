---
tags:
  - session
  - init
  - agent-context
  - scaffolding
  - startup
scope: Pattern for initializing agent context at session start
when: Initializing agent context or designing a session-start workflow
---

# Session Init Pattern

> A read-only pattern for initializing agent context: discover, verify, report — no files created, no directories scaffolded.

## Steps

1. **Read `AGENTS.md`** — load the universal entry point. Parse agent roles, commands, conventions, and any custom rules.

2. **Read `context/index.md`** — parse the `## Files` section to discover all available context files. Count files in each directory (architecture, standards, patterns, sessions).

3. **Verify context directories** — use `Test-Path` (PowerShell) to check each of the 4 context directories exists.

4. **Read the session timeline** — read `context/sessions/index.md`. Find the last (bottom-most) entry to identify the latest session file. Collect total session count, latest date, and file name.

5. **Read the latest session summary** — locate and read the most recent session file. If no sessions exist, report "No previous sessions found".

6. **Locate compaction content** — find the `## Session Compaction` section in the latest session file. This contains the auto-generated starting context block (a styled box). Report whether it was found.

7. **Report state** — print a summary box showing context file count, session count, latest session date, and compaction found status. No directories are scaffolded.

8. **Do NOT generate a session file** — init is read-only. No file is created in `context/sessions/`.

## Rationale

Separating agent initialization from session report generation keeps each command focused. `/session-init` answers "what does the agent know?" without creating noise. `/session` answers "what happened?" without mixing in startup logic.

## Related

- `commands/session-init.md` — The standalone init command (split from session.md)
