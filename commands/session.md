---
description: Log, view, or list session activity
agent: Vibuzo
subtask: true
---

Manage session logs: $ARGUMENTS

Usage:
- `/session log <message>` — append to today's session log
- `/session view` — read recent session logs
- `/session list` — list all session logs

## /session log <message>
1. Create `context/sessions/` if it doesn't exist
2. Create or append to `context/sessions/YYYY-MM-DD.md` (today's date)
3. Add a new entry with timestamp: `- [HH:MM] <message>`
4. If this is the first entry for today, add a heading: `## YYYY-MM-DD`

## /session view
Read the most recent session log files (last 3) and present a summary.

## /session list
List all `.md` files in `context/sessions/` with their dates and first entry.

If no arguments, show the most recent session log as a quick status check.
