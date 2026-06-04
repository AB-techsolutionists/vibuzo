# `/spec` Command — Task Breakdown

## Phase 1 — Create /spec Command

- [x] Task 1: Create /spec command definition [P]
  Files: commands/spec.md, .opencode/commands/spec.md
  Depends on: —
  Description: Create the `/spec` command. This is a new command that routes to `agent: Vibuzo` and `subtask: true`. The command defines a 5-phase pipeline that Vibuzo executes:
    - Phase 1: Create spec (same logic as /spec)
    - Phase 2: Create plan (same logic as /plan)
    - Phase 3: Create tasks (same logic as /tasks)
    - Phase 4: Delegate to Deepveloper (same logic as /implement)
    - Phase 5: Generate and save review (same logic as /review)
    Each phase ends with a gate prompt asking for approval before proceeding to the next (at approval_level ≥ 1). Feature name is derived from the first argument, converted to kebab-case. Review report is auto-saved to specs/<feature>/review.md.
  Acceptance:
    - commands/spec.md exists with YAML frontmatter (agent: Vibuzo, subtask: true)
    - .opencode/commands/spec.md exists with identical content
    - Defines 5 phases in sequential order
    - Each phase gates on completion with standard prompt format
    - Rejection handling: (r)etry, (s)kip, (a)bort
    - Feature name from first arg, kebab-case for multi-word
    - Phase 4 delegates to Deepveloper
    - Phase 5 auto-saves review.md
    - Respects approval_level (gates skip at level 0)

## Phase 2 — Deprecate Old Commands (parallel)

- [x] Task 2: Deprecate spec, plan, tasks commands [P]
  Files: commands/spec.md, commands/plan.md, commands/tasks.md, .opencode/commands/spec.md, .opencode/commands/plan.md, .opencode/commands/tasks.md
  Depends on: —
  Description: Add a DEPRECATED banner to the top of each command file. The banner must read: "⚠️ DEPRECATED — Use `/spec <description>` instead. This file is kept for reference." Preserve all original content below the banner. Mirror both commands/ and .opencode/commands/ copies.
  Acceptance:
    - All 6 files have DEPRECATED banner at the very top
    - Banner states: "⚠️ DEPRECATED — Use `/spec <description>` instead. This file is kept for reference."
    - All original content preserved intact below the banner

- [x] Task 3: Deprecate implement, review commands [P]
  Files: commands/implement.md, commands/review.md, .opencode/commands/implement.md, .opencode/commands/review.md
  Depends on: —
  Description: Same as Task 2 — add DEPRECATED banner to implement.md and review.md (both source and registry copies).
  Acceptance:
    - All 4 files have DEPRECATED banner at the very top
    - Banner states: "⚠️ DEPRECATED — Use `/spec <description>` instead. This file is kept for reference."
    - All original content preserved intact below the banner

## Phase 3 — Documentation

- [x] Task 4: Create architecture decision record
  Files: context/architecture/spec-command.md, context/index.md
  Depends on: Task 1, Task 2, Task 3
  Description: Create architecture decision record documenting the /spec command consolidation. Include date, context, decision, pipeline design, deprecation rationale, and file structure. Update context/index.md to reference the new file.
  Acceptance:
    - context/architecture/spec-command.md exists with all sections
    - context/index.md includes a reference to the new file

## Phase 4 — Verification

- [x] Task 5: Final review
  Files: (all modified files)
  Depends on: Task 4
  Description: Read all modified files and verify against acceptance criteria from the spec. Confirm no unintended changes. Save review report to specs/spec-command/review.md.
  Acceptance:
    - /spec command creates spec/plan/tasks/review in sequence
    - Phase gates pause for approval at level ≥ 1
    - Rejection offers (r)etry/(s)kip/(a)bort
    - Phase 4 delegates to Deepveloper
    - review.md auto-saved at end
    - All 10 deprecated command files have DEPRECATED banners
    - Original content preserved below all banners
    - Gates skip at approval_level 0
    - /context, /session, /add-context unchanged
    - Review report saved to specs/spec-command/review.md
