---
tags:
  - agent-skills
  - integration
  - pattern
  - context
  - workflow
scope: Pattern for importing external skill repositories (like addyosmani/agent-skills) as context standards rather than replacing existing pipeline infrastructure
when: Evaluating external workflow repositories for integration into Vibuzo
---

# External Skill Integration

## Overview

When external agent skill repositories (e.g., addyosmani/agent-skills) provide curated engineering workflows, the correct integration pattern is to extract specific structured workflows and save them as `context/standards/` reference files — not to replace Vibuzo's explicit `/spec` pipeline with implicit intent-mapping.

## When to Use

- Evaluating an external skill repository for integration
- A skill repository provides structured workflows (five-axis review, security checklists, debugging processes)
- You need to assess whether a skill's workflow fills a gap in Vibuzo's existing capabilities

## Integration Steps

1. **Analyze the external repo** — understand its architecture, skill anatomy, and integration approach for different tools
2. **Compare against Vibuzo's existing pipeline** — map each external workflow to an existing Vibuzo capability:
   - If Vibuzo has a superior equivalent (explicit commands + subagents), keep Vibuzo's approach
   - If the external skill fills a gap Vibuzo doesn't cover, extract the workflow as a `context/standards/` file
   - If the external skill formalizes a weak Vibuzo capability (e.g., generic checklist → structured framework), upgrade the existing capability using the external workflow as reference
3. **Save as context standard** — create the file under `context/standards/` with:
   - YAML frontmatter (tags, scope, when)
   - Structured content derived from the external skill
   - Adapt to Vibuzo's agent and pipeline conventions
4. **Wire into agents** — update the relevant agent file (e.g., `agents/deepviewer.md`) and/or command file (e.g., `commands/spec.md`) to reference the new standard

## Anti-Patterns

| Anti-Pattern | Correct Approach |
|---|---|
| Replacing Vibuzo's explicit /spec pipeline with implicit intent-mapping | Keep /spec as the canonical feature pipeline; import only specific workflow patterns |
| Copying external skills verbatim without adaptation | Adapt to Vibuzo's agent architecture (subagents, commands, context system) |
| Importing all skills wholesale | Cherry-pick only the skills that fill genuine gaps |
| Skipping the agent file updates | The standard is useless if agents don't know to reference it |

## Verification

- [ ] The imported workflow is saved under `context/standards/` with proper YAML frontmatter
- [ ] The relevant agent file (deepviewer.md, deepveloper.md, etc.) references the new standard
- [ ] The relevant command file (spec.md, etc.) references the new standard
- [ ] `context/index.md` lists the new file
- [ ] The external repo's approach is documented as a reference, not a replacement
