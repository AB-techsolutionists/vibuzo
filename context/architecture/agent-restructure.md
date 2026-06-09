---
tags:
  - architecture
  - agents
  - vibuzo
  - deepveloper
  - restructuring
scope: System architecture and agent role definitions
when: Understanding or modifying the agent system architecture
---

# Agent Restructure — Architecture Decision

## Date
2026-06-04

## Context
The original Vibuzo framework used a two-agent manual-switch system: Orchestrator (plan-only) and Vibuzo (execute-only). This required users to manually switch between agents, creating friction and context-switching overhead.

## Decision
Restructure to a single-agent architecture where Vibuzo is the sole main agent for everything, and Deepveloper is a subtask-only execution specialist triggered by delegation via `/spec`.

## Architecture

### Before
```
User → manual switch → Orchestrator (plan-only, no permissions)
                     └──→ Vibuzo (execute-only, full permissions)
```

### After
```
User → Vibuzo (main — plans + delegates + reviews)
            │
            ├──→ /spec → Deepveloper (subtask — pure execute)
            │
            ├──→ /research → Deepsearcher (subtask — web research)
            │
            └──→ /deepviewer → Deepviewer (subtask — codebase analysis)
```

## Agent Roles

### Vibuzo (Main Agent)
- **Role**: Plans, analyzes, delegates, reviews, AND executes everyday tasks
- **Permissions**: bash(allow), edit(allow), write(allow), task(allow)
- **Temperature**: 0.1
- **Mode**: primary
- **Tagline**: "I plan. I delegate. I review. I execute. I am the single entry point for everything."
- **When to execute**: Small changes, questions, analysis, planning, running commands
- **When to delegate**: Complex feature implementations via `/spec` → Deepveloper

### Deepveloper (Subtask Agent)
- **Role**: Pure execution specialist, triggered via `/spec` delegation
- **Permissions**: bash(allow), edit(allow), write(allow), **NO task permission** (cannot spawn sub-agents)
- **Temperature**: 0
- **Mode**: subagent
- **Tagline**: "I execute. I don't plan. I implement exactly what I'm told."

## File Structure

Agent definitions live in `agents/` and are installed to `.opencode/agent/core/` by the installer (`install.ps1`/`install.sh`). The installer copies them on install and overwrites on `--update`.

| Source | Install Target |
|--------|---------------|
| `agents/vibuzo.md` | `.opencode/agent/core/vibuzo.md` |
| `agents/deepveloper.md` | `.opencode/agent/core/deepveloper.md` |
| `agents/deepsearcher.md` | `.opencode/agent/core/deepsearcher.md` |
| `agents/deepviewer.md` | `.opencode/agent/core/deepviewer.md` |

Deepveloper is triggered as a subtask during `/spec` Implementation stage. The handoff includes the task description, file paths, numbered steps, and acceptance criteria.

## Key Principles

1. **Single entry point** — Vibuzo handles everything directly. No manual agent switching.
2. **Deepveloper constrained** — Cannot spawn sub-agents; no planning or scope creep.
3. **Planning discipline** — Planning rules are embedded in Vibuzo's definition.
4. **Installer-managed deployment** — `agents/` is the source of truth; `.opencode/agent/core/` is refreshed by `install.ps1`/`install.sh --update`.
5. **Unified mode** — `agents/deepveloper.md` uses `mode: subagent`, required by opencode for runtime compatibility.

> **Note:** The agent system has expanded from the original 2-agent (Vibuzo + Deepveloper) to a 4-agent system with the addition of Deepsearcher (research) and Deepviewer (codebase analysis).
