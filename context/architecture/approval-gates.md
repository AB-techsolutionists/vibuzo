---
tags:
  - architecture
  - approval-gates
  - permissions
  - security
  - levels
scope: Approval gate configuration, levels, and behavior
when: Configuring approval levels or understanding gate behavior rules
---

# Approval Gates — Architecture Decision

## Date
2026-06-04 (updated 2026-06-09)

## Context
Users wanted full control over agent actions — the ability to review and approve file writes, commands, and task progression before they happen. The original custom approval gate system (levels 0-3) worked via chat prompts but was error-prone (formatting bugs, manual typing).

## Decision
Switch to a **hybrid gating model**:

### Native Permission Popups (Mechanical Actions)
Opencode's built-in `permission` system handles all mechanical actions with native Desktop popup dialogs (Approve/Reject buttons):
- File writes, edits, deletes
- Bash command execution
- Task/subagent delegation

Set `"*": "ask"` in agent frontmatter permission blocks to enable.

### Custom Chat Gates (Conceptual Actions)
Only 2 remaining custom gates, since opencode has no native equivalent:
1. **Plan approval** — before execution, Vibuzo presents the plan inline and asks for approval
2. **Push approval** — before pushing to GitHub (custom rule: never push without approval)

## Agent Permissions

### Vibuzo (Main Agent)
- `approval_level` removed from frontmatter — replaced by native `"*": "ask"` for all permission types
- Custom gates only for plan approval and push approval
- Rejection handling: modify/skip/abort options

### Sub-Agents (Deepveloper, Deepsearcher, Deepviewer)
- All set to `"*": "ask"` for bash, edit, write — native popups gate mechanical actions
- No inherited level system; each sub-agent's gating is independent via its own permissions
- Deepveloper additionally uses a simple chat gate for between-task progression ("Proceed to next task? (y/N)")

## Key Principles

1. **User sovereignty** — The user always has final say before any state-mutating action.
2. **Native over custom** — Use opencode's built-in permission dialogs where possible, avoiding fragile chat gates.
3. **Only the conceptual stays custom** — Planning approval and push approval have no native equivalent, so they remain as chat gates.
4. **Zero runtime dependencies** — All gate behavior is encoded as LLM-followed rules in Markdown/YAML. No code.
