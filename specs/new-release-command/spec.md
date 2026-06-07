---
feature: new-release-command
created: 2026-06-07
status: draft
---

# /new-release Command — Specification

## Principles

- **Single responsibility**: The command does exactly one thing — auto-bump the version in `VERSION`. Nothing else.
- **Fully automatic**: No user prompts. The agent derives everything from context — bump type, description, all decisions.
- **Minimal surface**: No git operations, no file edits beyond `VERSION`, no release notes, no commit messages.
- **Consistent with existing conventions**: Follows the same command file format as all other commands (YAML frontmatter, `Do these steps NOW:` block, `$ARGUMENTS` in plain text).
- **Approval gates respected**: Operates within the project's `approval_level` setting.

## Overview

Create a new `/new-release` command that extracts and simplifies the version bump logic currently embedded in `/commit`. The new command is fully automatic — it reads the current version, auto-increments the patch, writes the new version to `VERSION`, and reports the result. No user input required.

This refactoring also simplifies `/commit` by removing the bump logic from it, leaving `/commit` to focus on release notes → versioning.md → README.md → git commit.

## Version Counting Scheme

The command uses this auto-increment scheme, without prompting the user:

```
Patch (3rd digit):  0 → 9, rolls over at 9 → minor +1, patch = 0
Minor (2nd digit):  0 → 19, rolls over at 19 → major +1, minor = 0
Major (1st digit):  No max, increments on minor rollover
```

Example progression:
```
0.0.0 → 0.0.1 → ... → 0.0.9 → 0.1.0 → 0.1.1 → ... → 0.19.9 → 1.0.0
```

## User Stories

- As a developer, I want to bump the version with a single command and no prompts.
- As a maintainer, I want `/commit` to only handle the commit-related steps after a version is already set.
- As a user, I want a lightweight automatic command that increments the version and nothing else.

## Functional Requirements

### FR1: `/new-release` command file
- Create `commands/new-release.md` as a standard command file with YAML frontmatter and imperative instructions.
- Sync to `.opencode/commands/new-release.md` via installers.

### FR2: No user prompts — fully automatic
- The agent reads the current `VERSION`, auto-calculates the next patch, and writes it.
- No bump type selection prompt. Always patch increment unless rollover occurs.
- No description prompt. Description is auto-generated from session context or defaults to "No description provided."

### FR3: Version calculation
- Read `VERSION` file, parse semver `$major.$minor.$patch`.
- Increment `$patch` by 1:
  - If `$patch > 9`: set `$patch = 0`, increment `$minor` by 1.
  - If `$minor > 19`: set `$minor = 0`, increment `$major` by 1.
- Store `$oldVersion` = original semver, `$newVersion` = computed semver.

### FR4: Approval gate
- Show proposed bump (`oldVersion → newVersion`), wait for approval before writing.

### FR5: Write VERSION
- Overwrite `VERSION` file with new version string.

### FR6: Report
- Show a compact completion box with old → new version.

### FR7: Simplify `/commit`
- Remove bump logic (currently steps 1–6) from `commands/commit.md`.
- `/commit` starts directly with release notes.
- Update `/commit`'s description and approval gate targets.

### FR8: Update command references
- Update `README.md` commands table to include `/new-release`.
- Update `AGENTS.md` command tree count if present.
- Update command count references from 11 → 12.

## Acceptance Criteria

✅ `/new-release` command file exists at `commands/new-release.md`.
✅ Runs fully automatic — no user prompts for bump type or description.
✅ `VERSION` file is updated with new version following the 0→9 patch / 0→19 minor scheme.
✅ Approval gate prompts before writing.
✅ Completion report shows old → new version.
✅ `/commit` no longer contains bump logic.
✅ `/commit` still works for release notes → versioning.md → README.md → git commit.
✅ README.md commands table updated.
✅ Command count references updated (11 → 12 where applicable).

## Out of Scope

- No user prompts of any kind.
- No git operations (add, commit, push).
- No release notes in `versioning.md` or `README.md` — those stay in `/commit`.
- No changes to the overall versioning scheme — only the /new-release command uses this 0→9/0→19 scheme.
