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

Vibuzo uses standard semver (`MAJOR.MINOR.PATCH`) matching the same format as opencode itself (e.g., `1.16.0`).

```
0.<minor>.<patch>
```

## The Scheme

| Position | Name | Counts | Max | Rollover To |
|----------|------|--------|-----|-------------|
| 3rd | Patch | 0 → 19 | 19 | Next minor |
| 2nd | Minor | 0 → 9 | 9 | 1.0.0 |
| 1st | Major | 0 | — | 1.0.0 at minor rollover |

### Example Progression

```
0.0.0  through 0.0.19   ← development (patch 0→19)
0.1.0  through 0.1.19   ← post-dev refinement (minor 1, patch 0→19)
...
0.9.0  through 0.9.19   ← post-dev refinement (minor 9 max)
1.0.0                    ← first major live release
```

### Current Version

**0.2.1** — Enhance context system with YAML frontmatter, semantic search, and auto-pattern scanning (2026-06-07).
**0.2.0** — New `/commit` command: full pipeline (spec → plan → tasks → implementation → review) creating a 13-step command for version bump → release notes → structured commit → no-push report. Fixed `/spec` feature naming (short kebab-case names). Saved 4 context files (installer-visual-language, feature-naming-convention, structured-commit-body-convention, commit-workflow-pattern).
**0.1.5** — Box renderer double-line borders: all installer boxes (`Write-Box`/`print_box`) now use `╔═╗║╚═╝` matching the VIBUZO banner style, fixed at 59-char total width, status lines wrapped in header boxes.
**0.1.4** — Box renderer emoji width bug fix: `Write-Box` (PowerShell) and `print_box` (Bash) now account for emoji double-width rendering (U+2700–U+27BF characters count as 1 char but render as 2 terminal columns).
**0.1.3** — Documentation sync: added version history to README, fixed `install.sh` syntax corruption from SHA removal, updated agent version check to fetch from `VERSION` file.

## Bump Rules

- **Bump trigger:** Every push to the GitHub source repository (`origin/main`), not individual file changes.
- **Patch bump:** Refinements, bug fixes, documentation updates, small changes between pushes.
- **Minor bump:** Significant changes, new features, command additions, agent changes. Can also trigger from a patch rollover (19 → 0, minor +1).
- **Major bump:** When minor reaches 9 and rolls over → `1.0.0` (first live release).

## Canonical Source

The single source of truth for the version is the **`VERSION` file at the repo root**. Both installers fetch this file from GitHub at runtime:

```
0.2.1
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
3. Commit and push to GitHub

**That's 2 spots total.** Installers fetch dynamically — no manual installer changes needed for a version bump.

## Related

- [`standards/installer-visual-language.md`](installer-visual-language.md) — How version displays in installers
- [`architecture/installer-update-mechanism.md`](../architecture/installer-update-mechanism.md) — How the `--update` flow uses `.vibuzo-version`
