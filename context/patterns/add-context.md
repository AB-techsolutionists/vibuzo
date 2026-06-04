# /add-context Command

> Save content as a permanent project context file. Supports both explicit and natural-language syntax. Automatically creates the file and updates the context index.

## Usage (Explicit Syntax)

```
/add-context <type> <name> <description>
```

## Usage (Natural Language)

```
/add-context <statement about a convention, rule, or architecture>
```

## Types

| Type | Directory | Purpose |
|------|-----------|---------|
| `pattern` | `context/patterns/<name>.md` | Reusable code patterns, architectural approaches, idioms |
| `standard` | `context/standards/<name>.md` | Code quality, naming conventions, testing requirements, style guides |
| `architecture` | `context/architecture/<name>.md` | System design decisions, data flow, component relationships |

## Explicit Syntax (Primary — backward compatible)

If `<args>` is empty, show usage. If `<type>` is a valid type and `<name>` is a name:

1. Create the file at `context/<type>/<name>.md`
2. Content is `<description>` (the rest of the arguments) — wrap it in a markdown note
3. Update `context/index.md` to include a reference to the new file
4. Report back what was created

Examples:
- `/add-context pattern react-hooks "Always use useCallback for event handlers"`
- `/add-context standard naming-conventions "All files must be kebab-case"`

## Natural Language Inference (Fallback)

When `<type>` is NOT a valid type, treat the entire input as a natural language statement and infer:

### Type Inference
- **`pattern`** — statements about conventions, idioms, "always/never" practices, code style preferences
- **`standard`** — statements about rules, "must/should" requirements, naming conventions, style guides
- **`architecture`** — statements about data flow, system design, component relationships, module boundaries

### Name Generation
1. Extract key nouns and concepts from the statement
2. Convert to kebab-case (e.g., "we always use useCallback for event handlers" → "use-callback-event-handlers")
3. Check uniqueness against existing files in the inferred type's directory
4. If name already exists, append a counter or present alternatives for confirmation

### Content Extraction
- Use the full statement as the content to save
- Wrap it in a markdown note with a descriptive heading derived from the name

### Ambiguity Resolution
- If type confidence is low (e.g., the statement could fit multiple categories), ask ONE clarifying question
- Use conversation history to resolve ambiguity (e.g., if the user just discussed architecture, bias toward `architecture`)
- If name generation produces an unintuitive name, present the generated name and ask for confirmation

### No-Arguments
If no arguments provided (`/add-context` alone), show this full usage documentation covering both syntaxes.

Examples:
- `/add-context we always use useCallback for event handlers` → infers type `pattern`, generates name `use-callback-event-handlers`
- `/add-context all components must have unit tests` → infers type `standard`, generates name `component-unit-tests`
- `/add-context the API gateway handles authentication before routing` → infers type `architecture`, generates name `api-gateway-auth-routing`
