---
feature: session-management-enhancement
date: 2026-06-07
status: plan
---

# Session Management Enhancement — Implementation Plan

## Tech Stack

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Command file | Markdown + YAML frontmatter | Matches all existing Vibuzo commands |
| Agent execution | Vibuzo (main agent) | No subtask needed — agent handles all logic directly |
| Search | grep (Select-String in PowerShell) | Zero dependencies, works cross-platform, already used in codebase |
| Frontmatter generation | Inline agent logic | Written directly into session.md template — no parser needed |
| Session file storage | Markdown in `context/sessions/` | Existing pattern, unchanged |

## Architecture

### Before (Current)

```
.opencode/commands/
├── session.md           ← generates reports
├── session-view.md      ← views past sessions (subcommand)
└── session-timeline.md  ← lists sessions (subcommand)
```

Agent init is implicit — handled by context/index.md auto-load chain, no explicit command.

### After (Target)

```
.opencode/commands/
└── session.md           ← unified command with 4 modes:
                            • /session          → generate report
                            • /session init     → initialize agent context
                            • /session view     → view past session
                            • /session timeline → list sessions
                            • /session find     → search sessions
```

### Session.md Internal Structure (Mode Routing)

```
$ARGUMENTS
  ├── empty / "report"    → Step Set A (generate report)
  ├── "init"             → Step Set B (initialize agent)
  ├── "view"             → Step Set C (view past session)
  ├── "timeline"         → Step Set D (list chronologically)
  └── "find"             → Step Set E (search sessions)
```

Each mode is a distinct set of imperative steps in the same file. The agent reads `$ARGUMENTS` to determine which set to run.

## Components

### Component 1: session.md — Unified Command File

The single file at `commands/session.md` (mirrored to `.opencode/commands/session.md`).

**Modes:**

| Mode | Trigger | Behavior |
|------|---------|----------|
| **Report** | `/session` (no args) or `/session report` | Existing `/session` behavior — generate full summary, save to sessions/, scan for patterns (5 gates) |
| **Init** | `/session init` | Read context/index.md, verify directories exist, report loaded state. No file generation. |
| **View** | `/session view <ref>` | Look up session by name/date in context/sessions/, display content |
| **Timeline** | `/session timeline` | Read and display sessions/index.md chronologically |
| **Find** | `/session find <query>` | Grep context/sessions/ for query, return matches with line context. Support `tag:` prefix |

### Component 2: Frontmatter Generator

Logic added to the Report mode's write step. After generating the session content, prepend:

```yaml
---
title: <kebab-case-title>
date: <YYYY-MM-DD>
tags:
  - <tag1>
  - <tag2>
status: complete | in-progress
---
```

Tags are derived from:
- Keywords in the session content
- Files changed (e.g., "versioning" if versioning.md was modified)
- User-provided context from the session

### Component 3: Search Engine

Built into `/session find` — uses PowerShell's `Select-String` (cross-platform in pwsh 7+) to grep the `context/sessions/` directory.

```
Select-String -LiteralPath "context/sessions/*.md" -Pattern "<query>"
```

For `tag:` prefixed queries, grep for `tags:\n  - <tagname>` pattern in frontmatter blocks.

### Component 4: Auto-Hint Enhancer

Added to the existing auto-load chain in `session.md`. After generating a report, if the latest session file has a `## Session Compaction` section with meaningful content (not the placeholder default), present a gate:

```
── SESSION HINT ────────────────────────
Previous session compaction content found.
Load it as working context? (y/N):
───────────────────────────────────────
```

## Implementation Order

| Step | Component | Depends On | Description |
|------|-----------|------------|-------------|
| 1 | **Restructure session.md** | None | Merge view/timeline/find into session.md as inline modes. This is the core structural change. |
| 2 | **Delete old files** | Step 1 | Remove `session-view.md` and `session-timeline.md` from `commands/` and `.opencode/commands/` |
| 3 | **Add init mode** | Step 1 | Add `/session init` mode that initializes agent context |
| 4 | **Add frontmatter** | Step 1 | Extend the report generation step to prepend YAML frontmatter |
| 5 | **Add find mode** | Step 1 | Add `/session find` mode with grep-based search |
| 6 | **Add auto-hint** | Step 1 | Add auto-load prompt for compaction content |
| 7 | **Update docs** | All | Update AGENTS.md commands table, README.md commands table, command counts |
| 8 | **Update context** | All | Update context/index.md, update/remove session-view/timeline standards if any reference them |
