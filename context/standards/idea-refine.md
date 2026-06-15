---
tags:
  - protocol
  - ideation
  - refinement
  - divergent-convergent
scope: Divergent→convergent thinking framework for refining raw ideas into actionable concepts — fires before /spec when the user has a rough concept
when: The user says "refine this idea" / "ideate" / "stress-test my plan", or has a rough concept that needs shaping before spec writing
---

# Idea-Refine Protocol

## Overview

Raw ideas are fragile — they either get committed to too early (before their flaws are visible) or never get committed to at all (because they never sharpened into something actionable). This standard turns raw ideas into sharp, actionable concepts through structured divergent and convergent thinking.

The output is a markdown one-pager that feeds directly into `/spec`. Use this when the user has a rough concept but no clear direction yet.

## Phase 1: Understand & Expand (Divergent)

**Goal:** Take the raw idea and open it up.

1. **Restate the idea** as a crisp "How Might We" problem statement. This forces clarity on what's actually being solved.

2. **Ask 3-5 sharpening questions** — focus on: who is this for specifically? What does success look like? What are the real constraints (time, tech, resources)? What's been tried before? Why now?

3. **Generate 5-8 idea variations** using these lenses:
   - **Inversion** — "What if we did the opposite?"
   - **Constraint removal** — "What if budget/time/tech weren't factors?"
   - **Audience shift** — "What if this were for a different user?"
   - **Combination** — "What if we merged this with an adjacent idea?"
   - **Simplification** — "What's the version that's 10x simpler?"
   - **10x version** — "What would this look like at massive scale?"
   - **Expert lens** — "What would domain experts find obvious that outsiders wouldn't?"

Quality over quantity. 5-8 well-considered variations beat 20 shallow ones.

## Phase 2: Evaluate & Converge

After the user reacts to Phase 1, shift to convergent mode:

1. **Cluster** the ideas that resonated into 2-3 distinct directions, each meaningfully different.

2. **Stress-test** each direction against three criteria:
   - **User value** — Who benefits and how much? Painkiller or vitamin?
   - **Feasibility** — What's the technical and resource cost? What's the hardest part?
   - **Differentiation** — What makes this genuinely different? Would someone switch from their current solution?

3. **Surface hidden assumptions.** For each direction, explicitly name what you're betting is true (but haven't validated), what could kill this idea, and what you're choosing to ignore (and why that's okay for now).

**Be honest, not supportive.** If an idea is weak, say so with kindness. A good ideation partner is not a yes-machine.

## Phase 3: Sharpen & Ship

Produce a concrete artifact — a markdown one-pager:

```
# [Idea Name]

## Problem Statement
[One-sentence "How Might We" framing]

## Recommended Direction
[The chosen direction and why — 2-3 paragraphs max]

## Key Assumptions to Validate
- [Assumption 1 — how to test it]
- [Assumption 2 — how to test it]

## MVP Scope
[The minimum version that tests the core assumption]

## Not Doing (and Why)
- [Thing 1] — [reason]
- [Thing 2] — [reason]

## Open Questions
- [Question that needs answering before building]
```

The "Not Doing" list is arguably the most valuable part — focus is about saying no to good ideas. Make trade-offs explicit. Ask the user if they'd like to save this to `docs/ideas/[idea-name].md`. Only save if they confirm.

## Anti-Patterns

1. Generating 20+ shallow variations instead of 5-8 well-considered ones
2. Skipping the "who is this for" question — every good idea starts with a person and their problem
3. No assumptions surfaced before committing to a direction (untested assumptions are the #1 killer)
4. Yes-machining weak ideas instead of pushing back with specificity
5. Producing a plan without a "Not Doing" list
6. Jumping straight to Phase 3 output without running Phases 1 and 2

## Verification Checklist

- [ ] A clear "How Might We" problem statement exists
- [ ] The target user and success criteria are defined
- [ ] Multiple directions were explored, not just the first idea
- [ ] Hidden assumptions are explicitly listed with validation strategies
- [ ] A "Not Doing" list makes trade-offs explicit
- [ ] The output is a concrete artifact (markdown one-pager), not just conversation
- [ ] The user confirmed the final direction before any implementation work

## Wiring into Vibuzo

This standard fires when the routing flowchart in `agents/vibuzo.md` matches "idea-refine". The agent loads this standard and follows the three-phase protocol. The output one-pager feeds into `/spec` for the downstream pipeline (spec → plan → implement → review).
