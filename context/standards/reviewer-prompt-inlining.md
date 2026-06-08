---
tags:
  - standards
  - commands
  - reviewer
  - spec
  - pipeline
scope: When building review stages into commands (especially /spec pipeline), embed reviewer instructions directly in the command definition rather than maintaining separate prompt files
when: Creating or modifying any command definition that involves subagent review stages
---

# Reviewer Prompt Inlining Standard

**Rule:** Inline reviewer prompts as blockquotes within the command step logic. Do NOT create separate `.md` prompt files in a `prompts/` or `prompts/reviewers/` directory.

## Rationale

- **No file drift:** External prompt files and command logic inevitably diverge over time
- **Self-contained commands:** A command file is the single source of truth for its behavior
- **No extra directory:** Eliminates the need for a prompts/ directory structure and its maintenance
- **One fewer decision:** No need to decide where prompt files live or how they're referenced

## Implementation

In the command definition, embed reviewer instructions as blockquotes directly within the relevant step:

```markdown
## Review

1. Read spec/plan/tasks files.
2. Find implemented code.
3. **Stage 1 — Spec Compliance Review:**
   - Dispatch a reviewer subagent via `task()` with subagent_type "general"
   - Provide the reviewer with these instructions inline:
     > **Role:** You are a spec compliance reviewer...
     > **Checklist:**
     > - All required functionality is present
     > - No extra unintended functionality
     > ...
```

## Anti-Pattern

❌ Creating external files like `prompts/reviewers/spec-reviewer-prompt.md` and referencing them:

```markdown
- Instruct the reviewer to read `prompts/reviewers/spec-reviewer-prompt.md`
```

## Example

See `commands/spec.md` → **Review** section for the canonical example of inlined spec-compliance and code-quality reviewer prompts.
