# Plan: Context System Enhancement

**Date:** 2026-06-07
**Status:** Draft
**Feature:** context-system-enhancement
**Based on:** spec.md (19 FRs, 8 ACs)

## Tech Stack

| Component | Technology | Justification |
|-----------|-----------|---------------|
| All changes | Markdown + YAML + PowerShell (`.ps1`) + Bash (`.sh`) | Vibuzo is a file-based framework — all existing commands are `.md` instructions run by the agent; no compiled code |
| Semantic search | In-file TF-IDF scoring with Levenshtein distance | No external dependencies; works cross-platform; no vector DB needed |
| YAML frontmatter | Standard YAML between `---` delimiters in `.md` files | Already supported by Markdown parsers; human-readable; agent-parsable |
| Agent behavior | Instruction updates to `AGENTS.md` and `commands/spec.md` | Auto-query behavior is agent instruction changes, not code |

## Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────┐
│                    Vibuzo Agent                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  Auto-Query Trigger (FR1)                         │   │
│  │  - On implementation task detected                │   │
│  │  - Scan context/index.md for relevant files        │   │
│  │  - Match against frontmatter tags/scope/when       │   │
│  │  - Present results inline                          │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  /context find (FR2)                              │   │
│  │  - Exact keyword match (existing)                 │   │
│  │  - TF-IDF scoring against all context files       │   │
│  │  - Levenshtein fuzzy matching                     │   │
│  │  - Ranked results with scores                     │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  /add-context (FR3)                               │   │
│  │  - Prompts for tags/scope/when                    │   │
│  │  - Generates YAML frontmatter                     │   │
│  └──────────────────────────────────────────────────┘   │
│                                                          │
│  ┌──────────────────────────────────────────────────┐   │
│  │  /session (FR4)                                   │   │
│  │  - After summary generation, scan for patterns    │   │
│  │  - Present candidates as save prompts             │   │
│  │  - Append "Patterns detected" section             │   │
│  └──────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────┘
```

### Data Flow

```
Task Start (FR1)
  │
  ├─► Agent checks: is this an implementation task?
  │     YES ─► Scan context/index.md
  │              │
  │              ├─► Read each file's frontmatter (tags, scope, when)
  │              ├─► Score relevance by keyword overlap
  │              ├─► >2 matches → load full content
  │              └─► 1-2 matches → list as "possibly relevant"
  │
  NO  ─► Continue normally (no scan)

/context find "query" (FR2)
  │
  ├─► Parse query into tokens
  ├─► For each context file:
  │    ├─► Exact keyword match in frontmatter + title + content
  │    ├─► TF-IDF score on content keywords
  │    └─► Levenshtein distance on file name + tags
  ├─► Combine scores → relevance ranking (0.0–1.0)
  └─► Display ranked results

/add-context "description" (FR3)
  │
  ├─► Agent infers file type + name
  ├─► Generate tags/scope/when frontmatter
  ├─► Write file with YAML frontmatter + content
  └─► Update context/index.md

/session (FR4)
  │
  ├─► Generate session summary (existing)
  ├─► Post-generation: scan conversation history
  │    ├─► Detect new conventions, patterns, decisions
  │    ├─► Generate file name + frontmatter for each
  │    └─► Present as save candidates to user
  ├─► User approves/edits/rejects each candidate
  └─► Append "Patterns detected" section to session file
```

### Integration Points

| Component | Integrates With | How |
|-----------|----------------|------|
| Auto-query | `AGENTS.md` (agent instructions) | New section in agent rules describing when/how to auto-scan |
| Auto-query | `context/index.md` | Already the discovery entry point — no changes needed |
| Semantic search | `commands/context-find.md` | Updated instruction steps for fuzzy matching + scoring |
| YAML frontmatter | `commands/add-context.md` | Updated to prompt for and generate frontmatter |
| YAML frontmatter | All context files under `context/` | Batch frontmatter addition to existing files |
| Auto-scan | `commands/session.md` | Post-generation step appended to existing flow |
| Auto-scan | `context/` | New files saved via `/add-context` pathway |

## Components

### C1: Agent Instructions Update (FR1)
- **File:** `AGENTS.md` (and mirrored `agents/vibuzo.md`)
- **Responsibility:** Add "Context Auto-Query" section that instructs the agent to:
  1. Before starting any implementation task, scan `context/index.md` for relevant files
  2. Match by frontmatter tags/scope/when + title/content keywords
  3. Load files with >2 matches, list files with 1-2 matches
  4. Do NOT scan for analysis/conversational tasks
- **Dependencies:** FR3 must be complete (frontmatter on files improves matching)

### C2: /context find Enhancement (FR2)
- **File:** `commands/context-find.md`
- **Responsibility:** Add steps for:
  1. Parse query into tokens
  2. For each context file: exact keyword match + TF-IDF scoring + Levenshtein fuzzy match
  3. Combine scores into 0.0–1.0 relevance ranking
  4. Display scored results
- **Dependencies:** None (falls back to current behavior for files without frontmatter)

### C3: YAML Frontmatter Batch Update (FR3)
- **Task:** Add `tags:`, `scope:`, `when:` to every file in `context/standards/`, `context/patterns/`, `context/architecture/`
- **Responsibility:** Manual or scripted addition of frontmatter matching each file's purpose
- **Dependencies:** None

### C4: /add-context Frontmatter Generation (FR3)
- **File:** `commands/add-context.md`
- **Responsibility:** Add steps to prompt for and generate YAML frontmatter when saving new context files
- **Dependencies:** C3 establishes the convention

### C5: /session Auto-Scan (FR4)
- **File:** `commands/session.md`
- **Responsibility:** Add post-generation step:
  1. After summary is written, scan conversation for patterns
  2. Generate candidate file name + suggested frontmatter
  3. Present candidates one at a time for user approval
  4. Append "Patterns detected" section to session file
- **Dependencies:** C3 (frontmatter convention for candidates)

### C6: context/index.md Update
- **File:** `context/index.md`
- **Responsibility:** Note that files now have frontmatter; update any stale references
- **Dependencies:** C3

## Implementation Order

| Phase | Component | Why First |
|-------|-----------|-----------|
| **1** | C3 — YAML Frontmatter Batch Update | Foundation — all other components benefit from or depend on structured frontmatter |
| **2** | C4 — /add-context Frontmatter Generation | Ensures new files follow the convention established in Phase 1 |
| **3** | C2 — /context find Enhancement | Semantic search works best with frontmatter (Phase 1); no other dependencies |
| **4** | C5 — /session Auto-Scan | Depends on frontmatter convention (Phase 1) for candidate generation |
| **5** | C1 — Agent Instructions Update | Auto-query depends on frontmatter (Phase 1) for accurate matching |
| **6** | C6 — context/index.md Update | Final cleanup — depends on all other phases completing |

### Risk Factors

| Risk | Impact | Mitigation |
|------|--------|-----------|
| Frontmatter values may be inaccurate if guessed | Medium | Human review of every file; accurate scope/when is essential for auto-query |
| TF-IDF scoring may produce noisy results | Low | Test with real queries; adjust tokenization if needed |
| Auto-scan may propose low-value patterns | Medium | User approval gate before saving; quality threshold scoring |
| Agent may trigger auto-query too often | Medium | Strict definition of "implementation task" in agent instructions |
| Backward compatibility: old files without frontmatter | Low | All features fall back gracefully — frontmatter is additive |

## Verification Strategy

| Phase | Verification |
|-------|-------------|
| C3 | Read each file in context/standards/, context/patterns/, context/architecture/ and confirm YAML frontmatter exists with valid tags/scope/when |
| C4 | Run `/add-context "test pattern"` and verify output file has frontmatter |
| C2 | Run `/context find "how do we name things"` and verify ranked results |
| C5 | Run `/session` and verify pattern candidates are presented and "Patterns detected" section is appended |
| C1 | Start an implementation task and verify auto-query fires (without being prompted) |
