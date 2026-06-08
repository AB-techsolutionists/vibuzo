---
tags:
  - deepviewer
  - review
  - spec
  - pipeline
  - architecture
scope: Architecture decision for Deepviewer replacing generic reviewer in /spec pipeline Review phase
when: Understanding how the /spec Review phase works or why Deepviewer was chosen as the reviewer
---

# Deepviewer Review Phase

**Date:** 2026-06-08
**Status:** Active

## Context

The `/spec` pipeline's Review phase previously dispatched a "general" subagent to perform two-stage review (spec compliance + code quality). This worked but lacked deep codebase context — the generic agent had no pre-existing knowledge of the project's architecture, standards, patterns, or session history.

## Decision

Deepviewer — the codebase analysis agent — now owns the Review phase of the `/spec` pipeline. Both review stages delegate to Deepviewer via `task()` instead of a "general" subagent.

### Stage 1 — Spec Compliance Review

Deepviewer receives the spec document, plan, task breakdown, and all implemented file paths. It reads the spec requirements, reads the actual implementation files, and compares each piece of functionality against what was specified. Output: compliance status (✅ Pass / ❌ Fail) with specific file:line issues.

### Stage 2 — Code Quality Review

Deepviewer receives all implemented files. It checks structure, naming conventions, error handling, dead code, hardcoded secrets, and project pattern compliance. Output: quality status (✅ Approved / ❌ Changes Required) with the top 3 critical issues.

## Rationale

- Deepviewer's purpose is exhaustive codebase understanding — it reads every file, every session, every context file
- Reviewing implementation against spec is a natural fit for an agent that already knows the full codebase
- Eliminates the cold-start problem of generic reviewers that have no project context
- Consistent with the principle of specialization: each subagent has a well-defined domain

## Consequences

- The `/spec` pipeline structure (phases, gates, handoff format) remains unchanged — only the agent dispatched changes
- Both review stages preserve their original checklist instructions and output formats
- Deepviewer must be available as a subtask before the Review phase can execute
- The `commands/spec.md` file explicitly dispatches Deepviewer for both stages

## Related

- `context/standards/deepviewer-invocation-modes.md` — Deepviewer's three invocation modes including /spec Review
- `commands/spec.md` — The spec pipeline with Deepviewer review delegation
- `.opencode/agent/core/deepviewer.md` — Deepviewer agent definition
