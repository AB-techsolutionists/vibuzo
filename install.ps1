<#
.SYNOPSIS
    Vibuzo Agentic Framework Installer (Windows)
.DESCRIPTION
    Installs Vibuzo agents (Orchestrator + Vibuzo) to .opencode/ or ~/.config/opencode/
.PARAMETER Global
    Install to ~/.config/opencode/ (available in ALL projects)
.PARAMETER Help
    Show this help message
.EXAMPLE
    pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }"
.EXAMPLE
    pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }" -Global
#>

param(
  [switch]$Global,
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

# ─── Help ────────────────────────────────────────────────────────────────────

if ($Help) {
  Write-Host @"
install.ps1 — Vibuzo Agentic Framework Installer

Usage:
  pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }"
  pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) } -Global"

Options:
  -Global     Install to ~/.config/opencode/ (available in ALL projects)
  -Help       Show this help message
"@
  exit 0
}

# ─── Install ─────────────────────────────────────────────────────────────────

Write-Host "🔧 Installing Vibuzo ($InstallTarget)..."
New-Item -ItemType Directory -Path $AgentsDir -Force | Out-Null
New-Item -ItemType Directory -Path $CommandsDir -Force | Out-Null

Write-Host "   → orchestrator.md"
Invoke-WebRequest -Uri "$RawUrl/agents/orchestrator.md" -OutFile "$AgentsDir\orchestrator.md"

Write-Host "   → vibuzo.md"
Invoke-WebRequest -Uri "$RawUrl/agents/vibuzo.md" -OutFile "$AgentsDir\vibuzo.md"

# Download command files
Write-Host "   → commands/"
Invoke-WebRequest -Uri "$RawUrl/commands/spec.md" -OutFile "$CommandsDir\spec.md"
Invoke-WebRequest -Uri "$RawUrl/commands/plan.md" -OutFile "$CommandsDir\plan.md"
Invoke-WebRequest -Uri "$RawUrl/commands/tasks.md" -OutFile "$CommandsDir\tasks.md"
Invoke-WebRequest -Uri "$RawUrl/commands/implement.md" -OutFile "$CommandsDir\implement.md"
Invoke-WebRequest -Uri "$RawUrl/commands/review.md" -OutFile "$CommandsDir\review.md"

# Download AGENTS.md to project root (if local) or to opencode dir (if global)
if (-not $Global) {
  Write-Host "   → AGENTS.md (project root)"
  Invoke-WebRequest -Uri "$RawUrl/AGENTS.md" -OutFile "AGENTS.md"
} else {
  Write-Host "   → AGENTS.md (opencode dir)"
  Invoke-WebRequest -Uri "$RawUrl/AGENTS.md" -OutFile "$OpenCodeDir\AGENTS.md"
}

# ─── Path Rewriting (global install only) ────────────────────────────────────

if ($Global) {
  Write-Host "   → Rewriting paths for global install"
  (Get-Content "$AgentsDir\orchestrator.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\orchestrator.md"
  (Get-Content "$AgentsDir\vibuzo.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\vibuzo.md"
  (Get-Content "$OpenCodeDir\AGENTS.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$OpenCodeDir\AGENTS.md"
}

# ─── Tool Detection ──────────────────────────────────────────────────────────

# Claude Code
if (Get-Command "claude" -ErrorAction SilentlyContinue) {
  Write-Host "   📋 Detected Claude Code — creating .claude/agents/"
  New-Item -ItemType Directory -Path ".claude\agents" -Force | Out-Null
  Copy-Item "$AgentsDir\orchestrator.md" ".claude\agents\orchestrator.md"
  Copy-Item "$AgentsDir\vibuzo.md" ".claude\agents\vibuzo.md"
  Write-Host "   ✓ .claude/agents/ created"
}

# ─── Done ────────────────────────────────────────────────────────────────────

$Sep = "────────────────────────────────────────────"
Write-Host ""
Write-Host "  ╭$Sep╮"
Write-Host "  │"
Write-Host "  │  ✅ Vibuzo installed successfully!"
Write-Host "  │"
Write-Host "  │  Location: $InstallTarget"
Write-Host "  │  Agents:   $AgentsDir"
Write-Host "  │"
if (-not $Global) {
  Write-Host "  │  AGENTS.md is in your project root."
  Write-Host "  │  Commit it to share with your team."
} else {
  Write-Host "  │  Vibuzo is now available in ALL your projects."
  Write-Host "  │  Run install without -Global per project for AGENTS.md."
}
Write-Host "  │"
Write-Host "  │  Next: opencode will pick up Orchestrator"
Write-Host "  │  as your primary agent."
Write-Host "  │"
Write-Host "  ╰$Sep╯"
Write-Host ""
