# Meta-Skill Routing Integration

## Principles

1. **Surgical change** — modify `agents/vibuzo.md` minimally. One new section, no restructuring of existing content.
2. **Flowchart first** — the routing flowchart becomes Vibuzo's first dispatch layer, BEFORE command matching.
3. **Explicit fallback** — if no flowchart branch matches, fall through to existing behavior (command matching, question answering, etc.).
4. **Honest gap reporting** — skills not yet imported are marked clearly, with an offer to import.
5. **Persistent reference** — the routing table is saved as a context standard so it's auto-loaded in future sessions.

## Specification

### Overview
Import the `using-agent-skills` meta-skill from addyosmani/agent-skills into Vibuzo's core agent file as a dynamic routing flowchart. This enables Vibuzo to determine user intent from natural language and route to the appropriate workflow (existing command or pending skill) without requiring explicit slash commands.

### User Stories
- **As a user**, when I say "I'm not sure what I want" or "interview me", Vibuzo recognizes this as an intent-extraction need and routes accordingly.
- **As a user**, when I say "let me think through this idea" or "refine this", Vibuzo recognizes this as idea refinement.
- **As a user**, when I say "something broke" or "debug this", Vibuzo recognizes this as debugging.
- **As a user**, when I say "review this code", Vibuzo routes to @deepviewer.
- **As a user**, when I say "write a spec for X", Vibuzo routes to /spec.
- **As a user**, when I say a skill isn't imported yet, Vibuzo tells me clearly and offers to import it.

### Functional Requirements

1. **Routing section in agents/vibuzo.md**
   - Insert a new `## Skill Discovery & Dynamic Routing` section after `## Core Rules` (line 44) and before `## Context Auto-Query` (line 46).
   - Include the adapted agent-skills flowchart as a code block decision tree.
   - Include routing rules: flowchart is first dispatch, explicit commands override, fallback to normal processing.
   - Include status markers for each skill: ✅ imported, 🔲 not yet imported.

2. **Context standard creation**
   - Create `context/standards/skill-routing-vibuzo.md` with full YAML frontmatter.
   - Include the complete adapted flowchart.
   - Include a status table of all 24 agent-skills mapped to Vibuzo equivalents.
   - Include implementation rules for routing.

3. **Context index update**
   - Add `standards/skill-routing-vibuzo.md` to the Files section in `context/index.md`.

### Acceptance Criteria

- ✅ `agents/vibuzo.md` has a new `## Skill Discovery & Dynamic Routing` section between Core Rules and Context Auto-Query
- ✅ The section contains the full adapted routing flowchart as a decision tree
- ✅ Skills already imported (five-axis, security) are marked ✅
- ✅ Skills not yet imported are marked 🔲
- ✅ `context/standards/skill-routing-vibuzo.md` exists with YAML frontmatter
- ✅ `context/index.md` lists the new standard file
- ✅ Routing section does NOT conflict with or duplicate existing "When to Execute vs. Delegate" table
- ✅ Existing vibuzo.md sections (Context Auto-Query, Execute vs. Delegate, Handoff, etc.) remain unchanged

### Out of Scope

- Actual implementation of the individual skills (interview-me, idea-refine, etc.) — these are future batches
- Creating new command files for the routing
- Modifying `.opencode/` mirror files (installer-managed)
- Modifying any agent file other than `agents/vibuzo.md`
