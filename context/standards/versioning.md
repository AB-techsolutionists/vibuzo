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

**0.1.1** — this version introduced a redesign the visual output of `install.ps1` and `install.sh` (mirrored implementations) to be simpler, prettier, and more compact. The redesign covers the install flow, update flow, and the "up to date" case. Both installers must remain visually identical.

This is purely a visual/cosmetic change. No functional changes to what gets installed, how files are downloaded, or how version checking works.

## Bump Rules

- **Bump trigger:** Every push to the GitHub source repository (`origin/main`), not individual file changes.
- **Patch bump:** Refinements, bug fixes, documentation updates, small changes between pushes.
- **Minor bump:** Significant changes, new features, command additions, agent changes. Can also trigger from a patch rollover (19 → 0, minor +1).
- **Major bump:** When minor reaches 9 and rolls over → `1.0.0` (first live release).

## Canonical Source

The single source of truth for the version is **`.opencode/.vibuzo-version`**:

```
0.x.x | yyyy-MM-dd HH:mm sssssss mode
```

- The semver (`0.x.x`) comes first, before the `|`
- Everything after `|` is installer metadata (date, time, commit SHA, install mode)
- Installers parse both: the semver for display, the SHA for `--update` comparison

## Where Version Appears

| Location | What Shows |
|----------|------------|
| `.opencode/.vibuzo-version` | Canonical: `<semver> \| ...` |
| `install.ps1` | `$ScriptVersion` variable at top, referenced everywhere |
| `install.sh` | `SCRIPT_VERSION` variable at top, referenced everywhere |
| Agent (vibuzo.md) | Reads `.vibuzo-version` and reports dynamically — no hardcode |
| `AGENTS.md` | Directory tree annotation: `← Version marker` (no hardcoded version) |

## How to Bump

1. Edit `.opencode/.vibuzo-version` — change the `0.x.x` prefix
2. Update the version in:
   - `install.ps1` — change the `$ScriptVersion = "..."` value at the top
   - `install.sh` — change the `SCRIPT_VERSION="..."` value at the top
   - `context/standards/versioning.md` — update the "Current Version" section
3. Commit and push to GitHub

**That's 4 spots total.** No more scattering version strings across a dozen locations.

## Related

- [`standards/installer-visual-language.md`](installer-visual-language.md) — How version displays in installers
- [`architecture/installer-update-mechanism.md`](../architecture/installer-update-mechanism.md) — How the `--update` flow uses `.vibuzo-version`
