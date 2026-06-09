# Tasks: Installer Enhancement

**Feature:** `installer-enhancement`
**Based on:** `spec.md`, `plan.md`
**Date:** 2026-06-09

## Task 1: NO_COLOR, --no-color, --yes Flag Support

**Description:** Add `--no-color`, `--yes`/`-y` flag parsing and `NO_COLOR` environment variable support to both installers. Color output functions must check a global `$NoColor`/`NO_COLOR` flag and skip ANSI codes when set. `--yes` must auto-confirm all prompts.

**Files:**
- `install.ps1` — add param parsing, color gating, global state
- `install.sh` — add arg parsing, color gating, global state

**Steps:**
1. In `install.ps1`: Add `[switch]$NoColor` and `[switch]$Yes` to the `param()` block. Add `$Script:NoColor = $NoColor -or [bool]$env:NO_COLOR` and `$Script:Yes = $Yes` after param parsing.
2. In `install.sh`: Add `--no-color` and `--yes`/`-y` to the `case` arg parser. Add `NO_COLOR=${NO_COLOR:-}` and `YES=false` vars; set `YES=true` on `--yes`/`-y`.
3. In both: Update the `--help` output to document the new flags.
4. In both: Create color wrapper functions (e.g., `Write-Color` / `color_print`) that check the no-color flag before emitting ANSI codes.

**Verification:**
- Run installer with `--no-color` — output must contain no ANSI escape sequences
- Run installer with `NO_COLOR=1` — same result
- Run installer with `--yes` — no `Read-Host`/`read` prompts should appear (auto-confirm all)

**Acceptance:**
- ✅ `--no-color` flag suppresses all ANSI color output
- ✅ `NO_COLOR` env var suppresses all ANSI color output
- ✅ `--yes` flag auto-confirms all interactive prompts
- ✅ `--yes` and `--no-color` documented in `--help`

---

## Task 2: Enhanced Box Renderer (Multi-Section)

**Description:** Extend `Write-Box`/`print_box` to support a multi-section layout with a divider character (`═` separator rows). Used for summary output (location, agents, commands, next steps).

**Files:**
- `install.ps1` — extend `Write-Box` function
- `install.sh` — extend `print_box` function

**Steps:**
1. In both: Add a new `$HasDivider`/`has_divider` parameter. When a content line is `"━━━..."` (3+ `=` chars with `BOX` chars), render it as `║ ══ ... ══ ║` instead of a regular content line.
2. Keep the existing single-section box behavior as default (no divider).
3. Verify divider rendering matches 59-char total width, no alignment drift.

**Verification:**
- Call `Write-Box` / `print_box` with a mix of regular lines and divider-only lines — verify dividers render as `═══` rows within the box
- Verify single-section boxes still render identically to before

**Acceptance:**
- ✅ Existing single-section boxes render identically (backward compatible)
- ✅ Multi-section boxes with `═══` dividers render correctly at 59-char width

---

## Task 3: Spinner & Step Renderer Utilities

**Description:** Add a spinner function for indeterminate tasks (detection phases) and a step header function for the wizard flow. Spinner uses Braille dot characters `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` cycling on each call.

**Files:**
- `install.ps1` — `Write-Spinner`, `Write-Step` functions
- `install.sh` — `print_spinner`, `print_step` functions

**Steps:**
1. In both: Create `Write-Spinner`/`print_spinner` — takes a message string and step number. On first call, prints the step header with the first spinner char and the message. On subsequent calls with the same step, overwrites the line with the next spinner char. On completion call (with `-Completed`/`--completed` flag), overwrites with `✓` in green.
2. In both: Create `Write-Step`/`print_step` — prints `Step N/M: Description` with color. When completed, reprints with `✓` prefix.
3. Both functions must respect the no-color flag from Task 1.
4. Add a global spinner state variable (current step, current frame index).

**Verification:**
- Call spinner with a sequence of frames — verify characters cycle through the Braille set
- Call spinner with `-Completed` — verify it shows `✓` and stops
- Call step header — verify it prints `Step 1/7: Detecting Environment...`
- Verify no ANSI codes when `--no-color` is active

**Acceptance:**
- ✅ Spinner cycles through Braille dot characters correctly
- ✅ Spinner overwrites same line on each call (not newline)
- ✅ Spinner completion shows `✓` in green (or `[OK]` without color)
- ✅ Step header shows `Step N/M: Description` format

---

## Task 4: Prompt Helper

**Description:** Create a unified prompt function that wraps `Read-Host`/`read` with default answer, `--yes` auto-confirm, and consistent formatting.

**Files:**
- `install.ps1` — `Confirm-Action` function
- `install.sh` — `confirm_action` function

**Steps:**
1. In both: Create `Confirm-Action`/`confirm_action(prompt, default)` that:
   - If `$Yes`/`$YES` is true, return `$true`/`0` immediately (auto-confirm)
   - If not TTY (piped), return the default answer
   - Otherwise display `prompt (Y/n): ` or `prompt (y/N): ` based on default
   - Parse response: `y`/`Y`/`yes`/`YES` → true, anything else → false
2. Replace all existing `Read-Host` / `read` prompts in both installers with this function.

**Verification:**
- Run with `--yes` — all prompts auto-confirm without waiting
- Run in piped mode — all prompts return default without waiting
- Run interactively — prompts display correctly and accept input

**Acceptance:**
- ✅ `--yes` auto-confirms all prompts
- ✅ Non-TTY mode returns default without waiting
- ✅ Prompt displays `(Y/n)` or `(y/N)` based on default parameter
- ✅ All existing prompts (update confirmation, AGENTS.md confirmation) use this function

---

## Task 5: Environment Detection Module

**Description:** Add a detection function that identifies OS, architecture, available tools, and terminal capabilities. Runs as Step 1 of the wizard.

**Files:**
- `install.ps1` — `Detect-Environment` function and result display
- `install.sh` — `detect_environment` function and result display

**Steps:**
1. In both: Create detection function that uses spinner during checks and returns a structured result object.
2. Run these checks:
   - OS: `$env:OS` / `uname -s`, with distro name on Linux (`/etc/os-release`)
   - Architecture: `$env:PROCESSOR_ARCHITECTURE` / `uname -m` (handle x64, ARM64, x86)
   - Shell version: `$PSVersionTable.PSVersion` / `bash --version`
   - Tool availability: `Get-Command`/`command -v` for curl, wget, git, pwsh (on Unix)
   - Terminal: `[Console]::BufferWidth` / `tput cols`, TTY vs piped detection
   - PowerShell execution policy (PS1 only): `Get-ExecutionPolicy -Scope CurrentUser`
3. Display results in a formatted block with checkmarks per line. Use spinner animation during each check.

**Verification:**
- Run installer on Windows — detects Windows, correct arch, PowerShell version
- Run installer on macOS (Bash) — detects macOS, correct arch, Bash version
- Run installer on Linux (Bash) — detects Linux with distro name, correct arch

**Acceptance:**
- ✅ OS detection shows correct OS name
- ✅ Architecture detection shows x64 or ARM64 correctly
- ✅ Tool availability shows available tools with ✓
- ✅ Terminal width and TTY status detected correctly
- ✅ Results displayed with spinner animation during detection

---

## Task 6: Install State Detection Module

**Description:** Add a detection function that identifies whether Vibuzo is already installed, what version, when, and AGENTS.md status. Runs as Step 2 of the wizard.

**Files:**
- `install.ps1` — `Detect-InstallState` function and result display
- `install.sh` — `detect_install_state` function and result display

**Steps:**
1. In both: Create detection function that checks:
   - `.opencode/` directory exists
   - `.opencode/.vibuzo-version` exists and parse its contents (version, date, mode)
   - AGENTS.md exists and determine its status (fresh/vibuzo-with-rules/user-owned)
   - All expected agent and command files are present (detect partial install)
2. Return structured result with: `$InstallState`/`INSTALL_STATE` (absent/fresh/partial/uptodate/outdated)
3. Display results in a formatted block.

**Verification:**
- Run in a clean directory — shows "Not installed"
- Run with existing install up to date — shows "Up to date (v0.3.7, installed Jun 09 at 16:19)"
- Run with outdated install — shows "Update available (v0.3.5 → v0.3.7)"
- Manually delete one agent file — shows "Partial install (3/4 agents) — repair available"

**Acceptance:**
- ✅ Fresh directory shows "Not installed"
- ✅ Existing install shows version, date, mode
- ✅ Partial install (missing files) detected and reported
- ✅ AGENTS.md status determined correctly

---

## Task 7: AI Tool Detection Module

**Description:** Add a detection function that scans for installed AI coding agents and their config directories. Runs as Step 3 of the wizard.

**Files:**
- `install.ps1` — `Detect-AITools` function and result display
- `install.sh` — `detect_ai_tools` function and result display

**Steps:**
1. In both: Create detection function that checks for these tools in priority order:
   - Claude Code: `claude` in PATH, `.claude/` directory
   - opencode: `.opencode/` directory, `opencode` in PATH
   - Cline: `.cline/` directory, `.github/agents/` directory
   - Cursor: `cursor` in PATH, `.cursor/` directory
   - GitHub Copilot CLI: `gh copilot` subcommand
   - Gemini CLI: `gemini` in PATH
   - Windsurf: `.windsurf/` directory
2. For each detected tool, determine the config directory path where agent files should be copied.
3. Return structured list of detected tools with their config paths.
4. Display results grouped: "✓ Detected (N)" in green, "✗ Not found (M)" in gray.

**Verification:**
- Run on a machine with Claude Code installed — Claude Code shows as detected
- Run on a machine with opencode installed — opencode shows as detected
- Run on a clean machine — shows all as "Not found"

**Acceptance:**
- ✅ Claude Code detected if `claude` command or `.claude/` directory exists
- ✅ opencode detected if `.opencode/` directory exists
- ✅ Cline detected if `.cline/` or `.github/agents/` exists
- ✅ Cursor detected if `cursor` command exists
- ✅ GitHub Copilot CLI detected if `gh copilot` works
- ✅ Results grouped and color-coded

---

## Task 8: Install Engine with Progress (X-of-Y)

**Description:** Replace the silent file download loops with X-of-Y progress display showing each file being downloaded with per-file status.

**Files:**
- `install.ps1` — agent and command download loops with progress
- `install.sh` — agent and command download loops with progress

**Steps:**
1. In both: Enhance the agent download loop to show:
   - `[1/4] Downloading vibuzo.md...` with spinner during download
   - `[1/4] vibuzo.md ✓` on success (green checkmark)
   - `[1/4] vibuzo.md ✗` on failure (red X)
2. Same enhancement for the command download loop with its own count.
3. Add basic retry: on failure, retry once after 1 second. If second attempt fails, report the error but continue to the next file.
4. Use atomic writes: download to a temp filename first, then rename to the target filename on success. Clean up temp files on failure.

**Verification:**
- Run fresh install — verify 4 agents download with `[1/4]` through `[4/4]` counter
- Run fresh install — verify 7 commands download with `[1/7]` through `[7/7]` counter
- Simulate a download failure (disconnect network mid-download) — verify retry and graceful error reporting

**Acceptance:**
- ✅ Agent downloads show `[N/4]` counter with per-file success/failure
- ✅ Command downloads show `[N/7]` counter with per-file success/failure
- ✅ Failed downloads retry once then report error
- ✅ Temp files cleaned up on failure

---

## Task 9: Integration Installer

**Description:** Add a step that copies agent files to detected AI tool config directories. Runs as Step 7 of the wizard.

**Files:**
- `install.ps1` — `Install-Integrations` function
- `install.sh` — `install_integrations` function

**Steps:**
1. In both: Create integration installer function that:
   - Takes the list of detected tools from Task 7
   - For each detected tool, creates the config directory if needed
   - Copies all 4 agent files (`vibuzo.md`, `deepveloper.md`, `deepsearcher.md`, `deepviewer.md`) to each tool's config dir
   - Shows progress per tool: `[1/3] Configuring Claude Code... ✓`
2. The existing Claude Code integration (lines 340-351 in PS1, 349-360 in SH) should be reworked to use this function — it becomes one of potentially many integrations.
3. For opencode: agents were already installed to `.opencode/agent/core/` during the main install — skip the copy (agents are already there).
4. For each tool, detect existing Vibuzo agent files and offer to overwrite.

**Verification:**
- Run with Claude Code detected — verify agents copied to `.claude/agents/`
- Run with opencode detected — verify agents NOT re-copied (already in place)
- Run with no tools detected — step shows "No integrations to configure" and skips

**Acceptance:**
- ✅ Agent files copied to each detected tool's config directory
- ✅ opencode integration skipped (agents already installed)
- ✅ Existing agent files in tool dirs are overwritten on confirmation
- ✅ Progress shown per tool

---

## Task 10: Wizard Flow Controller

**Description:** Build the main wizard orchestrator that runs Steps 1-7 in sequence, manages step state, and handles the install flow.

**Files:**
- `install.ps1` — wizard flow logic in the main script body
- `install.sh` — wizard flow logic in the main script body

**Steps:**
1. In both: Replace the current linear script body (everything after the banner, lines 237-377 in PS1) with the wizard controller.
2. The wizard controller:
   - Prints the banner (unchanged)
   - Runs Step 1 (Task 5 — environment detection)
   - Runs Step 2 (Task 6 — install state detection) — based on state, may exit early if up to date
   - Runs Step 3 (Task 7 — AI tool detection)
   - Shows Step 4 — Preview: summary of what will be installed/updated, prompts for confirmation
   - Runs Step 5 (Task 8 — agent downloads)
   - Runs Step 6 (Task 8 — command downloads)
   - Runs Step 7 (Task 9 — integration installer)
   - Runs Step 8 — Summary (Task 12 — post-install box)
3. Each step header is rendered with `Write-Step`/`print_step` showing `Step N/8: Title`.
4. Steps show `✓` on completion, stay visible with green text.
5. Handle abort: if user cancels at any prompt, show cancellation message and exit cleanly.

**Verification:**
- Run fresh install — all 8 steps execute in order with correct numbering
- Run with up-to-date install — Step 2 detects this and exits early
- Run update — wizard flow runs with update-specific messages
- Cancel mid-flow (press N at any prompt) — exits cleanly with message

**Acceptance:**
- ✅ All 8 steps execute in numbered order
- ✅ Step 2 correctly branches based on install state
- ✅ Step 4 shows installation preview with confirmation
- ✅ Cancellation exits cleanly at any point
- ✅ Each completed step shows `✓` and stays visible

---

## Task 11: Enhanced Update Flow

**Description:** Refactor the `--update` flow to use the wizard style with step headers, version comparison preview, and progress display.

**Files:**
- `install.ps1` — update flow logic
- `install.sh` — update flow logic

**Steps:**
1. In both: When `--update` is used, restructure the flow:
   - Show banner (unchanged)
   - Show "Step 1/4: Checking Version..." — read `.vibuzo-version`, fetch latest, compare
   - Show upgrade preview box with: current version, latest version, status, last update date, location
   - If up to date: show summary and exit 0
   - If update available: prompt "Proceed with update? (y/N):" (via Task 4's prompt helper)
   - Show "Step 2/4: Downloading Agents..." with X-of-Y progress (via Task 8)
   - Show "Step 3/4: Downloading Commands..." with X-of-Y progress (via Task 8)
   - Show "Step 4/4: Configuring Integrations..." with tool-based progress (via Task 9)
   - Show post-update summary (Task 12)
2. The AGENTS.md handling logic (preserving custom rules) must remain unchanged but use the prompt helper.

**Verification:**
- Run `--update` with outdated version — show preview, prompt, apply update with progress
- Run `--update` with up-to-date version — show "Up to date" and exit 0
- Run `--update` with `--yes` — auto-confirm, apply update

**Acceptance:**
- ✅ Update flow shows 4 step headers
- ✅ Version comparison preview shown before update
- ✅ Up-to-date case exits early without prompting
- ✅ Agent and command downloads show X-of-Y progress
- ✅ AGENTS.md custom rules preserved during update

---

## Task 12: Post-Install Summary

**Description:** Rewrite the final output box to show a structured multi-section summary with location, agents, commands, integrations, and next steps.

**Files:**
- `install.ps1` — done block
- `install.sh` — done block

**Steps:**
1. In both: Replace the existing success box (lines 357-376 in PS1, lines 371-387 in SH) with the new multi-section format using the enhanced box renderer from Task 2.
2. The new summary must include:
   - Title: `✅ Vibuzo X.X.X installed/updated successfully!`
   - Section 1 (Details): Location, version, agents count, commands count, integrations list
   - Divider `═══`
   - Section 2 (Next Steps): Restart opencode, /context init, /spec, learn more link
3. Use the divider rendering from Task 2 to separate sections.

**Verification:**
- Run fresh install — verify summary shows correct counts and paths
- Run update — verify summary says "updated" with correct version
- Run with integrations — verify detected tools listed in summary

**Acceptance:**
- ✅ Summary box shows with correct title and success/update message
- ✅ Location, version, agents count, commands count displayed
- ✅ Integrations listed
- ✅ Next Steps section with actionable guidance
- ✅ Multi-section box rendered at 59-char width with ═══ dividers
