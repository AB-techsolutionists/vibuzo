---
feature: new-release-command
created: 2026-06-07
---

# /new-release Command — Review Report

## Coverage

| Requirement | Status | Notes |
|------------|--------|-------|
| FR1: `/new-release` command file | ✅ | `commands/new-release.md` created (50 lines), synced to `.opencode/` |
| FR2: Fully automatic | ✅ | No prompts for bump type or description. Agent auto-calculates patch. |
| FR3: Version calculation (0→9 patch, 0→19 minor) | ✅ | Step 2 implements the exact rollover scheme |
| FR4: Approval gate | ✅ | Step 3 shows bump proposal, waits for y/N |
| FR5: Write VERSION | ✅ | Step 4 uses write tool to overwrite VERSION |
| FR6: Auto-generate description | ✅ | Step 5 reads latest session summary for context |
| FR7: Update versioning.md | ✅ | Step 6 inserts new entry under Current Version |
| FR8: Update README.md | ✅ | Step 7 adds row to Version History table |
| FR9: Report box with all files | ✅ | Step 8 shows Version + Files touched |
| FR7: Remove `/commit` | ✅ | `commands/commit.md` and `.opencode/commands/commit.md` deleted |
| FR8: Update references | ✅ | README table updated, counts updated to 12 |

## Accuracy

- The version counting scheme (patch 0→9, minor 0→19, major on rollover) matches the spec exactly.
- The `/new-release` command is fully automatic with no user prompts as specified.
- `/commit` command removed entirely — all functionality lives in `/new-release`.
- All file edits are surgical — no unrelated changes.

## Quality

- Command file follows the exact same format as all other commands (YAML frontmatter, `## RUN:` header, `Do these steps NOW:`).
- Steps are numbered clearly with no ambiguity.
- Rollover logic correctly handles both patch→minor and minor→major transitions.
- Approval gate format matches the project's standard.

## Gaps

- None identified. All 10 acceptance criteria are met.

## Issues

- None.
