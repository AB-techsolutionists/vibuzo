# Project Context

This directory contains project-level context files that are automatically loaded at the start of every new session. Agents read this index to discover available knowledge.

## Structure

| Directory | Purpose |
|-----------|---------|
| `standards/` | Code quality, naming conventions, testing requirements, style guides |
| `patterns/` | Reusable code patterns, architectural approaches, idioms |
| `architecture/` | System design decisions, data flow, component relationships |
| `sessions/` | Auto-generated compaction archives (via `/session`) |

See the master timeline at `sessions/index.md` for a chronological list of all compactions.

## How to Add Context

- **Manually**: Create a `.md` file in the appropriate directory
- **Via command**: `/add-context <type> <name> <description>`
- **From sessions**: `/context harvest` promotes session patterns to permanent files

## Files

### Architecture
- `architecture/agent-restructure.md` — Agent architecture decision: Vibuzo as main agent, Deepveloper triggered via /spec for implementation subtasks
- `architecture/approval-gates.md` — Architecture decision for configurable approval gates (levels 0-3)
- `architecture/spec-command.md` — Architecture decision for the /spec command (5-phase pipeline, deprecated old commands)
- `architecture/build-agent-override.md` — ⚠️ CORRECTED — Old approach for overriding Build agent (superseded by default-agent-in-opencode-jsonc.md)
- `architecture/default-agent-in-opencode-jsonc.md` — Correct approach: use `"default_agent": "vibuzo"` in opencode.jsonc to make `/new` open Vibuzo
- `architecture/split-file-command-pattern.md` — Architecture decision: commands with subcommands must use routing-only main file + individual sub-files (applied to `context` and `session`)

### Patterns
- `patterns/add-context.md` — Specification for the `/add-context` command (types, usage, behavior)
- `patterns/route-based-argument-handling.md` — Pattern for parsing $ARGUMENTS at command top and routing to subcommand sections
- `patterns/session-history-candidate-scanning.md` — Pattern for scanning conversation history and saving context-worthy knowledge
- `patterns/title-based-session-naming.md` — Pattern for YYYY-MM-DD-<title>.md session compaction filenames

### Standards
- `standards/imperative-command-style.md` — All command files must use imperative "Do these steps NOW:" instructions
- `standards/naming.md` — Use camelCase for variables, functions, and methods
- `standards/approval-gate-code-block-rendering.md` — Approval gates must be rendered inside code blocks for terminal card display
- `standards/arguments-usage-in-command-templates.md` — $ARGUMENTS must only appear in routing section, never in section bodies
- `standards/source-mirror-synchronization.md` — Every active source file in commands/ and agents/ must have an identical mirror in .opencode/
- `standards/agent-report-summary-next-steps.md` — Agents must always report a summary and next steps after completing any work

### Sessions
- `sessions/index.md` — Auto-generated master timeline of all compactions (via `/session`)

## Maintenance

**Rule: After creating, updating, or deleting any context file, the agent MUST update this index immediately.** Do not close the task without verifying the index is current. The sessions timeline at `sessions/index.md` is auto-maintained by `/session`.
