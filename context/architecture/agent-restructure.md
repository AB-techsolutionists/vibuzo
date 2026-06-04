# Agent Restructure — Architecture Decision

## Date
2026-06-04

## Context
The original Vibuzo framework used a two-agent manual-switch system: Orchestrator (plan-only) and Vibuzo (execute-only). This required users to manually switch between agents, creating friction and context-switching overhead.

## Decision
Restructure to a single-agent architecture where Vibuzo is the sole main agent for everything, and Deepveloper is a subtask-only execution specialist triggered by `/implement`.

## Architecture

### Before
```
User → manual switch → Orchestrator (plan-only, no permissions)
                     └──→ Vibuzo (execute-only, full permissions)
```

### After
```
User → Vibuzo (main — plans + executes)
            │
            └──→ /implement → Deepveloper (subtask — pure execute)
```

## Agent Roles

### Vibuzo (Main Agent)
- **Role**: Plans, analyzes, delegates, reviews, AND executes everyday tasks
- **Permissions**: bash(allow), edit(allow), write(allow), task(allow)
- **Temperature**: 0.1
- **Mode**: primary
- **Tagline**: "I plan. I delegate. I review. I execute. I am the single entry point for everything."
- **When to execute**: Small changes, questions, analysis, planning, running commands
- **When to delegate**: Complex feature implementations via `/implement` → Deepveloper

### Deepveloper (Subtask Agent)
- **Role**: Pure execution specialist, triggered only by `/implement`
- **Permissions**: bash(allow), edit(allow), write(allow), **NO task permission** (cannot spawn sub-agents)
- **Temperature**: 0
- **Mode**: subagent
- **Tagline**: "I execute. I don't plan. I implement exactly what I'm told."

### Orchestrator (Deprecated)
- **Role**: Former plan-mode agent — now deprecated
- **Status**: Files kept for reference with DEPRECATED banner
- **Reason**: All planning logic absorbed into Vibuzo

## File Structure

Agent definitions live in `agents/` (source) and are mirrored in `.opencode/agent/core/` (opencode registry):

| Source | Registry Copy |
|--------|---------------|
| `agents/vibuzo.md` | `.opencode/agent/core/vibuzo.md` |
| `agents/deepveloper.md` (`mode: subagent`) | `.opencode/agent/core/deepveloper.md` (`mode: subagent`) |
| `agents/orchestrator.md` (deprecated) | `.opencode/agent/core/orchestrator.md` (deprecated) |

The `/implement` command template routes to Deepveloper via `agent: Deepveloper` and `subtask: true` in its YAML frontmatter (both `commands/implement.md` and `.opencode/commands/implement.md`).

## Key Principles

1. **Single entry point** — Vibuzo handles everything directly. No manual agent switching.
2. **Deepveloper constrained** — Cannot spawn sub-agents; no planning or scope creep.
3. **Planning discipline** — Orchestrator's "plan first" rules are embedded in Vibuzo's definition.
4. **Backward compatibility** — Orchestrator files preserved (deprecated) so existing references don't break.
5. **Source + registry mirror** — Every agent definition exists in both `agents/` and `.opencode/agent/core/`.
6. **Unified mode** — Both source (`agents/deepveloper.md`) and registry copy (`.opencode/agent/core/deepveloper.md`) use `mode: subagent`. The `mode: subagent` value is required by opencode for runtime compatibility.
