---
tags:
  - routing
  - skills
  - meta-skill
  - agent-skills
  - dispatch
scope: Dynamic skill routing flowchart for Vibuzo — maps user intent to the appropriate workflow (command or skill import gap)
when: At session start, before processing any user message, to determine which skill or command applies
---

# Skill Routing — Vibuzo

## Overview

Adapted from [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) `using-agent-skills` meta-skill. This flowchart enables Vibuzo to determine user intent from natural language and route to the appropriate workflow without requiring explicit slash commands.

The flowchart is the **first dispatch layer** — checked before explicit command matching. If no branch matches, Vibuzo falls through to normal processing (questions, analysis, conversation).

## Routing Flowchart

```
Task arrives
    │
    ├── Unsure what you want / "interview me" / "grill me"
    │   ────────────────────────────────────────→ interview-me (✅ Batch 1)

    ├── Have a rough concept / "refine this idea" / "ideate"
    │   ────────────────────────────────────────→ idea-refine (✅ Batch 1)
    │
    ├── New feature or change / "write a spec"
    │   ────────────────────────────────────────→ /spec
    │
    ├── Implementing code
    │   ├── Normal implementation ─────────────→ Delegate to Deepveloper
    │   ├── Need doc-verified code ────────────→ source-driven-dev (🔲 Batch 2)
    │   └── High stakes / unfamiliar code ─────→ doubt-driven-dev (🔲 Batch 2)
    │
    ├── Writing or running tests / "test this"
    │   ────────────────────────────────────────→ TDD skill (🔲 Batch 3)
    │
    ├── Something broke / "debug this" / error
    │   ────────────────────────────────────────→ debugging skill (🔲 Batch 5)
    │
    ├── Reviewing code / "review this"
    │   ────────────────────────────────────────→ @deepviewer or /deepviewer
    │   ├── Too complex / "simplify this" ──────→ code-simplification (🔲 Batch 2)
    │   ├── Security concerns ─────────────────→ Security axis (✅)
    │   └── Performance concerns ──────────────→ Performance optimization (🔲 Batch 4)
    │
    ├── Need research on a topic
    │   ────────────────────────────────────────→ /research or @deepsearcher
    │
    ├── Need session context / summary
    │   ────────────────────────────────────────→ /session or /session-init
    │
    ├── Committing or branching / "commit this"
    │   ────────────────────────────────────────→ git workflow skill (🔲 Batch 5)
    │
    ├── Writing docs or ADRs
    │   ────────────────────────────────────────→ /add-context or manual
    │
    └── Shipping or deploying
        ────────────────────────────────────────→ not implemented
```

## Skill Status Table

| # | Skill | Vibuzo Equivalent | Status | Batch |
|---|-------|-------------------|--------|-------|
| 1 | using-agent-skills (meta) | This file | ✅ | 0 |
| 2 | interview-me | Load context/standards/interview-me.md | ✅ | 1 |
| 3 | idea-refine | Load context/standards/idea-refine.md | ✅ | 1 |
| 4 | spec-driven-development | /spec command | ✅ | — |
| 5 | planning-and-task-breakdown | /spec Plan phase | ✅ | — |
| 6 | incremental-implementation | Deepveloper subagent | ✅ | — |
| 7 | test-driven-development | Not yet imported | 🔲 | 3 |
| 8 | code-review-and-quality | Deepviewer five-axis | ✅ | 0 (prev session) |
| 9 | security-and-hardening | Deepviewer Security axis | ✅ | 0 (prev session) |
| 10 | performance-optimization | Not yet imported | 🔲 | 4 |
| 11 | code-simplification | Not yet imported (partial: Karpathy Principle) | 🔲 | 2 |
| 12 | debugging-and-error-recovery | Not yet imported | 🔲 | 5 |
| 13 | git-workflow-and-versioning | Custom push rules only | 🔲 | 5 |
| 14 | ci-cd-and-automation | Out of scope | N/A | — |
| 15 | frontend-ui-engineering | Out of scope | N/A | — |
| 16 | api-and-interface-design | Out of scope | N/A | — |
| 17 | browser-testing-with-devtools | Out of scope | N/A | — |
| 18 | context-engineering | /session-init + auto-query | Partial | — |
| 19 | source-driven-development | Not yet imported | 🔲 | 2 |
| 20 | doubt-driven-development | Not yet imported (partial: Karpathy Principle) | 🔲 | 2 |
| 21 | documentation-and-adrs | /add-context + manual | Partial | 5 |
| 22 | deprecation-and-migration | Out of scope | N/A | — |
| 23 | observability-and-instrumentation | Out of scope | N/A | — |
| 24 | shipping-and-launch | Out of scope | N/A | — |

## Routing Rules

1. **Flowchart is first dispatch** — scan user message against flowchart branches before matching explicit command syntax.
2. **Explicit commands override** — if the user types /spec, @deepviewer, or any known command, route directly. Do NOT flowchart-interpret command invocations.
3. **🔲 status handling** — if a flowchart branch matches but the skill is not yet imported, respond: "I recognize you need [skill], but I haven't imported that workflow yet. Would you like me to import it?" Then offer to run the import batch.
4. **✅ status handling** — route to the indicated command or agent directly.
5. **No match** — fall through to normal processing (question answering, analysis, conversation).
6. **One check per turn** — check the flowchart against the user's first message in a turn. Do not re-route mid-turn.

## Implementation Rules for Vibuzo

1. The routing flowchart is checked against the user's **first message in a turn**.
2. Do NOT re-route mid-conversation unless the user changes topic significantly.
3. For skills not yet imported (🔲), always ask: "Would you like me to import this skill?" — do not silently skip.
4. When a skill is partially implemented, note what exists and what's missing.
5. The context standard auto-loads at session start — the flowchart should be fresh in working memory.
