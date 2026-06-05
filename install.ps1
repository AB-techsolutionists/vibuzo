<#
.SYNOPSIS
    Vibuzo Agentic Framework Installer (Windows)
.DESCRIPTION
    Installs Vibuzo (main), Deepveloper (subtask), /spec pipeline, and active commands to .opencode/ or ~/.config/opencode/
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

Write-Host "   → vibuzo.md (main agent)"
Invoke-WebRequest -Uri "$RawUrl/agents/vibuzo.md" -OutFile "$AgentsDir\vibuzo.md"

Write-Host "   → deepveloper.md (execution specialist)"
Invoke-WebRequest -Uri "$RawUrl/agents/deepveloper.md" -OutFile "$AgentsDir\deepveloper.md"

# Download command files
Write-Host "   → spec.md (feature pipeline)"
Invoke-WebRequest -Uri "$RawUrl/commands/spec.md" -OutFile "$CommandsDir\spec.md"
Write-Host "   → add-context.md"
Invoke-WebRequest -Uri "$RawUrl/commands/add-context.md" -OutFile "$CommandsDir\add-context.md"
Write-Host "   → context-init.md (scaffold context)"
Invoke-WebRequest -Uri "$RawUrl/commands/context-init.md" -OutFile "$CommandsDir\context-init.md"
Write-Host "   → context-find.md (search context)"
Invoke-WebRequest -Uri "$RawUrl/commands/context-find.md" -OutFile "$CommandsDir\context-find.md"
Write-Host "   → context-harvest.md (promote sessions)"
Invoke-WebRequest -Uri "$RawUrl/commands/context-harvest.md" -OutFile "$CommandsDir\context-harvest.md"
Write-Host "   → context-append.md (scan conversation)"
Invoke-WebRequest -Uri "$RawUrl/commands/context-append.md" -OutFile "$CommandsDir\context-append.md"
Write-Host "   → session-compaction.md (scaffold session)"
Invoke-WebRequest -Uri "$RawUrl/commands/session-compaction.md" -OutFile "$CommandsDir\session-compaction.md"
Write-Host "   → session-view.md (browse sessions)"
Invoke-WebRequest -Uri "$RawUrl/commands/session-view.md" -OutFile "$CommandsDir\session-view.md"
Write-Host "   → session-timeline.md (session timeline)"
Invoke-WebRequest -Uri "$RawUrl/commands/session-timeline.md" -OutFile "$CommandsDir\session-timeline.md"

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
  (Get-Content "$AgentsDir\vibuzo.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\vibuzo.md"
  (Get-Content "$AgentsDir\deepveloper.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$AgentsDir\deepveloper.md"
  (Get-Content "$OpenCodeDir\AGENTS.md") -replace '\.opencode/', "$OpenCodeDir/" | Set-Content "$OpenCodeDir\AGENTS.md"
}

# ─── Tool Detection ──────────────────────────────────────────────────────────

# Claude Code
if (Get-Command "claude" -ErrorAction SilentlyContinue) {
  Write-Host "   📋 Detected Claude Code — creating .claude/agents/"
  New-Item -ItemType Directory -Path ".claude\agents" -Force | Out-Null
  Copy-Item "$AgentsDir\vibuzo.md" ".claude\agents\vibuzo.md"
  Copy-Item "$AgentsDir\deepveloper.md" ".claude\agents\deepveloper.md"
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
Write-Host "  │  Next: opencode will pick up Vibuzo"
Write-Host "  │  as your primary agent. Use /spec to start a feature pipeline."
Write-Host "  │"
Write-Host "  ╰$Sep╯"
Write-Host ""
