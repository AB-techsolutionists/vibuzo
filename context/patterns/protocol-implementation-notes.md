---
tags:
  - wiring
  - agent-config
  - routing
  - protocol
  - integration
scope: Pattern for wiring imported protocol standards into agents/vibuzo.md with concise implementation notes — a subsection that references and directs the agent to load the full protocol from context/standards/
when: Adding a new protocol standard that needs routing integration in the agent file
---

# Protocol Implementation Notes

## Overview

When importing a protocol-style skill (e.g., interview-me, idea-refine) from an external repository or creating a new protocol standard, the agent file (`agents/vibuzo.md`) needs a concise wiring entry that tells the agent what to do when the routing flowchart matches that skill.

The full procedure lives in the context standard (`context/standards/<name>.md`). The agent file only gets a reference note directing the agent to load and follow that standard.

## When to Use

- Importing a new protocol standard that fires before `/spec` (front-end skills)
- Adding a new skill to the routing flowchart that requires multi-step execution
- Any protocol where the full procedure is too long to embed inline in the agent file

## Structure

Add a subsection under the routing flowchart section in `agents/vibuzo.md`:

```markdown
### Protocol Implementation Notes

When the flowchart matches a specific protocol skill:

- **<skill-name> (✅)** — Load `context/standards/<file-name>.md` and follow its protocol step by step. <one-line description>. Output is <what it produces> that feeds into `/spec` or downstream processing.

- **<next-skill> (✅)** — Load `context/standards/<file-name>.md` and follow its protocol step by step. <one-line description>. Output is <what it produces> that feeds into `/spec` or downstream processing.
```

## Rules

1. **One entry per protocol skill** — each gets its own bullet point under the subsection
2. **Reference, not inline** — the note says "load and follow" — the full procedure lives in the context standard
3. **Output chain** — always state what the protocol produces and where it feeds (typically `/spec`)
4. **Update on import** — when a skill transitions from 🔲 to ✅, add its entry here
5. **Surgical insertion** — insert after the Routing Rules subsection; do not restructure surrounding content

## Verification

- [ ] Each imported protocol skill has an entry in the Protocol Implementation Notes
- [ ] Each entry references the correct context standard file path
- [ ] Each entry describes the output and its downstream target
- [ ] The notes are under the Routing Flowchart section, after Routing Rules
