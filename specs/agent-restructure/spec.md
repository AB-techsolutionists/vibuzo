# Agent Restructure — Specification

## Principles

- **Code quality** — Agent definitions must be clean, self-documenting, and follow the established YAML frontmatter + markdown format. Each agent has a single, unambiguous responsibility.
- **Separation of concerns** — Vibuzo handles planning + everyday execution. Deepveloper handles only `/implement` subtasks. No overlap, no ambiguity.
- **Zero runtime impact** — This is configuration, not runtime code. No dependencies, no build steps, no performance overhead.
- **Backward compatibility** — Existing commands (`/plan`, `/review`, `/spec`, `/tasks`, `/context`, `/session`, `/add-context`) continue working unchanged. Orchestrator files are preserved (deprecated) so nothing breaks.

## Specification

### Overview

Restructure the Vibuzo framework from a two-agent manual-switch system to a single-agent architecture. Vibuzo becomes the one and only main agent — handling planning, analysis, review, AND execution. A new agent, Deepveloper, is introduced as a pure execution specialist that runs only when `/implement` is invoked as a subtask. Orchestrator is deprecated (files kept for reference) and its planning capabilities are absorbed into Vibuzo. The result: no more manual agent switching.

### User Stories

1. As a developer using Vibuzo, I want to interact with a single main agent for everything (planning, execution, review), so I never have to manually switch between agents.
2. As a developer, I want `/implement` to automatically trigger a focused execution agent (Deepveloper), so complex multi-step implementation tasks get dedicated, undistracted attention without derailing my main conversation.
3. As a framework maintainer, I want Orchestrator's planning logic preserved inside Vibuzo, so the discipline of "plan before execute" is maintained even without a separate agent.

### Functional Requirements

1. Vibuzo shall be the primary/default agent with permissions for both planning (bash/edit/write/task) and execution (bash/edit/write).
2. Deepveloper shall be a subtask-only agent, triggered exclusively by the `/implement` command.
3. The `/implement` command template shall specify `agent: Deepveloper` and `subtask: true` in its YAML frontmatter.
4. Orchestrator agent files shall be clearly marked as DEPRECATED with a visible banner, but their content shall be preserved for reference.
5. `AGENTS.md` shall describe the new architecture: Vibuzo as main agent, Deepveloper for `/implement`, Orchestrator as deprecated.
6. `README.md` shall reflect the new single-entry-point workflow.

### Acceptance Criteria

- ✅ Vibuzo agent definition has bash/edit/write/task permissions (can plan AND execute)
- ✅ Deepveloper agent definition has bash/edit/write permissions (execute only, no task delegation — no permission to spawn sub-agents)
- ✅ `/implement` command template has `agent: Deepveloper` and `subtask: true` in YAML frontmatter
- ✅ Orchestrator agent files display a DEPRECATED banner at the top
- ✅ `AGENTS.md` describes Vibuzo as the main agent and Deepveloper as the `/implement` specialist
- ✅ `README.md` workflow section shows the new single-agent flow without manual switching
- ✅ All existing commands (`/plan`, `/review`, `/spec`, `/tasks`, `/context`, `/session`, `/add-context`) remain unchanged

### Out of Scope

- Removing or deleting Orchestrator files entirely
- Changing how `/plan`, `/review`, `/spec`, or `/tasks` commands work
- Modifying the context system (`/context`, `/session`, `/add-context`)
- Adding new commands or agents beyond Vibuzo, Deepveloper, and deprecated Orchestrator
- Changing the installer scripts (`install.sh`, `install.ps1`)
- Any runtime code, build steps, or dependencies
