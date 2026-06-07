# Commit Command — Task Breakdown

*Tasks — 2026-06-07*

## Task 1 — Create command scaffold (YAML frontmatter + arg parsing)

**Description:** Create `commands/commit.md` with YAML frontmatter, description, agent field, and the initial steps for parsing `$ARGUMENTS` and extracting commit type + description.

**Files:**
- `commands/commit.md` (new file)

**Dependencies:** None

**Steps:**
1. Add YAML frontmatter following the existing command pattern:
   ```yaml
   ---
   description: Bump version, update release notes, and commit with detailed message (no push)
   agent: Vibuzo
   ---
   ```
2. Add instruction: `Do these steps NOW:` followed by numbered steps
3. **Step 1 — Parse arguments:**
   - Read `$ARGUMENTS` (if any)
   - If `$ARGUMENTS` matches pattern `^(feat|fix|refactor|chore|docs|style|test|perf):\s*(.+)$`, extract `commit_type` and `description` separately
   - Otherwise, use the full `$ARGUMENTS` as `description`, set `commit_type` to empty (will prompt later)
   - If `$ARGUMENTS` is empty, set both to empty
4. **Step 2 — Display intent:**
   - Show a header stating the commit workflow is starting
   - Include what was parsed (type, description) if available

**Acceptance:**
| # | Check |
|---|-------|
| ✅ | File exists at `commands/commit.md` with valid YAML frontmatter |
| ✅ | `$ARGUMENTS` parsing correctly splits `"feat: add dark mode"` into type=`feat:`, description=`add dark mode` |
| ✅ | `$ARGUMENTS` parsing correctly handles un-prefixed descriptions like `"fix login bug"` |
| ✅ | `$ARGUMENTS` parsing handles empty/no arguments |

## Task 2 — Implement version flow (bump type → calculation → gate → VERSION write → release notes)

**Description:** Add steps for bump type selection, version calculation, bump approval gate, VERSION file write, and versioning.md release notes update.

**Files:**
- `commands/commit.md` (edit — append steps after Task 1 steps)

**Dependencies:** Task 1

**Steps:**
1. **Step 3 — Bump type prompt:**
   - Ask user: "Bump type? (p)atch, (m)inor, (c)ustom [p]:"
   - Read response. Default to `patch` if empty
   - If `custom`, ask for explicit version string (e.g., "0.2.0")

2. **Step 4 — Calculate new version:**
   - Read `VERSION` file → parse semver into `major.minor.patch` integers
   - If `patch`: increment patch by 1. If patch would exceed 19, set patch=0, increment minor.
   - If `minor`: increment minor by 1, set patch=0. If minor would exceed 9, set minor=0, increment major to 1.
   - If `custom`: use the user-provided string as-is
   - Store: `$oldVersion`, `$newVersion`

3. **Step 5 — Bump approval gate:**
   - Display in a code-block gate:
     ```
     ── APPROVAL GATE ──────────────────────
     Action: Version bump
     Target: VERSION → context/standards/versioning.md
     Details: Bump 0.x.x → 0.y.y (<bump type>)
     ───────────────────────────────────────
     Approve? (y/N):
     ```

4. **Step 6 — Write VERSION:**
   - If gate approved, write `$newVersion` to `VERSION` file using write tool
   - If gate rejected, stop and report "Commit cancelled."

5. **Step 7 — Release notes description:**
   - If description was not provided in args, prompt: "Describe the changes (single line):"
   - Read user input. If still empty, use "No description provided."

6. **Step 8 — Update versioning.md:**
   - Read `context/standards/versioning.md`
   - Find the "Current Version" section header line
   - Insert a new bullet after the section header in format: `**<newVersion>** — <description> (YYYY-MM-DD).`
   - Use the edit tool to insert the line

**Acceptance:**
| # | Check |
|---|-------|
| ✅ | Bump prompt shows and accepts p/m/c with default patch |
| ✅ | Patch bump: 0.1.5 → 0.1.6 |
| ✅ | Minor bump: 0.1.5 → 0.2.0 |
| ✅ | Patch rollover: 0.1.19 → 0.2.0 |
| ✅ | Minor rollover: 0.9.19 → 1.0.0 |
| ✅ | Gate pauses before any file writes |
| ✅ | VERSION file updated on approval |
| ✅ | versioning.md gets new entry prepended under "Current Version" |
| ✅ | Release notes prompt shows when no args given |

## Task 3 — Implement commit flow (commit type → message building → commit gate → git commit → report box)

**Description:** Add steps for commit type selection (if not detected), commit message construction, commit approval gate, git commit execution, and final report box with push instructions.

**Files:**
- `commands/commit.md` (edit — append steps after Task 2 steps)

**Dependencies:** Task 2

**Steps:**
1. **Step 9 — Commit type selection (if needed):**
   - If `commit_type` was not auto-detected from args, prompt: "Commit type? (feat/fix/refactor/chore/docs/style/test/perf) [chore]:"
   - Read response. Default to `chore:` if empty
   - Format as `<type>:`

2. **Step 10 — Build commit message:**
   - Subject: `<commit_type> <description>` (e.g., `feat: add dark mode`)
   - Body: auto-generated structured description of ALL changes made during this `/commit` run:
     - List each file that was modified with a brief human-readable explanation of what changed and why (e.g., `- Modified VERSION: bumped 0.1.5 → 0.1.6`, `- Updated versioning.md: added 0.1.6 entry with release notes`)
     - End with a summary paragraph in present tense, imperative mood, explaining the change holistically (e.g., "This updates the version and release notes in preparation for the new release.")
     - Written in natural language for developers to read smoothly
   - Footer: "Part of the \`/commit\` workflow."
   - Store: `$commitSubject`, `$commitBody`, `$fullCommitMessage`

3. **Step 11 — Commit approval gate:**
   - Display the full proposed commit message inside a code-block gate:
     ```
     ── APPROVAL GATE ──────────────────────
     Action: Git commit
     Target: VERSION + context/standards/versioning.md
     Details:
     Subject: feat: add dark mode
     
     Body:
     - Modified VERSION: bumped 0.1.5 → 0.1.6
     - Updated versioning.md: added 0.1.6 entry
       documenting the dark mode implementation
     
     This bumps the version and updates release notes
     for the dark mode feature. The patch increment
     reflects a backward-compatible enhancement.
     
     Part of the `/commit` workflow.
     ───────────────────────────────────────
     Approve commit? (y/N):
     ```

4. **Step 12 — Git commit:**
   - If gate approved, run:
     ```bash
     git add VERSION context/standards/versioning.md
     git commit -m "$commitSubject" -m "$commitBody"
     ```
   - DO NOT run `git push`
   - If gate rejected, stop and report "Commit cancelled."

5. **Step 13 — Report box:**
   - Get the abbreviated commit hash from `git rev-parse --short HEAD`
   - Display a VIBUZO-style report box:
     ```
     ╔══════ Commit Complete ══════════════════════════════════╗
     ║                                                         ║
     ║  Commit:    <hash>                                      ║
     ║  Version:   0.x.x → 0.y.y                              ║
     ║  Files:     VERSION, versioning.md                      ║
     ║  Subject:   <commit subject>                            ║
     ║                                                         ║
     ║  ─────────────────────────────────────────────           ║
     ║                                                         ║
     ║  ╔══════════════════════════════════════════╗            ║
     ║  ║  Push manually when ready:               ║            ║
     ║  ║  git push                                ║            ║
     ║  ╚══════════════════════════════════════════╝            ║
     ║                                                         ║
     ╚═════════════════════════════════════════════════════════╝
     ```

**Acceptance:**
| # | Check |
|---|-------|
| ✅ | Commit type prompt shows only when not auto-detected from args |
| ✅ | Default commit type is `chore:` |
| ✅ | Commit message follows `<type>: <description>` format |
| ✅ | Commit gate shows full message and pauses for approval |
| ✅ | `git add` stages only VERSION + versioning.md |
| ✅ | `git commit` executes with subject + body + footer |
| ✅ | `git push` is NEVER called — not even --dry-run |
| ✅ | Report box shows commit hash, version, files, subject, push instruction |
| ✅ | On gate reject at any point, workflow stops cleanly with "Commit cancelled." |
