---
tags:
  - standards
  - spec
  - pipeline
  - research
scope: The Research phase must precede the Briefing phase in the /spec pipeline so the briefing is a research-driven debrief grounded in actual data, not upfront speculation
when: Modifying the /spec pipeline, creating new pipeline commands, or discussing phase ordering
---

# Research-Briefing Phase Order Standard

**Rule:** In the `/spec` pipeline, the **Research** phase must execute before the **Briefing** phase. The Briefing is a research-driven debrief — it reviews, challenges, and summarizes what Research discovered.

## Rationale

- **Prevents speculative briefing:** If Briefing comes before Research, the agent produces direction based on assumptions that research may later contradict
- **Data-driven design:** Research gathers concrete facts (existing code patterns, real-world examples, web findings) that Briefing then interprets — not the other way around
- **Avoids wasted work:** Research that must conform to a pre-written briefing is less objective and more likely to cherry-pick supporting data

## Pipeline Order

```
Phase 1: Research   ← web search + codebase analysis + existing pattern review
Phase 2: Briefing   ← debrief of what Research found, with critical analysis
Phase 3: Spec       ← specification written from grounded understanding
...
```

## Anti-Pattern

❌ Briefing before Research — agent writes a direction without data, then Research must "prove" it:

```
Phase 1: Briefing   ← speculative direction
Phase 2: Research   ← cherry-picks supporting evidence
```

## Example

See `commands/spec.md` for the canonical pipeline order.
