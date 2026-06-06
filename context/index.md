# Project Context

This directory contains project-level context files that are automatically loaded at the start of every new session. Agents read this index to discover available knowledge.

**At session start, after reading this file, the agent MUST:**
1. Read `sessions/index.md` to find the latest (last) entry
2. Read that latest session summary file to understand the previous session's state, pending work, and decisions
3. Then proceed normally

This ensures every new session automatically picks up where the last one left off — no manual prompting needed.

## Structure

| Directory | Purpose |
|-----------|---------|
| `standards/` | Code quality, naming conventions, testing requirements, style guides |
| `patterns/` | Reusable code patterns, architectural approaches, idioms |
| `architecture/` | System design decisions, data flow, component relationships |
| `sessions/` | Auto-generated summary archives (via `/session`) |

See the master timeline at `sessions/index.md` for a chronological list of all summaries.

## How to Add Context

- **Manually**: Create a `.md` file in the appropriate directory
- **Via command**: `/add-context <type> <name> <description>`
- **From sessions**: `/context harvest` promotes session patterns to permanent files

## Files

### Architecture
- `architecture/agent-restructure.md` — Agent architecture decision: Vibuzo as main agent, Deepveloper triggered via /spec for implementation subtasks
- `architecture/approval-gates.md` — Architecture decision for configurable approval gates (levels 0-3)
- `architecture/spec-command.md` — Architecture decision for the /spec command (5-phase pipeline)
- `architecture/split-file-command-pattern.md` — Architecture decision: each command gets one file with one `Do these steps NOW:` section. No routing-only files. Two execution modes: main session vs subtask.
- `architecture/build-agent-override.md` — 🗑️ DEPRECATED — Referenced opencode.jsonc (removed)
- `architecture/default-agent-in-opencode-jsonc.md` — 🗑️ DEPRECATED — Referenced opencode.jsonc (removed)
- `architecture/installer-update-mechanism.md` — Architecture decision for the `--update` flag: version marker file, GitHub API comparison, interactive confirmation, best-effort failure handling

### Patterns
- `patterns/route-based-argument-handling.md` — ⚠️ FAILED PATTERN — Single-file routing doesn't work. All commands use split files instead.
- `patterns/title-based-session-naming.md` — Pattern for YYYY-MM-DD-<title>.md session summary filenames
- `patterns/session-workflow.md` — Pattern for `/session → /compact → /new` golden workflow: preserve state before compaction, avoid overlap, auto-load latest session on `/new`

### Standards
- `standards/imperative-command-style.md` — All command files must use imperative "Do these steps NOW:" instructions
- `standards/naming.md` — Use camelCase for variables, functions, and methods
- `standards/arguments-usage-in-command-templates.md` — $ARGUMENTS must only appear in first description line, never in section bodies
- `standards/source-mirror-synchronization.md` — Every active source file in commands/ and agents/ must have an identical mirror in .opencode/
- `standards/command-parameter-notation.md` — All command parameters use `[descriptive prompts]` in square brackets; consistent across all surfaces
- `standards/agent-report-summary-next-steps.md` — Agents must always report a summary and next steps after completing any work
- `standards/terminology-change-process.md` — Repeatable process for renaming terms across the codebase: audit, classify, execute, verify

### Sessions
- `sessions/index.md` — Auto-generated master timeline of all summaries (via `/session`)

## Maintenance

**Rule: After creating, updating, or deleting any context file, the agent MUST update this index immediately.** Do not close the task without verifying the index is current. The sessions timeline at `sessions/index.md` is auto-maintained by `/session`.
