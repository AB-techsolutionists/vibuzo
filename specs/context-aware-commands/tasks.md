# Context-Aware Commands — Task Breakdown

## Task 1: Rewrite `/add-context` with natural language support [P]

**Description**: Replace the rigid-syntax-only instructions in `commands/add-context.md` with dual-mode instructions that support both the existing explicit syntax (`/add-context <type> <name> <description>`) and natural language inference. Add the inference pipeline: type inference, name generation, content extraction, clarification prompts, and conversation history integration.

**Files**:
- `commands/add-context.md` — rewrite
- `.opencode/commands/add-context.md` — mirror (same content)

**Depends on**: —
**Parallel**: Yes [P]

**Acceptance**:
- ✅ `/add-context pattern react-hooks "Always use useCallback"` works exactly as before (backward compat)
- ✅ `/add-context we always use useCallback for event handlers` infers type, generates name, extracts content
- ✅ Type inference heuristics documented (pattern vs standard vs architecture)
- ✅ Name generation heuristic documented (extract nouns → kebab-case → uniqueness check)
- ✅ Clarification prompts documented for low-confidence scenarios
- ✅ Conversation history integration documented
- ✅ No-args `/add-context` shows usage with both syntaxes
- ✅ Both `commands/add-context.md` and `.opencode/commands/add-context.md` are updated

---

## Task 2: Rewrite `/context find` with natural language support [P]

**Description**: Update the `/context find <topic>` subcommand in `commands/context.md` to accept natural language queries. When the rigid `<topic>` isn't a clear match, the agent searches across all context directories using keyword + filename matching. Add instructions for presenting results and handling no-results cases.

**Files**:
- `commands/context.md` — rewrite
- `.opencode/commands/context.md` — mirror

**Depends on**: —
**Parallel**: Yes [P]

**Acceptance**:
- ✅ `/context find authentication flow` searches across all `context/` subdirectories
- ✅ `/context find auth` does keyword/fuzzy matching, not exact match
- ✅ Results presented with file paths and content summaries
- ✅ No-results case suggests creating new context
- ✅ `/context find <exact-topic>` still works (backward compat)
- ✅ `/context init` and `/context harvest` subcommands unchanged
- ✅ Both files updated

---

## Task 3: Rewrite `/session` with natural language inference [P]

**Description**: Update `commands/session.md` to accept natural language statements and infer intent. If the user says `/session we finished the auth module`, the agent treats it as a session log entry. If the user asks about history, treat as view. Add intent inference heuristics.

**Files**:
- `commands/session.md` — rewrite
- `.opencode/commands/session.md` — mirror

**Depends on**: —
**Parallel**: Yes [P]

**Acceptance**:
- ✅ `/session we finished the auth module` creates a session log entry with timestamp
- ✅ `/session log "we finished the auth module"` works exactly as before (backward compat)
- ✅ `/session view` works exactly as before
- ✅ `/session list` works exactly as before
- ✅ `/session` (no args) shows recent logs — unchanged
- ✅ Past-tense statements are detected as log entries
- ✅ Question-like statements are detected as view requests
- ✅ Both files updated

---

## Task 4: Update `/spec` for unquoted multi-word descriptions [P]

**Description**: Update `commands/spec.md` to handle unquoted multi-word feature descriptions. Currently the spec says "Take the first word of the description as the feature name". Change to: parse the full `$ARGUMENTS` as the description, then convert the entire thing to kebab-case for the feature name. Handle both quoted and unquoted input.

**Files**:
- `commands/spec.md` — edit (targeted change)
- `.opencode/commands/spec.md` — mirror

**Depends on**: —
**Parallel**: Yes [P]

**Acceptance**:
- ✅ `/spec dark mode toggle` (unquoted) → feature name `dark-mode-toggle`
- ✅ `/spec "dark mode toggle"` (quoted) → feature name `dark-mode-toggle`
- ✅ `/spec auth` (single word) → feature name `auth`
- ✅ All existing `/spec` functionality preserved
- ✅ Both files updated

---

## Execution Order

All 4 tasks are marked `[P]` (parallel). No dependencies between them. Implementation order is arbitrary — all can be done concurrently.

## Total Tasks

**4 tasks**, all parallel, all low risk.
