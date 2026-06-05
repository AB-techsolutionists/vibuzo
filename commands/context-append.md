---
description: Scan the current conversation and save candidates to permanent context
agent: Vibuzo
---

Scan the current conversation for context-worthy candidates and save them.

Do these steps NOW:

1. **Scan the current conversation** — review the session history (this conversation's messages) for content worth preserving as permanent context:
   - **Architectural decisions** — design choices, tradeoffs discussed, system architecture decisions, component relationships
   - **Recurring patterns** — techniques, approaches, idioms mentioned or established during the conversation
   - **Conventions** — rules, standards, naming conventions discussed, agreed upon, or demonstrated
   - **Key insights** — important findings, gotchas, lessons learned, or contextual rationale

   Use the same type classification as `/add-context`:
   - `pattern` → `context/patterns/<name>.md`
   - `standard` → `context/standards/<name>.md`
   - `architecture` → `context/architecture/<name>.md`

2. **Generate candidate names** — for each candidate, derive a kebab-case name from the core concept (e.g., "we decided to use React Router for all navigation" → `react-router-navigation`). Check uniqueness against existing files in the target directory.

3. **Present each candidate** — for each, show:
   ```
   ── CONTEXT APPEND — Candidate N ───────
   Type: <pattern | standard | architecture>
   Name: <kebab-case-name>
   Evidence: <what was said, quoted or summarized>
   Target: context/<type>/<name>.md
   ───────────────────────────────────────
   Append this? (y/N):
   ```

   Process candidates one at a time. If the user says "y":
   - Check if `context/<type>/<name>.md` already exists
   - **If exists**: append the new content as a new section under a `## <heading>` derived from the candidate
   - **If new**: create the file with a markdown note and a descriptive heading
   - Update `context/index.md` to reference the new file (only for newly created files)

   If the user says "N": skip to the next candidate.

4. **No candidates found** — if nothing worth preserving is identified, inform the user: "No context-worthy candidates found in this conversation."

5. **Print status**:
   ```
   ── CONTEXT APPEND ─────────────────────
   Candidates found: N
   Appended: N (N new, N updated)
   ───────────────────────────────────────
   ```
