# Context System — Specification

## Principles

- **Pure markdown** — no databases, no CLI tools, no external dependencies. Context is just `.md` files in a directory.
- **Auto-discovery** — agents read available context at session start without being told. Index file acts as a table of contents.
- **Grow organically** — start empty (`context/` with just an index). Content accumulates over time via `add-context` and session logs.
- **Human-validated curation** — session logs capture raw work. Only patterns a human validates get promoted to permanent context files.

## Overview

Build a persistent context and session tracking system for the Vibuzo framework. Context files give every new session instant access to project conventions, patterns, and intelligence. Session logs capture what was done in each session so the next session can resume seamlessly.

## User Stories

1. As a developer, I want agents to automatically know my project's conventions when a new session starts, so I never repeat myself.
2. As a developer, I want to save patterns and standards to context with a simple command, so agents follow my preferred approach.
3. As a developer, I want previous session logs available in new sessions, so I can resume interrupted work instantly.
4. As a framework user, I want the context system to have zero setup beyond running `/context init` — just markdown files, no infrastructure.

## Functional Requirements

1. **`/context init`** — scaffolds `context/` directory with `index.md` + `standards/` + `patterns/` + `architecture/` + `sessions/`

2. **`/context find <topic>`** — agent searches context files for relevant content. If `$ARGUMENTS` is empty, reads `index.md` as a menu.

3. **`/context harvest`** — reads session logs and extracts recurring approaches into permanent files. Prompts user for confirmation before promoting.

4. **`/add-context <type> <name> <description>`** — saves content to appropriate context directory.

5. **`/session`** — without args, shows most recent session log. With `log`, saves entry. With `list`, lists all sessions. With `view`, reads recent logs.

6. **Auto-load at session start** — agents load `context/index.md` at session start.

7. **Index auto-update** — refreshed whenever context files change.

## Acceptance Criteria

### Commands
- [ ] `/context init` creates directory scaffold
- [ ] `/context find <topic>` searches and presents relevant context
- [ ] `/context harvest` promotes session patterns with confirmation
- [ ] `/add-context pattern|standard|architecture <name> <content>` creates file
- [ ] `/session log <message>` appends to dated session log
- [ ] `/session list` shows all session logs
- [ ] `/session view` reads recent session logs

### Files
- [ ] `commands/context.md` — agent: Orchestrator
- [ ] `commands/add-context.md` — agent: Vibuzo, subtask: true
- [ ] `commands/session.md` — agent: Vibuzo, subtask: true
- [ ] `AGENTS.md` — includes "load context/index.md at session start" instruction
- [ ] `install.sh` — downloads 3 new commands
- [ ] `install.ps1` — downloads 3 new commands

### Constraints
- [ ] No databases, no CLI tools, no dependencies
- [ ] All context is plain markdown
- [ ] Works with `$ARGUMENTS` and positional args

## Out of Scope
- Full conversation transcripts
- Cross-project context sharing
- Automatic context generation from code analysis
- Web UI for browsing context
- LLM-generated session summaries
