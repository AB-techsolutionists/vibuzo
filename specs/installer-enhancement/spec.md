# Installer Enhancement

**Feature:** `installer-enhancement`
**Date:** 2026-06-09
**Status:** Draft

## Principles

- **Interactive-first**: The install experience should feel like a guided wizard — detect, show, confirm, execute, summarize — not a silent batch script.
- **Defensive defaults**: Every download must survive partial failure. Use atomic writes, retry on transient errors, and clean up on abort.
- **Visual polish with purpose**: Every color, box, and spinner must convey meaningful state — never just decoration.
- **Cross-platform parity**: PowerShell and Bash installers must behave identically at every step. No feature in one without the other.
- **CI-friendly**: All interactivity must be gatable behind `--yes` so non-interactive shells and CI pipelines work without prompts.

## Specification

### Overview

Transform both Vibuzo installers (install.ps1, install.sh) from a linear download script into an interactive guided wizard with three detection phases (environment, AI tools, install state), live progress indicators, and a structured step-by-step flow. The update flow (`--update`) gets the same treatment with version comparison visualization and upgrade preview.

### User Stories

- As a **new user**, I want a guided install that detects my OS, architecture, and tools, shows me what it found, lets me choose integrations, and then installs with visible progress so I know what's happening at every step.
- As a **returning user**, I want `--update` to show me what version I have, what's new, and what will change before applying.
- As a **CI pipeline**, I want `--yes` to skip all prompts and auto-confirm every step.
- As a **multi-tool user**, I want the installer to detect all my AI coding agents and offer to configure them all at once.
- As a **power user**, I want `--no-color` and `NO_COLOR` to work so logs are clean.
- As a **developer maintaining both installers**, I want the detection and wizard logic to be easy to keep in sync between PS1 and Bash.

### Functional Requirements

#### FR1: Interactive Wizard Flow

The installer must execute a structured wizard with numbered steps:

```
Step 1: Detecting Environment
  ✓ OS: Windows (x64)
  ✓ Shell: PowerShell 7.4
  ✓ curl available

Step 2: Detecting Existing Install
  ✓ .opencode/ found (v0.3.5, installed Jun 08 at 15:22)
  → Choose: (f)resh install, (u)pdate, (a)bort

Step 3: Detecting AI Tools
  ✓ Claude Code — detected
  ✓ Cline — not found
  ✓ opencode — detected
  → Configure integrations? (Y/n)

Step 4: Installation Preview
  Summary:
    Type:     Update
    Target:   Local (.opencode/)
    Agents:   4 (vibuzo, deepveloper, deepsearcher, deepviewer)
    Commands: 7
    Integrations: Claude Code, opencode
  Proceed? (y/N)

Step 5: Installing [1/3] Agents — spinner → 4/4 ✓
Step 6: Installing [2/3] Commands — spinner → 7/7 ✓
Step 7: Installing [3/3] Integrations — spinner → 2/2 ✓

✅ Vibuzo 0.3.7 updated successfully!
  Location:   Local (.opencode/)
  Version:    0.3.7
  Agents:     4 installed
  Commands:   7 installed
  Integrations: Claude Code, opencode
  Next:       Restart opencode and select Vibuzo
```

Each step header must show the step number (1/N) and a description. Completed steps show a checkmark and green color. The active step shows a spinner or progress. Failed steps show a red X and the error.

#### FR2: Environment Detection

Must detect and display:
- **OS**: Windows, macOS, Linux (with distro name if possible)
- **Architecture**: x64, ARM64, x86
- **Shell**: PowerShell version (PS1 installer), Bash version (SH installer), Zsh detection (SH)
- **Available tools**: curl, wget, git, pwsh (on Linux/macOS)
- **Terminal**: color support (`[Console]::BufferWidth`, `$TERM`, `tput colors`), TTY vs piped
- **Execution policy** (PS1 only): detection of `Get-ExecutionPolicy -Scope Process` with suggestion to auto-set

Detection must happen silently in Step 1 with a spinner per check and results shown immediately.

#### FR3: AI Tool Detection

Must detect and report status for (in priority order):

| Tool | Detection Method |
|------|-----------------|
| Claude Code | `claude` command in PATH, `.claude/` directory |
| opencode | `.opencode/` directory, `opencode` command in PATH |
| Cline | `.cline/` or `.github/agents/` directory |
| Cursor | `cursor` command in PATH, `.cursor/` directory |
| GitHub Copilot CLI | `gh copilot` command availability |
| Gemini CLI | `gemini` command in PATH |
| Windsurf | `.windsurf/` directory |
| Codex CLI | `codex` command in PATH |

Detection runs in Step 3. Each tool shows ✓ found or ✗ not found. After detection, user is prompted: "Configure integrations? (Y/n)" — if yes, all detected tools get agent files copied to their config directories.

#### FR4: Install State Detection

In Step 2, detect:
- **Existing `.opencode/` directory**: found / not found
- **Version**: Read `.opencode/.vibuzo-version` if exists
- **Install date and mode**: Date/time of last install, local vs global
- **AGENTS.md**: Check if exists, if it has custom rules below marker
- **Dirty state**: Check for partial installs (missing agents or commands directories)

Based on state, present options:
- No install found → Fresh install
- Install found, versions match → Already up to date (exit)
- Install found, versions differ → Update available (offer upgrade with preview)
- Partial install → Offer repair (re-download missing files)

#### FR5: Progress Indicators

Replace silent `Invoke-WebRequest` / `curl` loops with live indicators:

- **Spinner**: For single indeterminate tasks (detection phases, version fetch)
  - Characters: `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` (Braille dots) with elapsed time
  - Tick on task completion, not timer-based (so stalls are visible)
- **X-of-Y counter**: For file downloads with known count
  - Format: `[3/7] Downloading deepsearcher.md... ✓`
  - Show filename being downloaded, checkmark on success, X on failure
- **Step indicator**: (reused in wizard)
  - `Step 1/7: Detecting Environment... ✓`
  - After completion, the line stays with a green checkmark

Spinner must work on both Windows PowerShell and Unix terminals. Must respect `NO_COLOR` and `--no-color` (fall back to plain dots).

#### FR6: NO_COLOR and --yes Flags

- `NO_COLOR` environment variable: When set (any value), suppress all ANSI color codes. Fall back to `[OK]` / `[FAIL]` / `[INFO]` prefixes instead of colored text.
- `--no-color` flag: Same as `NO_COLOR` but from command line. Overrides `NO_COLOR` if both specified.
- `--yes` / `-y` flag: Auto-confirm all prompts. Equivalent of pressing "y" at every gate. Must also suppress interactive detection results — show them but don't wait for confirmation.
- `--help` and `--version` must continue to work as before.

#### FR7: Update Flow Enhancement

When `--update` is used:
1. Show current version info in a box (same as now, but with step header formatting)
2. If up to date: Show "Already up to date" box with installed version metadata
3. If update available: Show upgrade preview with:
   - Current vs latest version comparison
   - List of files that will be overwritten
   - Confirmation prompt
4. Update progress: Same X-of-Y as fresh install
5. Post-update summary: Same wizard completion box

#### FR8: Post-Install Summary

After successful install or update, display a structured summary box:

```
╔═══════════════════════════════════════════════════════════╗
║            ✅ Vibuzo 0.3.7 installed successfully!        ║
║═══════════════════════════════════════════════════════════║
║  Location:   Local (.opencode/)                           ║
║  Agents:     4 installed ✓                                ║
║  Commands:   7 installed ✓                                ║
║  Integrations: Claude Code, opencode                      ║
║                                                           ║
║  ─── Next Steps ───────────────────────────────────────── ║
║                                                           ║
║  → Restart opencode and select Vibuzo                     ║
║    from the agent dropdown.                               ║
║  → First time? Run /context init                          ║
║    to set up project memory.                              ║
║  → Start building with:                                   ║
║    /spec [feature description]                            ║
║                                                           ║
║  💡 github.com/AB-techsolutionists/vibuzo                ║
╚═══════════════════════════════════════════════════════════╝
```

### Acceptance Criteria

1. Fresh install on Windows (PowerShell 7+) completes all 7 wizard steps without errors
2. Fresh install on macOS (Bash) completes all 7 wizard steps without errors
3. Fresh install on Linux (Bash) completes all 7 wizard steps without errors
4. `--update` with up-to-date version shows "Already up to date" and exits 0
5. `--update` with outdated version shows preview, applies update with progress, shows summary
6. `--yes` flag skips all interactive prompts and auto-confirms
7. `NO_COLOR` env var suppresses all ANSI codes
8. `--no-color` flag suppresses all ANSI codes
9. AI tool detection finds at least Claude Code and opencode on a standard dev machine
10. Environment detection reports correct OS, architecture, and available tools
11. Install state detection correctly identifies fresh vs existing vs partial installs
12. Spinner animates during detection phases (visible on both terminals)
13. X-of-Y counter shows correct progress during file downloads
14. AI tool integration copies agent files to each detected tool's config directory
15. Failed download shows error, retries once, then reports failure without leaving partial files

### Out of Scope

- Single-source code generation (YAML manifest + Mustache templates) — deferred to separate feature
- Package manager distribution (Homebrew formula, Scoop manifest, apt repo) — out of scope
- Binary/executable distribution — Vibuzo remains a Markdown-based framework
- GUI installer — CLI only
- Telemetry or analytics — no tracking of any kind
- Self-signed cert or code signing — not applicable to Markdown/script framework
- CI/CD pipeline integration beyond `--yes` flag
