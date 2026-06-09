---
tags:
  - commit
  - git
  - commit-message
  - version-bump
scope: Format for git commit messages when user says "commit"
when: User says "commit" or "commit and push" or "now commit"
---

# Commit Message Format

When the user says **"commit"** (or "commit and push", "now commit", etc.), follow this exact commit message format. This applies to every commit — not just version bumps.

## Format Template

When a commit covers changes of the same type, use a single type line:

```
<type>: <short summary>

## Summary
Brief overview of what this commit accomplishes — 1-3 sentences covering
the overall change.

## Version & Scheme
- <version-related changes>

## <Category>
- <specific bullet points>

## <Other category>
- <other changes>
```

When a commit covers changes of **multiple types**, list each type on its own line:

```
<type1>: <summary for type1 changes>
<type2>: <summary for type2 changes>
<type3>: <summary for type3 changes>

## Summary
Brief overview of what this commit accomplishes — 1-3 sentences covering
the overall change. This section is required when multiple types are used.

## Version & Scheme
- <version-related changes>

## <Category>
- <specific bullet points>
```

## Type Reference

Derive the type from the nature of each change:

| Type | When to Use |
|------|-------------|
| `feat:` | New feature, command, or capability |
| `fix:` | Bug fix or corrective patch |
| `docs:` | Documentation-only changes (README, context files, standards) |
| `refactor:` | Code restructuring without behavioral change |
| `style:` | Formatting, spacing, visual-only changes |
| `chore:` | Maintenance, tooling, installer updates |
| `perf:` | Performance improvement |
| `test:` | Adding or updating tests |

## Example (single type)

```
docs: documentation drift fixes for approval gate refactor, version 0.3.5

## Summary
Fixed 16 documentation files across 3 clusters to reflect the approval gate
refactor and 4-agent system.

## Version & Scheme
- Bumped VERSION 0.3.4→0.3.5 (patch)

## Documentation Drift Fixes
- Cleaned up stale approval_level refs in commands/spec.md, AGENTS.md,
  spec-command.md, new-release.md, terminology-change-process.md
- Updated architecture docs for 4-agent system: agent-restructure.md,
  deepsearcher-research-stage.md, vibuzo-main-session-only.md
- Fixed dead command refs and stale counts in context/index.md,
  internal-commands-convention.md, commit-workflow-pattern.md,
  structured-commit-body-convention.md, session-workflow-discipline.md

## README
- Updated commands table, file tree, agent descriptions
```

## Example (multiple types)

```
docs: documentation drift fixes across 16 files
refactor: pipeline gating in spec.md rewritten
feat: /session-init output standardized with linewrapped narrative

## Summary
Cleaned up documentation drift from the approval gate refactor, rewrote
/spec pipeline gating, and standardized the /session-init output format
into a unified codeblock with linewrapped session descriptions.

## Version & Scheme
- Bumped VERSION 0.3.4→0.3.5 (patch)

## /session-init Output Standardization
- Unified init box and narrative summary into single codeblock
- Replaced verbose step 7 with concise output instruction

## Pipeline & Commands
- commands/spec.md: Pipeline gating logic rewritten
- commands/new-release.md: Step 5 conversation-derived release notes
  + enhanced report box with installer status

## Context & Patterns
- AGENTS.md: Custom rule #2 added, approval section rewritten
- Session added: 2026-06-09-documentation-drift-release.md
```

## Type Lines

- Each type line starts with a lowercase conventional commit type followed by a colon and space
- The summary after the type is sentence case, no period at the end
- When using multiple types, order them by significance (most impactful first)
- Types must reflect actual content — do not force-fit all changes under one type

## Summary Section

- Always present when multiple types are used
- Optional for single-type commits (but recommended for complex ones)
- 1-3 sentences that answer: "what does this commit do as a whole?"

## Category Naming Rules

- Group changes by logical category (what changed, not which file)
- Use `## <Category>` as section headings
- Use `- <bullet>` for individual changes, each on its own line or wrapped with indentation

## Version Bump Pattern

When the commit includes a version bump, the first section is always `## Version & Scheme` with bullets showing:
- The before→after values
- Any scheme/sync changes

## What to Include

Include ALL uncommitted changes, organized by category. Do not omit files. Do not batch unrelated changes into one bullet.
