---
tags:
  - architecture
  - commands
  - split-files
  - routing
  - execution-mode
scope: Command file structure, routing, and execution mode design
when: Creating new commands or modifying command file architecture
---

# Split-File Command Pattern

> Commands with subcommands should use standalone sub-files, not a monolithic file with multiple `## RUN:` sections, and not a routing-only main file.

## Problem

Opencode command templates with multiple `## RUN:` sections (e.g., `init`, `find`, `harvest`, `append`) under one file cause the agent to execute **all** sections sequentially. The agent reads the entire substituted template and executes every `Do these steps NOW:` it encounters, regardless of routing instructions, critical warnings, or guard clauses above each section.

Attempted (and failed) solutions:
- Adding `⚠️ CRITICAL: execute only one section` routing instruction
- Adding per-section guard clauses (`⚠️ SKIP if...`)
- Using `$ARGUMENTS` inside guard text for template substitution
- Guard clauses referencing "the user's arguments"

None worked because the agent processes the file linearly and never "jumps over" non-matching sections.

## Solution

Split into multiple files — each subcommand gets its own file with a single `Do these steps NOW:` section. No routing-only main file — those don't work either (agent reads them as plain text with no imperative instructions).

### Execution Mode

Commands use one of two modes:

- **Main session** (no `subtask: true`) — runs inline in the current agent session. Used for context/session management commands that need access to the full conversation history.
- **Subtask** (with `subtask: true`) — runs as a separate agent via the task tool. Used for pipelines like `/spec` that need isolated execution.

### Sub-file example (`commands/context-append.md`)
```markdown
---
agent: Vibuzo
---

Do these steps NOW:
1. Step one
2. Step two
```

## Key Rules

1. Each sub-file has exactly one `Do these steps NOW:` section
2. Sub-files go in `commands/` directory
3. Mirrors must be synced to `.opencode/commands/`
4. `$ARGUMENTS` must only appear in the first description line — never in section bodies
5. Set `subtask: true` only for commands that need isolated execution (e.g., `/spec`)

## ⚠️ Lesson Learned: Routing-Only Main Files Don't Work

An earlier version of this pattern used a **routing-only main file** (`commands/<command>.md`) with zero `Do these steps NOW:` instructions, intended to dispatch to sub-files. This failed because:

- The agent reads the file and finds **no actionable instructions** → does nothing
- The routing text is just plain Markdown — the agent doesn't "execute" routing logic
- It shows the raw text to the user instead of taking action

**These routing files have been removed.**

## Applications

This pattern has been applied to:

| Command | Sub-Files | Mode |
|---------|-----------|------|
| `/context` | `context-init.md`, `context-find.md`, `context-harvest.md`, `context-append.md` | Main session |
| `/session` | `session.md` (modes: report, init) | Main session |
| `/spec` | `spec.md` | Subtask |

Context and session commands run in the main agent session so they can access conversation history and maintain continuity. `/spec` uses a subtask because the 5-phase pipeline benefits from isolated execution.

All future commands with subcommands MUST follow this pattern — use standalone sub-files only, no routing main file.

## Rationale

The template engine substitutes `$ARGUMENTS` everywhere before the agent reads the file. Multi-section files always fail because the agent executes everything imperative it sees. Splitting eliminates ambiguity — one file, one purpose. Routing-only files fail because imperative instructions are required for the agent to act.
