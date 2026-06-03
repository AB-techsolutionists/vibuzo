# /add-context Command

> Save content as a permanent project context file. Automatically creates the file and updates the context index.

## Usage

```
/add-context <type> <name> <description>
```

## Types

| Type | Directory | Purpose |
|------|-----------|---------|
| `pattern` | `context/patterns/<name>.md` | Reusable code patterns, architectural approaches, idioms |
| `standard` | `context/standards/<name>.md` | Code quality, naming conventions, testing requirements, style guides |
| `architecture` | `context/architecture/<name>.md` | System design decisions, data flow, component relationships |

## Behavior

1. Creates the file at `context/<type>/<name>.md`
2. Content is `<description>` (the rest of the arguments) — wrapped in a markdown note
3. Updates `context/index.md` to include a reference to the new file
4. Reports back what was created

If arguments are empty, displays usage info.

## Examples

- `/add-context pattern react-hooks "Always use useCallback for event handlers"`
- `/add-context standard api-patterns "All API routes follow /api/v1/<resource>"`
- `/add-context architecture data-flow "Data flows unidirectionally from stores to views"`
