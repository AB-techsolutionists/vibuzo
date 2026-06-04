# Context-Aware Commands — Specification

## Principles

- **Natural language first** — Commands should accept free-form natural language and infer intent rather than requiring rigid positional arguments. Users describe what they want; the agent figures out the mechanics.
- **No code changes** — All behavior changes live in command Markdown definitions with YAML frontmatter. No runtime code, no new dependencies, no build steps.
- **Backward compatible** — The existing rigid syntax (`/add-context <type> <name> <description>`) continues to work as an explicit override. Natural language parsing is the default when the rigid format isn't matched.
- **Conversation-aware** — When a user's statement is ambiguous or incomplete, the agent uses conversation history (recent messages, session context) to infer missing fields (type, name, content).
- **Surgical scoping** — Only the four targeted commands change: `/add-context`, `/context`, `/session`, `/spec`. No other commands are modified.

## Specification

### Overview

The Vibuzo framework's context-related commands currently require rigid argument syntax:

```
/add-context <type> <name> <description>
/context find <topic>
/session log <message>
/spec <feature-description>
```

This creates friction. Users must remember the exact argument order and valid values for each command. If a user types `/add-context we always use useCallback for event handlers`, the command fails because the parser expects `<type>` as the first argument ("we" is not a valid type).

This feature makes all four commands accept **natural language input**. The agent:
1. Receives the user's free-form statement
2. Infers intent using the command description + current conversation context
3. Maps to the equivalent structured operation (e.g., infer type, generate name, extract content)
4. Executes the operation

The rigid positional syntax is preserved as an explicit override for power users.

### User Stories

1. As a developer who wants to save a quick context rule, I want to type `/add-context we always use useCallback for event handlers` and have the agent infer the type (`pattern`), generate a name (`react-use-callback`), and save the content — without me thinking about argument order.
2. As a developer who types rigid syntax out of habit, I want `/add-context pattern react-hooks "Always use useCallback"` to still work exactly as before, so existing workflows aren't broken.
3. As a developer who is unsure about the type of context to save, I want the agent to ask me clarifying questions or suggest the most likely type based on my statement, so I don't need to memorize the type taxonomy.
4. As a developer using `/context find`, I want to say `/context find authentication patterns` instead of remembering the exact topic name, so the agent can search semantically.
5. As a developer using `/session log`, I want to say `/session we finished the auth module today` and have the agent format a proper session entry.
6. As a developer using `/spec`, I want to say `/spec build a dark mode toggle` instead of `/spec "dark mode toggle"` and have the agent correctly derive the feature name.

### Functional Requirements

#### FR1: Natural Language Parsing (All Four Commands)

Each command shall accept free-form natural language as `$ARGUMENTS`. The agent shall:
1. First attempt to match the rigid positional syntax (e.g., `/add-context <type> <name> <description>` with `<type>` matching `pattern|standard|architecture`) — if matched, use explicit values.
2. If the rigid syntax does not match, fall through to natural language parsing:
   - Parse the statement for content, intent, type indicators
   - Use conversation context to fill in missing information
   - Ask clarifying questions if ambiguity cannot be resolved
3. Generate a sensible name (kebab-case) from the content if not explicitly provided.

#### FR2: Type Inference for `/add-context`

When the type is not explicitly provided, the agent shall infer it from the statement:
- **pattern** — Statements about "how we do X", "always/never", conventions, idioms, code patterns, best practices
- **standard** — Statements about "must", "required", naming, formatting, style, rules, linter-like statements
- **architecture** — Statements about data flow, component relationships, system design, decisions, tradeoffs

If unclear, the agent shall present the options and ask.

#### FR3: Name Generation

When the name is not explicitly provided, the agent shall:
1. Extract 1-4 key nouns/concepts from the statement
2. Convert to kebab-case
3. Ensure uniqueness (check if file already exists; if so, append `-N` or suggest alternatives)
4. Present the generated name for confirmation before creating the file

#### FR4: `/add-context` — Updated Behavior

```
Current: /add-context <type> <name> <description>
New:
  - /add-context <type> <name> <description>  (explicit — unchanged)
  - /add-context <natural language statement>  (inferred)
  - /add-context                                (show usage with both syntaxes)
```

When using natural language:
1. Infer `type` from statement content (FR2)
2. Generate `name` from statement content (FR3)
3. Extract `description` as the remaining content
4. Create file at `context/<type>/<name>.md`
5. Update `context/index.md`
6. Report what was inferred and created

#### FR5: `/context find` — Updated Behavior

```
Current: /context find <topic>
New:
  - /context find <topic>           (unchanged)
  - /context find <natural query>   (search across all context files semantically)
  - /context find                    (present index as menu — unchanged)
```

When using natural language:
1. Search across all context files (`context/patterns/`, `context/standards/`, `context/architecture/`, `context/sessions/`) for relevant content matching the query
2. Use keyword matching and file name matching
3. Present the most relevant results with their content summaries
4. If nothing relevant found, report that and suggest creating new context

#### FR6: `/session log` — Updated Behavior

```
Current: /session log <message>
New:
  - /session log <message>          (unchanged — explicit log message)
  - /session <natural statement>    (infer intent: log, view, list)
  - /session                        (show recent logs — unchanged)
```

When using natural language:
1. If statement describes past work → format as a session log entry with timestamp
2. If statement asks about history → treat as `/session view` with filter
3. If statement lists accomplishments → format as structured bullet points

#### FR7: `/spec` — Updated Behavior

```
Current: /spec <feature-description>
New:
  - /spec <feature-description>        (unchanged — quoted or unquoted multi-word)
  - /spec                               (show usage — unchanged)
```

The `/spec` command already accepts free-form description. The improvement is:
1. Accept unquoted multi-word descriptions (e.g., `/spec dark mode toggle` works without quotes)
2. Derive the feature name intelligently from the description, not just the first word
3. Use the full description as the feature description

#### FR8: Clarification Prompts

When the agent cannot resolve ambiguity with high confidence, it shall ask:
- "I think you want to save this as a `<type>` rule. Is that right? (y/N)"
- "I generated the name `<name>` from your statement. Does this work? (y/N)"

Keep prompts minimal — one at a time, not a form.

#### FR9: Conversation History Integration

The agent shall use recent conversation history to:
- Resolve ambiguous types: if the user just discussed architecture, prefer `architecture` type
- Resolve missing content: if the user said "save that as a pattern", use the previous message as content
- Provide continuity: maintain context across multiple natural-language commands in the same session

### Acceptance Criteria

- ✅ `/add-context we always use useCallback for event handlers` infers type `pattern`, generates name `use-callback-event-handlers` or similar, creates file, updates index
- ✅ `/add-context pattern react-hooks "Always use useCallback"` works exactly as before (backward compatible)
- ✅ `/add-context` with no args shows usage with both explicit and natural-language syntax
- ✅ `/context find authentication flow` searches across all context dirs and returns relevant results
- ✅ `/context find auth` also returns results (keyword matching)
- ✅ `/session we finished the auth module` creates a proper session log entry
- ✅ `/session log "finished the auth module"` works exactly as before
- ✅ `/spec dark mode toggle` (unquoted) correctly derives feature name `dark-mode-toggle`
- ✅ `/spec "dark mode toggle"` (quoted) still works
- ✅ Ambiguous statements trigger a single clarifying question (not a form)
- ✅ Conversation history is used to resolve ambiguity when possible
- ✅ All changes are in command Markdown files only — no code files modified or created
- ✅ No other commands (`/plan`, `/tasks`, `/implement`, `/review`) are modified

### Out of Scope

- Modifying the approval gates system
- Adding runtime code, dependencies, or build steps
- Changing Deepveloper's behavior
- Semantic search with embeddings or vector databases (keyword + filename matching only)
- Multi-turn conversational context across separate sessions
- Modifying deprecated commands (`/plan`, `/tasks`, `/implement`, `/review`)
- Changing the agent definition files (`agents/vibuzo.md`, `agents/deepveloper.md`)
- Modifying `AGENTS.md` or `README.md`
