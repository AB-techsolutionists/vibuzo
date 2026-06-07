---
tags:
  - auto-query
  - context-scanning
  - agent-behavior
  - task-detection
scope: Agent behavior rules for automatic context relevance scanning
when: Understanding or modifying when and how the agent auto-scans context
---

# Context Auto-Query

**Date:** 2026-06-07
**Status:** Active

## Overview

Before starting any implementation task (file creation, modification, deletion, or code generation), the Vibuzo agent automatically scans the context system for relevant knowledge. This reduces user friction — no need to manually run `/context find` before each task.

## When It Fires

Auto-query triggers on:
- Implementation tasks (file creation, modification, deletion)
- Code generation requests

Auto-query does NOT trigger on:
- Simple questions or analysis requests
- Conversation-only interactions
- `/` commands (context commands, session commands, spec, etc.)

## Scoring Rules

1. Read `context/index.md` to discover all available context files
2. For each file listed, read its YAML frontmatter to extract `tags:`, `scope:`, `when:` fields
3. Score relevance by counting keyword/tag overlap between the task description and each file's scope/tags/when:
   - Each matching tag/keyword = +1 score point
   - Matching scope description = +2 score points
   - Matching when trigger = +2 score points

## Action on Score

| Score | Action |
|-------|--------|
| >2 matches | Load full file content into working context. Present as: `[Context] Found <N> relevant files: loading <file1>, <file2>...` |
| 1-2 matches | List as "Possibly relevant" with file name and scope, allowing the user to opt-in |
| No matches (>2 threshold) | List top 3 scoring candidates with their scope so the user knows what's available |

## Presentation

Results are displayed inline without user prompting. The loaded context becomes part of the working session for the implementation task.

## Dependencies

Auto-query accuracy depends on:
- `tags:` — keyword matching for domain relevance
- `scope:` — applicability description (double-weighted)
- `when:` — trigger condition description (double-weighted)

All context files should have accurate frontmatter for optimal auto-query performance.

## Related

- [`semantic-context-search.md`](semantic-context-search.md) — search formula used by /context find
- [`AGENTS.md`](../../AGENTS.md) — agent instructions with auto-query rules
