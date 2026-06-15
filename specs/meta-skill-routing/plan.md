# Meta-Skill Routing — Implementation Plan

## Tech Stack
- **Markdown** — agent files and context standards are Markdown with YAML frontmatter
- **No code changes** — this is documentation/configuration only

## Architecture

### Current State
```
User message
    │
    ▼
Vibuzo checks for explicit commands (/spec, @deepviewer, etc.)
    │
    ▼
If no command match → process as question, analysis, or conversation
```

### Target State
```
User message
    │
    ▼
[NEW] Skill Discovery & Dynamic Routing flowchart
    │
    ├── Match found (✅ skill) → route to command or agent
    ├── Match found (🔲 skill) → report not imported, offer to import
    └── No match → fall through to existing behavior
                       │
                       ▼
              Check for explicit commands
                       │
                       ▼
              Process as question/analysis/conversation
```

### Component Diagram
```
agents/vibuzo.md
  ├── Core Rules (existing)
  ├── Skill Discovery & Dynamic Routing [NEW]
  ├── Context Auto-Query (existing)
  ├── When to Execute vs. Delegate (existing)
  ├── Handoff to Deepveloper (existing)
  ├── Version Reporting (existing)
  ├── Session Summaries (existing)
  ├── Error Handling (existing)
  └── Approval Gates (existing)

context/standards/skill-routing-vibuzo.md [NEW]
  ├── YAML frontmatter
  ├── Full adapted routing flowchart
  ├── 24-skill status table
  └── Routing implementation rules
```

## Implementation Order

### Task 1: Create context standard
- Create `context/standards/skill-routing-vibuzo.md`
- Write YAML frontmatter with tags, scope, when
- Include full flowchart adapted from agent-skills
- Include 24-skill status table mapping each to Vibuzo equivalent
- Include routing rules

### Task 2: Modify agents/vibuzo.md
- Insert `## Skill Discovery & Dynamic Routing` section after Core Rules (after line 44)
- Embed the condensed flowchart
- Write routing behavior rules
- Ensure no duplication with existing Execute vs. Delegate table

### Task 3: Update context/index.md
- Add the new file listing under `### Standards`

## Risks
- **Low risk** — no operational code changes, no agent behavior is broken
- **Medium risk** — the flowchart could make Vibuzo over-eager to route. Mitigated by making the routing rules explicit about fallback and requiring the flowchart to be used as "first check, not only check"
