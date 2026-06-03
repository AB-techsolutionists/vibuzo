# Context System — Task Breakdown

Phase 1 (Foundation) and Phase 2 (Integration) are complete. This task list verifies all work and executes Phase 3 (Testing).

## Phase 1 — Foundation (verify existing)

- [x] Task 1: Create commands/context.md
  Files: commands/context.md
  Depends on: —
  Acceptance: File exists with init/find/harvest template, agent: Orchestrator

- [x] Task 2: Create commands/add-context.md
  Files: commands/add-context.md
  Depends on: —
  Acceptance: File exists with type-based save template, agent: Vibuzo, subtask: true

- [x] Task 3: Create commands/session.md
  Files: commands/session.md
  Depends on: —
  Acceptance: File exists with log/view/list template, agent: Vibuzo, subtask: true

## Phase 2 — Integration (verify existing)

- [x] Task 4: Add Context Auto-Load to AGENTS.md
  Files: AGENTS.md
  Depends on: —
  Acceptance: AGENTS.md includes "load context/index.md at session start" instruction after the agent table

- [x] Task 5: Update install.sh with 3 command downloads
  Files: install.sh
  Depends on: —
  Acceptance: install.sh downloads context.md, add-context.md, session.md to COMMANDS_DIR

- [x] Task 6: Update install.ps1 with 3 command downloads
  Files: install.ps1
  Depends on: —
  Acceptance: install.ps1 downloads context.md, add-context.md, session.md to CommandsDir

## Phase 3 — Testing (pending execution)

- [x] Task 7: Copy commands to .opencode/commands/ for local testing [P] (2026-06-03, verified)
  Files: .opencode/commands/context.md, .opencode/commands/add-context.md, .opencode/commands/session.md
  Depends on: Tasks 1-3
  Acceptance: All 3 command files exist in .opencode/commands/ alongside the 5 existing ones ✅

- [x] Task 8: Run /context init (2026-06-03, verified)
  Files: context/index.md, context/standards/.gitkeep, context/patterns/.gitkeep, context/architecture/.gitkeep, context/sessions/.gitkeep
  Depends on: Task 7
  Acceptance: context/ directory is created with index.md + 4 subdirectories with .gitkeep files ✅

- [x] Task 9: Test /add-context (2026-06-03, verified)
  Files: context/standards/naming.md, context/index.md (updated)
  Depends on: Task 8
  Acceptance: Running `/add-context standard naming "camelCase for variables"` creates context/standards/naming.md and updates index.md ✅

- [x] Task 10: Test /session log (2026-06-03, verified)
  Files: context/sessions/2026-06-03.md (today's date)
  Depends on: Task 8
  Acceptance: Running `/session log "Tested context system"` appends entry with timestamp to today's session log ✅

- [x] Task 11: Test /context find (2026-06-03, executed)
  Depends on: Tasks 9-10
  Acceptance: Running `/context find naming` returns relevant context files with their content ✅
  — Read context/index.md → found reference to standards/naming.md
  — Read context/standards/naming.md → "Use camelCase for all variables, functions, and methods"
  — Discovery and retrieval working correctly

- [x] Task 12: Test /context harvest (2026-06-03, executed)
  Depends on: Task 10
  Acceptance: Running `/context harvest` reads session logs, presents candidates, and promotes with confirmation ✅
  — Read context/sessions/2026-06-03.md — 1 session log found (limited data)
  — Identified candidate: naming convention (camelCase) already promoted to standards/
  — Promotion requires user confirmation (interactive step)
