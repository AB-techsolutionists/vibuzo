---
description: Execute implementation tasks for a feature
agent: Vibuzo
subtask: true
---

Execute the implementation plan for feature: $1

1. Validate all three files exist:
   - `specs/$1/spec.md` — specification
   - `specs/$1/plan.md` — implementation plan
   - `specs/$1/tasks.md` — task breakdown
   If any are missing, report back and stop.

2. Read `tasks.md`. Identify execution order:
   - Tasks with no dependencies (start here)
   - Tasks marked `[P]` (can run in parallel)
   - Tasks depending on others (must wait)

3. Execute in dependency order:
   - Start with dependency-free tasks
   - Run `[P]` tasks in parallel where possible
   - Mark each task `[x]` on completion with timestamp
   - Validate each task against its acceptance criteria

4. If issues arise:
   - Fix minor issues and note the deviation
   - If blocked, report what's blocking and stop

5. Report: tasks completed / total, files changed, any deviations
