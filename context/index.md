# Project Context

This directory contains project-level context files that are automatically loaded at the start of every new session. Agents read this index to discover available knowledge.

## Structure

| Directory | Purpose |
|-----------|---------|
| `standards/` | Code quality, naming conventions, testing requirements, style guides |
| `patterns/` | Reusable code patterns, architectural approaches, idioms |
| `architecture/` | System design decisions, data flow, component relationships |
| `sessions/` | Auto-generated logs of session activity (via `/session log`) |

## How to Add Context

- **Manually**: Create a `.md` file in the appropriate directory
- **Via command**: `/add-context <type> <name> <description>`
- **From sessions**: `/context harvest` promotes session patterns to permanent files

## Files

- `architecture/agent-restructure.md` — Agent architecture decision: Vibuzo as main, Deepveloper for /implement, Orchestrator deprecated
- `patterns/add-context.md` — Specification for the `/add-context` command (types, usage, behavior)
- `standards/naming.md` — Use camelCase for variables, functions, and methods

## Maintenance

When you add or remove a context file, update this index with a brief reference so agents can discover it.
