# Session Workflow: `/session → /compact → paste into Session Compaction → /new`

A reliable pattern for preserving session state across compaction and new-session cycles using the Session Compaction placeholder in every session file.

## The Golden Workflow

```
1. Work on a feature / task
2. At a natural breakpoint → run `/session` (creates session file with Session Compaction placeholder)
3. Open the session file
4. Run `/compact` in opencode's TUI
5. Copy the compaction output
6. Paste it into the Session Compaction section (replace the placeholder text)
7. `/new` — start a fresh session, copy the Session Compaction block as starting context
```

## Why This Order

| Step | What happens | Why it matters |
|------|-------------|----------------|
| `/session` first | Captures full conversation into `context/sessions/YYYY-MM-DD-<title>.md` + presents context candidates | I have complete context — every request, decision, file change, and git state |
| `/compact` second | opencode's TUI command truncates conversation for the model, generates a compaction summary | Safe — everything is already saved to a persistent file |
| Paste into Session Compaction | The compaction output goes into the designated section | Next session will have a ready-made starting context block |
| `/new` fourth | Starts a fresh session | Copy the Session Compaction block and paste as starting context |

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

This means the agent knows the previous session's goal, decisions, pending work, and state — without you typing a single prompt. Pasting the Session Compaction block gives you the exact starting point.

## Origin

This workflow was established in `session-workflow-auto-load` (2026-06-06) and refined in `session-compaction` (2026-06-06) when the Session Compaction section was added to the session file template as a paste target for `/compact` output.
