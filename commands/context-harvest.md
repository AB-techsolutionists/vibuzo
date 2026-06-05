---
description: Mine session files for patterns to promote to permanent context
agent: Vibuzo
---

Mine session compactions for patterns worth promoting to permanent context.

Do these steps NOW:

1. **Read all session files** — glob `context/sessions/*.md` (exclude `index.md`). Read each file.

2. **Analyze for promotion candidates** — look for:
   - **Recurring patterns** — the same technique or approach appears across multiple sessions
   - **Architectural decisions** — decisions described in Critical Context or Key Decisions that belong in a permanent ADR
   - **Conventions** — repeated practices or standards that should be formalized in `standards/`

3. **Present candidates** — for each candidate, show:
   ```
   Candidate: <title>
   Type: <standard | pattern | architecture>
   Source: <session filename>
   Evidence: <what was said across sessions>
   Proposed file: context/<type>/<name>.md
   ```

4. **Ask per candidate** — "Save this candidate? (y/N)". If the user says yes, write the file to the appropriate directory with a Markdown summary of the finding.

5. **Print status**:
   ```
   ── CONTEXT HARVEST ────────────────────
   Candidates found: N
   Saved: N
   ───────────────────────────────────────
   ```
