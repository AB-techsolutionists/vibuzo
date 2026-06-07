---
feature: session-management-enhancement
date: 2026-06-07
status: tasks
---

# Session Management Enhancement — Task Breakdown

## Task 1: Restructure session.md with mode routing

**Description:** Rewrite `commands/session.md` to support 5 modes routed by `$ARGUMENTS`. The existing `/session` report generation becomes one mode. View, timeline, init, find become new modes.

**Files:**
- `commands/session.md`

**Dependencies:** None

**Steps:**
1. Read the current `commands/session.md` to understand its full structure
2. Insert a mode router at the top (after frontmatter) that reads `$ARGUMENTS`:
   - Empty or `report` → Report mode (existing flow)
   - `init` → Init mode
   - `view` → View mode
   - `timeline` → Timeline mode
   - `find` → Find mode
3. Wrap the existing report-generation steps under a `## Report Mode` heading
4. Add `## Init Mode`, `## View Mode`, `## Timeline Mode`, `## Find Mode` sections (each with stub steps for now — detailed logic in later tasks)
5. Preserve all existing report-generation logic unchanged

**Acceptance:**
- ✅ `commands/session.md` routes correctly based on `$ARGUMENTS`
- ✅ All existing report-generation steps are preserved under Report mode
- ✅ Stub sections exist for the 4 new modes
- ✅ File still has valid YAML frontmatter

**Parallel:** No

---

## Task 2: Delete session-view.md and session-timeline.md

**Description:** Remove the two standalone subcommand files from both `commands/` and `.opencode/commands/`.

**Files:**
- `commands/session-view.md`
- `commands/session-timeline.md`
- `.opencode/commands/session-view.md`
- `.opencode/commands/session-timeline.md`

**Dependencies:** Task 1 (modes must exist before deleting old files)

**Steps:**
1. Remove `commands/session-view.md`
2. Remove `commands/session-timeline.md`
3. Remove `.opencode/commands/session-view.md`
4. Remove `.opencode/commands/session-timeline.md`

**Acceptance:**
- ✅ No file named `session-view.md` exists anywhere in the repo
- ✅ No file named `session-timeline.md` exists anywhere in the repo
- ✅ `commands/` no longer lists them
- ✅ `.opencode/commands/` no longer lists them

**Parallel:** No (depends on Task 1)

---

## Task 3: Implement /session init mode

**Description:** Add the init mode logic to `commands/session.md` under the `## Init Mode` section.

**Files:**
- `commands/session.md`

**Dependencies:** Task 1

**Steps:**
1. Under the `## Init Mode` heading, add these imperative steps:
   a. Read `context/index.md` to discover all available context files
   b. Verify each context directory exists (standards/, patterns/, architecture/, sessions/)
   c. If any directory is missing, scaffold it with `.gitkeep`
   d. Read `sessions/index.md` to find the latest session
   e. Read the latest session summary file
   f. Check for `## Session Compaction` section with real content
   g. Report a summary of what was loaded (number of context files, latest session date, whether compaction content was found)
   h. Do NOT generate a session report file — init is read-only
2. Wrap steps in "Do these steps NOW:" imperative style

**Acceptance:**
- ✅ `/session init` reads and reports context state without generating a file
- ✅ Missing directories are scaffolded
- ✅ Latest session + compaction status is reported
- ✅ No session file is created

**Parallel:** No (depends on Task 1)

---

## Task 4: Implement /session view and /session timeline modes

**Description:** Add view and timeline mode logic to `commands/session.md`.

**Files:**
- `commands/session.md`

**Dependencies:** Task 1

**Steps:**

For **View Mode** (`## View Mode`):
1. Parse `$ARGUMENTS` after the `view` keyword as the session reference (name or date)
2. Search `context/sessions/` for matching filenames (exact match first, then partial)
3. If found, read and display the file content
4. If not found, list available sessions and report "Session '<ref>' not found"

For **Timeline Mode** (`## Timeline Mode`):
1. Read `context/sessions/index.md`
2. Display the timeline table
3. If no entries exist, report "No session summaries found"

**Acceptance:**
- ✅ `/session view 2026-06-07` finds and displays matching session
- ✅ `/session view <partial-name>` finds partial matches
- ✅ `/session view <nonexistent>` shows helpful error with available sessions
- ✅ `/session timeline` displays the sessions index table
- ✅ Logic matches what was in the deleted standalone files

**Parallel:** No (depends on Task 1)

---

## Task 5: Add YAML frontmatter to session reports

**Description:** Extend the Report mode's file generation step to prepend YAML frontmatter with title, date, tags, status.

**Files:**
- `commands/session.md`

**Dependencies:** Task 1

**Steps:**
1. In the Report mode, find the step that writes the session file to `context/sessions/`
2. Before the write step, generate frontmatter:
   - `title:` — extract from the filename (kebab-case)
   - `date:` — today's date (YYYY-MM-DD)
   - `tags:` — derive from: files changed mentioned in session, keywords in content, common vibuzo tags (versioning, commands, context, installer, docs, sessions)
   - `status:` — always `complete` (generated after the session ends)
3. Prepend the frontmatter block before the session content when writing
4. The frontmatter is the first lines of the file, followed by a blank line, then the regular content

**Acceptance:**
- ✅ New session files start with YAML frontmatter (title, date, tags, status)
- ✅ Tags are relevant to the session content
- ✅ Existing session files are not modified
- ✅ File remains valid markdown (frontmatter + blank line + content)

**Parallel:** No (depends on Task 1)

---

## Task 6: Implement /session find mode

**Description:** Add find mode logic to `commands/session.md` for searching across session summaries.

**Files:**
- `commands/session.md`

**Dependencies:** Task 1

**Steps:**
1. Under the `## Find Mode` heading, add imperative steps:
   a. Parse `$ARGUMENTS` after the `find` keyword as the search query
   b. If query starts with `tag:`, extract the tag name and search for `- <tagname>` lines in the frontmatter tags section of session files
   c. Otherwise, use PowerShell's `Select-String` to grep all `context/sessions/*.md` for the query (excluding the index file)
   d. Display results as: filename, line number, matching line content
   e. If no matches found, report "No matches found for '<query>'"
   f. Limit output to 50 matches to avoid flooding

**Acceptance:**
- ✅ `/session find versioning` returns all sessions mentioning "versioning" with line context
- ✅ `/session find tag:versioning` returns sessions tagged with "versioning"
- ✅ `/session find <no matches>` shows clean "No matches found" message
- ✅ Results are readable and not overwhelming

**Parallel:** No (depends on Task 1)

---

## Task 7: Add auto-compaction hint to Report mode

**Description:** After generating a session report, check if the latest existing session has compaction content and prompt to load it.

**Files:**
- `commands/session.md`

**Dependencies:** Task 1

**Steps:**
1. In the Report mode, after the session file is written, add these steps:
   a. Read the second-to-latest session file (the one that existed before this new one)
   b. Search for `## Session Compaction` section
   c. If found, check if the content below it is not the default placeholder text
   d. If real content found, present:
      ```
      ── SESSION HINT ────────────────────────
      Previous session compaction content found.
      Load it as working context? (y/N):
      ───────────────────────────────────────
      ```
   e. If "y", instruct the user to paste the compaction block as starting context
   f. If "N" or anything else, skip

**Acceptance:**
- ✅ After `/session`, if compaction content exists, a hint gate is shown
- ✅ User can accept or skip
- ✅ No file changes — hint is advisory only
- ✅ No hint shown if no previous session or no compaction content

**Parallel:** No (depends on Task 1)

---

## Task 8: Update user-facing docs

**Description:** Update AGENTS.md, README.md, and context/index.md to reflect the new command structure.

**Files:**
- `AGENTS.md`
- `README.md`
- `context/index.md`
- `context/standards/session-summary-forward-template.md` (if it references session-view/timeline)

**Dependencies:** Tasks 1-7

**Steps:**
1. In `AGENTS.md`:
   - Replace the three session commands (`/session`, `/session view`, `/session timeline`) with two: `/session` and `/session init`
   - Remove `session-view.md` and `session-timeline.md` from the directory tree
   - Update command counts (11 → 10 in user-facing docs... wait, let me count)
2. In `README.md`:
   - Update commands table: merge view/timeline into the `/session` row, add `/session init` row
   - Update Quick Start step 5 if it references session commands
3. In `context/index.md`:
   - No changes needed — sessions are already listed under Files
4. In `context/standards/session-summary-forward-template.md`:
   - Check if it references session-view or session-timeline — update if so
5. Update any command counts (10 user-facing commands → still 10 since we removed 2 and added 1 new mode)

**Acceptance:**
- ✅ AGENTS.md commands table shows `/session init` and merged `/session`
- ✅ README.md commands table matches
- ✅ Directory trees and counts are accurate
- ✅ No references to session-view.md or session-timeline.md in docs

**Parallel:** No

---

## Summary

| Task | Description | Depends On | Est. Complexity |
|------|-------------|------------|-----------------|
| 1 | Restructure session.md with mode routing | — | High |
| 2 | Delete session-view.md and session-timeline.md | 1 | Low |
| 3 | Implement /session init mode | 1 | Medium |
| 4 | Implement /session view and /session timeline modes | 1 | Medium |
| 5 | Add YAML frontmatter to session reports | 1 | Low |
| 6 | Implement /session find mode | 1 | Medium |
| 7 | Add auto-compaction hint to Report mode | 1 | Low |
| 8 | Update user-facing docs | 1-7 | Medium |
