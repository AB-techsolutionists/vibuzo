# Agent Restructure — Implementation Plan

## Tech Stack

| Technology | Choice | Justification |
|------------|--------|---------------|
| **Markdown** | Content format | Every artifact (agent definitions, commands, docs) is already plain `.md`. Zero dependencies, zero build step. |
| **YAML Frontmatter** | Agent metadata | Required by opencode for agent definitions (name, description, mode, permissions). Already used by all agent files. |
| **No runtime code** | — | This is a configuration-only restructure. No JavaScript, Python, Shell, or any executable code needed. |

The entire change is text-based configuration. No new languages, frameworks, or dependencies are introduced.

## Architecture

### Before (Current)

```
You ──manual switch──► Orchestrator (plan-only, no permissions)
                     └──► Vibuzo (execute-only, full permissions)
```

**Problem:** You must manually switch between two agents. Orchestrator can't execute, Vibuzo can't plan. Every task requires context switching.

### After (Target)

```
You ──────────────────► Vibuzo (main agent — plans + executes)
                              │
                              └──► /implement ──► Deepveloper (subtask — pure execute)
```

**Key change:** Single entry point. Vibuzo does everything except `/implement`, which automatically spawns Deepveloper as a focused subtask.

### Data Flow

1. User says "Plan feature X" → **Vibuzo** analyzes, proposes options, gets approval
2. User says "Implement feature X" → **Vibuzo** runs `/implement X` → opencode routes to **Deepveloper** (subtask) → Deepveloper reads spec/plan/tasks, executes, reports back to user
3. User says "Review my code" → **Vibuzo** reads files, analyzes, reports
4. User says "Add context" → **Vibuzo** runs `/add-context` command directly
5. User says "Log session" → **Vibuzo** runs `/session log` command directly

No manual agent switching at any point.

### Integration Points

| Integration | Affected Files | Nature of Change |
|-------------|---------------|------------------|
| **Agent definitions** | `agents/vibuzo.md`, `agents/deepveloper.md`, `agents/orchestrator.md` | Rewrite / Create / Deprecate |
| **opencode agent registry** | `.opencode/agent/core/vibuzo.md`, `.opencode/agent/core/deepveloper.md`, `.opencode/agent/core/orchestrator.md` | Same changes mirrored |
| **Command routing** | `commands/implement.md`, `.opencode/commands/implement.md` | Change `agent:` from Vibuzo to Deepveloper |
| **Project rules** | `AGENTS.md` | Rewrite architecture description |
| **Documentation** | `README.md` | Rewrite workflow section |

## Components

### New Components

| Component | File(s) | Responsibility |
|-----------|---------|---------------|
| **Deepveloper agent** | `agents/deepveloper.md`, `.opencode/agent/core/deepveloper.md` | Pure execution specialist. Triggered only as a subtask by `/implement`. Has full bash/edit/write permissions but NO `task` permission (cannot spawn sub-agents). Strictly follows spec/plan/tasks. Never plans, never adds scope. |

### Modified Components

| Component | File(s) | Change |
|-----------|---------|--------|
| **Vibuzo agent** | `agents/vibuzo.md`, `.opencode/agent/core/vibuzo.md` | Gains planning rules (from Orchestrator) + execution permissions (bash/edit/write/task). Becomes the sole primary agent. |
| **/implement command** | `commands/implement.md`, `.opencode/commands/implement.md` | Change `agent: Vibuzo` → `agent: Deepveloper` in YAML frontmatter. Content unchanged. |
| **AGENTS.md** | `AGENTS.md` | Replace two-agent table with new single-agent architecture description. Update handoff protocol to reflect no manual switching. |
| **README.md** | `README.md` | Update workflow diagram, remove manual switch instructions, reflect new architecture. |

### Deprecated Components

| Component | File(s) | Change |
|-----------|---------|--------|
| **Orchestrator agent** | `agents/orchestrator.md`, `.opencode/agent/core/orchestrator.md` | Add DEPRECATED banner at the top. Full original content preserved below. |

### Interfaces

```
User ←→ Vibuzo (primary interface for ALL interaction)
             │
             ├──→ Bash/Edit/Write (execute everyday tasks)
             ├──→ task() → Deepveloper (via /implement only)
             └──→ Reads: AGENTS.md, commands/, context/, specs/
```

```
/implement command → opencode routing → Deepveloper (subtask)
                                               │
                                               ├──→ Bash/Edit/Write (execute implementation)
                                               └──→ Reads: specs/<feature>/{spec,plan,tasks}.md
```

## Implementation Order

### Phase 1 — Foundation (parallel, no deps)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 1 | **Create Deepveloper agent** | `agents/deepveloper.md`, `.opencode/agent/core/deepveloper.md` | Low — new file, no existing content to break |
| 2 | **Rewrite Vibuzo agent** | `agents/vibuzo.md`, `.opencode/agent/core/vibuzo.md` | Medium — must merge planning + execution without losing existing rules |
| 3 | **Deprecate Orchestrator** | `agents/orchestrator.md`, `.opencode/agent/core/orchestrator.md` | Low — just adding a banner, content unchanged |

### Phase 2 — Routing (depends on Phase 1)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 4 | **Update /implement routing** | `commands/implement.md`, `.opencode/commands/implement.md` | Low — single YAML field change (`agent: Vibuzo` → `agent: Deepveloper`) |

### Phase 3 — Documentation (depends on Phase 1-2)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 5 | **Update AGENTS.md** | `AGENTS.md` | Medium — must accurately describe new architecture without breaking auto-load instruction |
| 6 | **Update README.md** | `README.md` | Low — documentation only, no functional impact |

### Risk Factors

1. **Vibuzo rewrite could lose planning discipline** — Solution: Explicitly embed Orchestrator's "plan first" rules into Vibuzo's definition. Don't assume Vibuzo will naturally plan.
2. **Deepveloper could be confused with old Vibuzo** — Solution: Give Deepveloper a distinct personality ("I execute. I don't plan.") and explicitly deny `task` permission so it cannot spawn further agents.
3. **opencode may not recognize Deepveloper until agent files are in `.opencode/agent/core/`** — Solution: Create both `agents/` (source) and `.opencode/agent/core/` (registry) copies in the same task.
4. **AGENTS.md must remain readable by 25+ tools** — Solution: Keep the Handoff Protocol section intact. Only change the agent table and workflow description.

### Dependency Graph

```
Step 1 (Deepveloper) ──┐
Step 2 (Vibuzo)     ──┼──► Step 4 (/implement routing) ──► Step 5 (AGENTS.md) ──► Step 6 (README.md)
Step 3 (Orchestrator) ─┘
```

Steps 1, 2, and 3 are fully parallel. Step 4 requires all three to exist. Steps 5 and 6 are sequential after Step 4.
