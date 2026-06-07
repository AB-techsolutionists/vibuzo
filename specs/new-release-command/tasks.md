---
feature: new-release-command
created: 2026-06-07
---

# /new-release Command — Task Breakdown

## Task 1: Create `/new-release` command file

**Description:** Write `commands/new-release.md` with the full automatic version bump workflow.

**Files:**
- `commands/new-release.md` (create)

**Dependencies:** None

**Steps:**
1. Write YAML frontmatter with `description: Auto-bump version (no prompts, no git)` and `agent: Vibuzo`
2. Write `## RUN: /new-release` header with summary
3. Write `Do these steps NOW:` with these steps:
   - Step 1: Read `VERSION`, parse semver into `$major.$minor.$patch`
   - Step 2: Calculate new version:
     - Increment `$patch` by 1
     - If `$patch > 9`: set `$patch = 0`, increment `$minor` by 1
     - If `$minor > 19`: set `$minor = 0`, increment `$major` by 1
   - Step 3: Display proposed bump as approval gate
   - Step 4: Write `$newVersion` to `VERSION`
   - Step 5: Report box showing old → new version
4. Sync to `.opencode/commands/new-release.md`

**Acceptance:** ✅ `commands/new-release.md` exists with all 5 steps. ✅ `.opencode/commands/new-release.md` synced.

---

## Task 2: Simplify `/commit` — remove bump logic

**Description:** Edit `commands/commit.md` to remove steps 1–6 (bump logic). Re-number remaining steps 7→14 to 1→8. Update descriptions and approval gate targets.

**Files:**
- `commands/commit.md` (edit)
- `.opencode/commands/commit.md` (sync)

**Dependencies:** Task 1

**Steps:**
1. Remove steps 1–6 (Parse arguments, Display intent, Ask bump type, Calculate new version, Bump approval gate, Write VERSION)
2. Re-number remaining steps: old 7→1, 8→2, 9→3, 10→4, 11→5, 12→6, 13→7, 14→8
3. Update the command header — remove "Bumps the version" from description
4. Update the initial approval gate — remove VERSION from target, it now only targets versioning.md → README.md
5. Update the commit approval gate target: remove VERSION
6. Update git stage command to only stage `context/standards/versioning.md README.md`
7. Update the report box to remove VERSION from files list
8. Sync to `.opencode/commands/commit.md`

**Acceptance:** ✅ `/commit` starts directly with release notes. ✅ No bump logic remaining. ✅ All references to VERSION in commit gates/steps removed.

---

## Task 3: Update `README.md` commands table

**Description:** Add `/new-release` row to the commands table and update command count.

**Files:**
- `README.md` (edit)

**Dependencies:** Task 2

**Steps:**
1. Add a new row in the commands table between `/commit` and `/context init`:
   ```
   | `/new-release` | Auto-bump version (patch/minor/major) — no prompts, no git | `/new-release` |
   ```
2. Search for "11 command" references and update to "12 command"

**Acceptance:** ✅ `/new-release` appears in commands table. ✅ Command counts updated to 12.

---

## Task 4: Update `AGENTS.md` command count

**Description:** Update the command count reference in `AGENTS.md`.

**Files:**
- `AGENTS.md` (edit)

**Dependencies:** Task 2

**Steps:**
1. Find "11 command" and change to "12 command"

**Acceptance:** ✅ AGENTS.md reflects 12 commands.
