---
feature: spec-workflow-enhancement
date: 2026-06-08
status: spec
---

# Spec Workflow Enhancement

## Principles

- **Catch issues per-task, not at the end** — Two-stage review after every task catches spec drift and quality problems immediately, before they compound.
- **Brief before you build** — Phase 0 briefing catches misunderstanding before any research or spec work begins.
- **Standardize to automate** — A structured task format means the executor always knows what to build and how to verify it.
- **Over-communication is free** — The briefing phase intentionally errs on the side of explaining too much rather than too little.
- **No changes to user-facing commands** — `/spec` remains the same. The pipeline internals improve.

## Specification

### Overview

The current `/spec` pipeline has 5 phases: Research → Specification → Plan → Implementation → Review. This enhancement adds 2 new phases (Briefing before Research, and a per-task two-stage review loop inside Implementation) and standardizes the Plan phase output format.

The pipeline becomes:

```
Phase 0 — Briefing       (NEW)  → Pre-spec understanding check with user
Phase 1 — Research       (same) → Deepsearcher research
Phase 2 — Specification  (same) → Spec document with FRs/AC
Phase 3 — Structured Plan (ENHANCED) → Tasks in standardized format
Phase 4 — Two-stage Implementation (ENHANCED) → Per-task: implement → spec review → quality review
Phase 5 — Review         (same) → Verify acceptance criteria
```

### Part 1: Phase 0 — Pre-Spec Briefing

#### User Stories

- **US1.1** As a user, before research begins, I want Vibuzo to present a concise briefing of its understanding of the feature, so I can correct misunderstandings before effort is wasted.
- **US1.2** As a user, I want the briefing to include: what Vibuzo understands the feature to be, key unknowns or open questions, proposed approach, and specific things I should confirm or reject.
- **US1.3** As a user, I want an explicit approval gate after the briefing — work does not proceed until I approve.

#### Functional Requirements

- **FR1.1** When `/spec <feature>` is invoked, before any research, Vibuzo generates a briefing block that includes:
  - Vibuzo's understanding of the feature (2-4 sentences)
  - Key unknowns or ambiguities
  - Proposed research direction
  - Any assumptions being made
- **FR1.2** The briefing is presented inline (not saved to a file) as a concise summary.
- **FR1.3** After the briefing, Vibuzo asks "Proceed? (y/N)" — only "y" advances to Research.
- **FR1.4** If the user says "N", Vibuzo asks for clarification and regenerates the briefing.

#### Acceptance Criteria

- ✅ `/spec <feature>` shows a briefing block before any research starts
- ✅ Briefing includes understanding, unknowns, proposed approach, assumptions
- ✅ Proceed gate works — "N" stops the pipeline
- ✅ Briefing is not saved as a file

### Part 2: Phase 3 — Structured Task Format

#### User Stories

- **US2.1** As a user, I want every task in the plan to follow a consistent format so I know what to expect and can verify completeness.
- **US2.2** As a user, I want each task to specify exact file paths, concrete implementation steps, and verification steps so the executor has zero ambiguity.

#### Functional Requirements

- **FR2.1** Every task in Phase 3 uses this template:

```
## Task N: <short name>

**Description:** <1-2 sentence summary>

**Files:**
- `<path/to/file>` — <what changes>

**Steps:**
1. <step>
2. <step>

**Verification:**
- <how to verify this task works>

**Acceptance:**
- ✅ <criterion>
```

- **FR2.2** Each task must be executable independently (minimal cross-task coupling).
- **FR2.3** Each task must include explicit verification steps (not just "test it").
- **FR2.4** File paths must be exact and complete (no placeholders like `<filename>`).

#### Acceptance Criteria

- ✅ All tasks in `tasks.md` follow the structured template
- ✅ No placeholder paths — every file reference is exact
- ✅ Every task has a verification step
- ✅ Tasks are ordered by dependency

### Part 3: Phase 4 — Two-Stage Review

#### User Stories

- **US3.1** As a user, after Deepveloper implements a task, I want an automated spec compliance check to confirm the output matches the spec — nothing extra, nothing missing.
- **US3.2** As a user, after spec compliance passes, I want an automated code quality check to confirm the implementation is well-structured, maintainable, and follows project standards.
- **US3.3** As a user, I want failed reviews to trigger a fix loop — the implementer fixes the issue and the reviewer re-checks — before the next task starts.

#### Functional Requirements

- **FR3.1** After Deepveloper completes each task, Phase 4 runs two sequential reviews:
  - **Stage A: Spec Compliance Review** — A reviewer subagent checks the implementation against the spec/task requirements. Checks for: missing functionality, extra unintended functionality, correctness against spec.
  - **Stage B: Code Quality Review** — A reviewer subagent checks the implementation for: code structure, naming, adherence to project standards, error handling, test coverage.
- **FR3.2** Each reviewer uses a dedicated prompt template:
  - For Stage A: `specs/spec-workflow-enhancement/prompts/spec-reviewer-prompt.md`
  - For Stage B: `specs/spec-workflow-enhancement/prompts/quality-reviewer-prompt.md`
- **FR3.3** If a reviewer identifies issues, the implementer (Deepveloper) fixes them, then the same reviewer re-checks. Loop repeats until the reviewer approves or a max of 3 iterations.
- **FR3.4** The order is strict: Stage A must pass before Stage B begins.
- **FR3.5** Results of each review are logged in a per-task review section in `tasks.md`.

#### Acceptance Criteria

- ✅ After each task implementation, spec compliance review runs first
- ✅ After spec compliance passes, code quality review runs
- ✅ If either review fails, implementer fixes and reviewer re-checks
- ✅ Max 3 iterations before escalation
- ✅ Reviews use dedicated prompt templates
- ✅ Order is enforced: spec → quality

### Part 4: Pipeline Integration

#### User Stories

- **US4.1** As a user, I want the existing `/spec` command to remain unchanged — no new flags, no new subcommands.

#### Functional Requirements

- **FR4.1** The `commands/spec.md` file is updated to include the new Phase 0 briefing step and the new Phase 4 two-stage review loop.
- **FR4.2** The existing 5-phase pipeline is preserved as-is, with Phase 0 inserted before Research and Phase 4 enhanced with two-stage review.
- **FR4.3** The `PIPELINE GATE` approval prompts are updated to reflect the new phase names and structure.

#### Acceptance Criteria

- ✅ `/spec <feature>` works exactly as before — no new flags or subcommands
- ✅ Phase 0 briefing appears before Research
- ✅ Two-stage review runs during Phase 4
- ✅ Pipeline gates still prompt at each phase transition

### Out of Scope

- No changes to user-facing `/spec` command interface (no new flags, no subcommands)
- No changes to Deepsearcher research behavior
- No worktree isolation (deemed overengineered for this use case)
- No changes to existing session files or session workflow
- No automatic commit/push behavior changes
