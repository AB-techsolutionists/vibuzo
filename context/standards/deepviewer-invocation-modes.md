---
tags:
  - deepviewer
  - audit
  - invocation-modes
  - subagent
  - review
scope: Using Deepviewer for codebase analysis and pipeline review
when: Deciding how to invoke Deepviewer or documenting its invocation behavior
---

# Deepviewer Invocation Modes

**Date:** 2026-06-08
**Status:** Active

Deepviewer has three distinct invocation modes, each with different file-creation and reporting behavior.

## The Three Modes

| Mode | Spawns Subtask? | Creates File? | Reports To |
|------|----------------|---------------|------------|
| `/deepviewer audit` | ✅ Deepviewer | ✅ `context/reports/audit-report-YYYY-MM-DD.md` | Vibuzo → main session |
| `@deepviewer <query>` | ✅ Deepviewer | ❌ No | Vibuzo → main session |
| `/spec` Review phase | ✅ Deepviewer | ❌ No (pipeline generates review.md) | Vibuzo → /spec pipeline |

### `/deepviewer audit` — Full Codebase Audit

- Invoked via `/deepviewer audit` or `/deepviewer` with no arguments
- Deepviewer spawns as subtask, runs the full 5-phase pipeline (Structural Scan → Pattern Analysis → Session/Context Cross-Reference → Git History → Report Generation)
- Saves the complete audit report to `context/reports/audit-report-YYYY-MM-DD.md`
- Reports findings summary back to Vibuzo

### `@deepviewer` — Inline Ad-Hoc Codebase Question

- Invoked directly in conversation via `@deepviewer <question>`
- Deepviewer spawns as subtask, determines question scope (specific file, module, cross-cutting, history, pattern), runs targeted analysis
- Returns answer in chat — **no file created**
- Useful for quick questions about codebase structure, history, specific files, or patterns

### `/spec` Review Phase — Pipeline Integration

- Invoked by the `/spec` pipeline during the ## Review phase
- Deepviewer receives the spec document, plan, tasks, and implemented file paths as context
- Performs two-stage review: Stage 1 (Spec Compliance) → Stage 2 (Code Quality)
- Returns structured output in the format expected by the /spec pipeline
- **No file created** — results go back to the pipeline, which handles report saving

## Rules

1. **Only `/deepviewer audit` creates files** — the other two modes always report in chat/back to pipeline without writing to disk
2. **`@deepviewer` never creates a report file** — its purpose is targeted answers, not persistent documentation
3. **`/spec` Review phase follows pipeline structure** — the review output format is dictated by the spec pipeline, not Deepviewer's standalone template
4. **Each invocation is stateless** — Deepviewer does not cache results between invocations
