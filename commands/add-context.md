---
description: Save a rule or pattern to project context
agent: Vibuzo
subtask: true
---

Save content to project context: $ARGUMENTS

Usage: /add-context <type> <name> <description>

Types:
- `pattern` → context/patterns/<name>.md
- `standard` → context/standards/<name>.md
- `architecture` → context/architecture/<name>.md

Example:
- `/add-context pattern react-hooks "Always use useCallback for event handlers"`

If $1 is empty, show usage. If $1 is a valid type and $2 is a name:
1. Create the file at `context/$1/$2.md`
2. Content is $3 (the rest of the arguments) — wrap it in a markdown note
3. Update `context/index.md` to include a reference to the new file
4. Report back what was created
