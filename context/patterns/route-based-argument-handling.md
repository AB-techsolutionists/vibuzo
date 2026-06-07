---
tags:
  - routing
  - arguments
  - failed-pattern
  - command-design
scope: Command file architecture and routing decisions
when: Considering multi-section command files or routing-only dispatch files
---

# Route-Based Argument Handling — ⚠️ FAILED PATTERN

> **This pattern does NOT work.** It is kept as a record of what was tried and why it failed.

## The Attempt

The original command design used a single file with a routing block at the top, followed by multiple `## RUN:` sections — one per subcommand. The routing block would parse `$ARGUMENTS` and the agent was supposed to execute only the matching section.

## Why It Failed

Opencode substitutes `$ARGUMENTS` into **every** `Do these steps NOW:` section in the file before the agent reads it. The agent then executes **all** sections sequentially, regardless of routing instructions, critical warnings, or guard clauses. The agent processes the file linearly and never "jumps over" non-matching sections.

Attempted (and failed) mitigations:
- Adding `⚠️ CRITICAL: execute only one section` routing instruction
- Adding per-section guard clauses (`⚠️ SKIP if...`)
- Using `$ARGUMENTS` inside guard text for template substitution
- Guard clauses referencing "the user's arguments"

None worked.

## The Fix

Every command gets its own file with exactly one `Do these steps NOW:` section. No routing, no multiple sections. See `architecture/split-file-command-pattern.md` for the correct pattern.

## Historical Note

Routing-only main files (`commands/<command>.md` with zero `Do these steps NOW:` sections that were meant to dispatch to sub-files) also failed — the agent reads them as plain text and does nothing.
