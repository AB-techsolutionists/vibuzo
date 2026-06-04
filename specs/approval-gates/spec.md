# Approval Gates — Specification

## Principles

- **User sovereignty** — The human user always has final say before any action that mutates state. Vibuzo never writes, edits, deletes, or delegates without explicit approval at the configured gate level.
- **Configuration over hardcoding** — Gate strictness is defined by a configurable level (not separate agent modes). The user sets the level once; Vibuzo adapts its behavior accordingly.
- **Zero runtime dependencies** — All approval gate behavior is encoded as agent rules and behavioral instructions in Markdown/YAML. No JavaScript, Python, or executable code.
- **Transparency** — Vibuzo always states exactly what it plans to do (file path, change summary, side effects) before asking for approval. No surprises.
- **Consistent UX** — Every approval prompt follows the same format so the user knows exactly where to look and what to type.

## Specification

### Overview

Add configurable approval gates to the Vibuzo framework so the user has full control over every action the agent takes. Approval gates are checkpoints where Vibuzo presents the proposed action and waits for a y/N response before proceeding. The strictness is controlled by a single configuration level (0-3) that determines which actions require approval. This gives users the flexibility to trust the agent completely (level 0) or review every single action (level 3).

### User Stories

1. As a user who wants full control, I want Vibuzo to ask for approval before every file write, edit, delete, and bash command, so no change happens without my review.
2. As a user who trusts the agent for simple tasks, I want to set a lower gate level where only destructive or complex actions require approval, so I'm not interrupted for trivial operations.
3. As a user managing a multi-step feature implementation, I want Vibuzo to pause between tasks and ask "Proceed?" so I can inspect intermediate results before the next step.
4. As a user reviewing a plan, I want Vibuzo to present the full plan and ask for approval before it starts implementing, so I can catch issues early.
5. As a user delegating to Deepveloper via `/implement`, I want the same approval gates to apply (at the configured level), so I have control even during automated subtask execution.

### Functional Requirements

1. **Gate level configuration** — A setting (`approval_level`) shall be defined in Vibuzo's agent configuration. Valid values are 0, 1, 2, 3 (see Levels table below).
2. **Before-execution gate** — Before writing, editing, or deleting any file, Vibuzo shall present the proposed change (file path, diff summary or content description) and wait for y/N approval.
3. **Before-command gate** — Before running any bash command, Vibuzo shall present the full command string and wait for y/N approval.
4. **Before-delegation gate** — Before delegating to Deepveloper via `/implement`, Vibuzo shall present the task spec and ask for approval.
5. **Between-tasks gate** — During multi-step execution (e.g., `/implement` task list), Vibuzo/Deepveloper shall pause after each completed task, report what was done, and ask "Proceed to next task? (y/N)".
6. **Post-plan approval gate** — After Vibuzo presents an implementation plan (via `/plan` or inline proposal), it shall ask for approval before executing any part of it.
7. **Standard prompt format** — Every approval prompt shall follow this structure:
   ```
   ── APPROVAL GATE ──────────────────────
   Action: <write | edit | delete | command | delegate>
   Target: <file path or command string>
   Details: <summary of what will change>
   ───────────────────────────────────────
   Approve? (y/N):
   ```
8. **Rejection handling** — If the user responds "N" (or anything other than "y"/"yes"), Vibuzo shall not proceed. It shall ask if the user wants to modify the action, skip it, or abort the current flow.
9. **Gate level override** — The user may temporarily override the gate level for a single interaction by specifying it in their request (e.g., "implement feature X at gate level 0").
10. **Deepveloper compliance** — Deepveloper shall respect the same gate level when executing tasks. It shall pause between tasks for approval and before destructive operations.

#### Approval Levels

| Level | Name | Gates Active |
|-------|------|-------------|
| 0 | **Trusted** | No gates. Vibuzo executes freely. Equivalent to current behavior. |
| 1 | **Safe** | File mutations (write/edit/delete) and destructive bash commands require approval. Reads and non-destructive commands pass freely. |
| 2 | **Cautious** | All file mutations + all bash commands + delegation to Deepveloper require approval. Planning and analysis are free. |
| 3 | **Full Control** | Every action requires approval — including planning steps, file reads (if >100 lines), command execution, delegation, and between-task progression. |

### Acceptance Criteria

- ✅ Vibuzo pauses and shows an approval prompt before writing/editing/deleting files at level ≥ 1
- ✅ Vibuzo pauses and shows an approval prompt before running bash commands at level ≥ 2
- ✅ Vibuzo pauses and shows an approval prompt before delegating to Deepveloper at level ≥ 2
- ✅ Vibuzo/Deepveloper pauses between tasks and asks to proceed at level ≥ 1
- ✅ Vibuzo asks for plan approval before execution at level ≥ 1
- ✅ User can configure `approval_level` in agent YAML frontmatter or a dedicated config file
- ✅ User can override gate level inline in a request
- ✅ Standard prompt format is used consistently across all gates
- ✅ Rejection ("N") stops the action and offers modify/skip/abort options
- ✅ All gate behavior is implemented as agent rules — no runtime code or dependencies
- ✅ Existing commands (`/plan`, `/spec`, `/tasks`, `/review`, `/context`, `/session`, `/add-context`) remain unchanged at level 0 and gain gates at higher levels

### Out of Scope

- Adding a separate "approval agent" or new agent mode
- GUI or UI-based approval (terminal y/N only)
- Timeout-based auto-approval
- Approvals from multiple users or roles
- Audit logging beyond what the session log already provides
- Integration with external approval systems (Slack, email, etc.)
- Runtime code, dependencies, or build steps
- Changing the `/implement` task execution engine (gate logic is additive, not structural)
