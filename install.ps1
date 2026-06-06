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

# ─── Version ─────────────────────────────────────────────────────────────────

$ScriptVersion = "0.1.0"

# ─── File Arrays ──────────────────────────────────────────────────────────────

$AgentFiles = @(
    @{ Name = "vibuzo.md";      Desc = "main agent" }
    @{ Name = "deepveloper.md"; Desc = "execution specialist" }
)

$CommandFiles = @(
    "spec", "add-context", "context-init", "context-find",
    "context-harvest", "context-append", "session",
    "session-view", "session-timeline"
)

# ─── Terminal Colors ─────────────────────────────────────────────────────────

$Cyan = "Cyan"
$Green = "Green"
$Yellow = "Yellow"
$Red = "Red"

# ─── Section Renderer ────────────────────────────────────────────────────────

function Write-Section {
    param(
        [string]$Name,
        [string[]]$Items
    )

    # Section header with count: "  ── Name (N) ──────────────────────"
    $header = "  ── $Name ($($Items.Count)) "
    $header = $header.PadRight(54, '─')
    Write-Host $header -ForegroundColor $Cyan

    # Grouped items with wrapping at 4 items
    $line = "  ✓ "
    for ($i = 0; $i -lt $Items.Count; $i++) {
        if ($i -gt 0 -and $i % 4 -eq 0) {
            Write-Host $line.TrimEnd(', ') -ForegroundColor $Green
            $line = "    "
        }
        $line += "$($Items[$i]), "
    }
    if ($line -ne "  ✓ ") {
        Write-Host $line.TrimEnd(', ') -ForegroundColor $Green
    }
}

# ─── Box Renderer ───────────────────────────────────────────────────────────

function Write-Box {
    param(
        [string]$Title,
        [string[]]$Lines,
        [string]$Color = "Cyan"
    )

    # Calculate content width from the longest line
    $maxLen = 0
    foreach ($line in $Lines) {
        if ($line.Length -gt $maxLen) { $maxLen = $line.Length }
    }
    $contentWidth = [Math]::Max($maxLen, $Title.Length + 2)
    $totalWidth = $contentWidth + 4  # 2 spaces padding each side

    # Top border with title
    $titleSection = " $Title "
    $sideDashes = ($totalWidth - $titleSection.Length) / 2
    $top = "╭" + "─" * [Math]::Floor($sideDashes) + $titleSection + "─" * [Math]::Ceiling($sideDashes) + "╮"
    Write-Host $top -ForegroundColor $Color

    # Content lines
    foreach ($line in $Lines) {
        Write-Host ("│ " + $line.PadRight($contentWidth) + " │") -ForegroundColor $Color
    }

    # Bottom border
    Write-Host ("╰" + "─" * $totalWidth + "╯") -ForegroundColor $Color
}

# ─── Help ────────────────────────────────────────────────────────────────────

if ($Help) {
  Write-Host @"
install.ps1 — Vibuzo Agentic Framework Installer ($ScriptVersion)

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
  # Format: 0.x.x | yyyy-MM-dd HH:mm sssssss mode
  $VersionAndRest = $CurrentVersion -split ' \| '
  $Version = $VersionAndRest[0]
  $OldParts = $VersionAndRest[1] -split ' '
  $InstalledDate = $OldParts[0]
  $InstalledTime = $OldParts[1]
  $InstalledCommit = $OldParts[2]
  $InstalledMode = $OldParts[3]

  # Format date for display: "Jun 07 at 00:42"
  $InstalledFull = Get-Date "$InstalledDate $InstalledTime" -Format "MMM dd 'at' HH:mm"

  # Try to fetch latest commit SHA from GitHub API (best-effort)
  $LatestCommit = ""
  $UpToDate = $false
  try {
    $LatestCommit = (Invoke-RestMethod -Uri "https://api.github.com/repos/$Repo/commits/$Branch" -ErrorAction Stop).sha.Substring(0,7)
    if ($LatestCommit -eq $InstalledCommit) {
      $Status = "✅ Up to date"
      $UpToDate = $true
    } else {
      $Status = "⬆️ Update available"
    }
  } catch {
    $Status = "⚠️ Could not check"
  }

  # Build and display the update check box
  $BoxLines = @()
  $BoxLines += "Current:  $Version  ($InstalledCommit)"
  if ($LatestCommit) {
    $BoxLines += "Latest:   $ScriptVersion  ($LatestCommit)"
  }
  $BoxLines += "Status:   $Status"
  $BoxLines += ""
  $BoxLines += "Installed: $InstalledFull"
  $BoxLines += "Location:  $OpenCodeDir"

  Write-Box -Title "Vibuzo Update Check" -Lines $BoxLines

  if ($UpToDate) {
    exit 0
  }

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
  Write-Host "⬆️  Updating Vibuzo $ScriptVersion ($InstallTarget)..." -ForegroundColor $Yellow
} else {
  Write-Host ""
  Write-Host "🔧 Installing Vibuzo $ScriptVersion ($InstallTarget)..." -ForegroundColor $Cyan
}

# ─── Install / Update ────────────────────────────────────────────────────────

New-Item -ItemType Directory -Path $AgentsDir -Force | Out-Null
New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null

Write-Host ""
Write-Section "Agents" ($AgentFiles | ForEach-Object { $_.Name })

foreach ($file in $AgentFiles) {
    Invoke-WebRequest -Uri "$RawUrl/agents/$($file.Name)" -OutFile "$AgentsDir\$($file.Name)"
}

Write-Host ""
Write-Section "Commands" $CommandFiles

foreach ($file in $CommandFiles) {
    Invoke-WebRequest -Uri "$RawUrl/commands/$file.md" -OutFile "$CommandsDir\$file.md"
}

Write-Host ""
Write-Host "  ─── Project ─────────────────────────────" -ForegroundColor $Cyan

# Download AGENTS.md to project root (if local) or to opencode dir (if global)
if (-not $Global) {
  # ─── Check AGENTS.md status ────────────────────────────────────
  $ExistingContent = $null
  $UserRules = $null
  $AgentsStatus = "fresh copy"
  if (Test-Path "AGENTS.md") {
    $Lines = Get-Content "AGENTS.md"
    $MarkerIndex = $Lines.IndexOf("─── PASTE YOUR CUSTOM RULES BELOW THIS LINE ───")
    if ($MarkerIndex -ge 0) {
      # Vibuzo file — save content below marker (user's custom rules)
      if ($MarkerIndex -lt $Lines.Length - 1) {
        $SavedContent = $Lines[($MarkerIndex + 1)..($Lines.Length - 1)] -join "`n"
        if ($SavedContent.Trim() -ne "") {
          $UserRules = $SavedContent
          $AgentsStatus = "with custom rules preserved"
        }
      }
    } else {
      # User's own AGENTS.md — save entire content to prepend
      $ExistingContent = $Lines -join "`n"
      $AgentsStatus = "your content preserved at top"
    }
  }

  Write-Host "  ✓ AGENTS.md ($AgentsStatus)" -ForegroundColor $Green

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
  Write-Host "  ✓ AGENTS.md (fresh copy)" -ForegroundColor $Green
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
"$ScriptVersion | $Now $Sha $Mode" | Out-File -FilePath $VersionFile -Encoding ASCII

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
$StatusLine = "✅ Vibuzo $ScriptVersion ${Action} successfully!"

# Build content lines (compact box)
$BoxLines = @()
if ($Update) {
    $BoxLines += ""
    $BoxLines += "Location:  $InstallTarget"
    $BoxLines += ""
} else {
    $BoxLines += "Location:  $InstallTarget"
    $BoxLines += ""
    $BoxLines += "── Next Steps ──"
    $BoxLines += "1. Restart opencode → select Vibuzo"
    $BoxLines += "2. Run /context init to scaffold project memory"
    $BoxLines += "3. Start building with /spec [feature description]"
    $BoxLines += "💡 github.com/AB-techsolutionists/vibuzo"
}

# Calculate box width from content
$maxLineLen = $StatusLine.Length + 2
foreach ($l in $BoxLines) { if ($l.Length -gt $maxLineLen) { $maxLineLen = $l.Length } }
$innerWidth = $maxLineLen + 4

Write-Host ""
# Top border with title
$titleSection = " $StatusLine "
$sideDashes = ($innerWidth - $titleSection.Length) / 2
Write-Host ("╭" + "─" * [Math]::Floor($sideDashes) + $titleSection + "─" * [Math]::Ceiling($sideDashes) + "╮")
# Content lines
foreach ($l in $BoxLines) {
    if ($l -eq "") {
        Write-Host ("│" + "".PadRight($innerWidth) + "│")
    } else {
        Write-Host ("│ " + $l.PadRight($innerWidth - 2) + " │")
    }
}
# Bottom border
Write-Host ("╰" + "─" * $innerWidth + "╯")
Write-Host ""
