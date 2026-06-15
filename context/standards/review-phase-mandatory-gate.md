---
tags:
  - spec
  - review
  - deepviewer
  - pipeline
  - quality
  - gate
scope: The Review phase in /spec is mandatory — Vibuzo must not skip or self-substitute Deepviewer review after implementation
when: Completing the Implementation phase in /spec pipeline
---

# Review Phase — Mandatory Gate

## Overview

After Deepveloper completes implementation in the `/spec` pipeline, Vibuzo **MUST** dispatch Deepviewer for both stages of review before considering the pipeline complete. Vibuzo may not self-verify by reading files — only Deepviewer performs review.

## The Rule

The Review phase is not optional. The pipeline is:

```
Implementation (Deepveloper)
    │
    ▼
Stage 1: Spec Compliance Review (Deepviewer) ← MANDATORY
    │
    ▼
Stage 2: Code Quality Review (Deepviewer) ← MANDATORY
    │
    ▼
Fix findings → Re-review if needed
    │
    ▼
Pipeline Complete
```

## What Vibuzo Must NOT Do

- Self-verify by reading implementation files and declaring the work done
- Skip the Review phase because "the changes look straightforward"
- Skip the Review phase because "the user didn't ask for it"
- Declare pipeline complete without Deepviewer review
- Treat Implementation → Pipeline Complete as a valid path

## Detection

If the user says "why didn't you review?" or equivalent, the pipeline has been violated. The correct response is to stop, acknowledge the skip, and run the review immediately.

## Rationale

Skipping review reintroduces the exact failure modes the pipeline was designed to prevent: unchecked assumptions, missed edge cases, quality drift, and architectural inconsistency. Deepviewer catches what Vibuzo's own reading misses because Vibuzo has been immersed in the implementation context and carries confirmation bias.
