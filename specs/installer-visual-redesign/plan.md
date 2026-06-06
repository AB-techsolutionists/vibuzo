# Installer Visual Redesign — Plan

## Tech Stack

- **install.ps1** — PowerShell 5.1+ (no changes to language)
- **install.sh** — Bash 3.2+ (no changes to language)
- No external dependencies. All changes are pure output string/formatting changes and code restructuring.

## Architecture

The installers have 5 output sections that need redesign:

```
┌──────────┐
│  Banner  │ ← Unchanged
├──────────┤
│  Title   │ ← Minor: "${action} Vibuzo ${version}"
├──────────┤
│ Sections │ ← Major: grouped file display
│  Agents  │    Arrays + loop instead of repeating pairs
│  Commands│    Comma-separated listing
│  Project │    Single-line AGENTS.md status
├──────────┤
│ Success  │ ← Moderate: compact box, simplified
│ Box      │
├──────────┤
│ Update   │ ← Major: single compact comparison box
│ Check    │    with current/latest/status
└──────────┘
```

## Components

### A. File Lists as Arrays

**Problem:** 11 repeated `Write-Host "✓ file.md" + Invoke-WebRequest` pairs.
**Solution:** Define arrays and loop once.

```powershell
# install.ps1
$AgentFiles = @(
  @{ Name = "vibuzo.md";      Desc = "main agent" }
  @{ Name = "deepveloper.md"; Desc = "execution specialist" }
)
$CommandFiles = @(
  "spec", "add-context", "context-init", "context-find",
  "context-harvest", "context-append", "session",
  "session-view", "session-timeline"
)
```

### B. Section Renderer

Function that takes a section name, file array, and renders:
```
  ── <Name> (<Count>) ────────────────────
  ✓ <files comma-separated>
```

### C. Box Helper

Function to render rounded boxes with configurable width and content lines:
```powershell
function Write-Box {
  param([string[]]$Lines, [string]$Color = "Cyan", [int]$Width = 54)
  # Draw ╭─ top, ╰─ bottom, │ sides
}
```

### D. Update Check Box

Single box showing:
- Current version + SHA
- Latest version + SHA (or just "—" if fetch failed)
- Status line (✅ / ⬆️ / ⚠️)
- Installed date (short format) + Location

### E. Success Box (compact)

Simplified success box:
- Version + action line
- Location line
- Next Steps (install only) or nothing (update only)
- GitHub link

## Implementation Order

| Order | Component | Files | Risk | Dependencies |
|-------|-----------|-------|------|-------------|
| 1 | File arrays + download loop | install.ps1, install.sh | Low | None |
| 2 | Section renderer (grouped display) | install.ps1, install.sh | Low | #1 |
| 3 | AGENTS.md single-line status | install.ps1, install.sh | Medium | #2 (needs to work with the section renderer) |
| 4 | Update check compact box | install.ps1, install.sh | Medium | None (independent) |
| 5 | Compact success box | install.ps1, install.sh | Low | None |
| 6 | Update `installer-visual-language.md` | context/standards/ | Low | #1-5 complete (doc must match) |

**Risk factor:** Medium — the AGENTS.md logic is the most complex part (3 cases + preservation logic). The rest is pure string formatting.

## Key Constraints

- Both installers must remain visually identical. Every formatting change to one must be mirrored in the other.
- Box widths must handle the text that goes inside them. The longest string determines minimum width.
- Commas and wrapping: commands should wrap after 4 items with indent.
- No functional changes — only display formatting and code structure.
