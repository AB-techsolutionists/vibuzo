---
description: Initialize agent context — discover, verify, and report loaded state
agent: Vibuzo
---

Do these steps NOW:

1. **Read `AGENTS.md`** — load the universal entry point. Parse the file to understand agent roles (Vibuzo, Deepveloper, Deepsearcher), available commands (listed in the commands table), project conventions (Karpathy Principles, approval gates, custom rules), and file structure overview. Note any custom rules below the `─── PASTE YOUR CUSTOM RULES BELOW THIS LINE ───` marker. Do NOT print parsing details to chat.

2. **Read `context/index.md`** — parse the `## Files` section to discover all available context files. Count how many files exist under architecture/, standards/, patterns/, and sessions/. Do NOT print the file list to chat.

3. **Verify context directories** — use `Test-Path` to check each directory exists:
   - `context/architecture/`
   - `context/standards/`
   - `context/patterns/`
   - `context/sessions/`
   Do NOT print verification results to chat.

4. **Scan recent sessions** — read `context/sessions/index.md` and parse the timeline table:
   a. Determine today's date dynamically using `Get-Date -Format "yyyy-MM-dd"`
   b. Find all timeline rows matching today's date
   c. If today has entries → collect their file names → read ALL matching session files
   d. If no entries for today → compute yesterday's date using `(Get-Date).AddDays(-1).ToString("yyyy-MM-dd")` → find all rows matching yesterday → read ALL matching session files
   e. For each file read, check whether a `## Session Compaction` section with real content (not placeholder) exists

5. **Print the session summary box** — output ONLY this to chat:
   ```
   ── Session Initialized ──────────────
   Context files:  <N> total across all directories
   Sessions:       <N> total, <M> recent loaded from <date>
   Compaction:     <found in N files | not found>
   ──────────────────────────────────────
   ```
   Replace `<N>`, `<M>`, and `<date>` with actual values. Do not print any other output from steps 1-4.

6. **Do NOT generate a session report file** — init is read-only. No file is created in `context/sessions/`.
