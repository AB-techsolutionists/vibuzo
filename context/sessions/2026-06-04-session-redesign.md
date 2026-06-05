# 2026-06-04 — Session redesign

## Goal
- Define and implement the `/session` command system for auto-generating rich anchored summaries from conversations, with subcommands for viewing and timeline management.
- Establish a title-based summary file format (`YYYY-MM-DD-<title>.md`) alongside the legacy single-file session format.

## Constraints & Preferences
- Pure specification in this conversation — no implementation code written yet
- Backward compatible with existing `context/sessions/YYYY-MM-DD.md` (legacy single-file format)
- Titles derived from conversation content (short kebab-case, 2-5 words)
- Timeline master at `context/sessions/index.md` auto-generated and auto-updated
- All summaries use the standard anchored summary format (Goal, Constraints, Progress, Decisions, Next Steps, Critical Context, Relevant Files)

## Progress
### Done
- Full specification delivered for three subcommands:
  - `/session` (zero-arg) — auto-generate, save, and timeline-update
  - `/session view <ref>` — view past summaries by exact ref, date, or natural language keywords (yesterday, today, last, recent, all)
  - `/session timeline [month]` — view and optionally filter master timeline
- Title generation logic: extract 2-4 key words from conversation, kebab-case, collision handling
- summary format defined with all 8 sections (Goal, Constraints & Preferences, Progress, Key Decisions, Next Steps, Critical Context, Relevant Files)
- Timeline format defined with Date, File, Summary columns
- Natural language keyword resolution specified for `/session view` (yesterday, today, last, recent, all)

### In Progress
- (none — specification phase, ready for implementation)

### Blocked
- (none)

## Key Decisions
- Title-based summary files (`YYYY-MM-DD-<title>.md`) replace single-file daily sessions and opaque sequence numbers — enables multiple summaries per day with descriptive names
- Titles reset per-day with collision handling (`-2`, `-3`)
- Backward compatibility maintained — legacy files remain readable by `/session view`
- Natural language keywords for `/session view` extend usability (no need to remember exact filenames)
- Timeline index file doubles as discoverability tool for all past sessions

## Next Steps
- Implement the `/session` command files in both `commands/` and `.opencode/commands/`
- Implement the companion commands: `/session view` and `/session timeline`
- Add `context/sessions/index.md` creation logic in the `/session` subcommand
- Migrate existing `2026-06-04.md` and `2026-06-03.md` as needed (or leave for backward compat)

## Critical Context
- This is the **first title-based summary** — no `YYYY-MM-DD-<title>.md` files existed prior to this one
- Legacy sessions exist at `context/sessions/2026-06-04.md` and `context/sessions/2026-06-03.md` (single-file format)
- `context/sessions/index.md` created and populated by first `/session` run
- `context/index.md` already references `sessions/index.md` as "Auto-generated master timeline of all summaries"
- The `/session` command is designed to be pure Markdown + YAML frontmatter — no code changes needed

## Relevant Files
- `context/sessions/2026-06-04.md`: Existing legacy session (agent restructure, context-aware commands, session redesign)
- `context/sessions/2026-06-03.md`: Existing legacy session (earlier work)
- `context/index.md`: References sessions/index.md as auto-generated timeline
- `context/sessions/`: Target directory for all new title-based summary files
- `commands/` + `.opencode/commands/`: Target for `/session` command implementation
