# codebase-audit — Full project audit and gap fixing

*Paste opencode /compact output below this line*
────────────────────────────────────────
## Goal
- Transform Vibuzo framework from two-agent manual-switch system to single-agent architecture with consolidated `/spec` pipeline, configurable approval gates, context-aware commands, compaction-based session management, and a permanent context harvesting system.

## Constraints & Preferences
- No new languages, dependencies, or build steps — pure Markdown + YAML frontmatter
- Deprecated files kept but marked (not deleted) — backward compatibility preserved
- All existing commands remain functional even when deprecated or redirected
- Deepveloper uses `mode: subagent` in both source and mirror copies (unified per user preference)
- `/session` scaffolds a skeleton file — user pastes opencode's `/compact` output into the body
- Every context file write must be approved (approval_level: 3 — Full Control)
- Agent MUST update `context/index.md` after every context file change (hard rule)

## Progress
### Done
- Agent restructure: Vibuzo main (full permissions), Deepveloper subtask (no `task` perm, temp 0, `mode: subagent`), Orchestrator deprecated
- Approval gates: 5 tasks implemented, 11/11 criteria pass, `approval_level` raised to 3 (Full Control — every action requires approval)
- `/feature` → `/spec` rename: command files replaced, architecture ADR updated, zero stale references
- Context-aware commands: NL inference on `/add-context`, `/context find`, `/session`, `/spec` — 4 tasks, 12/12 acceptance criteria
- Install scripts cleaned — `orchestrator.md` removed from downloads, only active agents and commands ship
- `README.md` fully rewritten — accurate tree, commands table, context system section, session management section, updated roadmap (v0.8 current)
- Session compaction redesigned (paste workflow):
  - `/session` creates skeleton file with paste markers — user runs opencode's `/compact` and pastes body
  - `subtask: true` removed — runs in main session (subtask file writes don't persist)
  - Title-based filenames (`YYYY-MM-DD-<title>.md`) with collision handling
  - Timeline at `context/sessions/index.md` tracks all compactions (now with `Time` column)
  - Legacy `YYYY-MM-DD.md` files preserved and readable via `/session view`
- `/context` command rewritten in imperative style with routing, NL inference, and explicit subcommands
- Context harvest executed: 5 candidates found, 4 saved (imperative-command-style standard, source-mirror-synchronization standard, route-based-argument-handling pattern, title-based-session-naming pattern), 1 skipped (subtask-vs-main-session)
- `context/index.md` updated — all 10 files referenced, grouped by Architecture/Patterns/Standards/Sessions
- `specs/session-redesign/` backfilled — plan.md, tasks.md, review.md created (was only spec.md)
- `specs/context-system/review.md` created (was missing — 3/4 complete)
- `agents/deepveloper.md` mode unified — both source and mirror use `mode: subagent`
- Architecture ADR updated — principle #6 changed from "Intentional mirror exception" to "Unified mode"
- `install.sh` + `install.ps1` updated: path-rewriting references to orchestrator.md removed

### In Progress
- (none)

### Blocked
- (none)

## Key Decisions
- `/spec` is the single pipeline command — replaces `/feature` and deprecates 5 old commands
- Context-aware commands use NL-first fallback: rigid syntax tried first, natural language inference when it doesn't match
- `/session` uses paste workflow: agent creates skeleton + timeline, user pastes opencode's `/compact` output into the body — ensures both compaction outputs are identical
- Session commands run in main session (no `subtask: true`) — subtask file writes don't persist to the workspace
- Titles derived from conversation (2-4 keywords, kebab-case, collision handling with `-2`, `-3`)
- Command definitions must be imperative ("do this NOW") not spec-style ("the behavior is") — prevents agent from treating them as features to implement
- `approval_level: 3` (Full Control) — every file write, edit, delete, bash command, and delegation requires gate approval; "at gate level X" provides one-time overrides
- Deepveloper uses `mode: subagent` in both source and registry — unified per user preference (intentional divergence removed)
- Context index auto-update is now a hard rule: agent MUST update after every context file change

## Next Steps
- Continue using `/session` → `/compact` → paste workflow for regular session checkpoints
- Use `/session view` and `/session timeline` to browse past sessions
- Use `/context find` to search project context before starting new work
- Use `/context harvest` periodically to promote session patterns to permanent context

## Critical Context
- `approval_level: 3` — Full Control mode active; every action requires gate approval; "at gate level X" provides one-time overrides
- `/session` scaffolds a skeleton file, updates timeline, then instructs user to run opencode's `/compact` and paste output between marker lines
- `/session view` and `/session timeline` subcommands can use `subtask: true` (they don't need main conversation context)
- Legacy `context/sessions/YYYY-MM-DD.md` files (2026-06-03, 2026-06-04) preserved — listed in date views alongside title-based compactions
- Four context files saved via harvest: 2 standards, 2 patterns; 1 architecture candidate skipped
- Three title-based compactions exist for 2026-06-04: `session-redesign`, `session-polish`; `session-compaction-activation` was lost (subtask write didn't persist)
- `context/sessions/index.md` auto-updated on every compaction with Date, Time, File, and Summary columns
- `context/index.md` must be updated manually after every context file change (hard rule enforced)
- `context/patterns/add-context.md` was updated to document the full `/add-context` command specification
- `specs/session-redesign/` now has full lifecycle: spec.md, plan.md, tasks.md, review.md
- `specs/context-system/` now has full lifecycle: spec.md, plan.md, tasks.md, review.md
- All 6 specs complete: agent-restructure (4/4), approval-gates (4/4), context-aware-commands (4/4), context-system (4/4), session-redesign (4/4), spec-command (4/4)
- Source (`agents/`) and mirror (`.opencode/agent/core/`) differences: only `implement.md` has divergence (`agent: Deepveloper` source vs `agent: Deepveloper` mirror — intentional)
- `.opencode/` is gitignored — generated by installer; source of truth is `commands/` and `agents/`

## Relevant Files
- `agents/vibuzo.md` + `.opencode/agent/core/vibuzo.md`: Main agent, `approval_level: 3`, planning + execution rules, gate approval rules
- `agents/deepveloper.md` + `.opencode/agent/core/deepveloper.md`: Execution specialist, `mode: subagent` (both copies), no `task` permission, temperature 0
- `agents/orchestrator.md` + `.opencode/agent/core/orchestrator.md`: Deprecated, preserved for reference
- `commands/session.md` + `.opencode/commands/session.md`: Session compaction with paste workflow (no `subtask: true`)
- `commands/context.md` + `.opencode/commands/context.md`: Context management with init/find/harvest + NL inference (imperative style)
- `commands/add-context.md` + `.opencode/commands/add-context.md`: NL inference for type/name/content extraction
- `commands/spec.md` + `.opencode/commands/spec.md`: 5-phase pipeline command (active)
- `context/standards/imperative-command-style.md`: All command files must use imperative "Do these steps NOW:" instructions
- `context/standards/source-mirror-synchronization.md`: Source/mirror parity — commands/ and agents/ files must match .opencode/ copies
- `context/standards/naming.md`: Use camelCase for variables, functions, and methods
- `context/patterns/route-based-argument-handling.md`: Parse $ARGUMENTS at top, route to subcommand sections
- `context/patterns/title-based-session-naming.md`: YYYY-MM-DD-<title>.md format with collision handling
- `context/patterns/add-context.md`: Specification for the `/add-context` command (types, usage, behavior)
- `context/architecture/agent-restructure.md`: ADR — agent architecture with unified mode
- `context/architecture/approval-gates.md`: ADR — configurable approval levels 0-3
- `context/architecture/spec-command.md`: ADR — /spec pipeline consolidated command
- `context/index.md`: Master index of all context files, group by directory, hard rule for auto-update
- `context/sessions/index.md`: Master timeline with Date, Time, File, Summary columns
- `context/sessions/2026-06-04-session-redesign.md`: First title-based compaction
- `context/sessions/2026-06-04-session-polish.md`: Third title-based compaction (polish + paste workflow)
- `specs/session-redesign/`: Full lifecycle (spec, plan, tasks, review) — session compaction system
- `specs/context-system/`: Full lifecycle (spec, plan, tasks, review) — context init/find/harvest
- `install.sh` + `install.ps1`: Installers — ship vibuzo.md, deepveloper.md, spec.md, context.md, add-context.md, session.md (no deprecated artifacts)
────────────────────────────────────────
*Paste opencode /compact output above this line*

## Relevant Files
- `commands/session.md` + `.opencode/commands/session.md`: Rewritten to paste workflow
- `commands/context.md` + `.opencode/commands/context.md`: Rewritten in imperative style
- `agents/deepveloper.md` + `.opencode/agent/core/deepveloper.md`: Mode unified to `subagent`
- `context/index.md`: Added 2 new standards + auto-update rule
- `context/sessions/index.md`: Added timestamp column
- `context/architecture/agent-restructure.md`: Mode divergence → unified mode
- `context/standards/imperative-command-style.md`: New (harvest)
- `context/standards/source-mirror-synchronization.md`: New (harvest)
- `context/patterns/route-based-argument-handling.md`: New (harvest)
- `context/patterns/title-based-session-naming.md`: New (harvest)
- `context/patterns/add-context.md`: Updated (via task tool)
- `specs/session-redesign/plan.md`, `tasks.md`, `review.md`: Created (backfill)
- `specs/context-system/review.md`: Created (backfill)
- `specs/agent-restructure/review.md`, `tasks.md`: Mode references updated
- `install.sh` + `install.ps1`: Removed orchestrator download
- `README.md`: Full rewrite

## Timeline
| 2026-06-05 | 02:02 | `codebase-audit` | Full project audit and gap fixing |
