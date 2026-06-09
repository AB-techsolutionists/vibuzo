# Documentation Drift Fixes — Task Breakdown

## Task 1: Fix stale `approval_level` references in `commands/spec.md`

**Description:** Remove 6 stale references to the deleted `approval_level` system from the /spec command pipeline definition. Replace with the current hybrid model (native popups for mechanical gates, custom chat gates for plan/push approval).

**Files:**
- `commands/spec.md` — edit 6 locations

**Steps:**
1. Read `commands/spec.md` entirely
2. Line 17 (`## Setup` step 4): Replace `Check approval_level from Vibuzo's YAML frontmatter. If level ≥ 1, gates are active. If level is 0, skip all gates and auto-proceed.` with: `Gates are handled via the hybrid model — native opencode permission popups for mechanical actions (file ops, commands, delegation), custom chat gates for conceptual approvals (plan approval, push approval).`
3. Line 66 (Briefing step 5 gate): Replace `If approval_level is 0, auto-proceed past Briefing (no briefing needed).` with `Gates follow the hybrid model — always present the gate prompt for conceptual approvals.`
4. Line 76 (Specification step 5 gate): Replace `If approval_level ≥ 1, present:` with `Present:`
5. Lines 133-134 (Implementation step 2 gate): Replace `If approval_level ≥ 1, present:` with `Present:` in the gate header, and remove the gate condition logic
6. Line 143 (Implementation step 3): Replace `Include approval_level in the handoff so Deepveloper respects gates` with `Include gate mode info in the handoff so Deepveloper respects gates`
7. Lines 240-245 (Gate Skip Logic section): Replace the entire section with: `## Gate Skip Logic\n\nGates follow the hybrid model — native opencode permission popups for mechanical actions, custom chat gates for plan/push approval. All phase gates use chat prompts for conceptual approval. The phase gates always present unless the user explicitly opts out.`

**Verification:**
- Grep for `approval_level` in `commands/spec.md` — must return 0 matches

**Acceptance:**
- ✅ `commands/spec.md` has zero references to `approval_level`
- ✅ All 6 stale locations replaced with hybrid model references

---

## Task 2: Fix stale approval references in `AGENTS.md`

**Description:** Remove the old 4-level approval table, old gate prompt template, and stale override instruction from AGENTS.md (lines 172-189). Replace with accurate hybrid model description.

**Files:**
- `AGENTS.md` — lines 172-189

**Steps:**
1. Read `AGENTS.md` lines 168-199 to see the full Approval Gates section
2. Replace lines 172-189 (the level table, gate template, and override instruction) with a concise paragraph describing the hybrid model:
   - No level table — native popups handle mechanical gating
   - Only 2 custom chat gates remain: plan approval and push approval
   - The rejection handling flow: if user responds "N" or anything other than "y"/"yes", ask "(m)odify, (s)kip, or (a)bort"

**Verification:**
- Read `AGENTS.md` lines 168-175 — the old level table must be gone
- The word "Trusted" / "Safe" / "Cautious" / "Full Control" should not appear in the Approval Gates section

**Acceptance:**
- ✅ `AGENTS.md` no longer has the 4-level approval table
- ✅ No old gate prompt template (`── APPROVAL GATE ──`)
- ✅ No stale override instruction ("at gate level X")
- ✅ Hybrid model is described consistently (one paragraph after the intro line)

---

## Task 3: Fix stale `approval_level` references in remaining Cluster 1 files

**Description:** Update 3 files that still reference the deleted `approval_level` system or use the old gate format.

**Files:**
- `context/architecture/spec-command.md` — lines 60-65, 81
- `commands/new-release.md` — lines 24-32
- `context/standards/terminology-change-process.md` — line 68

**Steps:**

**3a. `context/architecture/spec-command.md`:**
1. Read the full file
2. Lines 60-65 (Integration with Approval Gates section): Replace the 3 lines about checking `approval_level` with: `The /spec command uses the hybrid approval model — native opencode permission popups for mechanical gates, custom chat gates for conceptual approval (plan/push). Each phase presents a gate prompt for user approval before proceeding.`
3. Line 81 (Key Principles item 3): Replace `Approval gate integration — Respects Vibuzo's approval_level setting. Level 0 = uninterrupted flow.` with `Approval gate integration — Uses the hybrid model: native popups for mechanical gates, custom chat for conceptual gates.`

**3b. `commands/new-release.md`:**
1. Read the full file
2. Lines 24-32 (Step 3 gate): Replace the old `── APPROVAL GATE ──` template format with an inline gate that uses the simpler format: `── VERSION BUMP GATE ──` with just the version bump details. Keep the approval action but don't use the full old template structure.

**3c. `context/standards/terminology-change-process.md`:**
1. Read lines 63-71
2. Line 68: Update the real-world example row from `approval_gate → approval_level` to `approval_level → native popup gates` to reflect that approval_level itself was also removed. Change the scope/effort as appropriate.

**Verification:**
- Grep for `approval_level` in all 3 files — must return 0 matches

**Acceptance:**
- ✅ `context/architecture/spec-command.md` references hybrid model, not approval_level
- ✅ `commands/new-release.md` gate format is consistent with current convention
- ✅ `context/standards/terminology-change-process.md` example doesn't reference removed system

---

## Task 4: Fix `README.md` — agent count, command count, file tree, commands table

**Description:** Fix 4 drift items in README.md: wrong agent count/roles, wrong command count in file tree, missing `/deepviewer` in commands table, and missing `deepviewer.md` in agent file tree.

**Files:**
- `README.md` — lines 12, 85-93, 106-114

**Steps:**
1. Read `README.md` entirely
2. Line 12: Change `three specialized agents (researcher, planner, executor)` to `four specialized agents (Vibuzo, Deepveloper, Deepsearcher, Deepviewer) through a structured pipeline of research → plan → execute → review, backed by persistent project context and session memory with approval gates.`
3. Lines 85-93 (What Gets Installed tree): 
   - Add `├── agent/core/deepviewer.md  ← Codebase analysis agent (used by /spec Review, @deepviewer)` between deepsearcher.md and commands/
   - Change `└── commands/ ← 6 command templates` to `└── commands/ ← 7 command templates`
   - The correct indentation should match the existing tree style
4. Lines 106-114 (Commands table): Add a row for `/deepviewer` between the existing rows (e.g., after `/add-context` or at the end):
   ```
   | `/deepviewer` | Full codebase audit and analysis via Deepviewer | `/deepviewer audit the error handling pattern` |
   ```

**Verification:**
- Read `README.md` — verify "three" is not present, "four" is used
- Verify `deepviewer.md` appears in the file tree
- Verify `/deepviewer` appears in the commands table
- Verify "6 command templates" is now "7 command templates"

**Acceptance:**
- ✅ `README.md` says 4 agents with correct names
- ✅ File tree includes `deepviewer.md` and shows "7 command templates"
- ✅ Commands table includes `/deepviewer`

---

## Task 5: Add missing agent references — architecture and standards docs

**Description:** Update 3 files that reference an incomplete agent count (missing Deepsearcher and/or Deepviewer).

**Files:**
- `context/architecture/agent-restructure.md` — lines 31-36, 60-64, 73
- `context/architecture/deepsearcher-research-stage.md` — lines 19, 57, 72-94
- `context/standards/vibuzo-main-session-only.md` — lines 30-36

**Steps:**

**5a. `context/architecture/agent-restructure.md`:**
1. Read the full file
2. Lines 31-36 (After architecture diagram): Update the diagram to show all 4 agents:
   ```
   User → Vibuzo (main — plans + delegates + reviews)
               │
               ├──→ /spec → Deepveloper (subtask — pure execute)
               │
               ├──→ /research → Deepsearcher (subtask — web research)
               │
               └──→ /deepviewer → Deepviewer (subtask — codebase analysis)
   ```
3. Lines 60-64 (File structure table): Add `deepsearcher.md` and `deepviewer.md` entries
4. Line 73 (end of file): If space allows, add a note about the agent system expanding

**5b. `context/architecture/deepsearcher-research-stage.md`:**
1. Read the full file
2. Line 19: Change `three-agent system` to `four-agent system` and add Deepviewer to the agent list
3. Line 57: Change `Three-agent system` to `Four-agent system`
4. Lines 72-94 (File structure section): Add `deepviewer.md` to any agent file structure listings

**5c. `context/standards/vibuzo-main-session-only.md`:**
1. Read the full file
2. Lines 30-36 (agent table): Add Deepviewer row:
   ```
   | Deepviewer | Codebase analysis and review | ✅ `true` |
   ```
3. Line 30: Change `Only Deepsearcher and Deepveloper commands use subtask: true` to `Only Deepsearcher, Deepveloper, and Deepviewer commands use subtask: true`

**Verification:**
- Read each file and confirm all 4 agents are mentioned

**Acceptance:**
- ✅ `agent-restructure.md` architecture diagram shows all 4 agents
- ✅ `deepsearcher-research-stage.md` references 4-agent system
- ✅ `vibuzo-main-session-only.md` agent table includes Deepviewer

---

## Task 6: Fix dead references and stale counts — context files

**Description:** Fix 7 minor drift items across context files: dead references to deleted commands, stale file counts, broken links, and outdated version examples.

**Files:**
- `context/index.md` — lines 38, 79
- `context/standards/versioning.md` — line 75
- `context/patterns/internal-commands-convention.md` — line 38
- `context/standards/structured-commit-body-convention.md` — lines 80-81
- `context/patterns/commit-workflow-pattern.md` — lines 78-89
- `context/patterns/session-workflow-discipline.md` — line 57

**Steps:**

**6a. `context/index.md`:**
1. Line 38: Update the architecture entry description from `Agent architecture decision: Vibuzo as main agent, Deepveloper triggered via /spec for implementation subtasks` to `Agent architecture decision: Vibuzo as main agent, Deepveloper (implementation), Deepsearcher (research), and Deepviewer (analysis) as subtask agents`
2. Line 79: Change `used by /context find` to `used for context relevance scoring`

**6b. `context/standards/versioning.md`:**
1. Line 75: Change example VERSION content from `0.2.5` to `0.3.4`

**6c. `context/patterns/internal-commands-convention.md`:**
1. Line 38: Change `Present in commands/ (11 files) but user-facing count is 10` to `Present in commands/ (8 files) but user-facing count is 7`

**6d. `context/standards/structured-commit-body-convention.md`:**
1. Line 76: Change `Footer line Part of the \`/commit\` workflow.` to `Footer line identifies the commit as generated by the workflow.`
2. Lines 80-81: Replace with: `- \`commands/new-release.md\` — The /new-release command (body format reference)`

**6e. `context/patterns/commit-workflow-pattern.md`:**
1. Lines 78-89: Update to note that `/commit` was deleted and the pattern now applies to `/new-release`. Change "Example: `/commit` Command" to "Example: `/new-release` Command (previously `/commit`)". Update references accordingly. Keep the 3-gate pattern description but update the file reference to `commands/new-release.md`.

**6f. `context/patterns/session-workflow-discipline.md`:**
1. Line 57: Remove the parenthetical `(see context/standards/timestamp-reliability.md if it exists)` since that file does not exist. Replace with just a period after "reliable."

**Verification:**
- Read each edited file at the changed lines to confirm correctness
- Check that no "context/standards/timestamp-reliability.md" references remain

**Acceptance:**
- ✅ `context/index.md` architecture entry mentions all 4 agents; no `/context find` ref
- ✅ `context/standards/versioning.md` example shows current version
- ✅ `context/patterns/internal-commands-convention.md` shows correct file count (8/7)
- ✅ `context/standards/structured-commit-body-convention.md` no longer references deleted `/commit`
- ✅ `context/patterns/commit-workflow-pattern.md` references `/new-release` instead of `/commit`
- ✅ `context/patterns/session-workflow-discipline.md` no broken link to non-existent file
