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
4. Gates are handled via the hybrid model — native opencode permission popups for mechanical actions (file ops, commands, delegation), custom chat gates for conceptual approvals (plan approval, push approval).

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
5. **Gate**: Gates follow the hybrid model — always present the gate prompt for conceptual approvals.

## Specification

1. Read `specs/<feature>/research.md` if it exists, incorporate findings into the specification.
2. Ask clarifying questions if the description is vague (what problem, who users are, what success looks like).
3. Once clear, generate a specification document with:
   - **Principles**: Code quality, testing, performance, UX consistency
   - **Specification**: Overview, User Stories, Functional Requirements, Acceptance Criteria, Out of Scope
4. Write to `specs/<feature>/spec.md`.
5. **Gate**: Present:
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
2. **Gate**: Present:
   ```
   ── PIPELINE GATE ──────────────────────
   Implementation ready.
   Summary: <N> tasks to execute via Deepveloper
   ───────────────────────────────────────
   Proceed to implementation? (y/N):
   ```
3. If approved, delegate all tasks to Deepveloper via `task()` with subagent_type "Deepveloper":
   - Include the feature name and instruct to read tasks.md and execute in order
   - Include gate mode info in the handoff so Deepveloper respects gates
4. Wait for Deepveloper to report back.
5. If Deepveloper reports failure: offer (r)etry, (s)kip to review, or (a)bort.
6. **Gate**: After implementation, present "Implementation complete" gate.

## Review

1. Read `specs/<feature>/spec.md`, `specs/<feature>/plan.md`, `specs/<feature>/tasks.md`.
2. Find implemented code in the codebase (read files referenced in tasks.md).
3. **Stage 1 — Spec Compliance Review:**
   - Dispatch Deepviewer via `task()` with subagent_type "Deepviewer" for Spec Compliance Review
   - Pass: spec doc, plan, tasks, implemented file paths as context
   - Provide Deepviewer with these instructions inline:
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
   - Provide Deepviewer with: the spec document, task requirements, and all files that were created/modified
   - If reviewer returns ❌ Fail:
     - Present issues to user with option to (r)etry fixes, (s)kip, or (a)bort
4. **Stage 2 — Code Quality Review:**
   - Only if Spec Compliance Review passed ✅
   - Dispatch Deepviewer via `task()` with subagent_type "Deepviewer" for Code Quality Review
   - Pass: all files that were created/modified as context
   - Provide Deepviewer with these instructions inline:
      > **Role:** You are a code quality reviewer using the Five-Axis Review Framework. Verify the implementation is well-structured, maintainable, secure, performant, and follows project standards.
      >
      > **Instructions:**
      > 1. Read all implementation files thoroughly using the Read tool
      > 2. Apply the Five-Axis Review Framework to evaluate every file:
      >    - **Correctness** — Does the code do what the spec says? Edge cases handled? Error paths?
      >    - **Readability** — Clear names? Straightforward logic? No unnecessary complexity?
      >    - **Architecture** — Follows existing patterns? Clean boundaries? Right abstraction level?
      >    - **Security** — Input validated? Secrets exposed? Injection vulnerabilities? Auth checks?
      >    - **Performance** — N+1 queries? Unbounded operations? Missing pagination?
      > 3. Check change sizing — flag anything exceeding ~300 lines as too large
      > 4. Reference `context/standards/code-review-framework.md` for the full framework
      >
      > **Checklist:**
      > - ✅ Correctness — matches spec, edge cases, error paths
      > - ✅ Readability — clear names, straightforward logic, no dead code
      > - ✅ Architecture — follows patterns, clean boundaries, no duplication
      > - ✅ Security — input validated, no secrets, auth checked, no injections
      > - ✅ Performance — no N+1, no unbounded ops, pagination where needed
      > - ✅ Change sizing — under ~300 lines or justified
      >
      > **Output format:**
      > ```
      > ## Code Quality Review
      > **Status:** ✅ Approved | ❌ Changes Required
      > **Five-Axis Results:**
      > - Correctness: ✅ Pass | ❌ Issues
      > - Readability: ✅ Pass | ❌ Issues
      > - Architecture: ✅ Pass | ❌ Issues
      > - Security: ✅ Pass | ❌ Issues
      > - Performance: ✅ Pass | ❌ Issues
      > - Change Sizing: ✅ OK | ❌ Too Large
      > **Issues:**
      > - [Critical] <issue> — <file:line>
      > - [Important] <issue> — <file:line>
      > - [Nit] <issue> — <file:line>
      > **Strengths:** <what was done well>
      > **Assessment:** approved or changes required
      > ```
      > **Rule:** Every issue MUST include a severity label (Critical / Important / Nit / Optional / FYI). No unlabeled findings.
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

Gates follow the hybrid model — native opencode permission popups for mechanical actions, custom chat gates for plan/push approval. All phase gates use chat prompts for conceptual approval. The phase gates always present unless the user explicitly opts out.
