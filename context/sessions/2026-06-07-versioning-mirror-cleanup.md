# versioning-mirror-cleanup

*Session summary — 2026-06-07 | 16 messages | 34 files touched | 3 commits*

## Session Summary
Add version tracking to Vibuzo framework (0.x.x semver), remove source-mirror sync convention, and capture session context candidates.

## Constraints & Preferences
- **Version format:** `0.<minor>.<patch>` semver matching opencode's `MAJOR.MINOR.PATCH` — no `v` prefix
- **Patch cap:** 0→19 then rolls over to minor bump; **Minor cap:** 0→9 then rolls to `1.0.0`
- **Bump trigger:** Every push to GitHub source repo — not per-file-change
- **`.opencode/` refresh:** Solely via `install.ps1`/`install.sh --update` — no manual mirroring
- **Large doc gate:** Files >200 lines need size preview and user approval before writing (lesson from 416-line README)

## Progress

### Done
- **Set up version tracking** — `.opencode/.vibuzo-version` now `0.0.19 | 2026-06-07 00:42 04638cc local`; both installers show version in install line, update display, success box, and version write; version reporting rule added to `agents/vibuzo.md` and `.opencode/agent/core/vibuzo.md`
- **Created `context/standards/versioning.md`** — documents full scheme: format, caps, bump rules, canonical source, where version appears, how to bump
- **Updated `AGENTS.md`** — version marker annotation now `(current: 0.0.19)`
- **Deleted `context/standards/source-mirror-synchronization.md`** — entire convention abolished
- **Purged mirror references** from 8 active files: `context/index.md`, `context/architecture/agent-restructure.md`, `context/architecture/approval-gates.md`, `context/architecture/deepsearcher-research-stage.md`, `context/standards/imperative-command-style.md`, `context/standards/terminology-change-process.md`, `context/standards/command-parameter-notation.md`, `context/standards/installer-visual-language.md`
- **Created `context/patterns/large-document-size-gate.md`** — pattern for gating large generated documents with size preview before writing
- **Committed and pushed 3 commits**: `a575ff0` (version tracking), `453a92f` (mirror removal + size gate), plus prior `04638cc` (Deepsearcher refinement from previous session)
- **Context append round 2** — no new candidates found; everything already documented

### In Progress
*(none)*

### Blocked
*(none)*

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Version scheme: 0.x.x** — `0.<minor>.<patch>`, patch 0→19, minor 0→9, then `1.0.0`. Current: `0.0.19` | Matches opencode's own semver style; rollover prevents versions from ballooning |
| 2 | **Bump on GitHub push** — every push to `origin/main`, not per-file-change | Version is a release marker, not an edit counter |
| 3 | **`.opencode/` is installer-managed only** — source files live in `agents/` and `commands/`; installer copies on install, overwrites on `--update` | Eliminates manual sync errors; `.opencode/` is local-only, not git-tracked |
| 4 | **Source-mirror sync abolished** — the `source-mirror-synchronization.md` standard file deleted; all 8 active-file references purged | Redundant with installer `--update`; was a source of drift and confusion |
| 5 | **Large document size gate** — generated docs >200 lines need size preview + approval before write | Lesson from 416-line README that was immediately discarded |
| 6 | **Version format in `.vibuzo-version`** — `<semver> \| <timestamp> <sha> <mode>` (e.g. `0.0.19 | 2026-06-07 00:42 04638cc local`) | Backward-compatible with installer's `--update` version detection |

## Forward Context

- **Next push bumps to 0.1.0** — `0.0.19` is at patch rollover. Update: `.vibuzo-version`, `install.ps1` (4x), `install.sh` (4x), `AGENTS.md`, `agents/vibuzo.md`, `.opencode/agent/core/vibuzo.md`.
- **`.opencode/` is NOT git-tracked** — edit source files in `agents/`, deploy via installer `--update`.

## Next Steps

1. Run `/compact` in opencode TUI (immediately after this summary)
2. Copy the compaction output and paste it into the **Session Compaction** section below
3. That block becomes the starting context for the next `/new` session

## Hot Files

| File | Why Hot |
|------|---------|
| `.opencode/.vibuzo-version` | Will be updated on next version bump |
| `install.ps1` | 4 strings to bump — highest miss risk |
| `install.sh` | Same — must stay in sync with ps1 |
| `agents/vibuzo.md` | Version reporting rule (hardcoded string) |
| `AGENTS.md` | Version marker annotation |

## Timeline Entry

| 2026-06-07 | 01:29 | `versioning-mirror-cleanup` | Established 0.x.x version scheme, deleted source-mirror convention, saved large-document-size-gate pattern. 3 commits pushed. |

## Session Compaction

## Goal
- Add version tracking to Vibuzo framework (0.x.x semver), remove source-mirror sync convention, capture session context candidates, and consolidate session summary template into forward-looking 7-section structure

## Constraints & Preferences
- Version format: `0.x.x` semver matching opencode's `MAJOR.MINOR.PATCH` (no `v` prefix)
- Patch counts 0→19 then rolls over, minor counts 0→9 then rolls to `1.0.0`
- Version bumps on push to GitHub source repo, not per-file-change
- `.opencode/` is local-only, not git-tracked; refreshed solely by `install.ps1`/`install.sh --update`
- "Large document size gate" pattern saved -- README was 416 lines and discarded as "too big"
- Session summary uses 7 forward-looking sections: Session Summary, Constraints & Preferences, Progress, Forward Decisions, Forward Context, Next Steps, Hot Files
- Do NOT include Chronological Log, File Manifest, Commands Invoked, or State sections -- `/compact` covers those

## Progress
### Done
- **Set up version tracking** -- `.opencode/.vibuzo-version` now `0.0.19 | 2026-06-07 00:42 04638cc local`; both installers show version in install line, update display, success box, and version write; version reporting rule added to both `agents/vibuzo.md` and `.opencode/agent/core/vibuzo.md`
- **Created `context/standards/versioning.md`** -- documents full scheme: format, caps, bump rules, canonical source, where version appears, how to bump
- **Updated `AGENTS.md`** -- version marker annotation now `← Version marker (current: 0.0.19)`
- **Deleted `context/standards/source-mirror-synchronization.md`** -- entire standard removed
- **Purged mirror sync references** from 8 active files: `context/index.md`, `context/architecture/agent-restructure.md`, `context/architecture/approval-gates.md`, `context/architecture/deepsearcher-research-stage.md`, `context/standards/imperative-command-style.md`, `context/standards/terminology-change-process.md`, `context/standards/command-parameter-notation.md`, `context/standards/installer-visual-language.md`
- **Created `context/patterns/large-document-size-gate.md`** -- pattern for gating large generated documents with size preview before writing
- **Committed and pushed 3 commits**: `a575ff0` (version tracking), `453a92f` (mirror removal + size gate), and prior `04638cc` (Deepsearcher refinement)
- **Context append round 2** -- no new candidates found; everything already documented
- **Consolidated session file** -- removed Chronological Log, File Manifest, Commands Invoked, State sections (now `/compact`'s domain); renamed sections to forward-looking names (Forward Decisions, Forward Context, Hot Files); trimmed content to only what matters next session
- **Updated `commands/session.md`** -- replaced old 11-section template with 7 forward-looking sections; removed timestamp rule instruction; step 1 now says "do NOT write chron log / file manifest / commands table / state"
- **Updated `agents/vibuzo.md`** -- added "Session Summaries" section codifying the 7-section template with purpose and trim rules per section

### In Progress
- (none)

### Blocked
- (none)

## Key Decisions
- **Version scheme:** `0.<minor>.<patch>` with patch 0→19, minor 0→9, then `1.0.0`. Current `0.0.19`; next push → `0.1.0` (first post-dev refinement)
- **Bump trigger:** Every push to GitHub, not per-file change
- **No more manual mirror sync:** `.opencode/` is installer-managed only. Source files are in `commands/` and `agents/`; installer copies them on install and overwrites on `--update`
- **Large document gate:** Files >200 lines need size preview and user approval before writing; lesson from the discarded 416-line README
- **`.` prefix missing**: Version format has no `v` prefix; matches opencode's `1.16.0` style exactly
- **Session summary structure:** 7 forward-looking sections instead of exhaustive chron log. Compaction-backed. Sections: Session Summary, Constraints & Preferences, Progress, Forward Decisions, Forward Context, Next Steps, Hot Files
- **Forward-prefix naming:** Sections that overlap with `/compact` use forward-looking names (Forward Decisions, Forward Context, Hot Files) to signal they are curated + next-session-facing, not exhaustive

## Next Steps
1. User runs `/compact` in opencode TUI, copies output, pastes into Session Compaction section of the session file
2. User starts `/new` session with compaction block as starting context
3. Session summary template is now codified in `commands/session.md` and `agents/vibuzo.md` -- future `/session` commands use the new 7-section format automatically

## Critical Context
- **Git:** `main` branch, clean working tree, 3 commits pushed today (`04638cc`, `a575ff0`, `453a92f`), 0 ahead/behind origin/main, last commit `453a92f`
- **Version:** `0.0.19` is current. Next push bumps to `0.1.0`
- **`.opencode/` is NOT git-tracked:** edits to `.opencode/agent/core/` or `.opencode/commands/` must be made to the source files in `agents/` and `commands/`, then deployed via installer `--update`
- **`.opencode/agent/core/vibuzo.md` is out of sync** -- needs installer `--update` to pick up the new "Session Summaries" section added to `agents/vibuzo.md`
- **Mirror convention is dead:** the old source-mirror-synchronization standard was deleted. All active files updated to say "installer-managed deployment"
- **Historical session files** still contain "mirror" references -- kept as immutable records
- **Session summary template** lives in `commands/session.md`; agent behavioral rules live in `agents/vibuzo.md`

## Relevant Files
- `.opencode/.vibuzo-version` -- Canonical version marker: `0.0.19 | 2026-06-07 00:42 04638cc local`
- `context/standards/versioning.md` -- New: full versioning scheme documented
- `context/standards/source-mirror-synchronization.md` -- DELETED
- `context/patterns/large-document-size-gate.md` -- New: document size gate pattern
- `install.ps1` -- Modified: version in help, install line, update display, success box, version write; updated parser for `0.0.19 | ...` format
- `install.sh` -- Same changes as install.ps1 (mirror visually, not by convention)
- `agents/vibuzo.md` -- Added Version Reporting and Session Summaries sections
- `.opencode/agent/core/vibuzo.md` -- Added Version Reporting section (mirror), missing Session Summaries section (awaiting installer `--update`)
- `AGENTS.md` -- Version marker annotation updated
- `context/index.md` -- Removed source-mirror reference, added versioning.md and large-document-size-gate.md references
- `commands/session.md` -- Updated template to 7 forward-looking sections; removed chron log, file manifest, commands table, state
- `context/sessions/2026-06-07-versioning-mirror-cleanup.md` -- Consolidated session file using new forward-looking template
