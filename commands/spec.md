---
description: Run the full feature development pipeline (spec → plan → tasks → implement → review)
agent: Vibuzo
subtask: true
---

Run the full feature development pipeline for: $ARGUMENTS

## Setup

1. Parse `$ARGUMENTS` as the feature description.
2. Derive the feature name:
   - Take `$ARGUMENTS` (the full description) as the feature basis
   - Convert the entire description to kebab-case (e.g., "dark mode toggle" → "dark-mode-toggle")
   - For single-word descriptions, use the word as-is (e.g., "auth" → "auth")
   - Handle both quoted (`/spec "dark mode toggle"`) and unquoted (`/spec dark mode toggle`) input — in both cases, the full description is used
3. Create `specs/<feature>/` directory if it doesn't exist.
4. Check `approval_level` from Vibuzo's YAML frontmatter. If level ≥ 1, gates are active. If level is 0, skip all gates and auto-proceed.

## Phase 1 — Specification

1. Ask clarifying questions if the description is vague (what problem, who users are, what success looks like).
2. Once clear, generate a specification document with:
   - **Principles**: Code quality, testing, performance, UX consistency
   - **Specification**: Overview, User Stories, Functional Requirements, Acceptance Criteria, Out of Scope
3. Write to `specs/<feature>/spec.md`.
4. **Gate**: If approval_level ≥ 1, present:
   ```
   ── PHASE GATE ─────────────────────────
   Phase 1: Specification complete.
   Summary: Created specs/<feature>/spec.md
   ───────────────────────────────────────
   Proceed to next phase? (y/N):
   ```
   - If "y": continue to Phase 2
   - If "N" or anything else: offer (r)etry, (s)kip to next, (a)bort

## Phase 2 — Plan

1. Read `specs/<feature>/spec.md`.
2. Generate a technical implementation plan with:
   - **Tech Stack**: Languages, frameworks, justifications
   - **Architecture**: Component diagram, data flow, integration points
   - **Components**: List of components, responsibilities, interfaces
   - **Implementation Order**: Dependencies, risk factors
3. Write to `specs/<feature>/plan.md`.
4. **Gate**: Same format as Phase 1, with "Phase 2: Plan complete."

## Phase 3 — Tasks

1. Read `specs/<feature>/spec.md` and `specs/<feature>/plan.md`.
2. Break down into actionable tasks. Each task includes:
   - Description, Files, Dependencies, Parallel marker [P], Acceptance criteria
3. Write to `specs/<feature>/tasks.md`.
4. **Gate**: Same format, with "Phase 3: Task breakdown complete."

## Phase 4 — Implementation

1. Read `specs/<feature>/tasks.md` to understand the task list and dependency order.
2. **Gate**: If approval_level ≥ 1, present:
   ```
   ── PHASE GATE ─────────────────────────
   Phase 4: Implementation ready.
   Summary: <N> tasks to execute via Deepveloper
   ───────────────────────────────────────
   Proceed to implementation? (y/N):
   ```
3. If approved, delegate to Deepveloper via `task()` with subagent_type "Deepveloper":
   - Include the feature name and a brief stating to read tasks.md and execute
   - Include `approval_level` in the handoff so Deepveloper respects gates
4. Wait for Deepveloper to report back.
5. If Deepveloper reports failure: offer (r)etry, (s)kip to review, or (a)bort.
6. **Gate**: After implementation, present "Phase 4: Implementation complete" gate.

## Phase 5 — Review

1. Read `specs/<feature>/spec.md`, `specs/<feature>/plan.md`, `specs/<feature>/tasks.md`.
2. Find implemented code in the codebase (read files referenced in tasks.md).
3. Generate a review report covering:
   - **Coverage**: Does implementation cover all requirements?
   - **Accuracy**: Does it match spec and plan?
   - **Quality**: Does code follow established principles?
   - **Gaps**: What's missing or incomplete?
   - **Issues**: Bugs, tech debt, concerns
4. Save the report to `specs/<feature>/review.md`.
5. **Gate**: Present "Phase 5: Review complete. Report saved to specs/<feature>/review.md."

## Done

Present a final summary:
```
── SPEC COMPLETE ─────────────────────────
Feature: <name>
Artifacts:
  - specs/<feature>/spec.md
  - specs/<feature>/plan.md
  - specs/<feature>/tasks.md
  - specs/<feature>/review.md
Implementation: <tasks completed / total>
──────────────────────────────────────────
```

## Gate Skip Logic

If `approval_level` is 0:
- Skip all phase gates. Auto-proceed after each phase completes.
- Generate a brief status message (no approval prompt) so the user knows what phase is running.
- Do NOT skip Deepveloper's between-task gates — those are Deepveloper's own rules.
