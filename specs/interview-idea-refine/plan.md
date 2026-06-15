# Interview-Idea-Refine — Implementation Plan

## Tech Stack

- **Format:** Markdown with YAML frontmatter (context standards)
- **Languages:** None — no code or scripts
- **Target files:**
  - `context/standards/interview-me.md` — new file
  - `context/standards/idea-refine.md` — new file
  - `agents/vibuzo.md` — edit (routing flowchart + Protocol Implementation Notes)
  - `context/standards/skill-routing-vibuzo.md` — edit (status table rows 2-3)
  - `context/index.md` — edit (add two new file listings)

## Architecture

### Data Flow

```
User says "interview me" or vague request
  └→ routing flowchart in agents/vibuzo.md matches interview-me
      └→ Vibuzo reads: "Protocol Implementation Notes" → "load context/standards/interview-me.md"
          └→ Vibuzo follows protocol step by step
              └→ Output: confirmed statement of intent (in conversation)
                  └→ Handoff to /spec (downstream)
```

```
User says "refine this idea" or rough concept
  └→ routing flowchart in agents/vibuzo.md matches idea-refine
      └→ Vibuzo reads: "Protocol Implementation Notes" → "load context/standards/idea-refine.md"
          └→ Vibuzo follows protocol step by step
              └→ Output: markdown one-pager (in conversation or saved to file)
                  └→ Handoff to /spec (downstream)
```

### Component Diagram

```
context/standards/
├── skill-routing-vibuzo.md    ← Status table (rows 2-3 updated to ✅)
├── interview-me.md            ← NEW: Full interview protocol
└── idea-refine.md             ← NEW: Full ideation protocol

agents/
└── vibuzo.md                  ← EDIT: Flowchart 🔲→✅, new Protocol Notes section

context/
└── index.md                   ← EDIT: Add both new files to Standards listing
```

## Components

| Component | Type | Responsibility |
|-----------|------|----------------|
| `context/standards/interview-me.md` | Standard (new) | Full adapted interview-me protocol with YAML frontmatter and Vibuzo wiring notes |
| `context/standards/idea-refine.md` | Standard (new) | Full adapted idea-refine protocol with YAML frontmatter and Vibuzo wiring notes |
| `agents/vibuzo.md` — Routing Flowchart | Agent config (edit) | Change 🔲→✅ for both skills in the first two flowchart branches |
| `agents/vibuzo.md` — Protocol Notes | Agent config (edit) | New subsection explaining how to load and follow each standard |
| `context/standards/skill-routing-vibuzo.md` | Standard (edit) | Update status table rows 2-3 from 🔲→✅ |
| `context/index.md` | Index (edit) | Add both new file listings to Standards section |

## Implementation Order

| Step | Task | Dependency | Risk |
|------|------|------------|------|
| 1 | Create `context/standards/interview-me.md` | None | Medium — must correctly adapt the 200+ line source protocol while keeping under ~200 lines |
| 2 | Create `context/standards/idea-refine.md` | None | Medium — same adaptation challenge |
| 3 | Update `agents/vibuzo.md` | Tasks 1-2 | Low — surgical edits only |
| 4 | Update `context/standards/skill-routing-vibuzo.md` | None | Low — two cell changes |
| 5 | Update `context/index.md` | Tasks 1-2 | Low — two new lines |
| 6 | Deepviewer Review | Tasks 1-5 | Low — review pass |

**Dependency graph:** Tasks 1-2 are parallel (no dependency). Task 3 depends on 1-2 (need to know the file paths for the Protocol Notes). Task 4 is independent. Task 5 depends on 1-2 (need the filenames). Task 6 depends on all.

## Risk Factors

1. **Protocol adaptation scope** — The agent-skills source for interview-me is ~200 lines. Keeping it under 200 lines while preserving the full protocol will be tight. Mitigation: trim the "Examples," "Common Rationalizations," and "Red Flags" sections to essentials only.
2. **YAML frontmatter consistency** — Both new files must match the established frontmatter convention (`tags:`, `scope:`, `when:`). Reference `context/standards/yaml-frontmatter-convention.md` as a template.
3. **Flowchart alignment** — The routing flowchart in `agents/vibuzo.md` uses condensed labels (`"refine this"` not `"refine this idea"`). The Protocol Notes must reference the exact same trigger text.
