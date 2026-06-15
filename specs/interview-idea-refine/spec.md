# Interview-Idea-Refine — Specification

## Principles

- **Protocol over principle** — Both skills are step-by-step protocols with checkable exit criteria, not vibe-based guidelines. The standards must preserve this structure.
- **Reference, not inline** — Full protocol text lives in `context/standards/`. The agent file (`agents/vibuzo.md`) gets a concise implementation note that references and loads the standard.
- **Surgical wiring** — No existing content in `agents/vibuzo.md` is restructured or removed. Only the 🔲 → ✅ updates and a new implementation-notes subsection below the routing flowchart.
- **Single source of truth** — The routing rules live canonically in `context/standards/skill-routing-vibuzo.md`. The agent file keeps a summary + reference link (already established pattern from Batch 0).
- **No new commands** — These are protocol standards, not command files. No new `.opencode/commands/` files are created.

## Specification

### Overview

Import two structured clarification protocols from the addyosmani/agent-skills repository — `interview-me` and `idea-refine` — as Vibuzo context standards. These are "front-end skills" that fire **before** `/spec` when the user is vague. They fill the gap between "user has a vague idea" and "we write a spec."

Both skills are saved as `context/standards/` files with YAML frontmatter, adapted to Vibuzo's agent architecture. The routing flowchart in `agents/vibuzo.md` is updated from 🔲 → ✅ with a short implementation-notes section. The status table in `context/standards/skill-routing-vibuzo.md` is updated.

### User Stories

- **US1**: As a user with a vague request ("build me a dashboard"), I want Vibuzo to interview me one question at a time until it understands what I actually want, instead of guessing and building the wrong thing.
- **US2**: As a user with a rough concept ("I want something for tracking experiments"), I want Vibuzo to help me expand and sharpen the idea through structured divergent/convergent thinking before we commit to a plan.
- **US3**: As a user typing "interview me" or "refine this idea", I want the routing flowchart to recognize my intent and trigger the appropriate protocol without requiring a slash command.
- **US4**: As a returning user, I want the 🔲 markers in the routing flowchart updated to ✅ so I know these skills are available.

### Functional Requirements

#### FR1: context/standards/interview-me.md
- Must have YAML frontmatter with tags (`protocol`, `clarification`, `interview`, `intent`), scope, and when
- Must contain the full adapted protocol: hypothesis with confidence, one-question-at-a-time with guess attached, "want vs should want" detection, 6-field restate (Outcome/User/Why now/Success/Constraint/Out of scope), 95% confidence stop condition
- Must include a "Wiring into Vibuzo" section explaining the interaction with Core Rule 1 (Plan first)
- Must be under ~200 lines

#### FR2: context/standards/idea-refine.md
- Must have YAML frontmatter with tags (`protocol`, `ideation`, `refinement`, `divergent-convergent`), scope, and when
- Must contain the full adapted protocol: Phase 1 (divergent — How Might We, sharpening questions, 5-8 idea variations through lenses), Phase 2 (convergent — cluster, stress-test, surface assumptions), Phase 3 (sharpen — one-pager output with Not Doing list)
- Must include a "Wiring into Vibuzo" section
- Must be under ~200 lines

#### FR3: agents/vibuzo.md routing update
- Update `interview-me (🔲)` → `interview-me (✅)` in the routing flowchart
- Update `idea-refine (🔲)` → `idea-refine (✅)` in the routing flowchart
- Add a "Protocol Implementation Notes" subsection below the routing flowchart with:
  - "When the flowchart matches interview-me → load `context/standards/interview-me.md` and follow its protocol step by step"
  - "When the flowchart matches idea-refine → load `context/standards/idea-refine.md` and follow its protocol step by step"

#### FR4: context/standards/skill-routing-vibuzo.md status table update
- Row 2 (interview-me): 🔲 → ✅
- Row 3 (idea-refine): 🔲 → ✅

#### FR5: context/index.md update
- Add `context/standards/interview-me.md` to the Standards section
- Add `context/standards/idea-refine.md` to the Standards section

### Acceptance Criteria

- ✅ `specs/interview-idea-refine/spec.md` exists and meets all principles
- ✅ `specs/interview-idea-refine/plan.md` exists with technical plan
- ✅ `specs/interview-idea-refine/tasks.md` exists with actionable task breakdown
- ✅ `specs/interview-idea-refine/review.md` exists with review results
- ✅ `context/standards/interview-me.md` exists with YAML frontmatter and full protocol
- ✅ `context/standards/idea-refine.md` exists with YAML frontmatter and full protocol
- ✅ `agents/vibuzo.md` shows `interview-me (✅)` and `idea-refine (✅)` in the flowchart
- ✅ `agents/vibuzo.md` has a Protocol Implementation Notes section
- ✅ `context/standards/skill-routing-vibuzo.md` shows ✅ for both skills in rows 2-3
- ✅ `context/index.md` lists both new files under Standards
- ✅ Deepviewer review passes both stages

### Out of Scope

- Full agent-skills repo import (Batch 2-5 are separate sessions)
- Command files for interview-me or idea-refine (no `.opencode/commands/`)
- New slash commands
- Automated test suite for the protocols
- Changes to `.opencode/` mirror files (installer-managed only)
- Version bump (follows existing 0.0.17)
