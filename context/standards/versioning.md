---
tags:
  - versioning
  - semver
  - version-bump
  - release
scope: Version tracking, bumping, and release management
when: Bumping version numbers or checking the version scheme
---

# Vibuzo Versioning

**Date:** 2026-06-07
**Status:** Active

## Format

Vibuzo uses standard semver (`MAJOR.MINOR.PATCH`).

```
0.<minor>.<patch>
```

## The Scheme

| Position | Name | Counts | Max | Rollover To |
|----------|------|--------|-----|-------------|
| 3rd | Patch | 0 → 9 | 9 | Next minor |
| 2nd | Minor | 0 → 19 | 19 | 1.0.0 |
| 1st | Major | 0 | — | 1.0.0 at minor rollover |

### Example Progression

```
0.0.0  through 0.0.9    ← development (patch 0→9)
0.1.0  through 0.1.9    ← post-dev refinement (minor 1, patch 0→9)
...
0.19.0 through 0.19.9   ← post-dev refinement (minor 19 max)
1.0.0                    ← first major live release
```

### Current Version

**0.0.18** — Batch 1 skill import: interview-me and idea-refine protocols (2026-06-16).
**0.0.17** — Five-axis code review framework and OWASP-informed security depth for Deepviewer (2026-06-15).
**0.0.16** — README mechanism table cleanup and reorder (2026-06-09).
**0.3.9** — Integration installer bug fix and installer sync (2026-06-09).
**0.3.8** — Interactive installer wizard with detection modules, progress indicators, and documentation drift fixes (2026-06-09).
**0.3.7** — Internal command cleanup, release notes convention update (2026-06-09).
**0.3.6** — README restructure, new-release detailed release notes, internal command cleanup (2026-06-09).
**0.3.5** — Documentation drift fixes across 15 files (approval_level cleanup, agent count corrections, dead ref removal) (2026-06-09).
**0.3.4** — Approval gate refactor (native popups), created agents/deepviewer.md source, synced installers (2026-06-09).
**0.3.3** — Deepviewer codebase audit, 3 remediation fixes (docs drift, legacy header), version bump 0.3.2→0.3.3 (2026-06-09).
**0.3.2** — Created Deepviewer codebase analysis and review agent: full audit pipeline (structural scan, pattern analysis, session/context cross-reference, git history), /spec Review phase delegation, updated AGENTS.md, context index, and installers (2026-06-08).
**0.3.1** — Session auto-compaction: `/session` now auto-generates the Session Compaction block (styled box with Goal, Constraints, Progress, Key Decisions, Next Steps, Critical Context, Relevant Files), eliminating manual `/compact` → paste step. Updated all docs for auto-compaction workflow (2026-06-08).
**0.3.0** — Split session command into two standalone command files: session.md (report generation) and session-init.md (agent context initialization). Removed routing logic, updated all docs and installers (2026-06-08).
**0.2.9** — Context command consolidation: deleted context-append/harvest/find, kept context-init as the only context command. Saved context-init-standalone architecture record from session scan (2026-06-07).
**0.2.8** — Context command consolidation: deleted context-append/harvest/find, kept context-init as the only context command (2026-06-07).
**0.2.7** — Session management enhancement: restructured session.md (report + init only), deleted session-view/timeline, updated installers and docs, added YAML frontmatter to reports, synced context standards (2026-06-07).
**0.2.6** — Synced versioning.md rollover scheme to match /new-release (patch 0→9, minor 0→19) (2026-06-07).
**0.2.5** — Finalize session documentation and save installer-content-preservation-dedup pattern (2026-06-07).
**0.2.4** — Fixed installer AGENTS.md rules duplication: added dedup guard to both installers; cleaned up duplicate rule in AGENTS.md (2026-06-07).
**0.2.3** — Update AGENTS.md structure, tagline, and commands section; update commit command to include README in bump workflow; add execution instructions for commands (2026-06-07).
**0.2.2** — Fixed missing `agents/deepsearcher.md` causing installer 404; added deepsearcher to path-rewriting and Claude Code copy in both installers (2026-06-07).
**0.2.1** — Enhance context system with YAML frontmatter, semantic search, and auto-pattern scanning (2026-06-07).
**0.2.0** — New `/commit` command: full pipeline (spec → plan → tasks → implementation → review) creating a 13-step command for version bump → release notes → structured commit → no-push report. Fixed `/spec` feature naming (short kebab-case names). Saved 4 context files (installer-visual-language, feature-naming-convention, structured-commit-body-convention, commit-workflow-pattern).
**0.1.5** — Box renderer double-line borders: all installer boxes (`Write-Box`/`print_box`) now use `╔═╗║╚═╝` matching the VIBUZO banner style, fixed at 59-char total width, status lines wrapped in header boxes.
**0.1.4** — Box renderer emoji width bug fix: `Write-Box` (PowerShell) and `print_box` (Bash) now account for emoji double-width rendering (U+2700–U+27BF characters count as 1 char but render as 2 terminal columns).
**0.1.3** — Documentation sync: added version history to README, fixed `install.sh` syntax corruption from SHA removal, updated agent version check to fetch from `VERSION` file.

## Bump Rules

- **Bump trigger:** Every push to the GitHub source repository (`origin/main`), not individual file changes.
- **Patch bump:** Refinements, bug fixes, documentation updates, small changes between pushes.
- **Minor bump:** Significant changes, new features, command additions, agent changes. Can also trigger from a patch rollover (9 → 0, minor +1).
- **Major bump:** When minor reaches 19 and rolls over → `1.0.0` (first live release).

## Canonical Source

The single source of truth for the version is the **`VERSION` file at the repo root**. Both installers fetch this file from GitHub at runtime:

```
0.3.7
```

Installers write a local copy to **`.opencode/.vibuzo-version`** with install metadata:

```
0.x.x | yyyy-MM-dd HH:mm mode
```

- Semver comes first, before the `|`
- Everything after `|` is installer metadata (date, time, install mode)
- No commit SHA tracked — version comparison uses semver strings only

## Where Version Appears

| Location | What Shows |
|----------|------------|
| `VERSION` (repo root) | **Canonical source**: single semver line `0.x.x` |
| `.opencode/.vibuzo-version` | Local copy: `<semver> \| <date> <time> <mode>` |
| `install.ps1` | Fetches version dynamically from `$RawUrl/VERSION` |
| `install.sh` | Fetches version dynamically from `$RAW_URL/VERSION` |
| Agent (vibuzo.md) | Reads `.vibuzo-version` and reports dynamically |
| `AGENTS.md` | Directory tree: `← Version marker` (no hardcoded version) |

## How to Bump

1. Edit the `VERSION` file at the repo root — change the `0.x.x` value
2. Update `context/standards/versioning.md` — update the "Current Version" section
3. Update `README.md` — add a row to the "Version History" table
4. Commit and push to GitHub

**That's 3 spots total.** Installers fetch dynamically — no manual installer changes needed for a version bump.

## Related

- [`standards/installer-visual-language.md`](installer-visual-language.md) — How version displays in installers
- [`architecture/installer-update-mechanism.md`](../architecture/installer-update-mechanism.md) — How the `--update` flow uses `.vibuzo-version`
