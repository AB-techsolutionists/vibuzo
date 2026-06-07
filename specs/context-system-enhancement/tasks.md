# Tasks: Context System Enhancement

**Date:** 2026-06-07
**Status:** Draft
**Feature:** context-system-enhancement
**Based on:** spec.md (19 FRs, 8 ACs), plan.md (6 components, 6 phases)

---

## Phase 1: YAML Frontmatter — Foundation

### T1.1: Add frontmatter to standards files [P]

**Description:** Add standardized YAML frontmatter (`tags:`, `scope:`, `when:`) to every file in `context/standards/`.

**Files:**
- `context/standards/imperative-command-style.md`
- `context/standards/naming.md`
- `context/standards/arguments-usage-in-command-templates.md`
- `context/standards/command-parameter-notation.md`
- `context/standards/agent-report-summary-next-steps.md`
- `context/standards/terminology-change-process.md`
- `context/standards/installer-visual-language.md`
- `context/standards/agents-preservation-convention.md`
- `context/standards/deepsearcher-invocation-modes.md`
- `context/standards/feature-naming-convention.md`
- `context/standards/vibuzo-main-session-only.md`
- `context/standards/opencode-mirror-files-integrity.md`
- `context/standards/versioning.md`
- `context/standards/session-summary-forward-template.md`
- `context/standards/structured-commit-body-convention.md`
- `context/standards/large-document-size-gate.md`

**Dependencies:** None

**Acceptance:**
- ✅ Every file in `context/standards/` has YAML frontmatter with `tags:`, `scope:`, `when:`
- ✅ Frontmatter accurately describes the file's domain, scope, and trigger condition
- ✅ Files without frontmatter continue to work (backward compatible)

---

### T1.2: Add frontmatter to patterns files [P]

**Description:** Add YAML frontmatter to every file in `context/patterns/`.

**Files:**
- `context/patterns/route-based-argument-handling.md`
- `context/patterns/title-based-session-naming.md`
- `context/patterns/session-workflow.md`
- `context/patterns/session-workflow-discipline.md`
- `context/patterns/large-document-size-gate.md`
- `context/patterns/commit-workflow-pattern.md`

**Dependencies:** None

**Acceptance:**
- ✅ Every file in `context/patterns/` has YAML frontmatter with `tags:`, `scope:`, `when:`
- ✅ Frontmatter accurately describes the pattern's domain and usage trigger

---

### T1.3: Add frontmatter to architecture files [P]

**Description:** Add YAML frontmatter to every active file in `context/architecture/`.

**Files:**
- `context/architecture/agent-restructure.md`
- `context/architecture/approval-gates.md`
- `context/architecture/deepsearcher-research-stage.md`
- `context/architecture/installer-update-mechanism.md`
- `context/architecture/spec-command.md`
- `context/architecture/split-file-command-pattern.md`

**Dependencies:** None

**Acceptance:**
- ✅ Every active file in `context/architecture/` has YAML frontmatter
- ✅ Deprecated files (`build-agent-override.md`, `default-agent-in-opencode-jsonc.md`) are left as-is

---

## Phase 2: /add-context Frontmatter Generation

### T2.1: Update /add-context to generate frontmatter

**Description:** Modify the `/add-context` command instructions to prompt the user for and auto-generate `tags:`, `scope:`, `when:` frontmatter when saving new context files.

**Files:**
- `commands/add-context.md`
- `.opencode/commands/add-context.md`

**Steps:**
1. After inferring file type and name, prompt for tags (comma-separated list)
2. Prompt for scope (single line describing applicability)
3. Prompt for when (single-line trigger description — "when the agent should consult this")
4. Generate standard YAML frontmatter block at the top of the file
5. Write file with frontmatter + content

**Dependencies:** T1.1–T1.3 (establishes the frontmatter convention)

**Acceptance:**
- ✅ `/add-context "We use pnpm not npm"` prompts for frontmatter fields
- ✅ Resulting file has valid YAML frontmatter followed by content
- ✅ Existing behavior (context/index.md update) is preserved

---

## Phase 3: Semantic Search

### T3.1: Enhance /context find with fuzzy matching

**Description:** Update `/context find` command instructions to include TF-IDF scoring and Levenshtein distance for semantic matching alongside exact keyword match.

**Files:**
- `commands/context-find.md`
- `.opencode/commands/context-find.md`

**Steps:**
1. Parse user query into tokens (split on whitespace/punctuation, lowercase)
2. For each context file:
   a. Extract searchable text: frontmatter tags + scope + when + file title (filename)
   b. Compute keyword overlap score (fraction of query tokens found)
   c. Compute TF-IDF-like score: term frequency in file vs. corpus frequency
   d. Compute Levenshtein similarity for each query token against each tag
3. Combine scores into final relevance (0.0–1.0): 40% keyword + 30% TF-IDF + 30% fuzzy
4. Sort results by score descending
5. Display: `[0.85] naming.md — naming conventions, scope, tags`
6. If no frontmatter available, fall back to filename + content word matching

**Dependencies:** T1.1–T1.3 (frontmatter improves scoring)

**Acceptance:**
- ✅ `/context find "how do we name things"` returns naming.md with score ≥0.5
- ✅ `/context find "naming"` still works (exact match preserved)
- ✅ Results are ranked with numeric scores
- ✅ All results returned within 2 seconds for ≤100 files
- ✅ Files without frontmatter still appear in results

---

## Phase 4: Auto-Scan After /session

### T4.1: Add pattern scanning to /session

**Description:** Add post-generation pattern scanning to the `/session` command that detects conventions, decisions, and patterns from the conversation and presents them as save candidates.

**Files:**
- `commands/session.md`
- `.opencode/commands/session.md`

**Steps:**
1. After the session summary file is written (existing behavior), add:
2. Scan the conversation history for:
   - New conventions established (e.g., "we use pnpm not npm")
   - Architecture decisions made
   - Repeated code patterns
   - Tooling preferences discovered
3. For each candidate, generate:
   - Suggested file name (kebab-case, under `context/standards/` or `context/patterns/`)
   - Suggested frontmatter (tags, scope, when)
   - Brief content summary
4. Present candidates one at a time with: "Save this pattern? (Name: <file> | Tags: <tags> | Scope: <scope> | When: <when>) — (y/N/edit)"
5. If "y": call /add-context logic to save the file
6. If "edit": let user modify name/tags/scope/when, then save
7. If "N": skip to next candidate
8. Append a "## Patterns Detected" section to the session file listing all candidates and which were saved

**Dependencies:** T2.1 (reuses /add-context save logic for candidates)

**Acceptance:**
- ✅ After `/session` completes, pattern candidates are presented
- ✅ Each candidate can be approved, edited, or rejected
- ✅ Approved candidates are saved as context files with frontmatter
- ✅ "Patterns Detected" section is appended to the session file
- ✅ User can reject all candidates and session still completes

---

## Phase 5: Agent Instructions — Auto-Query

### T5.1: Add context auto-query behavior to agent

**Description:** Update AGENTS.md and agents/vibuzo.md with instructions for automatic context scanning before implementation tasks.

**Files:**
- `AGENTS.md`
- `agents/vibuzo.md`

**Steps:**
1. Add a new section "Context Auto-Query" to the agent instructions:
2. Rule: Before starting ANY implementation task (file creation, modification, deletion, or code generation), the agent MUST:
   a. Read `context/index.md` to discover relevant files
   b. For each file listed, read its frontmatter (tags, scope, when)
   c. Score relevance: count keyword/tag overlap between task description and file's scope/tags/when
   d. Files with >2 matches: load full content into working context
   e. Files with 1-2 matches: list as "Possibly relevant: <file> — <scope>" for user opt-in
   f. If no file has >2 matches, still list the top 3 candidates
3. Do NOT scan for: simple queries, analysis, conversation, or `/` commands
4. Present results as: `[Context] Found <N> relevant files: loading <file1>, <file2>...`
5. Update `agents/vibuzo.md` with the same instructions

**Dependencies:** T1.1–T1.3 (auto-query accuracy depends on frontmatter)

**Acceptance:**
- ✅ Agent instructions include explicit auto-query rules
- ✅ Starting "implement user authentication" causes auto-scan to fire
- ✅ Asking "what does this function do?" does NOT trigger auto-scan
- ✅ Results are presented inline without user prompting

---

### T5.2: Sync agent instructions to .opencode mirror

**Description:** Copy the updated `agents/vibuzo.md` to `.opencode/agent/core/vibuzo.md` to ensure the installer-managed copy is in sync. Note: this is a one-time sync during development — the installer normally manages `.opencode/` files.

**Files:**
- `agents/vibuzo.md` → `.opencode/agent/core/vibuzo.md`

**Dependencies:** T5.1

**Acceptance:**
- ✅ `.opencode/agent/core/vibuzo.md` matches `agents/vibuzo.md` content

---

## Phase 6: Cleanup

### T6.1: Update context/index.md

**Description:** Update `context/index.md` to note that files now have YAML frontmatter and that the system uses auto-query and semantic search.

**Files:**
- `context/index.md`

**Dependencies:** All preceding tasks

**Acceptance:**
- ✅ `context/index.md` mentions that files have structured frontmatter
- ✅ Index references are accurate and up-to-date
