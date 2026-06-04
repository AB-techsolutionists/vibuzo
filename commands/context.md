---
description: Initialize, find, or harvest project context
---

Manage project context: $ARGUMENTS

If no arguments, show the options (init, find, harvest).

## /context init
Create the context directory scaffold:
```
context/
├── index.md
├── standards/
├── patterns/
├── architecture/
└── sessions/
```

Create `context/index.md` with a brief description of each subdirectory and update instructions. Each subdirectory gets a `.gitkeep` to preserve it in version control.

## /context find <topic>
Search project context for information about a topic.

### Exact Match (Primary — backward compatible)
If `<topic>` is provided, first try to find an exact match against filename or title in:
- `context/patterns/`
- `context/standards/`
- `context/architecture/`
- `context/sessions/`

Read matching files and present their content to the user. If $1 is empty, just present the index as a menu.

### Broader Search (Fallback)
If no exact match is found, perform a broader keyword search:
1. Scan all `.md` files in `context/patterns/`, `context/standards/`, `context/architecture/`, `context/sessions/` for keyword matches in filenames and file content
2. Rank results by relevance (filename matches rank higher than content matches)
3. Present results with:
   - File path
   - Brief content summary (first 1-2 lines or relevant excerpt)

### No Results
If nothing is found across all directories:
- Inform the user that no matching context was found
- Suggest creating new context via `/add-context <statement>` with an example relevant to their search

## /context harvest
Read all files in `context/sessions/`. Look for recurring patterns, architectural decisions, or conventions mentioned across sessions. Present candidates for promotion to permanent context (standards/, patterns/, architecture/). For each candidate, ask the user if they want to save it, then write the file.
