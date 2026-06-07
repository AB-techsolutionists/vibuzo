---
tags:
  - commit
  - git
  - commit-message
  - version-bump
scope: Format for git commit messages when user says "commit"
when: User says "commit" or "commit and push" or "now commit"
---

# Commit Message Format

When the user says **"commit"** (or "commit and push", "now commit", etc.), follow this exact commit message format. This applies to every commit — not just version bumps.

## Format Template

```
feat: <short summary of main change>

## Version & Scheme
- <version-related changes>

## <Feature/Command> Changes
- <feature-specific bullet points>

## <Other category>
- <other changes>
```

## Example

```
feat: version bump 0.2.5→0.2.6, new-release command, versioning scheme sync

## Version & Scheme
- Bumped VERSION 0.2.5→0.2.6 (patch)
- Synced versioning.md rollover scheme to match /new-release:
  Patch 0→19 → 0→9, Minor 0→9 → 0→19 (table, examples, bump rules)

## New /new-release Command (internal dev tool)
- Created commands/new-release.md: auto-bumps VERSION, updates versioning.md
  and README.md, generates release description from latest session
- Excluded from installer arrays (install.ps1, install.sh) — not user-facing
- Excluded from AGENTS.md and README.md commands tables
- /spec pipeline artifacts saved to specs/new-release-command/

## Removed /commit Command
- Deleted commands/commit.md entirely
- Removed from README.md (commands table, Quick Start step 4, pipeline description)
- Removed from AGENTS.md commands table

## README Overhaul
- Replaced three numbered paragraphs with compact table-based intro
- Fixed mechanism descriptions to match their names
- Cleaned up all /commit references

## AGENTS.md Updates
- Updated commands table: removed /commit and /new-release (10 user-facing)
- Updated directory tree count 12→10

## Context & Patterns
- Saved session: 2026-06-07-new-release-command-readme-overhaul
- Saved pattern: internal-commands-convention.md
```

## Category Naming Rules

- Group changes by logical category (what changed, not which file)
- Use `## <Category>` as section headings
- Use `- <bullet>` for individual changes, each on its own line or wrapped with indentation
- First line after `feat:` is always the summary — use sentence case, no period

## Version Bump Pattern

When the commit includes a version bump, the first section is always `## Version & Scheme` with bullets showing:
- The before→after values
- Any scheme/sync changes

## What to Include

Include ALL uncommitted changes, organized by category. Do not omit files. Do not batch unrelated changes into one bullet.
