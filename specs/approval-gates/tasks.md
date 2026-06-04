# Approval Gates — Task Breakdown

## Phase 1 — Agent Rules (parallel)

- [x] Task 1: Add approval gates to Vibuzo agent [P]
  Files: agents/vibuzo.md, .opencode/agent/core/vibuzo.md
  Depends on: —
  Description: Add `approval_level: 0` to Vibuzo's YAML frontmatter (custom field). Add a new "## Approval Gates" section with the level table, standard prompt format, rejection handling, and inline override rules. The section must define:
    - Levels 0-3 and which actions each level gates
    - Standard prompt format (── APPROVAL GATE ── ... Approve? (y/N))
    - Rejection behavior: on "N", offer modify / skip / abort
    - Inline override: user can say "at gate level X" for one interaction
    - Level 0 = current behavior (no gates active)
  Mirror identical content in both source and registry copies.
  Acceptance:
    - agents/vibuzo.md has `approval_level: 0` in YAML frontmatter
    - .opencode/agent/core/vibuzo.md has identical YAML + content
    - "## Approval Gates" section exists with level table (0-3)
    - Standard prompt format is defined
    - Rejection handling is defined (modify/skip/abort)
    - Inline override rule is defined
    - Level 0 explicitly states "no gates active — existing behavior unchanged"
    - All existing Core Rules, Handoff, Error Handling sections are preserved

- [x] Task 2: Add approval gates to Deepveloper agent [P]
  Files: agents/deepveloper.md, .opencode/agent/core/deepveloper.md
  Depends on: —
  Description: Add a new "## Approval Gates" section to Deepveloper's agent definition. Deepveloper receives the gate level from Vibuzo's handoff. The rules must cover:
    - Between-task gating: after each task, pause and ask "Proceed to next task? (y/N)"
    - Before destructive operations: present standard approval prompt
    - Gate level is inherited from Vibuzo's handoff — Deepveloper does not set its own level
    - Level 0 means no gating (execute as before)
  Mirror identical content in both source and registry copies.
  Acceptance:
    - agents/deepveloper.md has "## Approval Gates" section
    - .opencode/agent/core/deepveloper.md has identical content
    - Between-task gating rule is defined
    - Destructive operation gating is defined
    - Gate level inheritance from Vibuzo handoff is defined
    - Level 0 behavior is defined (no gating)
    - All existing Core Rules, Constraints, Report Format sections are preserved
    - No YAML frontmatter changes (Deepveloper has no approval_level of its own)

## Phase 2 — Documentation

- [x] Task 3: Update AGENTS.md with approval gates overview
  Files: AGENTS.md
  Depends on: Task 1, Task 2
  Description: Add a "### Approval Gates" subsection under the Universal Project Rules section at the bottom of AGENTS.md. This section should explain:
    - What approval gates are and why they exist
    - The 4 levels (0-3) in a summary table
    - How to configure (edit Vibuzo's YAML frontmatter or use inline override)
    - Link to `context/architecture/approval-gates.md` for full details
  Do not modify any existing sections (Karpathy Principles, Context Auto-Load, Two-Agent Workflow, Handoff Protocol).
  Acceptance:
    - AGENTS.md has "### Approval Gates" under Universal Project Rules
    - Section describes levels 0-3 and how to configure
    - All existing sections are preserved
    - Architecture decision is referenced

- [x] Task 4: Create architecture decision record
  Files: context/architecture/approval-gates.md
  Depends on: Task 1, Task 2
  Description: Create a new architecture decision record documenting the approval gates feature. Include:
    - Date and context (why approval gates were added)
    - Decision (configurable levels, standard prompt, rejection handling)
    - Level definitions table
    - Agent roles (how Vibuzo and Deepveloper implement gates)
    - File structure (which files were modified)
    - Key principles (user sovereignty, configuration over hardcoding, zero runtime deps)
  Also update `context/index.md` to reference the new architecture file.
  Acceptance:
    - context/architecture/approval-gates.md exists with all sections
    - context/index.md includes a reference to the new file
    - Architecture decision is clearly documented for future sessions

## Phase 3 — Verification

- [x] Task 5: Final review
  Files: (all modified files)
  Depends on: Task 3, Task 4
  Description: Read all modified files and verify against the acceptance criteria from the spec. Confirm no unintended changes to files outside scope. Report pass/fail for each criterion. Save review report to `specs/approval-gates/review.md`.
  Acceptance:
    - Vibuzo pauses for file mutations at level ≥ 1
    - Vibuzo pauses for bash commands at level ≥ 2
    - Vibuzo pauses for Deepveloper delegation at level ≥ 2
    - Vibuzo/Deepveloper pauses between tasks at level ≥ 1
    - Vibuzo asks for plan approval before execution at level ≥ 1
    - approval_level is configurable in YAML frontmatter
    - Inline override works
    - Standard prompt format is used
    - Rejection offers modify/skip/abort
    - All existing commands unchanged
    - No runtime code or dependencies introduced
    - Review report saved to specs/approval-gates/review.md
