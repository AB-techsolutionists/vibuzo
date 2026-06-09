---
title: approval-gate-refactor
date: 2026-06-09
tags:
  - approval-gates
  - permissions
  - agents
  - architecture
  - refactoring
status: complete
---

# Approval Gate Refactor

*Session summary — 2026-06-09 | ~15 messages | 11 files touched | 0 commits*

## Session Summary

Refactored Vibuzo's approval system from a custom chat-based gate model (`approval_level: 3` with manual y/N prompts) to a hybrid model using opencode's native permission popups (Desktop Approve/Reject buttons). Changed all 4 agent files (Vibuzo, Deepveloper, Deepsearcher, Deepviewer) from `"*": "allow"` to `"*": "ask"` in both source (`agents/`) and mirror (`.opencode/agent/core/`) directories. Removed `approval_level` from Vibuzo's frontmatter and stripped verbose Approval Gates sections from all sub-agents. Slimmed Vibuzo's own gates to only 3 conceptual actions (plan approval, push approval, rejection handling). Updated the architecture ADR and AGENTS.md to reflect the new model. User declined adding a runtime level override back.

## Constraints & Preferences

- **Native over custom:** opencode's permission system handles mechanical gating (file ops, commands, tasks) — no more chat-based approval prompts for these.
- **Custom only where necessary:** Plan approval and push approval have no native equivalent, so they stay as chat gates.
- **Never push without approval:** Custom rule remains — push is gated via chat gate.

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Hybrid gating model adopted** — native popups for mechanical actions, custom chat gates for conceptual (plan/push) | Open code's permission system provides native Desktop dialogs (Approve/Reject buttons) — more reliable and less error-prone than manual chat prompts |
| 2 | **No runtime level override** — `"*": "ask"` is static; user declined adding a dynamic "at gate level X" feature back | Simpler to maintain; native permissions are always "ask" for all mechanical actions |

## Forward Context

- Working tree is dirty — 9 agent files modified, ADR and AGENTS.md updated, nothing committed or pushed.
- The architecture ADR at `context/architecture/approval-gates.md` was rewritten to reflect the hybrid model — old level definitions removed.
- Sub-agents no longer inherit a gate level from Vibuzo; each has its own independent `ask` permission block.
- After restarting opencode, users will see native Desktop popups instead of chat approval boxes.

## Hot Files

| File | Why Hot |
|------|---------|
| `agents/vibuzo.md` | Core refactored agent — verify on next session that native popups + custom gates work as expected |
| `.opencode/agent/core/vibuzo.md` | Mirror copy — opencode reads this; restart required to pick up changes |
| `context/architecture/approval-gates.md` | ADR updated — reference for the new hybrid model |
| `AGENTS.md` | Updated references to approval model |

## Timeline Entry

| 2026-06-09 | 11:23 | `approval-gate-refactor` | Refactored approval gates from custom chat-level system to hybrid model: native opencode permission popups (ask) for mechanical actions, slimmed custom gates for plan/push only |

## Session Compaction

```
╭─────── Session Compaction ────────────────────────────────────────╮
│                                                                   │
│  Session:    approval-gate-refactor                               │
│  Date:       2026-06-09                                           │
│  Messages:   ~15                                                  │
│                                                                   │
├─────── Goal ──────────────────────────────────────────────────────┤
│                                                                   │
│  • Replace custom chat-based approval gates (approval_level +     │
│    manual y/N prompts) with native opencode Desktop popups        │
│                                                                   │
├─────── Constraints & Preferences ─────────────────────────────────┤
│                                                                   │
│  • Native over custom — use opencode's built-in permission        │
│    dialogs where possible                                         │
│  • Custom only for plan approval and push approval (no native     │
│    equivalent)                                                    │
│  • Never push without approval (custom rule)                      │
│                                                                   │
├─────── Progress ──────────────────────────────────────────────────┤
│                                                                   │
│  Done:                                                            │
│  • Changed all agent permissions "*": "allow" → "*": "ask"        │
│  • Removed approval_level from Vibuzo frontmatter                 │
│  • Replaced verbose Approval Gates sections with slim Gating      │
│    sections on all sub-agents                                     │
│  • Slimmed Vibuzo's Approval Gates to 3 conceptual gates          │
│    (plan, push, rejection handling)                               │
│  • Updated architecture ADR (context/architecture/approval-       │
│    gates.md) for hybrid model                                     │
│  • Updated AGENTS.md references                                   │
│  • Applied same changes to all 4 mirror files in                  │
│    .opencode/agent/core/                                          │
│                                                                   │
│  In Progress:                                                     │
│  • (none)                                                         │
│                                                                   │
│  Blocked:                                                         │
│  • (none)                                                         │
│                                                                   │
├─────── Key Decisions ─────────────────────────────────────────────┤
│                                                                   │
│  • Hybrid gating: native popups for mechanical, chat for          │
│    conceptual                                                     │
│  • No runtime level override — user declined adding it back       │
│  • Sub-agents have independent permission blocks (no inheritance) │
│                                                                   │
├─────── Next Steps ────────────────────────────────────────────────┤
│                                                                   │
│  • Restart opencode to load new permissions                       │
│  • Verify native popups appear on the next write/command/task     │
│  • Optionally commit and push the refactored files                │
│                                                                   │
├─────── Critical Context ──────────────────────────────────────────┤
│                                                                   │
│  • Git: working tree dirty — 9 files modified, 0 committed        │
│  • Version: 0.3.3 (current, from earlier bump)                    │
│  • Opencode restart required — agent permissions are read at      │
│    session start                                                  │
│  • The old approval_level system is fully removed; users will     │
│    get native Desktop popups on every gated action                │
│                                                                   │
├─────── Relevant Files ────────────────────────────────────────────┤
│                                                                   │
│  agents/vibuzo.md                    │ allow→ask, no approval_lvl │
│  agents/deepveloper.md               │ allow→ask, gating section  │
│  agents/deepsearcher.md              │ allow→ask, gating section  │
│  .opencode/agent/core/deepviewer.md  │ allow→ask, gating section  │
│  .opencode/agent/core/vibuzo.md      │ Mirror of vibuzo.md        │
│  context/architecture/approval-      │ ADR rewritten for hybrid   │
│   gates.md                           │ model                      │
│  AGENTS.md                           │ Updated references         │
│                                                                   │
╰───────────────────────────────────────────────────────────────────╯
```
