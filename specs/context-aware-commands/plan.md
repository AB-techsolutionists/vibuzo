# Context-Aware Commands — Implementation Plan

## Tech Stack

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Command definitions | Markdown + YAML frontmatter | Existing framework standard. No runtime code, no dependencies. |
| Natural language inference | Agent behavioral instructions | The LLM agent (Vibuzo) interprets natural language. No NLP library needed — the model's inherent language understanding does the work. |
| Name generation | Instruction-based heuristic | Agent extracts key nouns from user statement and converts to kebab-case per existing naming standard. |
| Type inference | Keyword + context heuristics | Agent matches user statement against type indicators defined in the command instructions. |
| Conversation history | Agent's inherent memory | The agent has access to the current conversation context. Instructions tell it how to use that. |

**Key principle**: Zero new dependencies, zero runtime code. Everything is agent behavior encoded in command file instructions.

## Architecture

### Data Flow

```
User: /add-context we always use useCallback for event handlers
                │
                ▼
          ┌─────────────────────┐
          │  Vibuzo reads       │
          │  add-context.md     │
          └────────┬────────────┘
                   │
        ┌──────────▼──────────┐
        │  Parse $ARGUMENTS   │
        │                     │
        │  Match rigid syntax?│──Yes──► Use explicit values (backward compat)
        │  (type = pattern│   │
        │   standard│arch)    │
        └──────────┬──────────┘
                   │ No
                   ▼
        ┌─────────────────────┐
        │ Natural language    │
        │ inference pipeline  │
        │                     │
        │ 1. Infer type       │
        │ 2. Generate name    │
        │ 3. Extract content  │
        │ 4. Confirm (if low  │
        │    confidence)      │
        └──────────┬──────────┘
                   │
                   ▼
        ┌─────────────────────┐
        │ Execute (create     │
        │ file, update index, │
        │ report)             │
        └─────────────────────┘
```

### Inference Heuristics

#### Type Inference Map

| User says... | Likely type |
|-------------|-------------|
| "always", "never", "convention", "do this when" | `pattern` |
| "must", "required", "naming", "style", "format" | `standard` |
| "flows", "architecture", "component", "diagram", "decision" | `architecture` |
| Vague or mixed | Ask clarifying question |

#### Name Generation Heuristic

```
Input: "we always use useCallback for event handlers"
  1. Extract key nouns: ["useCallback", "event", "handlers"]
  2. Filter stop words: ["useCallback", "event", "handlers"]
  3. Take first 2-3: ["useCallback", "event", "handlers"]
  4. Kebab-case: "usecallback-event-handlers"
  5. Check uniqueness → if "usecallback-event-handlers.md" exists, try "usecallback-event-handlers-2.md"
```

#### Conversation History Integration

When confidence is low (<70%), the agent checks:
- What was the user talking about in the last 3 messages?
- Was there a specific convention or pattern mentioned?
- Did the user reference a specific file or decision?

### Files to Modify

| File | Change Type | Description |
|------|-------------|-------------|
| `commands/add-context.md` | **Rewrite** | Replace rigid-syntax-only instructions with dual-mode (explicit + natural language) |
| `.opencode/commands/add-context.md` | Mirror | Same content as above |
| `commands/context.md` | **Rewrite** | Add natural language support to find subcommand |
| `.opencode/commands/context.md` | Mirror | Same content as above |
| `commands/session.md` | **Rewrite** | Add natural language inference for log/view commands |
| `.opencode/commands/session.md` | Mirror | Same content as above |
| `commands/spec.md` | **Edit** | Update feature name derivation for unquoted multi-word descriptions |
| `.opencode/commands/spec.md` | Mirror | Same content as above |

### No Changes To

- `commands/plan.md`, `commands/tasks.md`, `commands/implement.md`, `commands/review.md`
- `.opencode/commands/{plan,tasks,implement,review}.md`
- `agents/vibuzo.md`, `agents/deepveloper.md`
- `AGENTS.md`, `README.md`
- `context/` directory files
- Any `.ps1`, `.sh`, `.json` files

## Implementation Order

### Task 1: Update `/add-context` command (parallel-safe)
**File**: `commands/add-context.md` + `.opencode/commands/add-context.md`
**Risk**: Low. Self-contained command file rewrite.
**Description**: Replace rigid-syntax-only instructions with dual-mode instructions. Add natural language inference pipeline description.

### Task 2: Update `/context` command (parallel-safe)
**File**: `commands/context.md` + `.opencode/commands/context.md`
**Risk**: Low. Add natural language support to `/context find`.
**Description**: Add semantic search instructions to the find subcommand.

### Task 3: Update `/session` command (parallel-safe)
**File**: `commands/session.md` + `.opencode/commands/session.md`
**Risk**: Low. Add natural language inference.
**Description**: Update to accept natural statements and infer intent (log vs view vs list).

### Task 4: Update `/spec` command (parallel-safe)
**File**: `commands/spec.md` + `.opencode/commands/spec.md`
**Risk**: Lowest. Targeted change to feature name derivation.
**Description**: Update feature name derivation to handle unquoted multi-word descriptions.

### Dependency Graph

```
Task 1 ─┐
Task 2 ─┤ (all parallel, no dependencies)
Task 3 ─┤
Task 4 ─┘
```

## Risk Assessment

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Ambiguous user statements cause incorrect inference | Medium | Medium | Include clarification prompts; ask before writing |
| Backward compatibility break for rigid syntax | Low | High | Always try rigid syntax match FIRST before natural language fallback |
| User expects perfect semantic search from /context find | Low | Low | Document that it's keyword-based, not AI-powered search |
| Generated names are unhelpful or ugly | Medium | Low | Agent presents generated name for confirmation; user can override |
| Name collision (file already exists) | Low | Low | Check for existing file; append `-N` or ask user |
