# Session Workflow: `/session → /compact → /new`

A reliable pattern for preserving session state across compaction and new-session cycles without data loss or overlap.

## The Golden Workflow

```
1. Work on a feature / task
2. At a natural breakpoint → run `/session`
3. Then run opencode's native `/compact`
4. Then run `/new` to start a fresh session
```

## Why This Order

| Step | What happens | Why it matters |
|------|-------------|----------------|
| `/session` first | Captures full conversation into `context/sessions/YYYY-MM-DD-<title>.md` | I have complete context — every request, decision, file change, and git state |
| `/compact` second | Truncates the conversation for the model | Safe — everything is already saved to a persistent file |
| `/new` third | Starts a fresh session | Auto-load chain reads the latest session file → agent knows previous state without prompting |

## Trigger Points

Run `/session` at any of these moments:

- **After finishing a feature** — clean handoff before switching tasks
- **Before switching tasks** — avoids mixing unrelated work in one summary
- **When conversation feels long** — context window is filling up; capture before compaction
- **End of a work session / end of day** — permanent record of what was done
- **Always before opencode's `/compact`** — this is the hard rule

## Anti-Patterns

| Never Do This | Why |
|--------------|-----|
| `/compact` then `/session` | I've lost the conversation — timestamps become guesses, events get missed |
| `/session` twice without `/compact` in between | Overlap — both files cover the same conversation period |
| Skip `/session` and only use `/compact` | No persistent record survives beyond the current session |

## Auto-Load Chain

When you open `/new`, the agent automatically:

```
AGENTS.md → context/index.md → sessions/index.md → latest session file
```

This means the agent knows the previous session's goal, decisions, pending work, and state — without you typing a single prompt.

## Origin

This workflow was established in `session-workflow-auto-load` (2026-06-06) after discovering that mid-session checkpoints (`/session` without preceding `/compact`) produced overlapping summary files with duplicate coverage.
