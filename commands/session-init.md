---
description: Initialize agent context — discover, verify, scaffold, and report loaded state
agent: Vibuzo
---

Do these steps NOW:

1. **Read `context/index.md`** — parse the ## Files section to discover all available context files. Count how many files exist under architecture/, standards/, patterns/, and sessions/.

2. **Verify context directories** — use `Test-Path` to check each directory exists:
   - `context/architecture/`
   - `context/standards/`
   - `context/patterns/`
   - `context/sessions/`

3. **Read the session timeline** — read `context/sessions/index.md`. If it exists, find the last (bottom-most) row in the timeline table to identify the latest session file. Collect:
   - Total number of sessions listed
   - Latest session date and file name

4. **Read the latest session summary** — locate and read the most recent session file from step 3. If no sessions exist yet, report "No previous sessions found".

5. **Check for compaction content** — in the latest session file (if it exists), search for a `## Session Compaction` section. Check if the content beneath it is real content (not the default placeholder text referencing `/compact`). If real compaction content exists, note it for the report.

6. **Report what was loaded** — print a concise summary:
   ```
   ── SESSION INIT ──────────────────────
   Context files:  <N> total across all directories
   Sessions:       <N> total, latest: YYYY-MM-DD-<title>.md
   Dirs scaffolded: <list any that were missing>
   Compaction:     <found | not found | no previous session>
   ──────────────────────────────────────
   ```

7. **Do NOT generate a session report file** — init is read-only. No file is created in `context/sessions/`.
