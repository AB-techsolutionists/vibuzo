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
Read `context/index.md` to discover available context files. Then read the most relevant ones and present their content to the user. If $1 is empty, just present the index as a menu.

## /context harvest
Read all files in `context/sessions/`. Look for recurring patterns, architectural decisions, or conventions mentioned across sessions. Present candidates for promotion to permanent context (standards/, patterns/, architecture/). For each candidate, ask the user if they want to save it, then write the file.
