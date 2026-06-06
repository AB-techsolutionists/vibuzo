<#
.SYNOPSIS
    Vibuzo Agentic Framework Installer (Windows)
.DESCRIPTION
    Installs Vibuzo (main), Deepveloper (subtask), /spec pipeline, and active commands to .opencode/ or ~/.config/opencode/
.PARAMETER Global
    Install to ~/.config/opencode/ (available in ALL projects)
.PARAMETER Update
    Update existing installation. Shows version info and prompts for confirmation before overwriting.
.PARAMETER Help
    Show this help message
.EXAMPLE
    pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }"
.EXAMPLE
    pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }" -Global
.EXAMPLE
    pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }" -Update
#>

param(
  [switch]$Global,
  [switch]$Update,
  [switch]$Help
)

$Repo = "AB-techsolutionists/vibuzo"
$Branch = "main"
$RawUrl = "https://raw.githubusercontent.com/$Repo/$Branch"

# ─── Paths ───────────────────────────────────────────────────────────────────

if ($Global) {
  $OpenCodeDir = if ($env:OPENCODE_INSTALL_DIR) { $env:OPENCODE_INSTALL_DIR } else { "$env:USERPROFILE\.config\opencode" }
  $InstallTarget = "global ($OpenCodeDir)"
} else {
  $OpenCodeDir = ".opencode"
  $InstallTarget = "local (.opencode/)"
}

$AgentsDir = "$OpenCodeDir\agent\core"
$CommandsDir = "$OpenCodeDir\commands"
$VersionFile = "$OpenCodeDir\.vibuzo-version"

# ─── Terminal Colors ─────────────────────────────────────────────────────────

$Cyan = "Cyan"
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"

# ─── Help ────────────────────────────────────────────────────────────────────

if ($Help) {
  Write-Host @"
install.ps1 — Vibuzo Agentic Framework Installer

Usage:
  pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }"
  pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }" -Global
  pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }" -Update

Options:
  -Global     Install to ~/.config/opencode/ (available in ALL projects)
  -Update     Update existing installation (shows version info, prompts confirmation before overwriting)
  -Help       Show this help message
"@
  exit 0
}

# ─── Banner ──────────────────────────────────────────────────────────────────

$Banner = @'
╔═══════════════════════════════════════════════════════════╗
║                                                           ║
║   ██╗   ██╗██╗██████╗ ██╗   ██╗███████╗ ██████╗          ║
║   ██║   ██║██║██╔══██╗██║   ██║╚══███╔╝██╔═══██╗         ║
║   ██║   ██║██║██████╔╝██║   ██║  ███╔╝ ██║   ██║         ║
║   ╚██╗ ██╔╝██║██╔══██╗██║   ██║ ███╔╝  ██║   ██║         ║
║    ╚████╔╝ ██║██████╔╝╚██████╔╝███████╗╚██████╔╝         ║
║     ╚═══╝  ╚═╝╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝          ║
║                                                           ║
║               Agentic Framework                           ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
'@
Write-Host $Banner -ForegroundColor $Cyan

# ─── Update Mode ─────────────────────────────────────────────────────────────

if ($Update) {
  if (-not (Test-Path $VersionFile)) {
    Write-Host "❌ No existing Vibuzo installation found at $OpenCodeDir"
    Write-Host "   Run without -Update to install fresh."
    exit 1
  }

  $CurrentVersion = Get-Content $VersionFile
  $Parts = $CurrentVersion -split ' '
  $InstalledDate = $Parts[0]
  $InstalledTime = $Parts[1]
  $InstalledCommit = $Parts[2]
  $InstalledMode = $Parts[3]

  Write-Host "🔍 Checking for updates..." -ForegroundColor $Yellow
  Write-Host ""
  Write-Host "  Current install:" -ForegroundColor $Cyan
  Write-Host "    Date:   $InstalledDate at $InstalledTime"
  Write-Host "    Commit: $InstalledCommit"
  Write-Host "    Mode:   $InstalledMode"
  Write-Host "    Path:   $OpenCodeDir"
  Write-Host ""

  # Try to fetch latest commit SHA from GitHub API (best-effort)
  try {
    $LatestCommit = (Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/commits/$Branch" -ErrorAction Stop).sha.Substring(0,7)
    Write-Host "  Latest on origin/$($Branch): $LatestCommit" -ForegroundColor $Cyan
    if ($LatestCommit -eq $InstalledCommit) {
      Write-Host ""
      Write-Host "╭──────────────────────────────────────────────────────────────╮"
      Write-Host "│                                                              │"
      Write-Host "│              ✅ Vibuzo is already up to date!                 │" -ForegroundColor $Green
      Write-Host "│                                                              │"
      Write-Host "│  Installed: $InstalledDate at $InstalledTime ($InstalledCommit)"
      Write-Host "│  Location:  $InstallTarget"
      Write-Host "│                                                              │"
      Write-Host "╰──────────────────────────────────────────────────────────────╯"
      exit 0
    } else {
      Write-Host "  ⬆️  Update available!" -ForegroundColor $Yellow
    }
  } catch {
    Write-Host "  (Could not check remote — network issue or API limit)" -ForegroundColor $Red
  }
  Write-Host ""

  # Interactive confirmation (skip if piped or non-interactive)
  $Interactive = [Environment]::UserInteractive -and -not [Console]::IsInputRedirected
  if ($Interactive) {
    $Response = Read-Host "Proceed with update? (y/N)"
    if ($Response -notin @('y', 'Y', 'yes', 'YES')) {
      Write-Host "Update cancelled." -ForegroundColor $Yellow
      exit 0
    }
  } else {
    Write-Host "(non-interactive shell — proceeding automatically)"
  }

  Write-Host ""
  Write-Host "⬆️  Updating Vibuzo ($InstallTarget)..." -ForegroundColor $Yellow
} else {
  Write-Host ""
  Write-Host "🔧 Installing Vibuzo ($InstallTarget)..." -ForegroundColor $Cyan
}

# ─── Install / Update ────────────────────────────────────────────────────────

New-Item -ItemType Directory -Path $AgentsDir -Force | Out-Null
New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null

Write-Host ""
Write-Host "  ─── Agents ──────────────────────────────" -ForegroundColor $Cyan
Write-Host ""

Write-Host "   ✓ vibuzo.md       (main agent)" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/agents/vibuzo.md" -OutFile "$AgentsDir\vibuzo.md"

Write-Host "   ✓ deepveloper.md  (execution specialist)" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/agents/deepveloper.md" -OutFile "$AgentsDir\deepveloper.md"

Write-Host ""
Write-Host "  ─── Commands ────────────────────────────" -ForegroundColor $Cyan
Write-Host ""

Write-Host "   ✓ spec.md         (feature pipeline)" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/commands/spec.md" -OutFile "$CommandsDir\spec.md"
Write-Host "   ✓ add-context.md" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/commands/add-context.md" -OutFile "$CommandsDir\add-context.md"
Write-Host "   ✓ context-init.md (scaffold context)" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/commands/context-init.md" -OutFile "$CommandsDir\context-init.md"
Write-Host "   ✓ context-find.md" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/commands/context-find.md" -OutFile "$CommandsDir\context-find.md"
Write-Host "   ✓ context-harvest.md" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/commands/context-harvest.md" -OutFile "$CommandsDir\context-harvest.md"
Write-Host "   ✓ context-append.md" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/commands/context-append.md" -OutFile "$CommandsDir\context-append.md"
Write-Host "   ✓ session.md" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/commands/session.md" -OutFile "$CommandsDir\session.md"
Write-Host "   ✓ session-view.md" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/commands/session-view.md" -OutFile "$CommandsDir\session-view.md"
Write-Host "   ✓ session-timeline.md" -ForegroundColor $Green
Invoke-WebRequest -Uri "$RawUrl/commands/session-timeline.md" -OutFile "$CommandsDir\session-timeline.md"

Write-Host ""
Write-Host "  ─── Project ─────────────────────────────" -ForegroundColor $Cyan
Write-Host ""

# Download AGENTS.md to project root (if local) or to opencode dir (if global)
if (-not $Global) {
  # ─── Check AGENTS.md status and explain to user ────────────────
  $ExistingContent = $null
  $UserRules = $null
  if (Test-Path "AGENTS.md") {
    $Lines = Get-Content "AGENTS.md"
    $MarkerIndex = $Lines.IndexOf("─── PASTE YOUR CUSTOM RULES BELOW THIS LINE ───")
    if ($MarkerIndex -ge 0) {
      # Vibuzo file — save content below marker (user's custom rules)
      if ($MarkerIndex -lt $Lines.Length - 1) {
        $SavedContent = $Lines[($MarkerIndex + 1)..($Lines.Length - 1)] -join "`n"
        if ($SavedContent.Trim() -ne "") {
          $UserRules = $SavedContent
        }
      }
      Write-Host ""
      Write-Host "╭── AGENTS.md ─────────────────────────────────────────╮" -ForegroundColor $Cyan
      Write-Host "│                                                     │" -ForegroundColor $Cyan
      Write-Host "│  Vibuzo AGENTS.md found with custom rules below     │" -ForegroundColor $Cyan
      if ($UserRules) {
        Write-Host "│  the marker. These custom rules will be preserved   │" -ForegroundColor $Cyan
      } else {
        Write-Host "│  the marker. No custom rules found below marker.    │" -ForegroundColor $Cyan
      }
      Write-Host "│  The framework section (above ---) will be updated   │" -ForegroundColor $Cyan
      Write-Host "│  to the latest version.                              │" -ForegroundColor $Cyan
      Write-Host "│                                                     │" -ForegroundColor $Cyan
      Write-Host "╰─────────────────────────────────────────────────────╯" -ForegroundColor $Cyan
    } else {
      # User's own AGENTS.md — save entire content to prepend
      $ExistingContent = $Lines -join "`n"
      Write-Host ""
      Write-Host "╭── AGENTS.md ─────────────────────────────────────────╮" -ForegroundColor $Cyan
      Write-Host "│                                                     │" -ForegroundColor $Cyan
      Write-Host "│  An existing AGENTS.md was found in your project.   │" -ForegroundColor $Cyan
      Write-Host "│  Your current content will be preserved at the top. │" -ForegroundColor $Cyan
      Write-Host "│  Vibuzo's framework content will be appended below  │" -ForegroundColor $Cyan
      Write-Host "│  with a --- separator. Nothing will be overwritten. │" -ForegroundColor $Cyan
      Write-Host "│                                                     │" -ForegroundColor $Cyan
      Write-Host "╰─────────────────────────────────────────────────────╯" -ForegroundColor $Cyan
    }
  } else {
    Write-Host ""
    Write-Host "╭── AGENTS.md ─────────────────────────────────────────╮" -ForegroundColor $Cyan
    Write-Host "│                                                     │" -ForegroundColor $Cyan
    Write-Host "│  No existing AGENTS.md found. A fresh copy will be  │" -ForegroundColor $Cyan
    Write-Host "│  downloaded and placed in your project root.        │" -ForegroundColor $Cyan
    Write-Host "│                                                     │" -ForegroundColor $Cyan
    Write-Host "╰─────────────────────────────────────────────────────╯" -ForegroundColor $Cyan
  }

  $Interactive = [Environment]::UserInteractive -and -not [Console]::IsInputRedirected
  if ($Interactive) {
    $Response = Read-Host "Proceed with AGENTS.md? (y/N)"
    if ($Response -notin @('y', 'Y', 'yes', 'YES')) {
      Write-Host "AGENTS.md skipped." -ForegroundColor $Yellow
      return
    }
  } else {
    Write-Host "(non-interactive shell — proceeding automatically)"
  }

  Write-Host ""
  Write-Host "   ✓ AGENTS.md       (project root)" -ForegroundColor $Green
  Invoke-WebRequest -Uri "$RawUrl/AGENTS.md" -OutFile "AGENTS.md"
  if ($ExistingContent) {
    # User had their own AGENTS.md — prepend it above Vibuzo content
    $VibuzoContent = Get-Content "AGENTS.md" -Raw
    Set-Content -Path "AGENTS.md" -Value "$ExistingContent`n`n---`n`n$VibuzoContent"
  } elseif ($UserRules) {
    # Vibuzo file with custom rules below marker — re-append them
    Add-Content -Path "AGENTS.md" -Value "`n$UserRules"
  }
} else {
  Write-Host "   ✓ AGENTS.md       (opencode dir)" -ForegroundColor $Green
  Invoke-WebRequest -Uri "$RawUrl/AGENTS.md" -OutFile "$OpenCodeDir\AGENTS.md"
}

# ─── Path Rewriting (global install only) ────────────────────────────────────

if ($Global) {
  Write-Host "   ✓ Path rewriting" -ForegroundColor $Green
  (Get-Content "$AgentsDir\vibuzo.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\vibuzo.md"
  (Get-Content "$AgentsDir\deepveloper.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\deepveloper.md"
  (Get-Content "$OpenCodeDir\AGENTS.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$OpenCodeDir\AGENTS.md"
}

# ─── Write Version File ──────────────────────────────────────────────────────

$Now = Get-Date -Format "yyyy-MM-dd HH:mm"
$Mode = if ($Global) { "global" } else { "local" }
# Try to get the latest commit SHA (best-effort)
try {
  $Sha = (Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/commits/$Branch" -ErrorAction Stop).sha.Substring(0,7)
} catch {
  $Sha = "unknown"
}
"$Now $Sha $Mode" | Out-File -FilePath $VersionFile -Encoding ASCII

# ─── Tool Detection ──────────────────────────────────────────────────────────

# Claude Code
if (Get-Command "claude" -ErrorAction SilentlyContinue) {
  Write-Host ""
  Write-Host "  ─── Integrations ─────────────────────────" -ForegroundColor $Cyan
  Write-Host ""
  Write-Host "   ✓ Claude Code agents" -ForegroundColor $Green
  New-Item -ItemType Directory -Path ".claude\agents" -Force | Out-Null
  Copy-Item "$AgentsDir\vibuzo.md" ".claude\agents\vibuzo.md"
  Copy-Item "$AgentsDir\deepveloper.md" ".claude\agents\deepveloper.md"
}

# ─── Done ────────────────────────────────────────────────────────────────────

$Action = if ($Update) { "updated" } else { "installed" }
Write-Host ""
Write-Host "╭──────────────────────────────────────────────────────────────╮"
Write-Host "│                                                              │"
if ($Update) {
  Write-Host "│              ✅ Vibuzo updated successfully!                 │" -ForegroundColor $Green
} else {
  Write-Host "│              ✅ Vibuzo installed successfully!                │" -ForegroundColor $Green
}
Write-Host "│                                                              │"
Write-Host "│  Location: $InstallTarget"
Write-Host "│  Agents:   $AgentsDir"
Write-Host "│                                                              │"
Write-Host "│  ── Next Steps ──                                             │"
Write-Host "│                                                              │"
Write-Host "│  1. Restart opencode to pick up Vibuzo                       │"
Write-Host "│  2. Select Vibuzo from the agent dropdown                    │"
Write-Host "│  3. Run /context init to scaffold project memory             │"
Write-Host "│  4. Start building with /spec [feature description]          │"
Write-Host "│                                                              │"
Write-Host "│  💡 Learn more: github.com/AB-techsolutionists/vibuzo        │"
Write-Host "│                                                              │"
Write-Host "╰──────────────────────────────────────────────────────────────╯"
Write-Host ""
