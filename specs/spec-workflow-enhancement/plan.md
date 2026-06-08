---
feature: spec-workflow-enhancement
date: 2026-06-08
status: plan
---

# Spec Workflow Enhancement — Implementation Plan

## Tech Stack

- **No new languages or dependencies** — all changes are to existing `.md` command files and new `.md` prompt templates
- **Markdown** — all artifacts use the existing markdown convention

## Architecture

The enhancement modifies the `/spec` pipeline defined in `commands/spec.md`. No new components are introduced — the existing pipeline structure is extended with:

```
Before:                    After:
Setup                      Setup
                           ├── Research (moved earlier)
                           ├── Briefing (reworked from pre-research guess to research-driven debrief)
Specification              Specification
Plan                       Plan
Tasks                      Tasks (structured template)
Implementation             Implementation (two-stage review per task)
Review                     Review
```

## Components

| Component | File | Change |
|-----------|------|--------|
| Pipeline definition | `commands/spec.md` | 3 changes: Research → Briefing order swap, structured tasks template, two-stage review loop |
| Mirror | `.opencode/commands/spec.md` | Mirror all changes |
| Spec compliance prompt | `prompts/reviewers/spec-reviewer-prompt.md` | CREATED — reusable prompt template |
| Code quality prompt | `prompts/reviewers/quality-reviewer-prompt.md` | CREATED — reusable prompt template |

## Implementation Order

1. Create reviewer prompt templates (no deps)
2. Reorder phases: Research before Briefing, rework Briefing to debrief
3. Standardize task format in Plan/Tasks phase
4. Add two-stage review loop to Implementation phase
