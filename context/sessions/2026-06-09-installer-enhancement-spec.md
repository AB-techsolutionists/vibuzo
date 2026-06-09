---
title: installer-enhancement-spec
date: 2026-06-09
tags:
  - installer
  - spec
  - audit
  - documentation
  - commands
  - review
status: complete
---

# Installer Enhancement Spec

*Session summary — 2026-06-09 | ~60 messages | ~12 files touched | 0 commits*

## Session Summary

Ran a Deepviewer codebase audit finding 7 documentation drift issues across 5 files, then applied all fixes (versioning.md example stale, context/index.md step skip and duplicate bullets, AGENTS.md tree alignment, opencode-mirror-files-integrity.md contradiction, internal commands description). Then executed a full `/spec` pipeline for "installer-enhancement": research (CLI UX best practices, progress indicators, tool detection), specification (8 functional requirements: wizard flow, environment/AI tool/install state detection, progress indicators, NO_COLOR/--yes flags, enhanced update flow, post-install summary), plan (12 components by dependency), and 12 implementation tasks via Deepveloper. Both installers were transformed from linear download scripts to interactive guided wizards (install.ps1: 377→725 lines, install.sh: 387→799 lines). Webview spec compliance review found 9 issues — all fixed. Code quality review approved. Working tree remains dirty with all changes uncommitted.

## Constraints & Preferences

- **Surgical edits:** Documentation drift fixes touched only drifted lines — no adjacent cleanup.
- **No .opencode/ edits:** Mirror copies are installer-managed per opencode-mirror-files-integrity.md.
- **Banner preservation:** VIBUZO figlet banner in both installers must remain unchanged.
- **PS1/SH parity:** All features must be implemented identically in both installers — no feature in one without the other.

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Interactive wizard flow** — installers restructured from linear scripts to 8-step (install) / 4-step (update) guided wizards | Users benefit from clear step progress, detection summaries, and confirmation gates before destructive actions |
| 2 | **All 3 detection types combined** — environment, AI tool, and install state detection run as separate wizard steps | Each provides unique value: environment for debugging, AI tools for integration, install state for upgrade/repair decisions |
| 3 | **Codex CLI added to detection** — spec listed 8 AI tools, implementation had 7; review caught the gap and it was fixed | Spec compliance was verified by Deepviewer and any gap was corrected before closing |

## Forward Context

- Working tree is dirty — 7 modified files + 1 new untracked directory (`specs/installer-enhancement/`) with 5 spec artifacts. Nothing committed.
- Version 0.3.7 on disk, not in git.
- The installer wizard and detection modules are untested in real environments (no WSL available on this Windows machine for Bash testing).
- Dead `Write-Section`/`print_section` functions (~50 lines) remain in both installers — noted by code quality review but not removed.
- `.opencode/` mirror copies are out of sync with source changes — installer `--update` will sync them.

## Hot Files

| File | Why Hot |
|------|---------|
| `install.ps1` | Wizard flow + detection modules + progress — needs real-world testing |
| `install.sh` | Bash mirror of same — untested (no WSL), needs macOS/Linux verification |
| `VERSION` | 0.3.7 on disk, uncommitted — next session may bump |
| `specs/installer-enhancement/` | All 5 spec artifacts — reference for next installer feature |
| `context/reports/audit-report-2026-06-09.md` | Deepviewer audit report — reference for remaining minor issues |

## Timeline Entry

| 2026-06-09 | 14:28 | `installer-enhancement-spec` | Deepviewer audit + 7 doc drift fixes, full /spec pipeline for interactive installer wizard (12 tasks, 2 installers transformed, 9 review fixes) |

## Session Compaction

```
╭─────── Session Compaction ───────────────────────────────────────╮
│                                                                   │
│  Session:    installer-enhancement-spec                            │
│  Date:       2026-06-09                                            │
│  Messages:   ~60                                                   │
│                                                                   │
├─────── Goal ──────────────────────────────────────────────────────┤
│                                                                   │
│  • Fix documentation drift from Deepviewer audit and run full     │
│    /spec pipeline to transform both installers into interactive    │
│    guided wizards with detection, progress, and integration        │
│                                                                   │
├─────── Constraints & Preferences ─────────────────────────────────┤
│                                                                   │
│  • Surgical edits for doc fixes — touch only drifted lines        │
│  • No .opencode/ mirror modifications (installer-managed)         │
│  • VIBUZO figlet banner must remain unchanged                     │
│  • PS1/SH parity — identical features in both installers          │
│  • Never push without explicit approval (custom rule)             │
│                                                                   │
├─────── Progress ──────────────────────────────────────────────────┤
│                                                                   │
│  Done:                                                             │
│  • Deepviewer audit — 7 doc drift issues found and fixed          │
│  • /spec pipeline: installer-enhancement — 5 artifacts created    │
│  • Research: CLI installer UX, progress patterns, tool detection   │
│  • Spec: 8 functional requirements (wizard, 3 detections,         │
│    progress, flags, update, summary)                              │
│  • Plan: 12 components by dependency order                        │
│  • Tasks: 12 tasks for PS1 + SH modification                     │
│  • Implementation via Deepveloper: PS1 377→725, SH 387→799       │
│  • Review: Spec compliance (9 issues found, all fixed) +          │
│    Code quality (approved)                                        │
│  • install.ps1: --no-color/--yes flags, spinner, step renderer,  │
│    prompt helper, 3 detection modules, X-of-Y progress,           │
│    integration installer, 8-step wizard, enhanced update flow     │
│  • install.sh: identical feature set in Bash                      │
│                                                                   │
│  In Progress:                                                      │
│  • (none)                                                          │
│                                                                   │
│  Blocked:                                                          │
│  • (none)                                                          │
│                                                                   │
├─────── Key Decisions ─────────────────────────────────────────────┤
│                                                                   │
│  • All 3 detection types (environment, AI tools, install state)    │
│    included in the wizard — not just one                          │
│  • Codex CLI added to AI tool detection after review caught gap   │
│  • --yes flag auto-confirms all prompts for CI mode               │
│  • NO_COLOR env var supported for non-TTY environments            │
│  • Atomic writes (temp → rename) for all file downloads           │
│                                                                   │
├─────── Next Steps ────────────────────────────────────────────────┤
│                                                                   │
│  • Test installers in real environments (Windows PS1, macOS/Linux │
│    Bash)                                                          │
│  • Commit and push the working tree                               │
│  • Run install.ps1 --update to sync .opencode/ mirrors            │
│  • Remove dead Write-Section/print_section functions if desired   │
│                                                                   │
├─────── Critical Context ──────────────────────────────────────────┤
│                                                                   │
│  • Git: working tree dirty — 7 modified files + 1 untracked dir   │
│    (5 spec artifacts), 0 commits this session                     │
│  • Version: 0.3.7 on disk, not in git                             │
│  • Last commit: d0303b2 (version bump, release notes, internal    │
│    commands cleanup)                                              │
│  • Bash installer untested — no WSL on this Windows machine       │
│  • .opencode/ mirrors are stale — need installer --update         │
│                                                                   │
├─────── Relevant Files ────────────────────────────────────────────┤
│                                                                   │
│  install.ps1                         │ Wizard + detection +        │
│                                      │ progress (needs testing)    │
│  install.sh                          │ Bash mirror (needs testing) │
│  specs/installer-enhancement/        │ 5 spec artifacts            │
│  context/reports/audit-report-       │ Audit findings reference    │
│    2026-06-09.md                     │                             │
│  VERSION                             │ 0.3.7, uncommitted          │
│  context/index.md                    │ Step numbering + duplicate  │
│                                      │ bullets fixed               │
│  AGENTS.md                           │ Tree indentation fixed      │
│                                                                   │
╰───────────────────────────────────────────────────────────────────╯
```

## Context Candidates

| Candidate | Type | Saved? |
|-----------|------|--------|
| Interactive Installer Design Principles | pattern | ✅ saved — `context/patterns/interactive-installer-wizard.md` |
