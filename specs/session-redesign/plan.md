# Session Redesign — Implementation Plan

## Objective

Replace the single-file session log system with summary-based session management using title-based files (`YYYY-MM-DD-<title>.md`), a master timeline, and view/timeline subcommands.

## Approach

Rewrite `/session` command (both `commands/session.md` and `.opencode/commands/session.md`) to support three subcommands: summary, view, timeline. All changes in Markdown command files only.

## Phases

### Phase 1: Command Definition

1. Rewrite `commands/session.md` with the full summary logic:
   - Conversation analysis (Goal, Constraints, Progress, Key Decisions, Next Steps, Critical Context, Relevant Files)
   - Title generation (2-4 keywords → kebab-case, collision handling with `-2`, `-3`)
   - File save to `context/sessions/YYYY-MM-DD-<title>.md`
   - Timeline update to `context/sessions/index.md`
   - Status box output

2. Mirror the same content to `.opencode/commands/session.md`

### Phase 2: View & Timeline Subcommands

3. Add `/session view <ref>` logic:
   - Exact filename match → full file content
   - Date only → list summaries for that date
   - NL keywords: yesterday, today, last, recent, all
   - Empty → show timeline + offer pick

4. Add `/session timeline [month]` logic:
   - Read and display `context/sessions/index.md`
   - Create if doesn't exist
   - Optional month filter

### Phase 3: Verification

5. Test all subcommands:
   - `/session` summary with zero arguments
   - `/session view` with various refs
   - `/session timeline` with and without month filter
6. Verify backward compatibility with legacy `YYYY-MM-DD.md` files

## Constraints

- Zero code changes — pure Markdown + YAML frontmatter
- All files mirrored in both `commands/` and `.opencode/commands/`
- Imperative execution style ("Do these steps NOW:")
- `subtask: true` removed — command runs in main session for conversation context access
