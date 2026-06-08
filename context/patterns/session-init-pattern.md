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

> A read-only pattern for initializing agent context: discover, verify, report — no files created.

## Steps

1. **Read `context/index.md`** — parse the `## Files` section to discover all available context files. Count files in each directory (architecture, standards, patterns, sessions).

2. **Verify context directories** — use `Test-Path` (PowerShell) to check each of the 4 context directories exists.

3. **Scaffold missing directories** — for any missing directory, create it with `New-Item -ItemType Directory -Path "context/<name>" -Force` and add a `.gitkeep` file.

4. **Read the session timeline** — read `context/sessions/index.md`. Find the last (bottom-most) entry to identify the latest session file. Collect total session count, latest date, and file name.

5. **Read the latest session summary** — locate and read the most recent session file. If no sessions exist, report "No previous sessions found".

6. **Check for compaction content** — search the latest session file for a `## Session Compaction` section. Determine if content beneath it is real (not the default placeholder).

7. **Report state** — print a summary box showing context file count, session count, latest session date, directories scaffolded (if any), and compaction found status.

8. **Do NOT generate a session file** — init is read-only. No file is created in `context/sessions/`.

## Rationale

Separating agent initialization from session report generation keeps each command focused. `/session-init` answers "what does the agent know?" without creating noise. `/session` answers "what happened?" without mixing in startup logic.

## Related

- `commands/session-init.md` — The standalone init command (split from session.md)
