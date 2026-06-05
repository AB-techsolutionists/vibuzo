# Split-File Command Pattern

> Commands with subcommands should use standalone sub-files (each with `subtask: true`), not a monolithic file with multiple `## RUN:` sections, and not a routing-only main file.

## Problem

Opencode command templates with multiple `## RUN:` sections (e.g., `init`, `find`, `harvest`, `append`) under one file cause the agent to execute **all** sections sequentially. The agent reads the entire substituted template and executes every `Do these steps NOW:` it encounters, regardless of routing instructions, critical warnings, or guard clauses above each section.

Attempted (and failed) solutions:
- Adding `⚠️ CRITICAL: execute only one section` routing instruction
- Adding per-section guard clauses (`⚠️ SKIP if...`)
- Using `$ARGUMENTS` inside guard text for template substitution
- Guard clauses referencing "the user's arguments"

None worked because the agent processes the file linearly and never "jumps over" non-matching sections.

## Solution

Split into multiple files — each subcommand gets its own file:

- `commands/<command>-<subcommand>.md` — **single purpose** with `Do these steps NOW:` instructions and `subtask: true` in YAML frontmatter.
- No routing-only main file — those don't work either (agent reads them as plain text with no imperative instructions).

### Sub-file (`commands/context-append.md`)
```markdown
---
subtask: true
---

Do these steps NOW:
1. Step one
2. Step two
```

## Key Rules

1. Each sub-file gets `subtask: true` in YAML frontmatter
2. Each sub-file has exactly one `Do these steps NOW:` section
3. Sub-files go in `commands/` directory
4. Mirrors must be synced to `.opencode/commands/`
5. `$ARGUMENTS` must only appear in the first description line — never in section bodies

## ⚠️ Lesson Learned: Routing-Only Main Files Don't Work

An earlier version of this pattern used a **routing-only main file** (`commands/<command>.md`) with zero `Do these steps NOW:` instructions, intended to dispatch to sub-files. This failed because:

- The agent reads the file and finds **no actionable instructions** → does nothing
- The routing text is just plain Markdown — the agent doesn't "execute" routing logic
- It shows the raw text to the user instead of taking action

**These routing files have been removed.** The sub-files remain and work correctly when invoked directly.

## Applications

This pattern has been applied to:

| Command | Sub-Files |
|---------|-----------|
| `/context` | `context-init.md`, `context-find.md`, `context-harvest.md`, `context-append.md` |
| `/session` | `session-compaction.md`, `session-view.md`, `session-timeline.md` |

All future commands with subcommands MUST follow this pattern — use standalone sub-files only, no routing main file.

## Rationale

The template engine substitutes `$ARGUMENTS` everywhere before the agent reads the file. Multi-section files always fail because the agent executes everything imperative it sees. Splitting eliminates ambiguity — one file, one purpose. Routing-only files fail because imperative instructions are required for the agent to act.
