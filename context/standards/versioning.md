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

**0.0.19** — The patch is at the rollover cap (19). The next push to GitHub will bump to **0.1.0**, marking the beginning of post-dev/refinement versions.

## Bump Rules

- **Bump trigger:** Every push to the GitHub source repository (`origin/main`), not individual file changes.
- **Patch bump:** Refinements, bug fixes, documentation updates, small changes between pushes.
- **Minor bump:** Significant changes, new features, command additions, agent changes. Can also trigger from a patch rollover (19 → 0, minor +1).
- **Major bump:** When minor reaches 9 and rolls over → `1.0.0` (first live release).

## Canonical Source

The single source of truth for the version is **`.opencode/.vibuzo-version`**:

```
0.0.19 | 2026-06-07 00:42 04638cc local
```

- The semver (`0.x.x`) comes first, before the `|`
- Everything after `|` is installer metadata (date, time, commit SHA, install mode)
- Installers parse both: the semver for display, the SHA for `--update` comparison

## Where Version Appears

| Location | What Shows |
|----------|------------|
| `.opencode/.vibuzo-version` | Canonical: `0.0.19 | ...` |
| `install.ps1` | Install line, update display, success box |
| `install.sh` | Install line, update display, success box |
| Agent (vibuzo.md) | When asked "what version?" → reads and reports |
| `AGENTS.md` | Annotated in directory tree: `← Version marker (current: 0.0.19)` |

## How to Bump

1. Edit `.opencode/.vibuzo-version` — change the `0.x.x` prefix
2. Update the version in:
   - `install.ps1` (4 places: help text, install line, success box, version write)
   - `install.sh` (same 4 places)
   - `AGENTS.md` (version marker annotation)
   - `.opencode/agent/core/vibuzo.md` (version reporting rule text — if it hardcodes the version string)
3. Commit and push to GitHub

## Related

- [`standards/installer-visual-language.md`](installer-visual-language.md) — How version displays in installers
- [`architecture/installer-update-mechanism.md`](../architecture/installer-update-mechanism.md) — How the `--update` flow uses `.vibuzo-version`
