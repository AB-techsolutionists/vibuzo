---
title: agent-skills-meta-routing
date: 2026-06-15
tags:
  - agent-skills
  - routing
  - spec
  - deepviewer
  - integration
status: complete
---

# Agent-Skills Meta-Routing

*Session summary — 2026-06-15 | ~25 messages | 7 files touched | 1 commit*

## Session Summary

Researched the full addyosmani/agent-skills repository (24 skills) and performed a structured gap analysis against Vibuzo's existing capabilities. Mapped all 24 skills to Vibuzo equivalents, identifying 10 genuine gaps and 7 out-of-scope skills. Planned a 6-batch import sequence prioritizing the meta-skill routing first. Implemented Batch 0: imported the `using-agent-skills` meta-skill as dynamic routing into `agents/vibuzo.md` — enabling intent-based dispatch before explicit command matching. Created `context/standards/skill-routing-vibuzo.md` with a full 24-skill status table. Ran the full `/spec` pipeline including Deepviewer review with 3 remediation fixes. Version remains 0.0.17; one commit pushed to origin/main.

## Constraints & Preferences

- **Source over mirror:** Agent source files live in `agents/` — `.opencode/` mirrors are installer-managed copies, not canonical source. Only `agents/vibuzo.md` was modified, not `.opencode/` files.
- **Surgical routing import:** The meta-skill was inserted as a new section between Core Rules and Context Auto-Query — no existing content was restructured or removed.
- **agent-skills as reference, not replacement:** The addyosmani/agent-skills repo provided workflow patterns but Vibuzo's explicit subagent pipeline was preserved. The meta-skill routing flowchart was adapted to map to Vibuzo commands, not replace them.
- **Slot-based batching:** Remaining 9 skills organized into 5 batches (Batches 1-5), each representing one `/spec` session of work.

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Meta-skill as first dispatch layer** — Vibuzo now checks the routing flowchart before matching explicit commands | Enables natural language intent detection (user says "debug this" → recognized as debugging) without requiring slash commands, while preserving explicit command override |
| 2 | **6-batch import sequence** — Skills organized by dependency: routing first (Batch 0), then front-end (1), quality gates (2), TDD (3), performance (4), shipping standards (5) | Batches are sized for single-session implementation with review; each batch is independently mergeable |
| 3 | **🔲 status for not-yet-imported skills** — Unimported skills display as actionable offers ("Would you like me to import it?") rather than silent gaps | Gives the user a clear migration path without cluttering the agent file with unimplemented workflows |
| 4 | **Duplicated routing rules removed from agents/vibuzo.md** — The canonical rules live only in the context standard; the agent file keeps a concise summary + reference link | Prevents maintenance drift between two copies of the same rules |
| 5 | **"Implementing code" routes through /spec** — All code implementation requests go through the spec pipeline rather than directly to Deepveloper | Consistent with Core Rule 3; ensures research/spec/plan gates are never bypassed |

## Forward Context

- Working tree is clean — all changes committed and pushed to `5da37ec` on `origin/main`
- Version remains 0.0.17 (no bump this session)
- Batch 0 is complete; 5 batches remain (9 skills pending)
- The `context/standards/skill-routing-vibuzo.md` standard now auto-loads at session start, providing the full routing flowchart and status table to every new session
- The next session should start with Batch 1 (interview-me + idea-refine)

## Hot Files

| File | Why Hot |
|------|---------|
| `agents/vibuzo.md` | Just received skill routing section — next import (interview-me, idea-refine) may reference or extend this |
| `context/standards/skill-routing-vibuzo.md` | Status table will need updating as each batch is imported (🔲 → ✅) |
| `context/standards/interview-me.md` | To be created in Batch 1 |
| `context/standards/idea-refine.md` | To be created in Batch 1 |
| `commands/spec.md` | May need updating if Batch 3 (TDD) adds a test phase |

## Timeline Entry

| 2026-06-15 | 23:32 | `agent-skills-meta-routing` | Imported agent-skills meta-skill routing into Vibuzo; 24-skill gap analysis; 6-batch plan; Batch 0 complete |

## Session Compaction

````
╭─────── Session Compaction ───────────────────────────────────────╮
│                                                                   │
│  Session:    agent-skills-meta-routing                            │
│  Date:       2026-06-15                                           │
│  Messages:   ~25                                                  │
│                                                                   │
├─────── Goal ──────────────────────────────────────────────────────┤
│                                                                   │
│  • Import agent-skills meta-skill (using-agent-skills) as         │
│    Vibuzo's dynamic routing layer — enabling intent-based         │
│    dispatch without explicit slash commands                       │
│                                                                   │
├─────── Constraints & Preferences ─────────────────────────────────┤
│                                                                   │
│  • Source files in agents/, not .opencode/ (mirror is installer-  │
│    managed copy)                                                  │
│  • Never push without explicit approval (custom rule)             │
│  • agent-skills patterns imported as context standards, not       │
│    replacing Vibuzo's explicit pipeline                           │
│  • Surgical insert into agents/vibuzo.md — no existing content    │
│    restructured or removed                                        │
│  • Routing rules live canonically in the context standard only    │
│    (not duplicated in the agent file)                             │
│                                                                   │
├─────── Progress ──────────────────────────────────────────────────┤
│                                                                   │
│  Done:                                                            │
│  • Researched full addyosmani/agent-skills repo — all 24          │
│    skills analyzed                                               │
│  • Performed gap analysis: mapped all 24 skills to Vibuzo,       │
│    identified 10 gaps, 7 out-of-scope, 7 already covered         │
│  • Organized 10 gap skills into 6 batches with dependency         │
│    ordering (Batch 0-5)                                           │
│  • Created specs/meta-skill-routing/ via full /spec pipeline      │
│  • Imported meta-skill flowchart into agents/vibuzo.md (42        │
│    lines added)                                                    │
│  • Created context/standards/skill-routing-vibuzo.md (111         │
│    lines) with full 24-skill status table, routing rules          │
│  • Updated context/index.md with new standard listing             │
│  • Ran Deepviewer review (Stage 1 + Stage 2), fixed 3 issues     │
│  • Committed and pushed: 7 files, 445 insertions                  │
│                                                                   │
│  In Progress:                                                     │
│  • None                                                           │
│                                                                   │
│  Blocked:                                                         │
│  • None                                                           │
│                                                                   │
├─────── Key Decisions ─────────────────────────────────────────────┤
│                                                                   │
│  • Meta-skill becomes first dispatch layer before command         │
│    matching — enables natural language routing                    │
│  • Remaining skills batched by dependency: front-end (1),         │
│    quality gates (2), TDD (3), performance (4), shipping (5)      │
│  • Routing rules stored canonically only in context standard to   │
│    prevent maintenance drift                                      │
│  • "Implementing code" branch routes through /spec, not directly  │
│    to Deepveloper — consistent with Core Rule 3                   │
│  • Not-yet-imported skills shown as 🔲 with actionable import     │
│    offer, not silent gaps                                         │
│                                                                   │
├─────── Next Steps ────────────────────────────────────────────────┤
│                                                                   │
│  • Start Batch 1: import interview-me + idea-refine (front-end    │
│    skills that fire BEFORE /spec when user is vague)              │
│  • Each subsequent batch follows the same /spec pipeline pattern  │
│  • After all batches, update agents/vibuzo.md routing to ref-     │
│    lect all skills as ✅                                          │
│                                                                   │
├─────── Critical Context ──────────────────────────────────────────┤
│                                                                   │
│  • Git: working tree clean, up to date with origin/main           │
│  • Version: 0.0.17 on main                                        │
│  • Last commit: 5da37ec — "feat: add intent-based skill routing   │
│    from agent-skills meta-skill"                                  │
│  • New context standard auto-loads at session start:              │
│    skill-routing-vibuzo.md with full status table                 │
│  • 9 gap skills remain across 5 batches, all documented in        │
│    the status table with batch assignments                        │
│                                                                   │
├─────── Relevant Files ────────────────────────────────────────────┤
│                                                                   │
│  agents/vibuzo.md                  │ Routing section added        │
│  context/standards/skill-routing-  │ Full status table + rules    │
│    vibuzo.md                       │                              │
│  specs/meta-skill-routing/         │ /spec pipeline artifacts     │
│  context/index.md                  │ New standard listed          │
│                                                                   │
╰───────────────────────────────────────────────────────────────────╯
````

## Context Candidates

| # | Type | Name | Status |
|---|------|------|--------|
| 1 | pattern | `slot-based-skill-import.md` | ✅ Saved |
| 2 | standard | `canonical-rules-single-source.md` | ❌ Skipped |
| 3 | standard | `review-phase-mandatory-gate.md` | ✅ Saved |
