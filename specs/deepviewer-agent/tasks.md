# Deepviewer Agent — Task Breakdown

**Feature:** deepviewer-agent
**Date:** 2026-06-08

---

## Task 1: Create Deepviewer Agent Definition

**Description:** Create the Deepviewer subagent definition file following the same pattern as Deepsearcher.

**Files:**
- `.opencode/agent/core/deepviewer.md` — New agent definition

**Steps:**
1. Read `.opencode/agent/core/deepsearcher.md` as a template for subagent structure
2. Create `.opencode/agent/core/deepviewer.md` with:
   - `name: Deepviewer`
   - `description: "Codebase analysis and review agent — performs full codebase audits, session/context cross-referencing, git history analysis, and /spec Review phase"`  
   - `mode: subagent`
   - `temperature: 0.1`
   - `approval_level: 3` (matching Vibuzo)
   - Appropriate permissions for reading all project files

**Verification:**
- Run `Get-Content .opencode/agent/core/deepviewer.md` and confirm YAML frontmatter is valid

**Acceptance:**
- ✅ `.opencode/agent/core/deepviewer.md` exists with valid YAML frontmatter
- ✅ Follows same structure as deepsearcher.md

---

## Task 2: Create `/deepviewer` Command File

**Description:** Create the main command file that implements the Deepviewer multi-phase audit pipeline and @deepviewer inline support.

**Files:**
- `commands/deepviewer.md` — New command file

**Steps:**
1. Read existing command files (e.g., `commands/research.md`) for format reference — YAML frontmatter + `Do these steps NOW:` block + `$ARGUMENTS` support
2. Create `commands/deepviewer.md` with YAML frontmatter:
   - `description: "Run a full codebase audit or ask a question about the project"`
   - `agent: Deepviewer`
   - `subtask: true` (runs in background for full audit)
3. Write the `Do these steps NOW:` block implementing the full audit pipeline:
   - Parse `$ARGUMENTS` — if user provided a question, run inline mode (targeted answer in chat, no file)
   - If no question or explicit `/deepviewer audit`, run full pipeline:
   - **Phase 1 — Structural Scan:**
     - Use `glob **/*` to get complete file tree (excluding .git, node_modules, .opencode/mirrors)
     - Categorize files by type (.md, .ps1, .sh, .json, .jsonc, etc.)
     - Output: file tree summary
   - **Phase 2 — Pattern-Based Analysis:**
     - `grep` for hardcoded secrets/credentials (patterns: `password\s*=`, `api_key\s*=`, `secret\s*=`, `token\s*=`, `-----BEGIN`)
     - `grep` for TODO/FIXME/HACK/XXX/NOTE markers
     - `grep` for performance concerns (nested loops in scripts, large file reads)
     - `grep` for duplicated code (identical blocks across files)
     - Check for dead code (unused exports, orphaned functions)
   - **Phase 3 — Session/Context Cross-Reference:**
     - Read all files in `context/sessions/`, `context/architecture/`, `context/standards/`, `context/patterns/`
     - For each context file, check file references against actual codebase (grep for referenced file names, APIs, concepts)
     - Flag context files that reference things that no longer exist
     - Flag session decisions that don't match current implementation
   - **Phase 4 — Git History Analysis:**
     - `git log --oneline --since="6 months ago"` for recent commit density
     - `git shortlog -sn` for contributor analysis
     - `git log --format="%s"` for commit message trend analysis
     - `git diff --stat` on major commits for churn hotspots
     - Identify project evolution phases (initial creation, feature additions, refactoring, stabilization)
   - **Phase 5 — Report Generation:**
     - Generate `context/reports/audit-report-YYYY-MM-DD.md`
     - Sections: Executive Summary, Methodology, Project Overview & Evolution, Architecture Map, Findings by Category, Strategic Observations, Outdated Context Inventory, Remediation Roadmap, Appendix
     - Each finding: severity (Critical/High/Medium/Low), affected files (with line numbers), description, evidence, recommended action
4. Include handling for `@deepviewer` inline mode:
   - If `$ARGUMENTS` contains a question (not empty and not "audit"), run targeted analysis
   - Determine question scope from keywords
   - Run relevant subset of phases 1-4
   - Return answer in chat (no file written)

**Verification:**
- Read the file and confirm YAML frontmatter + Do these steps NOW: block are properly formatted
- Confirm all 5 phases are present
- Confirm inline mode detection logic exists

**Acceptance:**
- ✅ `commands/deepviewer.md` exists with valid YAML frontmatter
- ✅ All 5 analysis phases are defined
- ✅ `$ARGUMENTS` parsing distinguishes between inline question and full audit
- ✅ Report generation writes to `context/reports/audit-report-YYYY-MM-DD.md`

---

## Task 3: Update AGENTS.md

**Description:** Add Deepviewer to the Three-Agent System table, file tree, and commands table in AGENTS.md.

**Files:**
- `AGENTS.md` — Edit existing file

**Steps:**
1. Read AGENTS.md
2. In the Three-Agent System table (lines 7-11), add a 4th row:
   ```
   | **Deepviewer** | Codebase analysis and review — audit pipeline, session/context cross-ref, git history, /spec Review phase | Subtask (`mode: subagent`) |
   ```
3. In the Agent Structure tree, add a line under `.opencode/agent/core/`:
   ```
   │   ├── agent/core/deepviewer.md   ← Codebase analysis and review sub-agent
   ```
4. In the Commands table, add a new row:
   ```
   | `/deepviewer <query>` | Full codebase audit or targeted codebase question | subtask |
   ```
5. Add `@deepviewer` inline to the inline command description

**Verification:**
- Read AGENTS.md and confirm all 3 sections are updated

**Acceptance:**
- ✅ Three-Agent System table has row for Deepviewer
- ✅ File tree lists deepviewer.md under agent/core/
- ✅ Commands table has `/deepviewer` entry

---

## Task 4: Create Reports Directory and Update Context Index

**Description:** Create `context/reports/` directory and add it to `context/index.md`.

**Files:**
- `context/index.md` — Edit existing file
- `context/reports/` — New directory

**Steps:**
1. Create directory: `New-Item -ItemType Directory -Path context/reports/ -Force`
2. Read `context/index.md`
3. Under `### Sessions`, add a new line or create a new section `### Reports`:
   ```
   ### Reports
   - `reports/` — Auto-generated audit reports (via /deepviewer)
   ```
4. Add a `reports/` entry after the `sessions/` directory entry

**Verification:**
- Test-Path `context/reports/` returns True
- Read `context/index.md` and confirm reports entry exists

**Acceptance:**
- ✅ `context/reports/` directory exists
- ✅ `context/index.md` lists `reports/` directory

---

## Task 5: Update /spec to Delegate Review Phase to Deepviewer

**Description:** Modify the `commands/spec.md` Review phase to delegate to Deepviewer instead of dispatching a "general" subagent.

**Files:**
- `commands/spec.md` — Edit existing file

**Steps:**
1. Read `commands/spec.md`
2. Locate the Review section that dispatches reviewer subagents
3. Replace the "general" subagent invocation with Deepviewer:
   - Change `subagent_type "general"` to `subagent_type "Deepviewer"` (or use task() with the deepviewer agent)
   - Keep the same inline prompt structure (spec compliance + code quality review instructions)
   - Maintain the same output format expected by the pipeline
4. Ensure the spec doc, plan, tasks, and implemented file paths are passed as context to Deepviewer
5. Keep the two-stage review structure (Stage 1: spec compliance, Stage 2: code quality)

**Verification:**
- Read `commands/spec.md` and confirm the Review phase now delegates to Deepviewer
- Confirm the same prompt structure is maintained

**Acceptance:**
- ✅ Review phase delegates to Deepviewer (not "general" agent)
- ✅ Both spec compliance and code quality review stages are preserved
- ✅ Output format matches what the pipeline expects

---

## Task 6: Update Installers

**Description:** Add deepviewer to the command file arrays in both installers so the new files are recognized and synced.

**Files:**
- `install.ps1` — Edit existing file
- `install.sh` — Edit existing file

**Steps:**
1. Read `install.ps1`
2. Find the `$commandFiles` or equivalent array of command file names
3. Add `"deepviewer"` to the array
4. Read `install.sh`
5. Find the equivalent array of command file names
6. Add `"deepviewer"` to the array

**Verification:**
- Grep each installer for "deepviewer" to confirm it was added

**Acceptance:**
- ✅ `install.ps1` lists deepviewer in its command file array
- ✅ `install.sh` lists deepviewer in its command file array
