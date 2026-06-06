# Deepsearcher Research Stage

**Date:** 2026-06-06
**Status:** Active

## Context

The Vibuzo agentic framework currently operates as a two-agent system: Vibuzo (primary planner/executor) and Deepveloper (implementation subagent). The `/spec` command pipeline follows a 5-phase approach (Specification → Plan → Tasks → Implementation → Review). However, there is no dedicated research capability in the pipeline.

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

A new command that routes research queries to Deepsearcher as a subtask. Accepts a natural language query via `$ARGUMENTS`, derives a kebab-case feature name, creates `specs/<feature>/` if needed, and instructs Deepsearcher to save structured research to `specs/<feature>/research.md`.

**Locations:** `commands/research.md`, `.opencode/commands/research.md` (mirrored per convention)

### 3. Phase 0 Integration in `/spec`

The existing `/spec` command gains an optional **Phase 0 — Research** at the start of the pipeline. The user is asked if they want to research the feature first. If yes, Deepsearcher is spawned with the feature description as the research query. After research completes, a phase gate asks whether to proceed to Phase 1 (Specification). Phase 1 is also updated to read `research.md` if it exists before generating the specification.

### 4. `@deepsearcher` Inline Support

Deepsearcher can be invoked inline via `@deepsearcher` in any conversation, allowing ad-hoc research without going through the full `/spec` pipeline. This is supported by the agent definition being registered in the opencode agent system.

## Consequences

### Positive

- **Three-agent system:** Vibuzo (planning/execution), Deepveloper (implementation), Deepsearcher (research) — clear separation of concerns
- **Optional research phase:** Features that don't need research skip Phase 0 entirely; features that do get structured, saved research
- **Reusable research artifacts:** `specs/<feature>/research.md` is a permanent project artifact that can be referenced later
- **Consistent output format:** Every research task produces Summary, Key Findings, Resources, Source Metadata
- **Inline invocation:** `@deepsearcher` provides ad-hoc research without pipeline overhead

### Negative

- **New command surface:** One additional command (`/research`) adds complexity to the command system
- **Subagent dependency:** Phase 0 introduces another subagent spawn in the `/spec` pipeline, adding latency
- **Mirror maintenance:** Two copies of the command file must be kept in sync (`commands/` and `.opencode/commands/`)

## File Structure

```
.opencode/
├── agent/
│   ├── core/
│   │   ├── vibuzo.md           ← Main agent (unchanged)
│   │   ├── deepveloper.md      ← Implementation subagent (unchanged)
│   │   └── deepsearcher.md     ← NEW: Research subagent
│   └── commands/
│       ├── spec.md             ← UPDATED: Phase 0 added
│       ├── research.md         ← NEW: Research command
│       └── ... (existing)
commands/
├── spec.md                     ← UPDATED: Phase 0 added (mirror)
├── research.md                 ← NEW: Research command (mirror)
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
- [`spec-command.md`](spec-command.md) — The 5-phase /spec pipeline that Phase 0 extends
- [`split-file-command-pattern.md`](split-file-command-pattern.md) — Each command gets one file, mirrored in two locations
