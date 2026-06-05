# Approval Gates — Architecture Decision

## Date
2026-06-04

## Context
Users wanted full control over agent actions — the ability to review and approve file writes, commands, and task progression before they happen. The existing "Plan first" rule provided a single approval checkpoint at the planning stage, but no mechanism for ongoing approval during execution.

## Decision
Add configurable approval gates to Vibuzo and Deepveloper agent definitions. Gate strictness is controlled by an `approval_level` setting (0-3) in Vibuzo's YAML frontmatter. Deepveloper inherits the level from Vibuzo's handoff.

## Architecture

### Level Definitions

| Level | Name | Gates Active |
|-------|------|-------------|
| 0 | Trusted | No gates. Execute freely. Equivalent to original behavior. |
| 1 | Safe | File mutations (write/edit/delete) and destructive bash commands require approval. |
| 2 | Cautious | All file mutations + all bash commands + delegation to Deepveloper require approval. |
| 3 | Full Control | Every action requires approval — including planning steps, large file reads, command execution, delegation, and between-task progression. |

### Agent Roles

#### Vibuzo (Main Agent)
- Stores `approval_level` in YAML frontmatter (default: 0)
- Checks level before every gated action
- Presents standard approval prompt (── APPROVAL GATE ── format)
- On rejection, offers modify/skip/abort
- Supports inline override: "at gate level X" for one interaction
- Asks for plan approval before execution at level ≥ 1

#### Deepveloper (Subtask Agent)
- Does NOT have its own `approval_level` setting
- Inherits gate level from Vibuzo's handoff
- Enforces between-task gating ("Proceed to next task? (y/N)")
- Enforces destructive action gating
- Strictly follows the level provided — no autonomous decisions

### Standard Prompt Format

The agent must always render the approval gate inside a code block (triple backticks) so opencode displays it as a terminal card UI element.

```
── APPROVAL GATE ──────────────────────
Action: <write | edit | delete | command | delegate>
Target: <file path or command string>
Details: <summary of what will change>
───────────────────────────────────────
Approve? (y/N):
```

### File Structure

| File | Change |
|------|--------|
| `agents/vibuzo.md` | Added `approval_level: 0` to YAML + "## Approval Gates" section |
| `.opencode/agent/core/vibuzo.md` | Mirrored same changes |
| `agents/deepveloper.md` | Added "## Approval Gates" section (no YAML changes) |
| `.opencode/agent/core/deepveloper.md` | Mirrored same changes |
| `AGENTS.md` | Added "### Approval Gates" under Universal Project Rules |

### Key Principles

1. **User sovereignty** — The user always has final say before any state-mutating action.
2. **Configuration over hardcoding** — One YAML field controls strictness. No separate agent modes.
3. **Zero runtime dependencies** — All gate behavior is encoded as LLM-followed rules in Markdown/YAML. No code.
4. **Level 0 = unchanged** — Setting level 0 preserves the original behavior exactly.
5. **Deepveloper inherits, doesn't own** — The subtask agent never sets its own level.
