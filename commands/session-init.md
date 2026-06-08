---
description: Initialize agent context — discover, verify, and report loaded state
agent: Vibuzo
---

Do these steps NOW:

1. **Read `AGENTS.md`** — load the universal entry point. Parse the file to understand agent roles (Vibuzo, Deepveloper, Deepsearcher), available commands (listed in the commands table), project conventions (Karpathy Principles, approval gates, custom rules), and file structure overview. Note any custom rules below the `─── PASTE YOUR CUSTOM RULES BELOW THIS LINE ───` marker.

2. **Read `context/index.md`** — parse the ## Files section to discover all available context files. Count how many files exist under architecture/, standards/, patterns/, and sessions/.

3. **Verify context directories** — use `Test-Path` to check each directory exists:
   - `context/architecture/`
   - `context/standards/`
   - `context/patterns/`
   - `context/sessions/`

4. **Read the session timeline** — read `context/sessions/index.md`. If it exists, find the last (bottom-most) row in the timeline table to identify the latest session file. Collect:
   - Total number of sessions listed
   - Latest session date and file name

5. **Read the latest session summary** — locate and read the most recent session file from step 4. If no sessions exist yet, report "No previous sessions found".

6. **Check for compaction content** — in the latest session file (if it exists), search for a `## Session Compaction` section. Check if the content beneath it is real content (not the default placeholder text referencing `/compact`). If real compaction content exists, note it for the report.

7. **Report what was loaded** — print a concise summary:
   ```
   ── Session Initialized ──────────────
   Context files:  <N> total across all directories
   Sessions:       <N> total, latest: YYYY-MM-DD-<title>.md
   Compaction:     <found | not found | no previous session>
   ──────────────────────────────────────
   ```

8. **Do NOT generate a session report file** — init is read-only. No file is created in `context/sessions/`.
