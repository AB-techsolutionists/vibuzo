# Installer Visual Language

Both `install.ps1` and `install.sh` use a consistent visual language for terminal output. Any changes to the installers must maintain this scheme.

## Color Scheme

| Element | PowerShell | Bash (ANSI) | Usage |
|---------|-----------|-------------|-------|
| Headers/section titles | `$Cyan` | `\033[0;36m` | Section dividers (`─── Agents ───`), info labels |
| Success/items | `$Green` | `\033[0;32m` | Checkmarks (`✓`), "Already up to date", "installed successfully" |
| Warnings/notices | `$Yellow` | `\033[0;33m` | "Checking for updates...", "Update available!", AGENTS.md warnings |
| Errors | `$Red` | `\033[0;31m` | Network failures, file errors |
| Default | None | `\033[0m` (NC) | Box borders, file paths, dimensions |

## Layout Structure

### Header
- VIBUZO figlet banner in ANSI Shadow font, printed in cyan, wrapped in a double-line box (`╔╗╚╝`)
- Always printed first, before any other output

### Install/Update Title
- Single colored line: `🔧 Installing Vibuzo 0.x.x (local)...` (cyan) or `⬆️  Updating Vibuzo 0.x.x...` (yellow)
- Version number always shown in the install/update title line

### Update Mode (if applicable)
- Version info block with cyan "Current install:" header
- Remote check with comparison result
- Exit early with "Already up to date" box if SHA matches

### File Sections
Files are grouped into sections with cyan headers:
```
  ─── Agents ──────────────────────────────
   ✓ vibuzo.md       (main agent)
   ✓ deepveloper.md  (execution specialist)

  ─── Commands ────────────────────────────
   ✓ spec.md         (feature pipeline)
   ...
```
- Each file gets a green checkmark prefix
- Descriptions in parentheses aligned by column

### Success Box
A rounded box (`╭╮╰╯`) containing:
1. Green success message with version: `✅ Vibuzo 0.x.x installed successfully!`
2. Location and agents path
3. `── Next Steps ──` section with numbered steps (1-4)
4. Link for more info

### AGENTS.md Warning
When overwriting an existing AGENTS.md:
- Yellow warning that it will be overwritten
- Instructions to copy custom rules and re-add via `/add-context`

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
