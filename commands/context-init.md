---
description: Scaffold the context directory structure and index file
agent: Vibuzo
---

Scaffold project context directories and index.

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
