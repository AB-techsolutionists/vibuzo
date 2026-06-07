---
tags:
  - architecture
  - installer
  - update
  - version-check
scope: Installer update flow, version comparison, and file management
when: Developing the installer or modifying the update mechanism
---

# Installer Update Mechanism

The `--update` flag (`-Update` in PowerShell) provides a safe way to update an existing Vibuzo installation without blindly overwriting files.

## Design

### Version Marker File (`.vibuzo-version`)

Stored at the install target directory (`.opencode/` or `~/.config/opencode/`). One-line format:

```
YYYY-MM-DD HH:mm SHA mode
```

- `SHA` — first 7 characters of the commit SHA from which the install was done (or `unknown` if API unavailable)
- `mode` — `local` or `global`

### Update Flow

1. **Detection** — checks if `.vibuzo-version` exists. If not, exits with error (user must run without `--update` first).
2. **Version read** — parses current install date, commit SHA, and mode from the marker file.
3. **Remote check** — fetches latest commit SHA from `https://api.github.com/repos/AB-techsolutionists/vibuzo/commits/main` (best-effort, graceful failure).
4. **Comparison** — shows current vs latest. Reports "Already up to date" or "Update available".
5. **Confirmation** — if interactive TTY (detected via `[Environment]::UserInteractive` in PowerShell, `[ -t 0 ]` in bash), prompts `Proceed with update? (y/N)`. If piped or non-interactive, auto-proceeds.
6. **Download** — same download logic as fresh install (overwrites all files).
7. **Version write** — overwrites `.vibuzo-version` with new timestamp and SHA.

### Bash-Specific Considerations

The bash installer uses `set -euo pipefail`. The GitHub API call pipeline:

```bash
SHA=$(curl -fsSL "https://api.github.com/repos/$REPO/commits/$BRANCH" 2>/dev/null \
    | grep -o '"sha":"[^"]*"' | head -1 | cut -d'"' -f4 | cut -c1-7 || true)
```

The `|| true` prevents `set -e` from killing the script if the API call or any pipe stage fails.

### PowerShell-Specific Considerations

The `$Branch:` pattern in interpolated strings causes a parser error because PowerShell interprets `$Variable:` as a scoped variable reference (like `$env:Path`). Use `$($Branch)` or `${Branch}` when a colon follows a variable.

```powershell
# Wrong — parser error
Write-Host "  Latest on origin/$Branch: $LatestCommit"

# Correct — subexpression delimiters
Write-Host "  Latest on origin/$($Branch): $LatestCommit"
```

### Usage

```bash
# bash
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --update

# PowerShell
pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }" -Update

# Combined with global
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --global --update
```
