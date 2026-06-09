---
tags:
  - frontmatter
  - yaml
  - metadata
  - tagging
  - context-organization
scope: Structure and requirements for YAML frontmatter on all context files
when: Creating or editing context files under context/
---

# YAML Frontmatter Convention

**Date:** 2026-06-07
**Status:** Active

## Purpose

All context files under `context/standards/`, `context/patterns/`, and `context/architecture/` include standardized YAML frontmatter with three fields: `tags:`, `scope:`, and `when:`. This frontmatter enables semantic search relevance scoring and automatic context scanning.

## Required Fields

### `tags:`
A YAML list of 3–6 keywords that describe the file's domain.

```yaml
tags:
  - naming-conventions
  - code-style
  - typescript
```

- Keywords should be specific and non-ambiguous
- Use kebab-case for multi-word tags
- First tag should be the primary category

### `scope:`
A single line describing what kind of task this file applies to.

```yaml
scope: Naming decisions for variables, functions, classes, and files
```

- Describes the **applicability domain**, not the content summary
- Used for relevance matching against task descriptions (double-weighted)

### `when:`
A single line describing when the agent should consult this file. Follows the Superpowers trigger-only pattern — describes **when**, not **how**.

```yaml
when: Naming variables, functions, or components
```

- Brief trigger condition
- Do NOT summarize the file's workflow or instructions
- Used for relevance matching (double-weighted)

## Example

```yaml
---
tags:
  - naming-conventions
  - camelcase
  - pascalcase
  - code-style
scope: All source code in the project
when: Writing or reviewing source code
---
```

## Backward Compatibility

Files without frontmatter continue to work — the auto-query system falls back to filename + content matching and lists them as lower-scored candidates. However, for optimal performance, all files should have frontmatter.

## Auto-Generation

When saving new context via `/add-context`, the command prompts for:
1. Tags (comma-separated, 3-6 keywords)
2. Scope (single line describing applicability)
3. When (single-line trigger description)

Sensible defaults are generated based on the content for the user to override.

## Related

- [`semantic-context-search.md`](semantic-context-search.md) — how frontmatter powers scoring
- [`context-auto-query.md`](context-auto-query.md) — how frontmatter powers auto-scanning
