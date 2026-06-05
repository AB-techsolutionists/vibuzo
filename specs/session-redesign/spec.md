# Session Redesign — Specification

## Principles

1. **One command, zero friction** — `/session` is the only command you need. It reads the conversation, generates a rich summary, and saves it. No arguments required.
2. **Multiple sessions per day** — Each summary creates its own file (`YYYY-MM-DD-<title>.md`). No more single-file overload.
3. **Auto-timeline** — A master `index.md` in the sessions directory tracks every summary across all days in chronological order.
4. **Session-aware** — New summaries scan past sessions and reference relevant ones. You always know what came before.
5. **No manual saves** — The anchored summary response IS the save. You never copy-paste again.
6. **Zero code changes** — All in command Markdown definitions. No runtime code, no new dependencies.

## Specification

### Overview

The current `/session` command creates a single file per day (`YYYY-MM-DD.md`) with a running log. This breaks down when:
- You have multiple distinct work sessions in one day
- You want a clean summary of each session, not a growing log
- You want to reference past sessions from new ones
- You have to manually "compact" and save anchored summaries

The redesign introduces **summary-based session management**:

1. At any point, run `/session` → Vibuzo analyzes the conversation, generates a comprehensive anchored summary, and saves it as a session file
2. Each save creates a new file: `YYYY-MM-DD-<title>.md` where `<title>` is a short kebab-case description derived from the conversation.
3. A master `context/sessions/index.md` timeline is auto-updated with every save
4. When starting new work, Vibuzo reads past summaries for context

### User Stories

1. As a developer, I want to run `/session` at the end of a work session and have it automatically save a comprehensive summary — no arguments, no options.
2. As a developer working in multiple sessions per day (morning, afternoon, evening), I want each session saved as its own file so I can review them individually.
3. As a developer starting a new session, I want Vibuzo to automatically reference relevant past summaries so I don't lose context.
4. As a developer, I want a timeline view of all summaries so I can see session history at a glance.
5. As a developer, I want to be able to view any past summary's full content with `/session view <date-or-index>`.

### Functional Requirements

#### FR1: `/session` — Zero-Argument summary

The primary command. No arguments needed.

```
/session
```

Behavior:
1. Analyze the **entire current conversation** (all messages in this session) for:
   - What was accomplished (features, fixes, decisions)
   - What constraints were at play
   - Key decisions made
   - What's still in progress or blocked
   - Files that were created or modified
2. Generate a **full anchored summary** in the rich format (Goal, Constraints, Progress, Key Decisions, Next Steps, Critical Context, Relevant Files).
3. **Generate a descriptive title**:
   - Extract 2-4 key words/concepts from the conversation
   - Convert to kebab-case (e.g., "session redesign" → `session-redesign`)
   - Keep it short and meaningful (2-5 words max)
   - Check for collisions: if `YYYY-MM-DD-<title>.md` already exists, append `-2`, `-3`, etc.
4. Save to `context/sessions/YYYY-MM-DD-<title>.md`.
5. **Update the timeline**: Add an entry to `context/sessions/index.md` with:
   ```
   | YYYY-MM-DD | HH:MM | `<title>` | <brief one-line summary> |
   ```
6. Report back:
   ```
   ── SESSION ─────────────────────────────
   Saved:  context/sessions/YYYY-MM-DD-<title>.md
   Summary: <one-line headline>
   Timeline: updated (N total summaries)
   ────────────────────────────────────────
   ```

#### FR2: `/session view` — View a Past summary

```
/session view <date-or-index>
```

Examples:
- `/session view 2026-06-04` — show today's summaries as a list with summaries
- `/session view 2026-06-04-session-redesign` — show the full content of that specific summary
- `/session view yesterday` — NL: show yesterday's summaries
- `/session view last` — show the most recent summary
- `/session view` — show timeline + offer to pick one

Behavior:
1. If a specific file is found by exact filename match, print its full content.
2. If a date is given (no title), list all summaries for that date with summaries.
3. Support NL keywords: `yesterday`, `today`, `last`, `recent`, `all`.

#### FR3: `/session timeline` — View the Master Timeline

```
/session timeline
```

Behavior:
1. Read and display `context/sessions/index.md`.
2. If it doesn't exist, create it and show empty.
3. Optionally filter: `/session timeline 2026-06` shows only June 2026 entries.

#### FR4: Auto-Context on Session Start

When Vibuzo starts a new session (detected by a fresh conversation), it should:
1. Read `context/sessions/index.md` to see all past summaries.
2. Read the last 3 most recent summary files.
3. Include in its context a brief summary of what was done before: "Previous sessions: [summary of last 3]"

This is already covered by the context auto-load in `context/index.md`, but the sessions timeline should be explicitly referenced there.

#### FR5: summary Format

Each summary file uses the anchored summary format:

```markdown
# YYYY-MM-DD-<title> — <Brief Headline>

## Goal
- <what was the objective>

## Constraints & Preferences
- <constraint 1>
- <constraint 2>

## Progress
### Done
- <item 1>
- <item 2>
### In Progress
- <item>
### Blocked
- <item>

## Key Decisions
- <decision 1>
- <decision 2>

## Next Steps
- <next step>

## Critical Context
- <important note for future sessions>

## Relevant Files
- <file path>: <description>
```

#### FR6: Timeline Format (`context/sessions/index.md`)

```markdown
# Session Timeline

Auto-generated by `/session`. Updated on every summary.

| Date | Time | File | Summary |
|------|------|------|------|---------|
| 2026-06-04 | 22:52 | `session-redesign` | Session summary command specification |
| 2026-06-04 | 23:18 | `context-aware-commands` | Context-aware commands — NL inference for 4 commands |
| 2026-06-04 | 23:30 | `agent-restructure` | Agent restructure — Vibuzo main, Deepveloper subtask |
```

#### FR7: Consolidated `/session` Command Catalog

| Subcommand | Action |
|------------|--------|
| `/session` | Auto-generate and save summary from conversation |
| `/session view <ref>` | View one or more past summaries |
| `/session timeline` | Show master timeline of all summaries |

### Acceptance Criteria

- ✅ `/session` with no arguments generates a rich summary from conversation and saves to `YYYY-MM-DD-<title>.md`
- ✅ Title is a short kebab-case description (2-5 words) derived from conversation content
- ✅ `context/sessions/index.md` gets a new entry with every summary
- ✅ `/session view 2026-06-04-session-redesign` shows the full content of that file
- ✅ `/session view 2026-06-04` lists all summaries for that date
- ✅ `/session view yesterday` / `last` / `today` work via NL inference
- ✅ `/session timeline` shows the master timeline
- ✅ `/session view` and `/session timeline` work as described
- ✅ Existing `context/sessions/2026-06-04.md` and `2026-06-03.md` are preserved (or optionally migrated into the new format)
- ✅ All changes in Markdown command files only — zero code changes
- ✅ Previously existing `context/sessions/YYYY-MM-DD.md` (single-file) format still readable by `/session view`

### Out of Scope

- Migrating existing `YYYY-MM-DD.md` files to the new numbered format (can be done manually)
- Modifying the approval gates system
- Adding runtime code, dependencies, or build steps
- Changing agent definitions or AGENTS.md
- Semantic search or vector embeddings for session content
