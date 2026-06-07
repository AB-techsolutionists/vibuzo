---
description: Save a rule or pattern to project context
agent: Vibuzo
subtask: true
---

Save content to project context: $ARGUMENTS

## Usage (Explicit Syntax)
- `/add-context <type> <name> <description>`

## Usage (Natural Language)
- `/add-context <statement about a convention, rule, or architecture>`

Types:
- `pattern` → context/patterns/<name>.md
- `standard` → context/standards/<name>.md
- `architecture` → context/architecture/<name>.md

## Explicit Syntax (Primary — backward compatible)

If $1 is empty, show usage. If $1 is a valid type and $2 is a name:
1. Prompt the user for frontmatter fields:
   - `tags:` — comma-separated list of keywords (3-6 tags)
   - `scope:` — single line describing what kind of task this applies to
   - `when:` — single-line trigger description (when the agent should consult this)
2. Generate standard YAML frontmatter block from the provided fields
3. Create the file at `context/$1/$2.md` with frontmatter at the top and content below
4. Content is $3 (the rest of the arguments) — wrap it in a markdown note below the frontmatter
5. Update `context/index.md` to include a reference to the new file
6. Report back what was created

Examples:
- `/add-context pattern react-hooks "Always use useCallback for event handlers"`
- `/add-context standard naming-conventions "All files must be kebab-case"`

## Natural Language Inference (Fallback)

When $1 is NOT a valid type, treat the entire input as a natural language statement and infer:

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

### Frontmatter Generation
After type and name are determined, prompt the user for frontmatter fields:
1. Ask: `Tags? (comma-separated, 3-6 keywords):` — generate sensible defaults based on content if possible, let user override
2. Ask: `Scope? (single line describing applicability):`
3. Ask: `When? (single-line trigger — when should the agent consult this):`
4. Generate standard YAML frontmatter block with the provided fields
5. When creating the file, write frontmatter first, then a blank line, then the content

### No-Arguments
If no arguments provided (`/add-context` alone), show this full usage documentation covering both syntaxes.

Examples:
- `/add-context we always use useCallback for event handlers` → infers type `pattern`, generates name `use-callback-event-handlers`
- `/add-context all components must have unit tests` → infers type `standard`, generates name `component-unit-tests`
- `/add-context the API gateway handles authentication before routing` → infers type `architecture`, generates name `api-gateway-auth-routing`
