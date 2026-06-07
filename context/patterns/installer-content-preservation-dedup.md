---
tags:
  - installers
  - content-preservation
  - dedup
scope: How installers handle preserving user content across updates without duplication
when: Adding or modifying installer content preservation logic
---

# Installer Content Preservation Dedup

> Before appending preserved user content, verify the fresh download doesn't already contain it.

## Problem

When an installer preserves user content (e.g., custom rules below a marker in `AGENTS.md`), saves it before downloading a fresh copy, then re-appends it, the content can **duplicate** if the repo's fresh copy already includes the same content below the marker.

This happens when:
1. User adds custom rules → installer saves them
2. Rules get committed to the repo (included in fresh download)
3. Installer re-appends the saved rules → duplication

## Solution

After downloading the fresh copy, check if the target section already has content before appending:

### PowerShell Pattern

```powershell
$FreshLines = Get-Content "AGENTS.md"
$FreshMarker = $FreshLines.IndexOf("─── MARKER TEXT ───")
$HasExistingRules = $FreshMarker -ge 0 -and $FreshMarker -lt $FreshLines.Length - 1 -and
                    ($FreshLines[($FreshMarker + 1)..($FreshLines.Length - 1)] -join "`n").Trim() -ne ""
if (-not $HasExistingRules) {
    Add-Content -Path "AGENTS.md" -Value "`n$UserRules"
}
```

### Bash Pattern

```bash
FRESH_AFTER_MARKER=$(awk '/MARKER TEXT/{found=1; next} found' AGENTS.md 2>/dev/null)
if [ -z "$(echo "$FRESH_AFTER_MARKER" | tr -d '[:space:]')" ]; then
    printf "\n%s" "$USER_RULES" >> AGENTS.md
fi
```

## Key Insight

The guard must check the **freshly downloaded** file (not the pre-download state) since the repo may have been updated between install runs. Simply comparing saved rules against previous state is not sufficient.
