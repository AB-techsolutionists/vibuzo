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
  [switch]$Help,
  [switch]$NoColor,
  [switch]$Yes
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

# ─── Color Support ────────────────────────────────────────────────────

$Script:UseColor = -not ($NoColor -or [bool]$env:NO_COLOR)

# ─── File Arrays ──────────────────────────────────────────────────────────────

$AgentFiles = @(
    @{ Name = "vibuzo.md";        Desc = "main agent" }
    @{ Name = "deepveloper.md";   Desc = "execution specialist" }
    @{ Name = "deepsearcher.md";  Desc = "research specialist" }
    @{ Name = "deepviewer.md";    Desc = "codebase analysis & review" }
)

$CommandFiles = @(
    "spec", "add-context", "context-init", "research", "session", "session-init", "deepviewer"
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
    if ($Script:UseColor) { Write-Host $header -ForegroundColor $Cyan } else { Write-Host $header }

    # Grouped items with wrapping at 4 items
    $line = "  ✓ "
    for ($i = 0; $i -lt $Items.Count; $i++) {
        if ($i -gt 0 -and $i % 4 -eq 0) {
            if ($Script:UseColor) { Write-Host $line.TrimEnd(', ') -ForegroundColor $Green } else { Write-Host $line.TrimEnd(', ') }
            $line = "    "
        }
        $line += "$($Items[$i]), "
    }
    if ($line -ne "  ✓ ") {
        if ($Script:UseColor) { Write-Host $line.TrimEnd(', ') -ForegroundColor $Green } else { Write-Host $line.TrimEnd(', ') }
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
    if ($Script:UseColor) { Write-Host $top -ForegroundColor $Color } else { Write-Host $top }

    # Content lines
    foreach ($line in $Lines) {
        # Check for divider line (3+ ═ characters)
        $trimmed = $line.Trim()
        if ($trimmed -match '^═{3,}$') {
            $dividerContent = "═" * $contentWidth
            if ($Script:UseColor) { Write-Host ("║ " + $dividerContent + " ║") -ForegroundColor $Color } else { Write-Host ("║ " + $dividerContent + " ║") }
            continue
        }
        # Account for emoji double-width (U+2700-U+27BF renders as 2 columns, counts as 1 char)
        $emojiExtra = 0
        foreach ($c in $line.ToCharArray()) {
            $code = [int]$c
            if ($code -ge 0x2700 -and $code -le 0x27BF) { $emojiExtra++ }
        }
        if ($Script:UseColor) { Write-Host ("║ " + $line.PadRight($contentWidth - $emojiExtra) + " ║") -ForegroundColor $Color } else { Write-Host ("║ " + $line.PadRight($contentWidth - $emojiExtra) + " ║") }
    }

    # Bottom border: exact width
    if ($Script:UseColor) { Write-Host ("╚" + "═" * ($totalWidth - 2) + "╝") -ForegroundColor $Color } else { Write-Host ("╚" + "═" * ($totalWidth - 2) + "╝") }
}

# ─── Spinner & Step Renderer ─────────────────────────────────────────────────

$Script:SpinnerFrames = @('⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏')
$Script:SpinnerIndex = 0

function Write-Spinner {
    param([string]$Message, [int]$Step, [switch]$Completed)
    $frame = if ($Completed) { '✓' } else { $Script:SpinnerFrames[$Script:SpinnerIndex % $Script:SpinnerFrames.Length] }
    $Script:SpinnerIndex++
    $prefix = "Step $Step/8"
    if ($Completed) {
        if ($Script:UseColor) { Write-Host "`r  $prefix $frame $Message" -ForegroundColor Green } else { Write-Host "  $prefix [OK] $Message" }
        Write-Host ""
    } else {
        if ($Script:UseColor) { Write-Host "`r  $prefix $frame $Message" -ForegroundColor Cyan -NoNewline } else { Write-Host "  $prefix . $Message" }
    }
}

function Write-Step {
    param([string]$Title, [int]$Step, [int]$Total, [switch]$Completed)
    $mark = if ($Completed) { '✓' } else { '→' }
    if ($Completed) {
        if ($Script:UseColor) { Write-Host "  Step $Step/${Total}: $Title" -ForegroundColor Green } else { Write-Host "  [$mark] Step $Step/${Total}: $Title" }
    } else {
        if ($Script:UseColor) { Write-Host "  Step $Step/${Total}: $Title" -ForegroundColor Cyan } else { Write-Host "  [$mark] Step $Step/${Total}: $Title" }
    }
}

# ─── Prompt Helper ──────────────────────────────────────────────────────────

function Confirm-Action {
    param([string]$Prompt, [string]$Default = 'n')
    if ($Script:Yes) { return $true }
    $interactive = [Environment]::UserInteractive -and -not [Console]::IsInputRedirected
    if (-not $interactive) { return ($Default -eq 'y') }
    $suffix = if ($Default -eq 'y') { '(Y/n)' } else { '(y/N)' }
    $response = Read-Host "$Prompt $suffix"
    if ($response -in @('y', 'Y', 'yes', 'YES')) { return $true }
    if ($response -in @('n', 'N', 'no', 'NO')) { return $false }
    return ($Default -eq 'y')
}

# ─── Environment Detection ───────────────────────────────────────────────────

function Detect-Environment {
    param([switch]$ShowOutput)
    $result = @{}
    Write-Step "Detecting Environment" -Step 1 -Total 8

    Write-Spinner "Checking operating system..." -Step 1
    if ($env:OS -match 'Windows') { $result.OS = "Windows" }
    elseif ($IsMacOS) { $result.OS = "macOS" }
    elseif ($IsLinux) { $result.OS = "Linux" }
    else { $result.OS = "Unknown" }

    Write-Spinner "Checking architecture..." -Step 1
    $arch = $env:PROCESSOR_ARCHITECTURE
    if ($arch -eq 'AMD64') { $result.Arch = 'x64' }
    elseif ($arch -eq 'ARM64') { $result.Arch = 'ARM64' }
    else { $result.Arch = $arch }

    Write-Spinner "Checking available tools..." -Step 1
    $result.Tools = @{}
    foreach ($tool in @('curl', 'wget', 'git', 'pwsh')) {
        $result.Tools[$tool] = [bool](Get-Command $tool -ErrorAction SilentlyContinue)
    }

    Write-Spinner "Checking PowerShell version..." -Step 1
    $result.PSVersion = "$($PSVersionTable.PSVersion.Major).$($PSVersionTable.PSVersion.Minor)"

    Write-Spinner "Checking execution policy..." -Step 1
    $result.ExecPolicy = Get-ExecutionPolicy -Scope CurrentUser -ErrorAction SilentlyContinue

    $result.TerminalWidth = [Console]::BufferWidth
    $result.IsTTY = [Environment]::UserInteractive -and -not [Console]::IsInputRedirected

    Write-Spinner "Environment detection complete" -Step 1 -Completed

    if ($ShowOutput) {
        if ($Script:UseColor) { Write-Host "  ✓ OS: $($result.OS) ($($result.Arch))" -ForegroundColor Green } else { Write-Host "  ✓ OS: $($result.OS) ($($result.Arch))" }
        if ($Script:UseColor) { Write-Host "  ✓ Shell: PowerShell $($result.PSVersion)" -ForegroundColor Green } else { Write-Host "  ✓ Shell: PowerShell $($result.PSVersion)" }
        if ($Script:UseColor) { Write-Host "  ✓ Tools:" -ForegroundColor Green } else { Write-Host "  ✓ Tools:" }
        foreach ($t in $result.Tools.Keys) {
            $icon = if ($result.Tools[$t]) { '✓' } else { '✗' }
            if ($Script:UseColor) { Write-Host "    $icon $t" -ForegroundColor $(if ($result.Tools[$t]) { 'Green' } else { 'DarkGray' }) } else { Write-Host "    $icon $t" }
        }
        if ($Script:UseColor) { Write-Host "  ✓ Execution Policy: $($result.ExecPolicy)" -ForegroundColor Green } else { Write-Host "  ✓ Execution Policy: $($result.ExecPolicy)" }
        if ($Script:UseColor) { Write-Host "  ✓ Terminal: $($result.TerminalWidth) cols, $(if ($result.IsTTY) { 'TTY' } else { 'Piped' })" -ForegroundColor Green } else { Write-Host "  ✓ Terminal: $($result.TerminalWidth) cols, $(if ($result.IsTTY) { 'TTY' } else { 'Piped' })" }
    }
    return $result
}

# ─── Install State Detection ─────────────────────────────────────────────────

function Detect-InstallState {
    param([switch]$ShowOutput)
    $result = @{ State = 'absent'; Version = $null; Date = $null; Mode = $null }
    Write-Step "Checking Installation" -Step 2 -Total 8
    Write-Spinner "Checking for existing installation..." -Step 2

    if (Test-Path $VersionFile) {
        $content = Get-Content ".opencode/.vibuzo-version" -Raw
        $parts = $content -split ' \| '
        $installedVer = $parts[0].Trim()
        $result.Version = $installedVer
        $result.Mode = $parts[1].Trim() -split ' ' | Select-Object -Last 1
        $result.Date = ($parts[1].Trim() -split ' ')[0..1] -join ' '

        $agentCount = @(Get-ChildItem ".opencode/agent/core/*.md" -ErrorAction SilentlyContinue).Count
        $cmdCount = @(Get-ChildItem ".opencode/commands/*.md" -ErrorAction SilentlyContinue).Count

        if ($agentCount -eq 4 -and $cmdCount -eq 7) {
            if ($installedVer -eq $ScriptVersion) { $result.State = 'uptodate' }
            else { $result.State = 'outdated' }
        } else {
            $result.State = 'partial'
            $result.Found = @{ Agents = $agentCount; Commands = $cmdCount }
        }
    }

    Write-Spinner "Install state check complete" -Step 2 -Completed
    return $result
}

# ─── AI Tool Detection ───────────────────────────────────────────────────────

function Detect-AITools {
    param([switch]$ShowOutput)
    $result = @{}
    Write-Step "Detecting AI Tools" -Step 3 -Total 8

    $tools = @{
        'Claude Code' = @{ Command = 'claude'; Dir = '.claude' }
        'opencode'    = @{ Command = 'opencode'; Dir = '.opencode' }
        'Cline'       = @{ Command = $null; Dir = @('.cline', '.github/agents') }
        'Cursor'      = @{ Command = 'cursor'; Dir = '.cursor' }
        'Copilot CLI' = @{ Command = $null; Check = 'gh copilot --help 2>$null' }
        'Gemini CLI'  = @{ Command = 'gemini'; Dir = $null }
        'Windsurf'    = @{ Command = $null; Dir = '.windsurf' }
        'Codex CLI'   = @{ Command = 'codex'; Dir = $null }
    }

    Write-Spinner "Scanning for AI coding agents..." -Step 3
    foreach ($tool in $tools.Keys) {
        $found = $false
        $info = $tools[$tool]
        if ($info.Command -and (Get-Command $info.Command -ErrorAction SilentlyContinue)) { $found = $true }
        if ($info.Dir -is [array]) { foreach ($d in $info.Dir) { if (Test-Path $d) { $found = $true; break } } }
        elseif ($info.Dir -and (Test-Path $info.Dir)) { $found = $true }
        if ($info.Check) { $null = Invoke-Expression $info.Check 2>$null; if ($LASTEXITCODE -eq 0) { $found = $true } }
        $result[$tool] = $found
    }

    Write-Spinner "Tool detection complete" -Step 3 -Completed
    $sortedTools = $result.Keys | Sort-Object
    $detected = ($result.Values | Where-Object { $_ }).Count
    if ($Script:UseColor) { Write-Host "  ✓ Detected: $detected tool(s)" -ForegroundColor Green } else { Write-Host "  ✓ Detected: $detected tool(s)" }
    foreach ($t in $sortedTools) {
        $icon = if ($result[$t]) { '✓' } else { '✗' }
        if ($Script:UseColor) { Write-Host "    $icon $t" -ForegroundColor $(if ($result[$t]) { 'Green' } else { 'DarkGray' }) } else { Write-Host "    $icon $t" }
    }
    return $result
}

# ─── Integration Installer ───────────────────────────────────────────────────

function Install-Integrations {
    param([hashtable]$DetectedTools)
    Write-Step "Configuring Integrations" -Step 7 -Total 8
    $skippableTools = @('opencode', 'Codex CLI')
    $total = ($DetectedTools.Keys | Where-Object { $DetectedTools[$_] -and $_ -notin $skippableTools }).Count
    if ($total -eq 0) {
        if ($Script:UseColor) { Write-Host "  (no integrations to configure)" -ForegroundColor DarkGray } else { Write-Host "  (no integrations to configure)" }
        return
    }
    $idx = 0
    $integrationList = @()
    foreach ($tool in $DetectedTools.Keys) {
        if (-not $DetectedTools[$tool] -or $tool -in $skippableTools) { continue }
        $targetDir = switch ($tool) {
            'Claude Code' { ".claude/agents" }
            'Cline'       { if (Test-Path ".cline") { ".cline/agents" } else { ".github/agents" } }
            'Cursor'      { ".cursor/agents" }
            default       { $null }
        }
        if (-not $targetDir) { continue }
        $idx++
        Write-Host "  [$idx/$total] $tool... " -NoNewline
        New-Item -ItemType Directory -Path $targetDir -Force | Out-Null
        foreach ($agent in $AgentFiles) {
            Copy-Item "$AgentsDir/$($agent.Name)" "$targetDir/$($agent.Name)" -Force
        }
        if ($Script:UseColor) { Write-Host "✓" -ForegroundColor Green } else { Write-Host "✓" }
        $integrationList += $tool
    }
    Set-Variable -Name Script:IntegrationList -Value ($integrationList -join ', ') -Scope Script
}

# ─── Project Files Helper ────────────────────────────────────────────────────

function Save-ProjectFiles {
    # Check AGENTS.md status
    $ExistingContent = $null
    $UserRules = $null
    $AgentsStatus = "fresh copy"
    if (Test-Path "AGENTS.md") {
        $Lines = Get-Content "AGENTS.md"
        $MarkerIndex = $Lines.IndexOf("─── PASTE YOUR CUSTOM RULES BELOW THIS LINE ───")
        if ($MarkerIndex -ge 0) {
            if ($MarkerIndex -lt $Lines.Length - 1) {
                $SavedContent = $Lines[($MarkerIndex + 1)..($Lines.Length - 1)] -join "`n"
                if ($SavedContent.Trim() -ne "") {
                    $UserRules = $SavedContent
                    $AgentsStatus = "with custom rules preserved"
                }
            }
        } else {
            $ExistingContent = $Lines -join "`n"
            $AgentsStatus = "your content preserved at top"
        }
    }

    if ($Script:UseColor) { Write-Host "  ✓ AGENTS.md ($AgentsStatus)" -ForegroundColor $Green } else { Write-Host "  ✓ AGENTS.md ($AgentsStatus)" }

    if (-not (Confirm-Action "Proceed with AGENTS.md?")) {
        if ($Script:UseColor) { Write-Host "AGENTS.md skipped." -ForegroundColor $Yellow } else { Write-Host "AGENTS.md skipped." }
        return
    }

    Invoke-WebRequest -Uri "$RawUrl/AGENTS.md" -OutFile "AGENTS.md"
    if ($ExistingContent) {
        $VibuzoContent = Get-Content "AGENTS.md" -Raw
        Set-Content -Path "AGENTS.md" -Value "$ExistingContent`n`n---`n`n$VibuzoContent"
    } elseif ($UserRules) {
        $FreshLines = Get-Content "AGENTS.md"
        $FreshMarker = $FreshLines.IndexOf("─── PASTE YOUR CUSTOM RULES BELOW THIS LINE ───")
        $HasExistingRules = $FreshMarker -ge 0 -and $FreshMarker -lt $FreshLines.Length - 1 -and
                            ($FreshLines[($FreshMarker + 1)..($FreshLines.Length - 1)] -join "`n").Trim() -ne ""
        if (-not $HasExistingRules) {
            Add-Content -Path "AGENTS.md" -Value "`n$UserRules"
        }
    }
}

function Write-PathRewrite {
    if ($Script:UseColor) { Write-Host "   ✓ Path rewriting" -ForegroundColor $Green } else { Write-Host "   ✓ Path rewriting" }
    (Get-Content "$AgentsDir\vibuzo.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\vibuzo.md"
    (Get-Content "$AgentsDir\deepveloper.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\deepveloper.md"
    (Get-Content "$AgentsDir\deepsearcher.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\deepsearcher.md"
    (Get-Content "$AgentsDir\deepviewer.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\deepviewer.md"
    (Get-Content "$OpenCodeDir\AGENTS.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$OpenCodeDir\AGENTS.md"
}

function Write-VersionFile {
    $Now = Get-Date -Format "yyyy-MM-dd HH:mm"
    $Mode = if ($Global) { "global" } else { "local" }
    "$ScriptVersion | $Now $Mode" | Out-File -FilePath $VersionFile -Encoding ASCII
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
  -NoColor    Suppress ANSI color output
  -Yes        Auto-confirm all prompts
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
if ($Script:UseColor) { Write-Host $Banner -ForegroundColor $Cyan } else { Write-Host $Banner }

# ─── Prepare Directories ───────────────────────────────────────────────────

New-Item -ItemType Directory -Path $AgentsDir -Force | Out-Null
New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null

# ─── Wizard Flow ───────────────────────────────────────────────────────────

if ($Update) {
  # ─── Update Flow (Task 11) ──────────────────────────────────────────

  if (-not (Test-Path $VersionFile)) {
    Write-Host "❌ No existing Vibuzo installation found at $OpenCodeDir"
    Write-Host "   Run without -Update to install fresh."
    exit 1
  }

  # Step 1/4: Check Version
  Write-Step "Checking Version" -Step 1 -Total 4

  $CurrentVersion = Get-Content $VersionFile
  $VersionAndRest = $CurrentVersion -split ' \| '
  $Version = $VersionAndRest[0]
  $OldParts = $VersionAndRest[1] -split ' '
  $InstalledDate = $OldParts[0]
  $InstalledTime = $OldParts[1]
  $InstalledMode = $OldParts[2]
  $InstalledFull = Get-Date "$InstalledDate $InstalledTime" -Format "MMM dd 'at' HH:mm"

  $UpToDate = $false
  if ($Version -eq $ScriptVersion) {
    $Status = "Up to date"
    $UpToDate = $true
  } elseif ($ScriptVersion -ne "unknown") {
    $Status = "Update available!"
  } else {
    $Status = "Could not check"
  }

    $fileList = "Files: $($AgentFiles.Count) agents, $($CommandFiles.Count) commands, AGENTS.md"
    $BoxLines = @(
    "Current:  $Version"
    "Latest:   $ScriptVersion"
    "Status:   $Status"
    ""
    "Last Update: $InstalledFull"
    "Location:  $OpenCodeDir"
    ""
    "To be updated:"
    "  $fileList"
  )

  Write-Box -Title "Vibuzo Update Check" -Lines $BoxLines

  if ($UpToDate) {
    exit 0
  }

  if (-not (Confirm-Action "Proceed with update?")) {
    if ($Script:UseColor) { Write-Host "Update cancelled." -ForegroundColor $Yellow } else { Write-Host "Update cancelled." }
    exit 0
  }

  # Step 2/4: Download Agents
  Write-Step "Downloading Agents" -Step 2 -Total 4

  $agentNames = $AgentFiles | ForEach-Object { $_.Name }
  $totalAgents = $agentNames.Count
  for ($i = 0; $i -lt $totalAgents; $i++) {
    $name = $agentNames[$i]
    $num = $i + 1
    $url = "$RawUrl/agents/$name"
    $outPath = "$AgentsDir/$name"
    $tempPath = "$AgentsDir/$name.tmp"
    try {
      Write-Host "  [$num/$totalAgents] $name... " -NoNewline
      Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop
      Move-Item -Path $tempPath -Destination $outPath -Force
      if ($Script:UseColor) { Write-Host "✓" -ForegroundColor Green } else { Write-Host "✓" }
    } catch {
      if ($Script:UseColor) { Write-Host "✗" -ForegroundColor Red } else { Write-Host "✗" }
      if (Test-Path $tempPath) { Remove-Item $tempPath -Force }
      Write-Spinner "Retrying $name..." -Step 2
      Start-Sleep -Seconds 1
      try {
        Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop
        Move-Item -Path $tempPath -Destination $outPath -Force
        if ($Script:UseColor) { Write-Host "  [$num/$totalAgents] $name... ✓" -ForegroundColor Green } else { Write-Host "  [$num/$totalAgents] $name... ✓" }
      } catch {
        if ($Script:UseColor) { Write-Host "  [$num/$totalAgents] $name... ✗ FAILED" -ForegroundColor Red } else { Write-Host "  [$num/$totalAgents] $name... ✗ FAILED" }
      }
    }
  }

  # AGENTS.md handling
  if (-not $Global) {
    Save-ProjectFiles
  } else {
    if ($Script:UseColor) { Write-Host "  ✓ AGENTS.md (fresh copy)" -ForegroundColor $Green } else { Write-Host "  ✓ AGENTS.md (fresh copy)" }
    Invoke-WebRequest -Uri "$RawUrl/AGENTS.md" -OutFile "$OpenCodeDir\AGENTS.md"
  }
  if ($Global) {
    Write-PathRewrite
  }
  Write-VersionFile

  # Step 3/4: Download Commands
  Write-Step "Downloading Commands" -Step 3 -Total 4

  $totalCmds = $CommandFiles.Count
  for ($i = 0; $i -lt $totalCmds; $i++) {
    $name = $CommandFiles[$i]
    $num = $i + 1
    $url = "$RawUrl/commands/$name.md"
    $outPath = "$CommandsDir/$name.md"
    $tempPath = "$CommandsDir/$name.md.tmp"
    try {
      Write-Host "  [$num/$totalCmds] $name.md... " -NoNewline
      Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop
      Move-Item -Path $tempPath -Destination $outPath -Force
      if ($Script:UseColor) { Write-Host "✓" -ForegroundColor Green } else { Write-Host "✓" }
    } catch {
      if ($Script:UseColor) { Write-Host "✗" -ForegroundColor Red } else { Write-Host "✗" }
      if (Test-Path $tempPath) { Remove-Item $tempPath -Force }
      Write-Spinner "Retrying $name.md..." -Step 3
      Start-Sleep -Seconds 1
      try {
        Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop
        Move-Item -Path $tempPath -Destination $outPath -Force
        if ($Script:UseColor) { Write-Host "  [$num/$totalCmds] $name.md... ✓" -ForegroundColor Green } else { Write-Host "  [$num/$totalCmds] $name.md... ✓" }
      } catch {
        if ($Script:UseColor) { Write-Host "  [$num/$totalCmds] $name.md... ✗ FAILED" -ForegroundColor Red } else { Write-Host "  [$num/$totalCmds] $name.md... ✗ FAILED" }
      }
    }
  }

  # Step 4/4: Configure Integrations
  Write-Step "Configuring Integrations" -Step 4 -Total 4
  $toolsResult = Detect-AITools
  Install-Integrations -DetectedTools $toolsResult

  # Post-update summary
  $summaryLines = @(
    "Location:  $InstallTarget"
    "Version:   $ScriptVersion"
    "Agents:    $($AgentFiles.Count) installed ✓"
    "Commands:  $($CommandFiles.Count) installed ✓"
    "Integrations: $Script:IntegrationList"
    ""
    "═══════════════════════════════════════════════════════"
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
  Write-Box "✅ Vibuzo $ScriptVersion updated successfully!" $summaryLines
  Write-Host ""
  exit 0
}

# ─── Install Wizard Flow ────────────────────────────────────────────────────

# Step 1: Detect Environment
$envResult = Detect-Environment

# Step 2: Detect Install State
$stateResult = Detect-InstallState
if ($stateResult.State -eq 'uptodate') {
  if ($Script:UseColor) { Write-Host "  ✓ Vibuzo is already up to date ($($stateResult.Version))" -ForegroundColor Green } else { Write-Host "  ✓ Vibuzo is already up to date ($($stateResult.Version))" }
  Write-Host "  Run with -Update to force reinstall."
  exit 0
}

# Step 3: Detect AI Tools
$toolsResult = Detect-AITools

# Configure integrations prompt
if (-not (Confirm-Action "Configure AI tool integrations?" -Default 'y')) {
    $toolsResult = @{}  # skip integrations
}

# Step 4: Installation Preview
Write-Step "Installation Preview" -Step 4 -Total 8
$detectedCount = ($toolsResult.Values | Where-Object { $_ }).Count
if ($Script:UseColor) { Write-Host "  Target: $InstallTarget" -ForegroundColor Cyan } else { Write-Host "  Target: $InstallTarget" }
if ($Script:UseColor) { Write-Host "  Version: $ScriptVersion" -ForegroundColor Cyan } else { Write-Host "  Version: $ScriptVersion" }
if ($Script:UseColor) { Write-Host "  AI Tools detected: $detectedCount" -ForegroundColor Cyan } else { Write-Host "  AI Tools detected: $detectedCount" }

if (-not (Confirm-Action "Proceed with installation?" -Default 'y')) {
  Write-Host "Installation cancelled."
  exit 0
}

# Step 5: Download Agents
Write-Step "Downloading Agents" -Step 5 -Total 8
$agentNames = $AgentFiles | ForEach-Object { $_.Name }
$totalAgents = $agentNames.Count
for ($i = 0; $i -lt $totalAgents; $i++) {
  $name = $agentNames[$i]
  $num = $i + 1
  $url = "$RawUrl/agents/$name"
  $outPath = "$AgentsDir/$name"
  $tempPath = "$AgentsDir/$name.tmp"
  try {
    Write-Host "  [$num/$totalAgents] $name... " -NoNewline
    Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop
    Move-Item -Path $tempPath -Destination $outPath -Force
    if ($Script:UseColor) { Write-Host "✓" -ForegroundColor Green } else { Write-Host "✓" }
  } catch {
    if ($Script:UseColor) { Write-Host "✗" -ForegroundColor Red } else { Write-Host "✗" }
    if (Test-Path $tempPath) { Remove-Item $tempPath -Force }
    Write-Spinner "Retrying $name..." -Step 5
    Start-Sleep -Seconds 1
    try {
      Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop
      Move-Item -Path $tempPath -Destination $outPath -Force
      if ($Script:UseColor) { Write-Host "  [$num/$totalAgents] $name... ✓" -ForegroundColor Green } else { Write-Host "  [$num/$totalAgents] $name... ✓" }
    } catch {
      if ($Script:UseColor) { Write-Host "  [$num/$totalAgents] $name... ✗ FAILED" -ForegroundColor Red } else { Write-Host "  [$num/$totalAgents] $name... ✗ FAILED" }
    }
  }
}

# AGENTS.md handling + version file
if (-not $Global) {
  Save-ProjectFiles
} else {
  if ($Script:UseColor) { Write-Host "  ✓ AGENTS.md (fresh copy)" -ForegroundColor $Green } else { Write-Host "  ✓ AGENTS.md (fresh copy)" }
  Invoke-WebRequest -Uri "$RawUrl/AGENTS.md" -OutFile "$OpenCodeDir\AGENTS.md"
}
if ($Global) {
  Write-PathRewrite
}
Write-VersionFile

# Step 6: Download Commands
Write-Step "Downloading Commands" -Step 6 -Total 8
$totalCmds = $CommandFiles.Count
for ($i = 0; $i -lt $totalCmds; $i++) {
  $name = $CommandFiles[$i]
  $num = $i + 1
  $url = "$RawUrl/commands/$name.md"
  $outPath = "$CommandsDir/$name.md"
  $tempPath = "$CommandsDir/$name.md.tmp"
  try {
    Write-Host "  [$num/$totalCmds] $name.md... " -NoNewline
    Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop
    Move-Item -Path $tempPath -Destination $outPath -Force
    if ($Script:UseColor) { Write-Host "✓" -ForegroundColor Green } else { Write-Host "✓" }
  } catch {
    if ($Script:UseColor) { Write-Host "✗" -ForegroundColor Red } else { Write-Host "✗" }
    if (Test-Path $tempPath) { Remove-Item $tempPath -Force }
    Write-Spinner "Retrying $name.md..." -Step 6
    Start-Sleep -Seconds 1
    try {
      Invoke-WebRequest -Uri $url -OutFile $tempPath -ErrorAction Stop
      Move-Item -Path $tempPath -Destination $outPath -Force
      if ($Script:UseColor) { Write-Host "  [$num/$totalCmds] $name.md... ✓" -ForegroundColor Green } else { Write-Host "  [$num/$totalCmds] $name.md... ✓" }
    } catch {
      if ($Script:UseColor) { Write-Host "  [$num/$totalCmds] $name.md... ✗ FAILED" -ForegroundColor Red } else { Write-Host "  [$num/$totalCmds] $name.md... ✗ FAILED" }
    }
  }
}

# Step 7: Configure Integrations
Install-Integrations -DetectedTools $toolsResult

# Step 8: Post-Install Summary
$summaryLines = @(
  "Location:  $InstallTarget"
  "Version:   $ScriptVersion"
  "Agents:    $($AgentFiles.Count) installed ✓"
  "Commands:  $($CommandFiles.Count) installed ✓"
  "Integrations: $Script:IntegrationList"
  ""
  "═══════════════════════════════════════════════════════"
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
Write-Box "✅ Vibuzo $ScriptVersion installed successfully!" $summaryLines
Write-Host ""
