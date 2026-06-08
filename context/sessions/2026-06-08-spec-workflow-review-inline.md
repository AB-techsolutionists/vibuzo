---
title: spec-workflow-review-inline
date: 2026-06-08
tags:
  - spec
  - commands
  - agent
  - sessions
  - pipeline
status: complete
---

# Spec Workflow Review Inline

*Session summary — 2026-06-08 | ~15 messages | 14 files touched | 0 commits*

## Session Summary

Started with session-init cleanup: removed directory scaffolding requirement, switched to AGENTS.md loading, renamed header to "Session Initialized". Then investigated and ran the full `/spec` pipeline for `spec-workflow-enhancement` — researched its origin (from 5-repo research in context-system-enhancement session), then implemented multiple pipeline refinements: removed phase numbering, swapped Research before Briefing so Briefing is a research-driven debrief, moved two-stage review (spec compliance + code quality) from per-task into the Review phase, and inlined both reviewer prompts into the spec command definition. Deleted the `prompts/reviewers/` directory — the spec command is now fully self-contained.

## Constraints & Preferences

- **Inline over external:** Reviewer prompts must be embedded directly in the command definition, not stored in separate prompt files. Self-containment over modularity for command definitions.
- **Research before design:** The Briefing phase in `/spec` must come after Research so it's grounded in actual data, not upfront speculation.
- **No phase numbering:** Pipeline phases are named (Research, Briefing, Spec, Plan, Tasks, Implement, Review, Done) without numeric prefixes.
- **Review centralized:** Both spec compliance and code quality review stages belong in the Review phase, not per-task.

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Reviewer prompts inlined** — spec-reviewer-prompt.md and quality-reviewer-prompt.md deleted; instructions embedded as blockquotes in Review section of commands/spec.md | Self-contained commands eliminate drift between prompt files and command logic; no separate prompts directory to maintain |
| 2 | **Research before Briefing** — flipped phase order so research findings drive the briefing content | Prevents speculative briefing that research later contradicts; briefing becomes a research-driven debrief |
| 3 | **Two-stage review in Review phase** — per-task review removed; single two-stage review (compliance → quality) runs at the end | Reduces pipeline disruption; reviewers compare final implementation against spec holistically rather than piecemeal |
| 4 | **Session-init is discovery-only** — no directory scaffolding, no directory argument required, loads AGENTS.md | Session-init should report what exists, not create structure; scaffolding is /context init's job |

## Forward Context

- The `/spec` pipeline for `spec-workflow-enhancement` completed successfully with all 5 artifacts (research, spec, plan, tasks, review) — but NO commit was made. The changes to `commands/spec.md` are ready to be committed.
- The `prompts/reviewers/` directory was deleted entirely — nothing should re-create external prompt files for reviewer instructions going forward.
- When the next feature is spec'd, the new pipeline structure (no phase numbers, Research before Briefing, centralized two-stage review with inline prompts) should be followed as the standard.

## Hot Files

| File | Why Hot |
|------|---------|
| `commands/spec.md` | Core pipeline command — just got restructured; next /spec run will verify the new flow works end-to-end |
| `.opencode/commands/spec.md` | Mirror of commands/spec.md — must stay in sync |
| `context/sessions/2026-06-08-spec-workflow-review-inline.md` | This session file — will be read at next session start via auto-load chain |

## Timeline Entry

| 2026-06-08 | 13:58 | `spec-workflow-review-inline` | Restructured spec pipeline (no phase nums, Research before Briefing, inline two-stage review), cleaned up session-init command |

## Session Compaction

```
╭─────── Session Compaction ───────────────────────────────────────╮
│                                                                   │
│  Session:    spec-workflow-review-inline                          │
│  Date:       2026-06-08                                           │
│  Messages:   ~15                                                  │
│  Commit:     none (working tree dirty)                            │
│                                                                   │
├─────── Chronological Log ─────────────────────────────────────────┤
│                                                                   │
│  1. Session-init cleanup — removed directory scaffolding          │
│     requirement, switched to AGENTS.md loading, renamed header    │
│     to "Session Initialized" (commands/session-init.md)           │
│                                                                   │
│  2. Investigated /spec pipeline origin — traced spec-workflow-    │
│     enhancement back to context-system-enhancement session        │
│                                                                   │
│  3. Full /spec run for spec-workflow-enhancement — generated      │
│     5 artifacts (research, spec, plan, tasks, review)             │
│                                                                   │
│  4. Removed phase numbering from pipeline (commands/spec.md)      │
│     • Phases go from "Phase 1: Research" → "Research"             │
│                                                                   │
│  5. Swapped Research before Briefing phase order                  │
│     • Briefing is now a research-driven debrief                   │
│     • Prevents speculative direction before research              │
│                                                                   │
│  6. Moved two-stage review from per-task to Review phase          │
│     • Spec compliance + code quality both in final Review         │
│     • Reduced pipeline disruption                                 │
│                                                                   │
│  7. Inlined both reviewer prompts into commands/spec.md           │
│     • Deleted prompts/reviewers/ directory                        │
│     • Prompts embedded as blockquotes in Review section           │
│                                                                   │
│  8. Updated session-init pattern in context/ (10 lines changed)   │
│                                                                   │
│  9. Ran /session — created this session file                      │
│                                                                   │
│  10. Pattern detection — saved 2 standards:                       │
│      • reviewer-prompt-inlining.md                                │
│      • research-briefing-phase-order.md                           │
│                                                                   │
│  11. Index updated in context/index.md (+2 entries)               │
│                                                                   │
├─────── File Manifest ─────────────────────────────────────────────┤
│                                                                   │
│  MODIFIED (5):                                                    │
│    commands/session-init.md          │ +11 -10  │                │
│    commands/spec.md                  │ +125 -13 │                │
│    context/index.md                  │ +2 -0    │                │
│    context/patterns/session-init-    │ +5 -5    │                │
│      pattern.md                      │          │                │
│    context/sessions/index.md         │ +1 -0    │                │
│                                                                   │
│  CREATED (4):                                                     │
│    context/sessions/2026-06-08-                                    │
│      spec-workflow-review-inline.md  │ new       │                │
│    context/standards/reviewer-       │ new       │                │
│      prompt-inlining.md              │           │                │
│    context/standards/research-       │ new       │                │
│      briefing-phase-order.md         │           │                │
│    specs/spec-workflow-enhancement/  │ 5 files   │                │
│      {research,spec,plan,tasks,      │           │                │
│       review}.md                     │           │                │
│                                                                   │
│  DELETED (3):                                                     │
│    prompts/reviewers/spec-           │ deleted   │                │
│      reviewer-prompt.md              │           │                │
│    prompts/reviewers/quality-        │ deleted   │                │
│      reviewer-prompt.md              │           │                │
│    prompts/reviewers/                │ rmdir     │                │
│                                                                   │
│  Total: 12 files touched (5 modified, 4 created, 3 deleted)      │
│                                                                   │
├─────── Commands Invoked ──────────────────────────────────────────┤
│                                                                   │
│  bash (7):                                                        │
│    • git log --oneline -10                                        │
│    • git status --short                                           │
│    • git diff --name-only                                         │
│    • Get-ChildItem -Name                                          │
│      specs/spec-workflow-enhancement/                             │
│    • Get-ChildItem -Name prompts/reviewers/                       │
│    • git show HEAD:prompts/reviewers/spec-reviewer-prompt.md      │
│    • git show HEAD:prompts/reviewers/quality-reviewer-prompt.md   │
│                                                                   │
│  read (10+):                                                      │
│    • commands/spec.md (multiple reads)                            │
│    • commands/session-init.md (multiple reads)                    │
│    • commands/research.md                                         │
│    • .opencode/commands/*.md (all 6 command files)                │
│    • context/patterns/session-init-pattern.md                     │
│    • context/sessions/index.md                                    │
│    • context/index.md                                             │
│    • .opencode/agent/core/vibuzo.md                               │
│    • .opencode/agent/core/deepveloper.md                          │
│    • AGENTS.md                                                    │
│                                                                   │
│  edit (9):                                                        │
│    • commands/spec.md × 4 (phase nums, Research before Briefing,  │
│      review consolidation, inline prompts)                        │
│    • commands/session-init.md × 2 (AGENTS.md loading, header)     │
│    • context/patterns/session-init-pattern.md × 1                 │
│    • context/index.md × 1                                         │
│    • .opencode/commands/spec.md   × 1 (sync)                      │
│                                                                   │
│  write (4):                                                       │
│    • context/sessions/2026-06-08-spec-workflow-review-inline.md   │
│    • context/standards/reviewer-prompt-inlining.md                │
│    • context/standards/research-briefing-phase-order.md           │
│    • context/sessions/index.md (auto-updated by /session)         │
│                                                                   │
│  glob + grep (3):                                                 │
│    • Glob for specs/spec-workflow-enhancement/*                   │
│    • Glob for prompts/reviewers/*                                 │
│    • Grep for "research" in commands/spec.md                      │
│                                                                   │
│  Commands (internal):                                             │
│    • /session (generated this file)                               │
│    • /spec spec-workflow-enhancement (pipeline run)               │
│                                                                   │
├─────── Git State ─────────────────────────────────────────────────┤
│                                                                   │
│  Branch:    main (implicit)                                       │
│  HEAD:      36bcefc feat: split session command into standalone   │
│             files (session.md + session-init.md), update docs,    │
│             and bump version to 0.3.0                             │
│  Status:    ⚠️  Working tree dirty                                │
│  Modified:  5 files                                               │
│  Untracked: 7 items (session file, 2 standards, specs directory)  │
│  Insertions: 144                                                   │
│  Deletions:  28                                                   │
│  Uncommitted: yes — changes to spec.md, session-init.md,          │
│               index.md, session-init-pattern.md, sessions/index.md│
│                                                                   │
│  Changes not staged:                                              │
│    +125 -13  commands/spec.md                                     │
│    +11 -10   commands/session-init.md                             │
│    +5 -5     context/patterns/session-init-pattern.md             │
│    +2 -0     context/index.md                                     │
│    +1 -0     context/sessions/index.md                            │
│                                                                   │
│  Untracked:                                                        │
│    ?? context/sessions/2026-06-08-spec-workflow-review-inline.md  │
│    ?? context/standards/research-briefing-phase-order.md          │
│    ?? context/standards/reviewer-prompt-inlining.md               │
│    ?? specs/spec-workflow-enhancement/ (5 artifacts)              │
│                                                                   │
╰───────────────────────────────────────────────────────────────────╯
```

## Patterns Detected

| Candidate | File | Status |
|-----------|------|--------|
| Reviewer prompt inlining standard | `context/standards/reviewer-prompt-inlining.md` | ✅ Saved |
| Research-briefing phase order standard | `context/standards/research-briefing-phase-order.md` | ✅ Saved |
