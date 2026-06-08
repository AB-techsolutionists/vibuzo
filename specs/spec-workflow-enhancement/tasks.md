---
feature: spec-workflow-enhancement
date: 2026-06-08
status: tasks
---

# Spec Workflow Enhancement — Task Breakdown

## Task 1: Create reviewer prompt templates

**Description:** Create the two prompt templates used by the spec compliance reviewer and code quality reviewer subagents during Phase 4 two-stage review. These are standalone prompt files that Deepveloper (or any subagent) reads when dispatched as a reviewer.

**Files:**
- `specs/spec-workflow-enhancement/prompts/spec-reviewer-prompt.md` — CREATED
- `specs/spec-workflow-enhancement/prompts/quality-reviewer-prompt.md` — CREATED

**Steps:**
1. Create directory `specs/spec-workflow-enhancement/prompts/`
2. Create `spec-reviewer-prompt.md` with:
   - Role definition: "You are a spec compliance reviewer. Your job is to verify that an implementation exactly matches its specification."
   - Instructions to read the spec/task requirements, then examine the implementation
   - Checklist: all required functionality present? any extra unintended functionality? does behavior match spec?
   - Output format: ✅ Pass or ❌ Fail with specific issues listed
   - Rule: must read actual code/files, not trust the implementer's summary
3. Create `quality-reviewer-prompt.md` with:
   - Role definition: "You are a code quality reviewer. Your job is to verify that an implementation is well-structured, maintainable, and follows project standards."
   - Checklist: code structure and organization, naming conventions (camelCase per Vibuzo standard), error handling, test coverage, adherence to project standards
   - Output format: Strengths section + Issues section (Critical/Important/Minor) + Assessment (✅ Approved / ❌ Changes Required)
   - Max 3 issues before rejection

**Verification:**
- Both files exist and are valid markdown
- Each file has clear instructions a subagent can follow autonomously
- No placeholders remain in either file

**Acceptance:**
- ✅ `specs/spec-workflow-enhancement/prompts/spec-reviewer-prompt.md` exists with role, checklist, output format
- ✅ `specs/spec-workflow-enhancement/prompts/quality-reviewer-prompt.md` exists with role, checklist, output format
- ✅ Both prompts are self-contained (agent can use them without additional context)

---

## Task 2: Add Phase 0 Briefing to commands/spec.md

**Description:** Insert a new Phase 0 step at the beginning of the `/spec` pipeline in `commands/spec.md`. Before any research, Vibuzo presents a briefing of its understanding and asks for approval.

**Files:**
- `commands/spec.md` — MODIFIED
- `.opencode/commands/spec.md` — MODIFIED (mirror sync)

**Steps:**
1. Read the current `commands/spec.md` to understand existing structure
2. After the "Do these steps NOW:" line and before the Research phase, insert a Phase 0 Briefing section with these imperative steps:
   a. Generate a briefing block with: Vibuzo's understanding of the feature (2-4 sentences), key unknowns, proposed research direction, assumptions being made
   b. Present the briefing inline using a concise format
   c. Ask "Proceed? (y/N)" — if "N", ask for clarification and regenerate
   d. Only "y" advances to Phase 1 Research
3. Renumber the existing phases accordingly
4. Update the PIPELINE GATE labels to include Phase 0
5. Mirror the same changes to `.opencode/commands/spec.md`

**Verification:**
- Read final `commands/spec.md` and confirm Phase 0 appears before Research
- Confirm proceed gate logic is correct
- Confirm mirror file is in sync

**Acceptance:**
- ✅ Phase 0 briefing appears as first step in spec.md
- ✅ Briefing includes understanding, unknowns, approach, assumptions
- ✅ Proceed gate: "N" blocks, "y" proceeds
- ✅ `.opencode/commands/spec.md` mirror matches

---

## Task 3: Standardize Phase 3 task format in commands/spec.md

**Description:** Update the Plan phase instructions in `commands/spec.md` to enforce the structured task template defined in the spec (US2.1, FR2.1).

**Files:**
- `commands/spec.md` — MODIFIED
- `.opencode/commands/spec.md` — MODIFIED (mirror sync)

**Steps:**
1. Find the Plan phase section in `commands/spec.md`
2. Update the step that describes how to write tasks to include the standardized template:
   ```
   ## Task N: <short name>
   **Description:** <1-2 sentence summary>
   **Files:** <exact paths>
   **Steps:** <numbered>
   **Verification:** <how to verify>
   **Acceptance:** <criteria>
   ```
3. Add explicit instructions: each task must be independently executable, no placeholder paths, every task must have verification
4. Mirror to `.opencode/commands/spec.md`

**Verification:**
- Read the Plan section — template is clearly specified
- Instructions include the rules (independent tasks, exact paths, verification required)

**Acceptance:**
- ✅ Plan phase steps include the standardized task template
- ✅ Template includes Description, Files, Steps, Verification, Acceptance sections
- ✅ Rules for placeholder-free paths and independent tasks are stated
- ✅ Mirror file matches

---

## Task 4: Add two-stage review loop to Phase 4 Implementation

**Description:** Enhance the Implementation phase in `commands/spec.md` to include per-task two-stage review: spec compliance first, then code quality, with re-review loops on failure.

**Files:**
- `commands/spec.md` — MODIFIED
- `.opencode/commands/spec.md` — MODIFIED (mirror sync)

**Steps:**
1. Find the Implementation phase section in `commands/spec.md`
2. Replace the current single-step "Deepveloper implements" with a per-task loop:
   a. Deepveloper implements the task
   b. **Stage A — Spec compliance review:** dispatch a reviewer subagent using `specs/spec-workflow-enhancement/prompts/spec-reviewer-prompt.md`. If fail → Deepveloper fixes → re-review (max 3 iterations)
   c. **Stage B — Code quality review:** dispatch a reviewer subagent using `specs/spec-workflow-enhancement/prompts/quality-reviewer-prompt.md`. If fail → Deepveloper fixes → re-review (max 3 iterations)
   d. Both must pass before moving to next task
3. Add instruction: order is strict — spec compliance must pass before code quality starts
4. Add instruction: if 3 iterations exhausted, escalate to user
5. Mirror to `.opencode/commands/spec.md`

**Verification:**
- Read the Implementation phase — two-stage loop is clearly defined
- Review prompts reference the correct file paths
- Max iterations and escalation path are specified

**Acceptance:**
- ✅ Implementation phase specifies per-task two-stage review (spec compliance → code quality)
- ✅ Reviewer prompts reference `specs/spec-workflow-enhancement/prompts/spec-reviewer-prompt.md` and `quality-reviewer-prompt.md`
- ✅ Fix loop with max 3 iterations is defined
- ✅ Escalation path (to user) is defined for iteration exhaustion
- ✅ Mirror file matches

---

## Summary

| Task | Description | Depends On | Complexity |
|------|-------------|------------|------------|
| 1 | Create reviewer prompt templates | — | Low |
| 2 | Add Phase 0 Briefing to spec.md | — | Medium |
| 3 | Standardize Phase 3 task format in spec.md | — | Low |
| 4 | Add two-stage review loop to Phase 4 | — | Medium |
