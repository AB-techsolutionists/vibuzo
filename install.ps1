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

try {
  $ScriptVersion = (Invoke-RestMethod -Uri "$RawUrl/VERSION" -ErrorAction Stop).Trim()
} catch {
  $ScriptVersion = "unknown"
}

# ─── File Arrays ──────────────────────────────────────────────────────────────

$AgentFiles = @(
    @{ Name = "vibuzo.md";        Desc = "main agent" }
    @{ Name = "deepveloper.md";   Desc = "execution specialist" }
    @{ Name = "deepsearcher.md";  Desc = "research specialist" }
)

$CommandFiles = @(
    "spec", "commit", "add-context", "context-init", "context-find",
    "context-harvest", "context-append", "research", "session",
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

    # Fixed box width matching the VIBUZO banner: 59 total, 55 content
    $contentWidth = 55
    $totalWidth = 59

    # Top border with title
    $titleSection = " $Title "
    $dashSpace = $totalWidth - 2 - $titleSection.Length
    $leftDashes = [Math]::Floor($dashSpace / 2)
    $rightDashes = $dashSpace - $leftDashes
    $top = "╔" + "═" * $leftDashes + $titleSection + "═" * $rightDashes + "╗"
    Write-Host $top -ForegroundColor $Color

    # Content lines
    foreach ($line in $Lines) {
        # Account for emoji double-width (U+2700-U+27BF renders as 2 columns, counts as 1 char)
        $emojiExtra = 0
        foreach ($c in $line.ToCharArray()) {
            $code = [int]$c
            if ($code -ge 0x2700 -and $code -le 0x27BF) { $emojiExtra++ }
        }
        Write-Host ("║ " + $line.PadRight($contentWidth - $emojiExtra) + " ║") -ForegroundColor $Color
    }

    # Bottom border: exact width
    Write-Host ("╚" + "═" * ($totalWidth - 2) + "╝") -ForegroundColor $Color
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
║   ██╗   ██╗██╗██████╗ ██╗   ██╗███████╗ ██████╗           ║
║   ██║   ██║██║██╔══██╗██║   ██║╚══███╔╝██╔═══██╗          ║
║   ██║   ██║██║██████╔╝██║   ██║  ███╔╝ ██║   ██║          ║
║   ╚██╗ ██╔╝██║██╔══██╗██║   ██║ ███╔╝  ██║   ██║          ║
║    ╚████╔╝ ██║██████╔╝╚██████╔╝███████╗╚██████╔╝          ║
║     ╚═══╝  ╚═╝╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝           ║
║                                                           ║
║          Agentic Framework for Ai coding                  ║
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
  # Format: 0.x.x | yyyy-MM-dd HH:mm mode
  $VersionAndRest = $CurrentVersion -split ' \| '
  $Version = $VersionAndRest[0]
  $OldParts = $VersionAndRest[1] -split ' '
  $InstalledDate = $OldParts[0]
  $InstalledTime = $OldParts[1]
  $InstalledMode = $OldParts[2]

  # Format date for display: "Jun 07 at 00:42"
  $InstalledFull = Get-Date "$InstalledDate $InstalledTime" -Format "MMM dd 'at' HH:mm"

  # Compare versions
  $UpToDate = $false
  if ($Version -eq $ScriptVersion) {
    $Status = "Up to date"
    $UpToDate = $true
  } elseif ($ScriptVersion -ne "unknown") {
    $Status = "Update available!"
  } else {
    $Status = "Could not check"
  }
  
  # Build and display the update check box
  $BoxLines = @()
  $BoxLines += "Current:  $Version"
  $BoxLines += "Latest:   $ScriptVersion"
  $BoxLines += "Status:   $Status"
  $BoxLines += ""
  $BoxLines += "Last Update: $InstalledFull"
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
  Write-Box "Updating" @("⬆️  Updating Vibuzo $ScriptVersion ($InstallTarget)...")
} else {
  Write-Host ""
  Write-Box "Installing" @("🔧 Installing Vibuzo $ScriptVersion ($InstallTarget)...")
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

  # Prompt only on fresh install — update auto-proceeds
  if (-not $Update) {
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
"$ScriptVersion | $Now $Mode" | Out-File -FilePath $VersionFile -Encoding ASCII

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

$BoxLines = @(
    "Location:  $InstallTarget"
    ""
    "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    ""
    "→ Restart opencode and select Vibuzo"
    "  from the agent dropdown."
    ""
    "→ First time? Run /context init"
    "  to set up project memory."
    ""
    "→ Start building with:"
    "  /spec [feature description]"
    ""
    "💡 Learn more:"
    "   github.com/AB-techsolutionists/vibuzo"
)

Write-Host ""
Write-Box "✅ Vibuzo $ScriptVersion ${Action} successfully!" $BoxLines
Write-Host ""
