# Deepsearcher Research Stage — Task Breakdown

## Phase 1 — Create Deepsearcher Agent

- [ ] Task 1: Create Deepsearcher agent definition [P]
  Files: .opencode/agent/core/deepsearcher.md
  Depends on: —
  Description: Create the Deepsearcher agent file following the same pattern as Deepveloper. Key differences: name is "Deepsearcher", tool access includes websearch and webfetch, core rules focus on web research behavior. The agent should have mode: subagent, identical permission model to Deepveloper, and a structured report format (summary, key findings, resources, metadata). Include core rules that describe how to conduct research: use websearch to find information, use webfetch to retrieve detailed content from promising URLs, synthesize findings into structured output, save to research.md.
  Acceptance:
    - .opencode/agent/core/deepsearcher.md exists
    - YAML frontmatter: name: Deepsearcher, mode: subagent
    - Permission model: same as Deepveloper (allow all except sensitive files)
    - Core rules describe web research methodology
    - Report format defined: Status, Summary, Key Findings, Resources, Source Metadata
    - Between-task gating rules inherited from Vibuzo's approval_level
    - No task() permission (cannot spawn sub-agents)

## Phase 2 — Create /research Command

- [ ] Task 2: Create /research command [P — runs after Task 1, parallel with Tasks 4,5,6]
  Files: commands/research.md, .opencode/commands/research.md
  Depends on: Task 1
  Description: Create the `/research` command that routes to Deepsearcher as a subtask. The command accepts a query via $ARGUMENTS, derives a feature name from the query (kebab-case), creates specs/<feature>/ if needed, and instructs Deepsearcher to conduct web research and save results to specs/<feature>/research.md. The command should include: YAML frontmatter (agent: Deepsearcher, subtask: true), description, and steps for Deepsearcher to execute (infer feature name, use websearch/webfetch, structure output, save to file).
  Acceptance:
    - commands/research.md exists with agent: Deepsearcher, subtask: true
    - .opencode/commands/research.md exists with identical content
    - Command accepts query via $ARGUMENTS
    - Feature name derived from query (kebab-case)
    - Steps instruct Deepsearcher to save output to specs/<feature>/research.md
    - Research output includes: Summary, Key Findings, Resources, Source Metadata

## Phase 3 — Update /spec Command

- [ ] Task 3: Update /spec command with Phase 0 (Research)
  Files: commands/spec.md, .opencode/commands/spec.md
  Depends on: Task 2
  Description: Add Phase 0 (Research) to the beginning of the existing /spec command pipeline. The phase should: (1) Ask the user "Research this feature? (y/N)" at the start, (2) If Yes: spawn Deepsearcher via task() with subagent_type "Deepsearcher", passing the feature description as the research query and instructing it to save to specs/<feature>/research.md, then wait for Deepsearcher to report back, (3) Present a phase gate "Research complete. Proceed to Phase 1?", (4) If No: skip directly to Phase 1. The existing phases 1-5 must remain unchanged. Add a note in Phase 1 to read research.md if it exists before generating the spec.
  Acceptance:
    - commands/spec.md has Phase 0 before Phase 1
    - Phase 0 asks "Research this feature? (y/N)"
    - "Y" path: spawns Deepsearcher with feature description as query, saves to specs/<feature>/research.md
    - "N" path: skips directly to Phase 1
    - Phase gate after research: "Research complete. Proceed to Phase 1?"
    - Phase 1 reads research.md if it exists before generating spec
    - Existing phases 1-5 are identical to current content
    - .opencode/commands/spec.md has identical changes

## Phase 4 — Documentation (Parallel)

- [ ] Task 4: Create architecture decision record [P]
  Files: context/architecture/deepsearcher-research-stage.md
  Depends on: —
  Description: Create an architecture decision record documenting the Deepsearcher Research Stage. Include: date (2026-06-06), context (why we need a research stage), decision (add Deepsearcher agent, /research command, Phase 0 integration), consequences (pipeline now has optional research, three agents instead of two), and file structure.
  Acceptance:
    - context/architecture/deepsearcher-research-stage.md exists
    - Includes date, context, decision, consequences
    - References the 3-agent system

- [ ] Task 5: Update AGENTS.md [P]
  Files: AGENTS.md
  Depends on: —
  Description: Update the Two-Agent System table in AGENTS.md to a Three-Agent System, adding Deepsearcher as the third agent. Also add note in AGENTS.md about the /research command and @deepsearcher inline invocation.
  Acceptance:
    - AGENTS.md shows three agents: Vibuzo, Deepveloper, Deepsearcher
    - Table includes: name, role, mode for Deepsearcher
    - Notes about /research command and @deepsearcher

- [ ] Task 6: Update context/index.md [P]
  Files: context/index.md
  Depends on: —
  Description: Add a reference to the new architecture decision record context/architecture/deepsearcher-research-stage.md in the architecture section of context/index.md.
  Acceptance:
    - context/index.md includes a link to context/architecture/deepsearcher-research-stage.md

## Phase 5 — Verification

- [ ] Task 7: Final review
  Files: .opencode/agent/core/deepsearcher.md, commands/research.md, .opencode/commands/research.md, commands/spec.md, .opencode/commands/spec.md, context/architecture/deepsearcher-research-stage.md, AGENTS.md, context/index.md
  Depends on: Task 3, Task 4, Task 5, Task 6
  Description: Read all modified files and verify against the acceptance criteria from the spec and the task acceptance criteria above. Confirm no unintended changes to existing functionality. Check that the /spec command's existing phases 1-5 are intact. Save the review report to specs/deepsearcher-research-stage/review.md.
  Acceptance:
    - Deepsearcher agent defined correctly (mode: subagent, tool access)
    - /research command spawns Deepsearcher, saves to research.md
    - /spec command has Phase 0 with skip logic
    - /spec existing phases 1-5 unchanged
    - Architecture decision record created
    - AGENTS.md updated to 3-agent system
    - context/index.md updated
    - All existing commands (/context, /session, /add-context) unchanged
    - Review report saved to specs/deepsearcher-research-stage/review.md

## Dependency Graph

```
Task 1 (agent) ───────────────────────► Task 2 (command) ────► Task 3 (update /spec) ──┐
Task 4 (arch doc) [P] ─────────────────────────────────────────────────────────────────┤
Task 5 (AGENTS.md) [P] ────────────────────────────────────────────────────────────────┤
Task 6 (context index) [P] ────────────────────────────────────────────────────────────┤
                                                                                       ├──► Task 7 (review)
                                                                                       │
All tasks must complete before Task 7 ──────────────────────────────────────────────────┘
```

## Summary

| Task | Description | Files | Parallel | Depends On |
|------|-------------|-------|----------|------------|
| 1 | Create Deepsearcher agent | 1 | Yes | — |
| 2 | Create /research command | 2 | No | Task 1 |
| 3 | Update /spec with Phase 0 | 2 | No | Task 2 |
| 4 | Architecture decision record | 1 | Yes | — |
| 5 | Update AGENTS.md | 1 | Yes | — |
| 6 | Update context/index.md | 1 | Yes | — |
| 7 | Final review | 8 | No | Tasks 3,4,5,6 |

**Total tasks: 7 (3 sequential, 3 parallel, 1 verification)**
