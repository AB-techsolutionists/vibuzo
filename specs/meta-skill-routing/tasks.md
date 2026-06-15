## Task 1: Create skill-routing-vibuzo.md context standard

**Description:** Create a new context standard file documenting the full adapted routing flowchart, the 24-skill status table, and routing implementation rules.

**Files:**
- `context/standards/skill-routing-vibuzo.md` — create

**Steps:**
1. Create `context/standards/skill-routing-vibuzo.md` with YAML frontmatter:
   ```yaml
   ---
   tags:
     - routing
     - skills
     - meta-skill
     - agent-skills
     - dispatch
   scope: Dynamic skill routing flowchart for Vibuzo — maps user intent to the appropriate workflow (command or skill import gap)
   when: At session start, before processing any user message, to determine which skill or command applies
   ---
   ```
2. Write a `## Overview` section explaining that this is adapted from addyosmani/agent-skills `using-agent-skills` meta-skill.
3. Write the full routing flowchart adapted from agent-skills, mapping each branch to Vibuzo's existing commands or marking as not-yet-imported.
4. Write a `## Skill Status Table` with columns: Skill, Vibuzo Equivalent, Status (✅ or 🔲), Batch.
5. Write `## Routing Rules`:
   - Flowchart is first dispatch layer (before explicit command matching)
   - Explicit commands override flowchart routing
   - If flowchart matches 🔲 status → inform user skill isn't imported, offer to import
   - If no flowchart match → fall through to normal processing
6. Write `## Implementation Rules`:
   - The routing flowchart is checked against the user's FIRST message in a turn
   - Do NOT re-route mid-conversation unless user changes topic significantly
   - For skills not yet imported, always ask: "Would you like me to import this skill?"
7. Write `## Status Key`:
   - ✅ = Skill imported and wired into Vibuzo
   - 🔲 = Skill identified as gap — not yet imported
   - N/A = Scope not applicable to Vibuzo
8. Verify the file has proper structure and no markdown errors.

**Verification:**
- File exists at `context/standards/skill-routing-vibuzo.md`
- Frontmatter is valid YAML
- Flowchart covers all 24 skills
- Status table is accurate

**Acceptance:**
- ✅ `context/standards/skill-routing-vibuzo.md` created with proper YAML frontmatter
- ✅ Full adapted flowchart present
- ✅ 24-skill status table present
- ✅ Routing rules documented

---

## Task 2: Insert routing section into agents/vibuzo.md

**Description:** Add the `## Skill Discovery & Dynamic Routing` section to the canonical source agent file, embedding a condensed routing flowchart.

**Files:**
- `agents/vibuzo.md` — edit

**Steps:**
1. Read `agents/vibuzo.md` to confirm exact line structure.
2. Insert a new `## Skill Discovery & Dynamic Routing` section after the `## Core Rules` section (after the "Single task per handoff" rule, before `## Context Auto-Query`).
3. The new section should contain:
   - A brief introduction paragraph explaining intent-based routing
   - A condensed decision tree flowchart in a code block (based on the full chart in the context standard)
   - Routing behavior rules (3-5 bullet points)
   - A note that the full reference is at `context/standards/skill-routing-vibuzo.md`
4. Do NOT modify any existing section content.
5. Do NOT remove or alter any existing text.

**Condensed flowchart for the agent file:**

```
## Skill Discovery & Dynamic Routing

Before checking for explicit commands, determine the user's intent
using this routing flowchart. This enables Vibuzo to understand what
the user needs from natural language without requiring slash commands.

### Routing Flowchart

```
Task arrives
    │
    ├── Unsure what you want / "interview me" ─→ interview-me skill (🔲)
    ├── Have a rough concept / "refine this" ──→ idea-refine skill (🔲)
    ├── New feature or change ──────────────────→ /spec
    ├── Implementing code ──────────────────────→ Delegate to Deepveloper
    │   ├── Need doc-verified code ────────────→ source-driven-dev (🔲)
    │   └── High stakes / unfamiliar ──────────→ doubt-driven-dev (🔲)
    ├── Writing or running tests ───────────────→ TDD skill (🔲)
    ├── Something broke / debug this ───────────→ debugging skill (🔲)
    ├── Reviewing code ─────────────────────────→ @deepviewer or /deepviewer
    │   ├── Too complex ───────────────────────→ code-simplification (🔲)
    │   ├── Security concerns ─────────────────→ Security axis (✅)
    │   └── Performance concerns ──────────────→ Performance axis (🔲)
    ├── Need research on something ─────────────→ /research or @deepsearcher
    ├── Need session context / summary ─────────→ /session or /session-init
    ├── Committing or branching ────────────────→ git workflow skill (🔲)
    ├── Writing docs or ADRs ───────────────────→ /add-context or manual
    └── Shipping or deploying ──────────────────→ not implemented
```

### Routing Rules

1. **Flowchart is first dispatch** — scan user message against flowchart branches before matching explicit command syntax.
2. **Explicit commands override** — if the user types /spec, @deepviewer, or any known command, route directly. Do NOT flowchart-interpret command invocations.
3. **🔲 status handling** — if a flowchart branch matches but the skill is not yet imported, respond: "I recognize you need [skill], but I haven't imported that workflow yet. Would you like me to import it?" Then offer to run the import batch.
4. **✅ status handling** — route to the indicated command or agent directly.
5. **No match** — fall through to normal processing (question answering, analysis, conversation).
6. **One check per turn** — check the flowchart against the user's first message in a turn. Do not re-route mid-turn.

See `context/standards/skill-routing-vibuzo.md` for the full reference including all 24 skills and their import status.
```

6. Ensure the insert is clean — exactly between the Core Rules block and Context Auto-Query, with one blank line before and after.

**Verification:**
- The new section is inserted after the last Core Rule (line 44 in current file)
- The section does not overlap or duplicate Context Auto-Query or Execute vs. Delegate
- Existing sections are untouched
- The flowchart is readable and correct

**Acceptance:**
- ✅ `agents/vibuzo.md` has new section between Core Rules and Context Auto-Query
- ✅ Condensed flowchart embedded in code block
- ✅ Routing rules documented
- ✅ No existing content modified
- ✅ File is valid markdown

---

## Task 3: Update context/index.md

**Description:** Add the new skill-routing-vibuzo.md to the standards listing in the context index.

**Files:**
- `context/index.md` — edit

**Steps:**
1. Read `context/index.md` to find the exact insertion point in the Standards section (alphabetical order — between `security-review-checklist.md` and `semantic-context-search.md`).
2. Insert a new bullet: `- `standards/skill-routing-vibuzo.md` — Standard for dynamic skill routing: intent-based dispatch flowchart adapted from agent-skills meta-skill, 24-skill status table, and routing implementation rules``
3. Verify the entry is in the correct position alphabetically.

**Verification:**
- The new entry is in the Standards list
- The description accurately reflects the file content
- No existing entries were modified or removed

**Acceptance:**
- ✅ `context/index.md` lists `standards/skill-routing-vibuzo.md` with description
- ✅ Entry is alphabetically correct
