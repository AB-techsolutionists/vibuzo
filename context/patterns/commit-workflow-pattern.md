# Commit Workflow Pattern

**Date:** 2026-06-07
**Status:** Active

## Problem

Commands that perform multiple state-mutating steps (file writes, git operations, version bumps) need a consistent workflow pattern that:
- Prevents partial or unintended changes
- Gives the user control over each mutation
- Never performs irreversible actions automatically
- Reports results clearly

## Solution

A **3-gate pipeline** with explicit no-push enforcement:

```
User invokes command
        │
        ▼
  ┌─────────────────────────┐
  │  Gate 1: Action Preview │  ← Shows what will change, pauses for approval
  │  → File mutations       │     "Approve? (y/N)"
  └─────────┬───────────────┘
            │ (approved)
            ▼
  ┌─────────────────────────┐
  │  Execute mutations      │  ← File writes, edits, calculations
  │  (no side effects)      │
  └─────────┬───────────────┘
            │
            ▼
  ┌─────────────────────────┐
  │  Gate 2: Commit Preview │  ← Shows full commit message, pauses for approval
  │  → git commit           │     "Approve commit? (y/N)"
  └─────────┬───────────────┘
            │ (approved)
            ▼
  ┌─────────────────────────┐
  │  git add + git commit   │  ← NO git push
  └─────────┬───────────────┘
            │
            ▼
  ┌─────────────────────────┐
  │  Gate 3: Report         │  ← Shows hash, changes, push instruction
  │  → "Push manually"      │     "git push"
  └─────────────────────────┘
```

## Key Rules

1. **Two approval gates minimum** — one before file mutations, one before git commit
2. **No automatic push** — the final step is always a report telling the user to push manually
3. **Clean cancellation** — any gate rejection prints a clear message (e.g., "Commit cancelled.") and stops immediately
4. **Transparent preview** — each gate shows exactly what will change, not just "are you sure?"
5. **Report box** — final output is a structured summary (commit hash, files changed, version, push command)

## When to Use

This pattern is appropriate for any command that:
- Modifies source-controlled files
- Performs irreversible git operations
- Requires user review before execution
- Should never auto-push

## Example: `/commit` Command

The `commands/commit.md` file implements this exact pattern:
- **Step 5**: Gate 1 — bump approval (old→new version shown)
- **Step 11**: Gate 2 — commit approval (full message shown)
- **Step 12**: `git add` + `git commit` (no push)
- **Step 13**: Report box with hash, version, push instruction

## Related

- [`commands/commit.md`](../../commands/commit.md) — The `/commit` command implementing this pattern
- [`architecture/approval-gates.md`](../architecture/approval-gates.md) — The approval gate infrastructure
- [`standards/structured-commit-body-convention.md`](../standards/structured-commit-body-convention.md) — Commit body format used in the commit gate
