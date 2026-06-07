---
tags:
  - architecture
  - deepsearcher
  - research
  - spec-pipeline
  - subagent
scope: Research integration in the /spec pipeline and Deepsearcher agent
when: Working with Deepsearcher agent or the /spec research stage
---

# Deepsearcher Research Stage

**Date:** 2026-06-06
**Status:** Active

## Context

The Vibuzo agentic framework currently operates as a three-agent system: Vibuzo (primary planner/executor), Deepveloper (implementation subagent), and Deepsearcher (research subagent). The `/spec` command pipeline follows a 6-stage approach (Research → Specification → Plan → Tasks → Implementation → Review).

When developing features that require understanding of external technologies, libraries, APIs, or best practices, the agents have no structured way to conduct web research. Vibuzo can perform web searches during everyday tasks, but there is no specialized, reproducible research workflow integrated into the feature development pipeline.

Key drivers for this decision:
- Feature specifications often need external research (e.g., "what's the best React state management library in 2026?")
- Implementation subtasks may need research context (e.g., "how does the Stripe API handle idempotency?")
- No standardized format for research output exists
- Research results are ad-hoc and not saved as project artifacts

## Decision

We will implement a **Deepsearcher Research Stage** consisting of four components:

### 1. Deepsearcher Agent

A new subagent (`mode: subagent`) dedicated exclusively to web research. It follows the same permission model as Deepveloper but its tool usage is focused on `websearch` and `webfetch`. It has no `task()` capability (cannot spawn sub-agents). Temperature set to 0 for deterministic, factual output.

**Location:** `.opencode/agent/core/deepsearcher.md`

### 2. `/research` Command

A command that routes research queries to Deepsearcher as a subtask for lightweight, ad-hoc research. Deepsearcher researches the topic and reports findings back to Vibuzo. **No files are created** — this is a pure research-and-report invocation.

**Location:** `commands/research.md` — installed to `.opencode/commands/research.md` by `install.ps1`/`install.sh`

### 3. Research Stage in `/spec`

The `/spec` command includes an optional **Research** stage at the start of the pipeline. The user is asked if they want to research the feature first. If yes, Deepsearcher is spawned with the feature description as the research query. Unlike `/research` mode, **this invocation saves results** to `specs/<feature>/research.md` as a permanent pipeline artifact. After research completes, a pipeline gate asks whether to proceed to Specification. The Specification phase reads the research file if it exists.

### 4. `@Deepsearcher` Inline Support

Deepsearcher can be invoked inline via `@Deepsearcher` in any conversation, allowing ad-hoc research without going through the full `/spec` pipeline. This spawns Deepsearcher as a subtask — **no files are created**. Findings are reported to Vibuzo, who presents them in the main session.

## Consequences

### Positive

- **Three-agent system:** Vibuzo (planning/execution), Deepveloper (implementation), Deepsearcher (research) — clear separation of concerns
- **Optional research stage:** Features that don't need research skip the stage entirely; features that do get structured, saved research
- **Reusable research artifacts:** `/spec` Research stage saves `specs/<feature>/research.md` as a permanent project artifact
- **Consistent output format:** Every research task produces Summary, Key Findings, Resources, Source Metadata
- **No-file modes:** `@Deepsearcher` and `/research` provide lightweight research without cluttering the project with files
- **Three clear invocation modes:** Different behaviors for inline, command, and pipeline contexts

### Negative

- **New command surface:** One additional command (`/research`) adds complexity to the command system
- **Subagent dependency:** Research stage introduces another subagent spawn in the `/spec` pipeline, adding latency
- **Mirror maintenance:** Two copies of the command file must be kept in sync (`commands/` and `.opencode/commands/`)
- **Three modes to remember:** Users must understand which mode creates files and which doesn't

## File Structure

```
.opencode/
├── agent/
│   ├── core/
│   │   ├── vibuzo.md           ← Main agent (unchanged)
│   │   ├── deepveloper.md      ← Implementation subagent (unchanged)
│   │   └── deepsearcher.md     ← NEW: Research subagent
│   └── commands/
│       ├── spec.md             ← UPDATED: Research stage added
│       ├── research.md         ← NEW: /research command (no-file mode)
│       └── ... (existing)
commands/
├── spec.md                     ← UPDATED: Research stage added
├── research.md                 ← NEW: /research command
└── ... (existing)
context/
├── architecture/
│   ├── deepsearcher-research-stage.md  ← THIS FILE
│   └── ... (existing)
└── index.md                    ← UPDATED: reference to this file
AGENTS.md                       ← UPDATED: Three-Agent System table
```

## Related Decisions

- [`agent-restructure.md`](agent-restructure.md) — Original agent architecture with Vibuzo + Deepveloper
- [`spec-command.md`](spec-command.md) — The /spec pipeline that the Research stage extends
- [`split-file-command-pattern.md`](split-file-command-pattern.md) — Each command gets one file with one purpose

## Related Standards

- [`standards/deepsearcher-invocation-modes.md`](../standards/deepsearcher-invocation-modes.md) — Three-mode invocation rules (@Deepsearcher, /research, /spec)
- [`standards/vibuzo-main-session-only.md`](../standards/vibuzo-main-session-only.md) — Vibuzo never spawned as subtask
