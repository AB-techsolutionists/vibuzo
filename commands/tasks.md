⚠️ **DEPRECATED** — Use `/spec <description>` instead. This file is kept for reference.

---

---
description: Break a plan into actionable tasks
---

Break down the feature plan into specific, actionable tasks.

Verify both `specs/$1/spec.md` and `specs/$1/plan.md` exist first. If either is missing, tell the user which to create first.

Read both files, then generate a task list where each task includes:

- **Description**: What specifically to implement
- **Files**: Exact file paths that will be created or modified
- **Dependencies**: Which tasks must be completed first (or "—" if none)
- **Parallel**: Mark with `[P]` if tasks can run simultaneously
- **Acceptance**: How to verify the task is done

Format:
```
- [ ] Task 1: Create user model [P]
  Files: src/models/user.ts
  Depends on: —
  Acceptance: Model has all required fields and validation

- [ ] Task 2: Create auth endpoint
  Files: src/routes/auth.ts
  Depends on: Task 1
  Acceptance: POST /auth/register returns 201
```

Write to `specs/$1/tasks.md`.
