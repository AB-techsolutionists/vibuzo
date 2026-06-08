---
tags:
  - session
  - workflow
  - compaction
  - golden-path
  - lifecycle
scope: Session management lifecycle with auto-generated compaction
when: Managing session lifecycle or running /session
---

# Session Workflow: `/session → /new`

A reliable pattern for preserving session state across sessions using the auto-generated Session Compaction block in every session file.

## The Golden Workflow

```
1. Work on a feature / task
2. At a natural breakpoint → run `/session` (creates session file with auto-generated Session Compaction)
3. `/new` — start a fresh session
4. Copy the Session Compaction block (the full styled box) and paste as starting context
```

## Why This Order

| Step | What happens | Why it matters |
|------|-------------|----------------|
| `/session` first | Captures full conversation into `context/sessions/YYYY-MM-DD-<title>.md` + auto-generates Session Compaction | Everything saved — narrative, decisions, state, and compact starting context |
| `/new` second | Starts a fresh session | Copy the Session Compaction block and paste as starting context |

## Trigger Points

Run `/session` at any of these moments:

- **After finishing a feature** — clean handoff before switching tasks
- **Before switching tasks** — avoids mixing unrelated work in one summary
- **When conversation feels long** — context window is filling up; capture before compaction
- **End of a work session / end of day** — permanent record of what was done
- **Always before `/compact`** — this is the hard rule

## Anti-Patterns

| Never Do This | Why |
|--------------|-----|
| `/compact` then `/session` | I've lost the conversation — timestamps become guesses, events get missed |
| `/session` twice without `/compact` in between | Overlap — both files cover the same conversation period |
| Skip `/session` and only use `/compact` | No persistent record survives beyond the current session |
| `/compact` without `/session` first | The conversation is truncated before it's captured — permanent data loss |

## Auto-Load Chain

When you open `/new`, the agent automatically:

```
AGENTS.md → context/index.md → sessions/index.md → latest session file
```

This means the agent knows the previous session's goal, decisions, pending work, and state — without you typing a single prompt. The Session Compaction block gives you the exact starting point.

## Origin

This workflow was established in `session-workflow-auto-load` (2026-06-06) and refined in `session-compaction` (2026-06-06) when the Session Compaction section was added to the session file template. It was further streamlined in `session-auto-compaction` (2026-06-08) when `/session` began auto-generating the compaction block — eliminating the manual `/compact` → paste step.
