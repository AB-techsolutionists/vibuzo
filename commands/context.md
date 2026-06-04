---
description: Initialize, find, or harvest project context
agent: Vibuzo
---

Manage project context: $ARGUMENTS

Route by $ARGUMENTS:
- Empty → show options (init, find, harvest)
- Starts with "init" → run `/context init`
- Starts with "find" → run `/context find <topic>` (everything after "find " is the topic)
- Starts with "harvest" → run `/context harvest`
- Natural language match (e.g., "show me everything about approval gates") → infer the intent from keywords and route to the appropriate subcommand
- Anything else → treat as `/context find <everything>`

---

## RUN: `/context init`

Do these steps NOW:

1. **Check existing structure** — check if `context/index.md` exists and if the subdirectories exist:
   - `context/standards/`
   - `context/patterns/`
   - `context/architecture/`
   - `context/sessions/`

2. **Create missing directories** — for any subdirectory that doesn't exist, create it with `New-Item -ItemType Directory -Force`

3. **Create `.gitkeep` files** — for each subdirectory, if there's no `.gitkeep` inside, create one (this preserves empty dirs in version control)

4. **Create or update `context/index.md`** — if it doesn't exist, create it with:
   ```
   # Project Context

   Auto-generated context index. Update this file when adding new context files.

   ## Directories

   | Directory | Purpose |
   |-----------|---------|
   | `architecture/` | Architecture Decision Records — store design decisions and rationale |
   | `standards/` | Coding standards, style guides, and conventions enforced across the project |
   | `patterns/` | Reusable design patterns, code snippets, and templates |
   | `sessions/` | Session compactions — auto-saved summaries via `/session` |

   ## Adding Context

   Use `/add-context <statement>` to add a new context file. The agent will infer the type (standard, pattern, architecture) and name, and save it to the appropriate directory.
   ```
   If it exists, ensure it references all four subdirectories and is up-to-date.

5. **Print status**:
   ```
   ── CONTEXT INIT ───────────────────────
   Status: <created | already exists> — N directories, N .gitkeep files
   Index: <created | updated | no change>
   ───────────────────────────────────────
   ```

---

## RUN: `/context find <topic>`

Do these steps NOW:

1. **Parse the topic** — extract everything after "find " from `$ARGUMENTS`. If the entire `$ARGUMENTS` is just "find" with no topic, read and display `context/index.md` as a menu.

2. **Exact match (primary)** — search for exact filename or title match in:
   - `context/patterns/*.md`
   - `context/standards/*.md`
   - `context/architecture/*.md`
   - `context/sessions/*.md`
   
   A file matches if the topic appears in the filename (case-insensitive, partial match is fine) OR the first heading (`# Title`) of the file contains the topic.

   If match found: read the file(s) and present full content to the user. Stop here.

3. **Broader search (fallback)** — if no exact match, scan all `.md` files in the same four directories for keyword matches in both filenames and file content:
   - Rank results: filename matches rank higher than content matches
   - For each result present:
     - File path
     - Brief content summary (first 1-2 lines or a relevant excerpt containing the keyword)

4. **No results** — if nothing found, inform the user and suggest `/add-context <statement about topic>` with an example relevant to their search.

---

## RUN: `/context harvest`

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
