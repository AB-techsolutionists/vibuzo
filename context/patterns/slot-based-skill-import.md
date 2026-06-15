---
tags:
  - integration
  - agent-skills
  - batching
  - workflow
  - import
scope: Pattern for importing external skill repositories in dependency-ordered batches, each sized for single-session /spec implementation with review
when: Importing multiple workflows from an external skill repository into Vibuzo
---

# Slot-Based Skill Import

## Overview

When importing multiple workflows from an external skill repository (e.g., addyosmani/agent-skills), organize them into dependency-ordered batches rather than importing all at once. Each batch is independently implementable and mergeable in a single `/spec` session with review.

## When to Use

- Importing 3+ workflows from an external skill repository
- The workflows have natural dependency ordering (routing before front-end, front-end before quality gates, etc.)
- You need to ship incrementally with review gates between each batch

## Batch Structure

### Dependency Ordering

Order batches so that earlier batches are prerequisites for later ones:

1. **Routing / Meta-skill** — The dispatch layer that determines which skill applies (must exist before skills are usable)
2. **Front-end skills** — Skills that fire before `/spec` when the user is vague (interview-me, idea-refine)
3. **Execution-time quality gates** — Skills that run during implementation (code-simplification, doubt-driven-dev, source-driven-dev)
4. **Test-driven development** — Structured TDD workflow (may need a new command or pipeline phase)
5. **Performance optimization** — Deepen an existing review axis
6. **Shipping standards** — Debugging, git workflow, documentation/ADRs

### Batch Characteristics

- **Size:** Each batch should contain 1-3 skills
- **Dependency:** Earlier batches are prerequisites for later ones
- **Independence:** Each batch is independently implementable and mergeable
- **Review:** Each batch goes through the full `/spec` pipeline including Deepviewer review
- **Scope:** No batch modifies files from another batch

## Status Tracking

Each batch's skills are tracked in a status table with these markers:

| Marker | Meaning |
|--------|---------|
| ✅ | Imported and wired into Vibuzo |
| 🔲 | Identified as gap — not yet imported |
| Partial | Partially implemented (some aspects exist, full workflow does not) |
| N/A | Out of scope for Vibuzo |

The status table lives in `context/standards/skill-routing-vibuzo.md` and is updated as each batch completes.

## Implementation Process

```
For each batch:
1. Present plan to user with the specific skills and batch rationale
2. Get approval before starting implementation
3. Run /spec pipeline for the batch feature
4. Ensure Deepviewer review runs (Stage 1 + Stage 2)
5. Fix any review findings
6. Update the status table in skill-routing-vibuzo.md
7. Commit and push
8. Proceed to next batch
```

## Verification

- [ ] Each batch is independently implementable (no cross-batch file dependencies)
- [ ] Status table is updated after each batch
- [ ] Each batch has been through full /spec pipeline with review
- [ ] User has approved each batch before implementation
