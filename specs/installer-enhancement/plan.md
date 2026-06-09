# Plan: Installer Enhancement

**Feature:** `installer-enhancement`
**Based on:** `specs/installer-enhancement/spec.md`
**Date:** 2026-06-09

## Tech Stack

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Windows installer | PowerShell 7+ (install.ps1) | Native Windows shell; must work cross-platform via pwsh |
| Unix installer | Bash 3.2+ (install.sh) | Compatible with macOS default (3.2) and Linux |
| Source of truth | Markdown files in `agents/` and `commands/` | No compile step; downloaded directly from GitHub |
| Version tracking | `VERSION` file at repo root | Single canonical source, fetched at runtime |
| Install metadata | `.opencode/.vibuzo-version` | Local semver + date + mode for update checks |

No frameworks, external packages, or build tools introduced.

## Architecture

### Section Structure (both installers)

Each installer will be organized into clearly delineated sections in this order:

```
1. Metadata & Help (SYNOPSIS/header, param parsing)
2. Configuration (repo, branch, URLs, paths)
3. Utility Functions
   a. Color helpers (with NO_COLOR support)
   b. Box renderer (enhanced multi-section)
   c. Section renderer (existing, unchanged)
   d. Spinner renderer (NEW)
   e. Step header renderer (NEW)
   f. Prompt helper (with --yes support) (NEW)
4. Detection Functions
   a. detect_environment() — OS, arch, tools, terminal
   b. detect_install_state() — existing install check
   c. detect_ai_tools() — scan AI agent directories
5. Wizard Controller
   a. Step sequencing (1/7 through 7/7)
   b. Preview/review rendering
   c. Summary box rendering
6. Install Engine
   a. X-of-Y file download loop
   b. Atomic write (temp → rename)
   c. Retry logic
   d. Integration installer (copy to tool dirs)
7. Update Flow
   a. Enhanced version comparison with preview
   b. Upgrade confirmation
8. Main Flow
   a. Banner display
   b. Wizard execution (steps 1-7)
   c. Post-install summary
```

### Data Flow

```
User runs installer
       │
       ▼
  ┌─────────────┐
  │ --help flag  │──→ Show help, exit
  └─────────────┘
       │
       ▼
  ┌─────────────────┐
  │ --version flag   │──→ Show version, exit
  └─────────────────┘
       │
       ▼
  ┌────────────┐
  │ --update?   │──yes──→ Update Flow
  └────────────┘          │
       │ no               ▼
       ▼           Show version comparison
  ┌──────────┐     Preview changes
  │ Banner   │     Confirm ──yes──→ Apply update
  └──────────┘                    │
       │                          ▼
       ▼                    Post-update summary
  ┌─────────────────┐             │
  │ Step 1: Detect   │            ▼
  │ Environment      │           Done
  └─────────────────┘
       │
       ▼
  ┌─────────────────┐
  │ Step 2: Detect   │
  │ Install State    │
  └─────────────────┘
       │
       ▼
  ┌─────────────────┐
  │ Step 3: Detect   │
  │ AI Tools         │
  └─────────────────┘
       │
       ▼
  ┌─────────────────┐
  │ Step 4: Preview  │
  │ + Confirmation   │
  └─────────────────┘
       │
       ▼
  ┌─────────────────┐
  │ Step 5: Install  │── X-of-Y agents download
  │ Agents           │
  └─────────────────┘
       │
       ▼
  ┌─────────────────┐
  │ Step 6: Install  │── X-of-Y commands download
  │ Commands         │
  └─────────────────┘
       │
       ▼
  ┌─────────────────┐
  │ Step 7: Install  │── Copy to detected AI tool dirs
  │ Integrations     │
  └─────────────────┘
       │
       ▼
  ┌──────────────────┐
  │ Post-install      │
  │ Summary Box       │
  └──────────────────┘
```

### Integration Points

- **AGENTS.md handling**: Existing logic preserved (fresh/user-owned/Vibuzo-with-rules detection + marker preservation)
- **Path rewriting for global install**: Existing logic preserved
- **Claude Code integration**: Existing logic enhanced to use the new integration installer system
- **Version file format**: Existing `0.x.x | yyyy-MM-dd HH:mm mode` preserved

## Components

### C1: Spinner & Step Renderer Utilities
- **Output**: Spinning indicator for indeterminate tasks, step header with number/status
- **Functions**: `Write-Spinner` / `print_spinner`, `Write-Step` / `print_step`
- **Lines**: ~30 per installer
- **Dependencies**: Color helpers (C3)

### C2: Prompt Helper
- **Output**: `Read-Host` / `read` wrapper with default answer, `--yes` auto-confirm, consistency
- **Functions**: `Confirm-Action` / `confirm_action(prompt, default)`
- **Lines**: ~15 per installer
- **Dependencies**: C1 (for step formatting in prompts)

### C3: NO_COLOR / --no-color / --yes Flag Support
- **Output**: Global color gating, `--yes` auto-confirm, `--no-color` override
- **Changes**: Parameter parsing, color function wrappers, prompt helper integration
- **Lines**: ~20 per installer
- **Dependencies**: None (added to existing param parsing)

### C4: Environment Detection Module
- **Output**: OS, arch, tool availability, terminal capability
- **Functions**: `Detect-Environment` / `detect_environment`
- **Lines**: ~40 per installer
- **Dependencies**: C1 (for spinner during detection), C3 (for color)

### C5: Install State Detection Module
- **Output**: Existing install state, version, date, AGENTS.md status
- **Functions**: `Detect-InstallState` / `detect_install_state`
- **Lines**: ~25 per installer
- **Dependencies**: C1

### C6: AI Tool Detection Module
- **Output**: Detected AI coding tools and their config paths
- **Functions**: `Detect-AITools` / `detect_ai_tools`
- **Lines**: ~50 per installer
- **Dependencies**: C1, C3

### C7: Enhanced Box Renderer (Multi-Section)
- **Output**: Box with title + sub-sections (for summary output)
- **Functions**: `Write-Box` / `print_box` — extended to support multi-section layout
- **Lines**: ~15 added per installer
- **Dependencies**: C3

### C8: Wizard Flow Controller
- **Output**: Full step progression 1-7 with state management
- **Functions**: `Start-Wizard` / `start_wizard` orchestrates all steps
- **Lines**: ~60 per installer
- **Dependencies**: C2-C7

### C9: Install Engine with Progress
- **Output**: X-of-Y file downloads with per-file status, atomic write
- **Changes**: File download loops enhanced with counter display and atomic write
- **Lines**: ~30 added per installer
- **Dependencies**: C1, C3

### C10: Integration Installer
- **Output**: Agent files copied to detected AI tool config directories
- **Functions**: `Install-Integrations` / `install_integrations`
- **Lines**: ~30 per installer
- **Dependencies**: C6 (tool list), C9 (file copy with progress)

### C11: Enhanced Update Flow
- **Output**: Wizard-style update with version comparison preview
- **Changes**: Update block enhanced with step formatting and progress display
- **Lines**: ~25 added per installer
- **Dependencies**: C1, C3, C8

### C12: Post-Install Summary
- **Output**: Structured summary box with location, agents, commands, integrations, next steps
- **Changes**: Done block rewritten with new summary format
- **Lines**: ~15 per installer
- **Dependencies**: C7 (multi-section box)

## Implementation Order

| Order | Component | Risk | Why This Order |
|-------|-----------|------|----------------|
| 1 | C3 — NO_COLOR/--yes flags | Low | Foundation for all interactive features; no downstream deps |
| 2 | C7 — Enhanced box renderer | Low | Visual foundation for summary/preview; no downstream beyond C3 |
| 3 | C1 — Spinner & step renderer | Low | Core UX component; depends on C3 |
| 4 | C2 — Prompt helper | Low | Used by wizard and update flow; depends on C1 |
| 5 | C4 — Environment detection | Medium | First wizard step; depends on C1, C3 |
| 6 | C5 — Install state detection | Low | Second wizard step; depends on C1 |
| 7 | C6 — AI tool detection | Medium | Third wizard step; depends on C1, C3 |
| 8 | C9 — Install engine with progress | Medium | Fifth and sixth wizard steps; depends on C1, C3 |
| 9 | C10 — Integration installer | Low | Seventh wizard step; depends on C6, C9 |
| 10 | C8 — Wizard flow controller | Medium | Orchestrates all steps; depends on C4-C7, C9-C10 |
| 11 | C11 — Enhanced update flow | Low | Runs instead of wizard for --update; depends on C1, C3, C8 |
| 12 | C12 — Post-install summary | Low | Final output; depends on C7 |

## Verification Strategy

- **Per-component verification**: Each component tested in isolation by running the installer section
- **Integration test**: Full wizard flow executed in a temp directory
- **Cross-platform**: Verify each task produces identical output in PS1 and Bash
- **Update flow test**: Create fake `.vibuzo-version` with old version, run `--update`, verify behavior
- **CI test**: Run with `--yes` flag, verify no interactive prompts appear
- **NO_COLOR test**: Run with `$env:NO_COLOR=1` / `NO_COLOR=1`, verify no ANSI codes in output
