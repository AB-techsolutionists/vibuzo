---
tags:
  - routing
  - conventions
  - agent-config
  - consistency
  - skills
scope: Standard for keeping trigger phrases consistent across all three routing surfaces — the agent file flowchart, the routing standard flowchart, and the protocol standard's when: field
when: Adding, modifying, or removing trigger phrases for any routed skill
---

# Trigger Phrase Sync

## Overview

When a skill is imported or its trigger phrases are updated, the triggers must be synced across three surfaces. Failure to sync causes routing gaps where the agent doesn't respond to valid trigger phrases — the user may say "grill me" but the agent's working flowchart only checks for "interview me."

## The Three Surfaces

| # | Surface | File | Example |
|---|---------|------|---------|
| 1 | Agent file routing flowchart | `agents/vibuzo.md` | `├── Unsure what you want / "interview me" / "grill me" ─→ interview-me (✅)` |
| 2 | Routing standard flowchart | `context/standards/skill-routing-vibuzo.md` | `├── Unsure what you want / "interview me" / "grill me"` |
| 3 | Protocol standard when: field | `context/standards/<skill>.md` | `when: The user says "interview me" / "grill me" / "are we sure?"` |

## Rules

1. **All three surfaces must list the same trigger phrases** — no surface should be missing triggers that another surface has
2. **Expand triggers at the source** — when adding a new trigger phrase, add it to the protocol standard's `when:` field first, then mirror it in the other two surfaces
3. **Review check** — add a verification step in every skill import task: "Verify trigger phrases are synced across all three surfaces"
4. **When: field as canonical source** — the standard's `when:` field is the authoritative list of triggers; the flowchart lines in agents/vibuzo.md and skill-routing-vibuzo.md are condensed representations

## Verification

- [ ] agents/vibuzo.md flowchart line includes all trigger phrases from the standard's `when:` field
- [ ] skill-routing-vibuzo.md flowchart line includes all trigger phrases from the standard's `when:` field
- [ ] No surface has trigger phrases that another surface is missing
