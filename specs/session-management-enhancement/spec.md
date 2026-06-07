---
feature: session-management-enhancement
date: 2026-06-07
status: spec
---

# Session Management Enhancement

## Principles

- **Single responsibility** — One command, one job. `/session` generates reports, `/session init` initializes the agent. No subcommands.
- **Filesystem is the API** — Session files are markdown with YAML frontmatter. No database needed. grep/ripgrep is the search engine.
- **Progressive complexity** — Basic operations (list, search) work with zero config. Advanced features (cross-session queries, auto-hints) build on it.
- **Backward compatible** — Existing session files stay readable. `/session` without changes still works as before for generating reports.
- **Zero external dependencies** — No SQLite, no vector DBs, no npm packages. Pure shell + file I/O.

## Specification

### Overview

The current session system has three separate commands in `.opencode/commands/`:
- `session.md` — Generate a session report
- `session-view.md` — View a past session summary
- `session-timeline.md` — Show all summaries chronologically

Additionally, agent initialization is currently handled implicitly at session start (auto-load chain in context/index.md), not as an explicit command.

This spec restructures the command set into two commands and enhances the session system with metadata, search, and auto-hints.

### Part 1: Command Restructuring

#### User Stories

- **US1.1** As a user, I want `/session init` to initialize the agent with project context, so I can start a fresh session with full context awareness.
- **US1.2** As a user, I want `/session` (without subcommands) to generate a session report, the same as it does today.
- **US1.3** As a user, I want to view past sessions with `/session view <ref>` and list them with `/session timeline` as flags within the main session command.
- **US1.4** As a maintainer, I want `session-view.md` and `session-timeline.md` removed from `.opencode/commands/` and `commands/`, with their logic folded into `session.md`.

#### Functional Requirements

- **FR1.1** `/session init` — A new mode of the session command that initializes agent context:
  - Reads `context/index.md` and the auto-load chain
  - Verifies all context directories exist (scaffold if missing)
  - Reports what was loaded (session timeline, latest summary, compaction content)
  - Does NOT generate a session report — that's `/session` alone
- **FR1.2** `/session` — Unchanged behavior: generates a full session report and saves to `context/sessions/`
- **FR1.3** `/session view <ref>` — Look up a past session file by name or date, read it, display it (moved from `session-view.md`)
- **FR1.4** `/session timeline` — List all session summaries chronologically (moved from `session-timeline.md`)
- **FR1.5** `session-view.md` and `session-timeline.md` are deleted from `commands/` and `.opencode/commands/`
- **FR1.6** The command file remains as `session.md` in both `commands/` and `.opencode/commands/`

#### Acceptance Criteria

- ✅ `session-view.md` and `session-timeline.md` no longer exist anywhere in the repo
- ✅ `session.md` includes `/session init`, `/session view`, `/session timeline` as inline modes
- ✅ Running `/session init` initializes agent context without generating a report
- ✅ Running `/session` generates a session report (existing behavior preserved)
- ✅ Running `/session view 2026-06-07` displays that session file
- ✅ Running `/session timeline` lists all sessions chronologically

### Part 2: Session System Enhancements

#### User Stories

- **US2.1** As a user, I want session files to have structured YAML frontmatter (tags, scope, when) so search and filtering work without parsing content.
- **US2.2** As a user, I want `/session find <query>` to search across all session summaries by keyword or tag.
- **US2.3** As a user, I want new sessions to auto-load relevant compaction content from previous sessions without manual intervention.

#### Functional Requirements

- **FR2.1** When `/session` generates a new summary, prepend YAML frontmatter with fields:
  - `title:` — kebab-case title from the filename
  - `date:` — YYYY-MM-DD
  - `tags:` — list of relevant tags derived from the session content
  - `status:` — complete | in-progress
- **FR2.2** `/session find <query>` — Search across all session summaries:
  - Grep the `context/sessions/` directory for the query string
  - Return matching file names with line numbers and context lines
  - Support `tags:` field search (e.g., `/session find tag:versioning`)
- **FR2.3** Auto-load chain enhancement:
  - After reading the latest session summary, if it has a `## Session Compaction` section with real content (not placeholder text), auto-surfaced in a prompt: "Found previous session compaction content. Load it? (y/N)"
  - If yes, load it as working context
- **FR2.4** Existing session files are NOT retrofitted — frontmatter only applies to new files generated after this change

#### Acceptance Criteria

- ✅ New `/session` reports include YAML frontmatter with title, date, tags, status
- ✅ `/session find <query>` returns matching sessions with line context
- ✅ `/session find tag:<tag>` filters by frontmatter tags
- ✅ Auto-load prompt appears when compaction content exists
- ✅ No changes to existing session files

### Out of Scope

- No vector DB integration (stays file-based)
- No UI/terminal picker (stays CLI-only)
- No session forking or branching (may be future work)
- No changes to `/session` report content format — only add frontmatter
- No retrofitting of existing session files
