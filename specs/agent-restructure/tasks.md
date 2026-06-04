# Agent Restructure -- Task Breakdown

## Phase 1 -- Foundation (parallel)

- [x] Task 1: Create Deepveloper agent definition [P]
  Files: agents/deepveloper.md, .opencode/agent/core/deepveloper.md
  Depends on: --
  Description: Create the Deepveloper execution specialist agent. This is a pure execution agent triggered only as a subtask by `/implement`. It must have full bash/edit/write permissions but no `task` permission (cannot spawn sub-agents). Its personality is strict execution-only: "I execute. I don't plan." No planning rules, no questioning Orchestrator's approach. Mirror the same content in both `agents/deepveloper.md` (source) and `.opencode/agent/core/deepveloper.md` (opencode registry).
  Acceptance:
    - agents/deepveloper.md exists with YAML frontmatter (name: Deepveloper, mode: subagent, temperature: 0)
    - .opencode/agent/core/deepveloper.md exists with identical content
    - Permissions: bash(allow), edit(allow), write(allow) -- with sensitive file denials (env, key, pem, secret*)
    - Permissions explicitly do NOT include `task` -- Deepveloper cannot spawn sub-agents
    - Personality section: "I execute. I don't plan. I implement exactly what I'm told."
    - No planning or questioning rules

- [x] Task 2: Rewrite Vibuzo agent definition [P]
  Files: agents/vibuzo.md, .opencode/agent/core/vibuzo.md
  Depends on: --
  Description: Rewrite Vibuzo from a pure execution agent into the main agent that handles both planning AND execution. Merge Orchestrator's planning rules ("Plan first -- restate, surface tradeoffs, get approval") with Vibuzo's existing execution capability. Add the rule that `/implement` flows to Deepveloper as a subtask. Grant full permissions (bash/edit/write/task). Mirror both source and registry copies.
  Acceptance:
    - agents/vibuzo.md exists with merged planning + execution rules
    - .opencode/agent/core/vibuzo.md exists with identical content
    - Permissions: bash(allow), edit(allow), write(allow), task(allow) -- with sensitive file denials
    - Contains "Plan first" rule (restate, surface tradeoffs, get approval before delegating)
    - Contains execution rules (read files, implement, verify)
    - Contains delegation rule: "/implement flows to Deepveloper as subtask"
    - Temperature set to 0.1 (balanced between planning and execution)
    - All Orchestrator's planning logic is preserved, not summarized or lost

- [x] Task 3: Deprecate Orchestrator agent [P]
  Files: agents/orchestrator.md, .opencode/agent/core/orchestrator.md
  Depends on: --
  Description: Add a clear DEPRECATED banner at the top of both Orchestrator files. Preserve all original content below the banner. The banner should explain that Vibuzo now handles planning, and this file is kept for reference only. Do NOT delete or modify any existing content.
  Acceptance:
    - agents/orchestrator.md has DEPRECATED banner at the very top
    - .opencode/agent/core/orchestrator.md has identical DEPRECATED banner
    - All original content preserved intact below the banner
    - Banner states: "DEPRECATED -- Vibuzo now handles all planning and execution. This file is kept for reference only."

## Phase 2 -- Routing

- [x] Task 4: Update /implement command routing
  Files: commands/implement.md, .opencode/commands/implement.md
  Depends on: Task 1, Task 2, Task 3
  Description: Change the YAML frontmatter in both copies of the implement command template. Replace `agent: Vibuzo` with `agent: Deepveloper`. Ensure `subtask: true` remains. Do not change any other content in the file.
  Acceptance:
    - commands/implement.md has `agent: Deepveloper` and `subtask: true` in YAML frontmatter
    - .opencode/commands/implement.md has identical change
    - No other content in the files was modified
    - The rest of the command template (steps 1-5) is unchanged

## Phase 3 -- Documentation

- [x] Task 5: Update AGENTS.md
  Files: AGENTS.md
  Depends on: Task 4
  Description: Rewrite the architecture description in AGENTS.md. Replace the two-agent table (Orchestrator/Vibuzo) with the new single-agent architecture (Vibuzo main + Deepveloper for /implement). Preserve the Context Auto-Load section and the Handoff Protocol section unchanged. Update the "Default Mode" description to reflect that Vibuzo is now the default for everything. Keep Karpathy Principles and Universal Project Rules intact.
  Acceptance:
    - Agent table shows: Vibuzo (main - plans + executes), Deepveloper (/implement subtask - executes only)
    - Orchestrator removed from active agent list (may be mentioned as deprecated)
    - Context Auto-Load section intact
    - Handoff Protocol section intact
    - Karpathy Principles intact
    - Universal Project Rules section intact
    - Vibuzo's rules section describes both planning and execution responsibilities

- [x] Task 6: Update README.md
  Files: README.md
  Depends on: Task 4
  Description: Update the README.md to reflect the new architecture. Replace the two-agent workflow diagram with the single-agent flow. Remove the "How It Works" section that shows manual switching. Update the "What Gets Installed" section to mention Deepveloper. Keep the philosophy, install instructions, supported tools table, and roadmap intact.
  Acceptance:
    - Workflow section shows single-agent flow (User to Vibuzo for everything, /implement to Deepveloper)
    - No references to manual agent switching
    - "What Gets Installed" lists Deepveloper alongside Vibuzo
    - Philosophy, Install, Supported Tools, Roadmap sections intact
    - Handoff Protocol example preserved

## Verification

- [x] Task 7: Final review -- verify all acceptance criteria
  Files: (all modified files)
  Depends on: Task 5, Task 6
  Description: Read all modified files and verify against the 7 acceptance criteria from the spec. Confirm no unintended changes were made to files outside the scope. Report pass/fail for each criterion.
  Acceptance:
    - Vibuzo has bash/edit/write/task permissions (can plan AND execute)
    - Deepveloper has bash/edit/write permissions (no task - cannot spawn sub-agents)
    - /implement command has agent: Deepveloper and subtask: true
    - Orchestrator files display DEPRECATED banner
    - AGENTS.md describes Vibuzo as main agent, Deepveloper for /implement
    - README.md shows new single-agent flow without manual switching
    - All existing commands (/plan, /review, /spec, /tasks, /context, /session, /add-context) remain unchanged -- verified by spot-check
