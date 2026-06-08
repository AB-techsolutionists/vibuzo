---
description: Run the full feature development pipeline (research → briefing → specification → plan → tasks → implementation → review)
agent: Vibuzo
---

Run the full feature development pipeline for: $ARGUMENTS

## Setup

1. Parse `$ARGUMENTS` as the feature description.
2. Derive the feature name:
   - Analyze `$ARGUMENTS` to extract the core feature intent — find the 2-4 key words that define what is being built
   - Generate a short, meaningful kebab-case name (e.g., "add user authentication with JWT and refresh tokens" → "user-authentication", "i wanna introduce a new /commit command that bumps version" → "commit-command")
   - For single-word descriptions, use the word as-is (e.g., "auth" → "auth")
   - Handle both quoted (`/spec "dark mode toggle"`) and unquoted (`/spec dark mode toggle`) input — in both cases, the full description is used for analysis, only the shortened name goes in the directory path
3. Create `specs/<feature>/` directory if it doesn't exist.
4. Check `approval_level` from Vibuzo's YAML frontmatter. If level ≥ 1, gates are active. If level is 0, skip all gates and auto-proceed.

## Research (Optional)

1. Present the user with: "Research this feature? (y/N)"
2. If "y" or "yes":
   - Spawn Deepsearcher via `task()` with subagent_type "Deepsearcher"
   - Pass the feature description as the research query
   - Instruct Deepsearcher to:
     - This is `/spec` Research stage mode — save results to `specs/<feature>/research.md`
     - Keep research output under 150–200 lines. Be concise: summarize key findings, list 5–10 top resources, include brief source metadata. No verbatim citations or long paragraph prose.
   - Wait for Deepsearcher to report back
   - Present gate:
     ```
     ── PIPELINE GATE ──────────────────────
     Research complete.
     Summary: Created specs/<feature>/research.md
     ───────────────────────────────────────
     Proceed to Briefing? (y/N):
     ```
   - If "y": continue to Briefing
   - If "N" or anything else: offer (r)etry, (s)kip to next, (a)bort
3. If "N" or anything else: skip to Briefing directly

## Briefing

1. Read `specs/<feature>/research.md` if it exists. Synthesize the research findings.
2. Present a debriefing to the user with:
   - **Research summary:** Key findings from Deepsearcher (or state that no research was done if skipped)
   - **Possible approaches:** 2-3 viable approaches with pros/cons/tradeoffs for each
   - **Recommendation:** Which approach Vibuzo recommends and why
   - **Clarifying questions:** What needs to be decided or clarified before writing the spec
3. Present the briefing inline using this format:
   ```
   ── BRIEFING ─────────────────────────────
   Research summary: <key findings or "no research done">
   Possible approaches:
     - Approach A: <pros/cons>
     - Approach B: <pros/cons>
     - Approach C: <pros/cons>
   Recommendation: <recommended approach + rationale>
   Clarifying questions:
     - <question 1>
     - <question 2>
   ─────────────────────────────────────────
   ```
4. Ask: "Proceed to Specification? (y/N):"
   - If "y" or "yes": continue to Specification
   - If "N" or anything else: ask clarifying questions, discuss approaches, refine direction based on user input, then regenerate briefing or proceed
5. **Gate**: If approval_level is 0, auto-proceed past Briefing (no briefing needed).

## Specification

1. Read `specs/<feature>/research.md` if it exists, incorporate findings into the specification.
2. Ask clarifying questions if the description is vague (what problem, who users are, what success looks like).
3. Once clear, generate a specification document with:
   - **Principles**: Code quality, testing, performance, UX consistency
   - **Specification**: Overview, User Stories, Functional Requirements, Acceptance Criteria, Out of Scope
4. Write to `specs/<feature>/spec.md`.
5. **Gate**: If approval_level ≥ 1, present:
   ```
   ── PIPELINE GATE ──────────────────────
   Specification complete.
   Summary: Created specs/<feature>/spec.md
   ───────────────────────────────────────
   Proceed to Plan? (y/N):
   ```
   - If "y": continue to Plan
   - If "N" or anything else: offer (r)etry, (s)kip to next, (a)bort

## Plan

1. Read `specs/<feature>/spec.md`.
2. Generate a technical implementation plan with:
   - **Tech Stack**: Languages, frameworks, justifications
   - **Architecture**: Component diagram, data flow, integration points
   - **Components**: List of components, responsibilities, interfaces
   - **Implementation Order**: Dependencies, risk factors
3. Write to `specs/<feature>/plan.md`.
4. **Gate**: Same format, with "Plan complete."

## Tasks

1. Read `specs/<feature>/spec.md` and `specs/<feature>/plan.md`.
2. Break down into actionable tasks using this standardized template:

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

3. **Rules for task breakdown:**
   - Each task must be independently executable (minimal cross-task coupling)
   - File paths must be exact and complete — no placeholders like `<filename>`
   - Every task must include a verification step (not just "test it")
   - Tasks must be ordered by dependency
4. Write to `specs/<feature>/tasks.md`.
5. **Gate**: Same format, with "Task breakdown complete."

## Implementation

1. Read `specs/<feature>/tasks.md` to understand the task list and dependency order.
2. **Gate**: If approval_level ≥ 1, present:
   ```
   ── PIPELINE GATE ──────────────────────
   Implementation ready.
   Summary: <N> tasks to execute via Deepveloper
   ───────────────────────────────────────
   Proceed to implementation? (y/N):
   ```
3. If approved, delegate all tasks to Deepveloper via `task()` with subagent_type "Deepveloper":
   - Include the feature name and instruct to read tasks.md and execute in order
   - Include `approval_level` in the handoff so Deepveloper respects gates
4. Wait for Deepveloper to report back.
5. If Deepveloper reports failure: offer (r)etry, (s)kip to review, or (a)bort.
6. **Gate**: After implementation, present "Implementation complete" gate.

## Review

1. Read `specs/<feature>/spec.md`, `specs/<feature>/plan.md`, `specs/<feature>/tasks.md`.
2. Find implemented code in the codebase (read files referenced in tasks.md).
3. **Stage 1 — Spec Compliance Review:**
   - Dispatch a reviewer subagent via `task()` with subagent_type "general"
   - Provide the reviewer with these instructions inline:
     > **Role:** You are a spec compliance reviewer. Verify that the implementation exactly matches its specification.
     >
     > **Instructions:**
     > 1. Read the spec and task requirements first
     > 2. Examine actual implementation files using the Read tool — do not trust summaries
     > 3. Compare each piece of functionality in the spec against the actual code
     > 4. Check that only requested functionality was added — no extra unintended features
     >
     > **Checklist:**
     > - All required functionality from the spec is present
     > - No extra unintended functionality was added
     > - Behavior matches what the spec describes
     > - Edge cases from the spec are handled
     >
     > **Output format:**
     > ```
     > ## Spec Compliance Review
     > **Status:** ✅ Pass | ❌ Fail
     > **Checklist:** [x] or [ ] per item
     > **Issues:** <specific issues with file paths and line numbers>
     > **Assessment:** approved or changes required
     > ```
   - Provide the reviewer with: the spec document, task requirements, and all files that were created/modified
   - If reviewer returns ❌ Fail:
     - Present issues to user with option to (r)etry fixes, (s)kip, or (a)bort
4. **Stage 2 — Code Quality Review:**
   - Only if Spec Compliance Review passed ✅
   - Dispatch a reviewer subagent via `task()` with subagent_type "general"
   - Provide the reviewer with these instructions inline:
     > **Role:** You are a code quality reviewer. Verify that the implementation is well-structured, maintainable, and follows project standards.
     >
     > **Instructions:**
     > 1. Read the implementation files thoroughly using the Read tool
     > 2. Examine code structure, naming conventions, error handling, and testing
     > 3. Check for dead code, commented-out code, hardcoded secrets, or credentials
     > 4. Reference project patterns in context/patterns/ and context/standards/ for conventions
     >
     > **Checklist:**
     > - Code structure and organization (clear separation of concerns)
     > - Naming conventions (camelCase per Vibuzo standard)
     > - Error handling (appropriate try/catch, error messages)
     > - No dead code, no commented-out code
     > - No hardcoded secrets or credentials
     > - Follows project patterns
     >
     > **Output format:**
     > ```
     > ## Code Quality Review
     > **Status:** ✅ Approved | ❌ Changes Required
     > **Strengths:** <what was done well>
     > **Issues:** [Critical] <issue> / [Important] <issue> / [Minor] <issue>
     > **Assessment:** approved or changes required
     > ```
     > **Rule:** Max 3 issues before auto-rejection. List the top 3 most critical.
   - Provide the reviewer with: all files that were created/modified
   - If reviewer returns ❌ Changes Required:
     - Present issues to user with option to (r)etry fixes, (s)kip, or (a)bort
5. Generate a review report covering:
   - **Coverage**: Does implementation cover all requirements?
   - **Accuracy**: Does it match spec and plan?
   - **Quality**: Does code follow established principles?
   - **Gaps**: What's missing or incomplete?
   - **Issues**: Bugs, tech debt, concerns
   - **Spec compliance result**: ✅ Pass / ❌ Fail
   - **Code quality result**: ✅ Approved / ❌ Changes Required
6. Save the report to `specs/<feature>/review.md`.

## Done

Present a final summary:
```
── PIPELINE COMPLETE ─────────────────────
Feature: <name>
Artifacts:
  - specs/<feature>/research.md (if research was done)
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
