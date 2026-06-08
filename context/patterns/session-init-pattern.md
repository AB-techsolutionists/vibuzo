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

1. **Read `AGENTS.md`** — load the universal entry point. Parse agent roles, commands, conventions, and any custom rules. Run silently (no output to chat).

2. **Read `context/index.md`** — parse the `## Files` section to discover all available context files. Count files in each directory (architecture, standards, patterns, sessions). Run silently.

3. **Verify context directories** — use `Test-Path` (PowerShell) to check each of the 4 context directories exists. Run silently.

4. **Scan recent sessions** — read `context/sessions/index.md` and parse the timeline:
   a. Derive today's date dynamically (`Get-Date -Format "yyyy-MM-dd"`)
   b. Find all timeline rows matching today's date
   c. If today has entries → read ALL matching session files
   d. If no entries for today → derive yesterday's date (`(Get-Date).AddDays(-1).ToString("yyyy-MM-dd")`) → read ALL matching session files
   e. For each file read, note whether a `## Session Compaction` section with real content exists

5. **Report state** — print ONLY the summary box to chat (no intermediate output):
   ```
   ── Session Initialized ──────────────
   Context files:  <N> total across all directories
   Sessions:       <N> total, <M> recent loaded from <date>
   Compaction:     <found in N files | not found>
   ──────────────────────────────────────
   ```

6. **Do NOT generate a session file** — init is read-only. No file is created in `context/sessions/`.

## Rationale

Separating agent initialization from session report generation keeps each command focused. `/session-init` answers "what does the agent know?" without creating noise. `/session` answers "what happened?" without mixing in startup logic.

## Related

- `commands/session-init.md` — The standalone init command (split from session.md)
