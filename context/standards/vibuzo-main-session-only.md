---
tags:
  - vibuzo
  - main-session
  - subtask
  - agent-orchestration
scope: Agent configuration and command file frontmatter
when: Creating or editing command files with agent YAML frontmatter
---

# Vibuzo Main-Session Only

**Date:** 2026-06-06
**Status:** Active

Vibuzo must always run in the **main session**. It must never be spawned as a subtask.

## Rationale

Vibuzo is the primary orchestrator that manages approval gates, presents phase gates to the user, and coordinates subagents. If Vibuzo runs as a subtask:

1. **Approval gates are bypassed** — gates are presented to the subagent's context, not to the user in the main session. The subagent (or its parent) auto-approves them, defeating `approval_level` controls.
2. **User loses visibility** — the user never sees phase transitions, gate prompts, or decision points because they're consumed by the subagent pipeline.
3. **Accountability breaks** — the user has no opportunity to review, edit, or reject intermediate outputs before proceeding.

## Rule

**Never set `subtask: true` on any command where `agent: Vibuzo`.**

Only Deepsearcher and Deepveloper commands use `subtask: true`:

| Agent | Role | `subtask` |
|-------|------|-----------|
| Vibuzo | Orchestrator, planner, reviewer | Never |
| Deepsearcher | Web research | ✅ `true` |
| Deepveloper | Implementation | ✅ `true` |

## Enforcement

When creating or editing command files, check the YAML frontmatter:

```yaml
---
agent: Vibuzo
---
# ❌ WRONG — never add subtask: true when agent is Vibuzo
```

```yaml
---
agent: Deepsearcher
subtask: true
---
# ✅ CORRECT — research agents are subtasks
```

## Related

- [`architecture/agent-restructure.md`](../architecture/agent-restructure.md) — Original agent architecture
- [`approval-gates.md` in AGENTS.md](../../AGENTS.md#approval-gates) — Approval gate level documentation
