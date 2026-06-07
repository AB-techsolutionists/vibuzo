---
tags:
  - installer
  - visual-style
  - terminal-output
  - colors
  - powershell
  - bash
scope: install.ps1 and install.sh visual output formatting
when: Modifying installer script output or terminal formatting
---

# Installer Visual Language

Both `install.ps1` and `install.sh` use a consistent visual language for terminal output. Any changes to the installers must maintain this scheme.

## Color Scheme

| Element | PowerShell | Bash (ANSI) | Usage |
|---------|-----------|-------------|-------|
| Headers/section titles | `$Cyan` | `\033[0;36m` | Section dividers (`── Agents (N) ──`), box borders, "Installing Vibuzo..." title |
| Success/items | `$Green` | `\033[0;32m` | Checkmarks (`✓`), status lines |
| Warnings/notices | `$Yellow` | `\033[0;33m` | "Update available!", "Update cancelled" |
| Errors | `$Red` | `\033[0;31m` | Network failures, file errors |
| Default | None | `\033[0m` (NC) | Box corners, file paths, dimensions, success box borders |

## Layout Structure

### Header
- VIBUZO figlet banner in ANSI Shadow font, printed in cyan, wrapped in a double-line box (`╔╗╚╝`)
- Always printed first, before any other output

### Install/Update Title
- Wrapped in a header box using `Write-Box`/`print_box` with title "Installing" or "Updating"
- Version number always shown in the content line inside the box

### Update Mode (if applicable)
Single double-line box with version comparison, fixed 59-char width matching the banner:
```
╔══════ Vibuzo Update Check ═══════════════════════════════╗
║  Current:  0.1.4                                         ║
║  Latest:   0.1.5                                         ║
║  Status:   Update available                              ║
║                                                           ║
║  Installed: Jun 07 at 14:13                              ║
║  Location:  .opencode                                    ║
╚═══════════════════════════════════════════════════════════╝
```
- Three status modes: `Up to date`, `Update available`, `Could not check` (no emoji icons — removed for clean box alignment)
- "Up to date" exits immediately after the box
- "Could not check" only shows Current line (no Latest)
- Date uses short format (`Mon DD at HH:MM`)

### File Sections
Files are grouped into sections with cyan headers showing item count:
```
  ── Agents (2) ──────────────────────
  ✓ vibuzo.md, deepveloper.md

  ── Commands (5) ────────────────────
  ✓ spec, add-context, context-init, research,
    session
```
- Each section header: `── Name (N) ──` padded with dashes to fill width
- Items listed comma-separated on one line after a single green checkmark
- Commands listed without `.md` extension (stem name only)
- After 4 items, wrap to next line with 4-space indent

### AGENTS.md Status
Single line under the Project section instead of a decorative box:
```
  ── Project ────────────────────────
  ✓ AGENTS.md (fresh copy)
```
Three status messages:
- `✓ AGENTS.md (fresh copy)` — no existing file, downloaded new
- `✓ AGENTS.md (with custom rules preserved)` — Vibuzo file with user rules below marker
- `✓ AGENTS.md (your content preserved at top)` — user's own AGENTS.md

The interactive prompt (`Proceed with AGENTS.md? (y/N)`) appears after the status line without any decorative box.

### Success Box (Install)
Double-line box, fixed 59-char width matching the banner:
```
╔════ ✅ Vibuzo 0.1.5 installed successfully! ═════════════╗
║  Location:  local (.opencode/)                           ║
║                                                           ║
║  ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━                  ║
║                                                           ║
║  → Restart opencode and select Vibuzo                    ║
║    from the agent dropdown.                              ║
║                                                           ║
║  → First time? Run /context init                         ║
║    to set up project memory.                             ║
║                                                           ║
║  → Start building with:                                  ║
║    /spec [feature description]                            ║
║                                                           ║
║  💡 Learn more:                                          ║
║     github.com/AB-techsolutionists/vibuzo                ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```

### Success Box (Update)
Double-line box, fixed 59-char width matching the banner:
```
╔════ ✅ Vibuzo 0.1.5 updated successfully! ═══════════════╗
║  Location:  local (.opencode/)                           ║
╚═══════════════════════════════════════════════════════════╝
```
- No "Next Steps" section for updates
- Box width is fixed at 59 chars (matching the VIBUZO banner), not dynamic

## Helper Functions

### PowerShell: Write-Section
```powershell
function Write-Section {
    param([string]$Name, [string[]]$Items)
    # Renders: "  ── Name (N) ─────" header + "  ✓ item1, item2, ..."
    # Wraps at 4 items with 4-space indent on continuation lines
}
```

### PowerShell: Write-Box
```powershell
function Write-Box {
    param([string]$Title, [string[]]$Lines, [string]$Color = "Cyan")
    # Renders a double-line box (╔╗╚╝║═) with title in top border
    # Fixed width of 59 characters (matching the VIBUZO banner)
    # Content area: 55 chars, emoji double-width compensated
}
```

### Bash: print_section
```bash
print_section() {
    local name="$1"
    shift
    local items=("$@")
    # Same rendering as Write-Section
    # Uses printf with ANSI color codes
}
```

### Bash: print_box
```bash
print_box() {
    local title="$1"
    shift
    local lines=("$@")
    # Same rendering as Write-Box (╔╗╚╝║═, 59-char fixed width)
    # Uses printf with ANSI color codes
    # Emoji double-width: strips ✅❌ to compute padding
}
```

## PowerShell Implementation

```powershell
$Cyan = "Cyan"; $Green = "Green"; $Yellow = "Yellow"; $Red = "Red"
Write-Host "text" -ForegroundColor $Cyan
```

See `install.ps1` for full implementation.

## Bash Implementation

```bash
CYAN='\033[0;36m'; GREEN='\033[0;32m'; YELLOW='\033[0;33m'; RED='\033[0;31m'; NC='\033[0m'
printf "${CYAN}text${NC}\n"
```

Use `printf` (not `echo`) for ANSI-colored output. See `install.sh` for full implementation.

## Key Rules

1. **Never use color as the only conveyor of information** — output must be readable without color (e.g., on monochrome terminals)
2. **Both installers must match visually** — any visual change to one must be mirrored in the other
3. **Use `printf` in bash** — `echo -e` behavior varies across shells; `printf` is portable
4. **The banner must always appear first** — before any version checks or download output
5. **Version always shown** — install/update lines, success box, and update-mode display must include the current semver (`0.x.x`)
6. **Use arrays/loops** — file lists should be stored in arrays and processed with loops, not repeated `Write-Host`/`printf` + download pairs
7. **Double-line borders everywhere** — all installer boxes use `╔╗╚╝║═` (double-line) matching the VIBUZO banner style at a fixed 59-char total width. Never use `╭╮╰╯│─` (rounded) or `┌┐└┘│─` (single-line).
