# Research: CLI Installer Enhancement

**Date:** 2026-06-09
**Status:** Complete

## Summary

Research covers CLI installer design best practices, update mechanisms, dual-implementation maintenance, and cross-platform edge cases for Vibuzo's PowerShell (install.ps1, 377 lines) and Bash (install.sh, 387 lines) installers. Both scripts currently install agent definitions and command files from GitHub to `.opencode/` with good visual polish (box renderers, section groups, banners) but lack progress indicators, checksum verification, rollback on failure, CI-mode flags, and broader tool detection.

## Key Findings

1. **CLI Installer Design Principles (clig.dev, BetterCLI.org)**
   - Installers must be defensive: check assumptions, provide helpful error messages, support versioned installs (`curl -fsSL` with `-L` for redirects).
   - Never pipe to shell without HTTPS + TLS. Use `set -euo pipefail` (Bash) and `$ErrorActionPreference="Stop"` (PowerShell) — both scripts already do this.
   - Provide alternative install methods (package managers, direct download) for CI environments that block curl-pipe-bash.
   - Key resources: [clig.dev](https://clig.dev/), [BetterCLI.org](https://bettercli.org/design/distribution/self-executing-installer/)

2. **Progress Indicators & Visual UX (Evil Martians, CLI UX research)**
   - Three patterns: Spinner (indeterminate tasks, <5s), X-of-Y (step-countable tasks), Progress bar (parallel/long tasks).
   - Spinners should tick per-completion, not timer-based, so stalls are visible.
   - Use ANSI colors + Unicode symbols (✔ / ✖) for status. Support `NO_COLOR=1` and `--no-color` for non-TTY.
   - Clear progress artifacts on completion. Switch gerund → past tense ("Installing" → "Installed").
   - Current scripts already have box renderers and section groupings but no live spinners or progress bars.
   - Resource: [Evil Martians — 3 patterns for progress displays](https://evilmartians.com/chronicles/cli-ux-best-practices-3-patterns-for-improving-progress-displays)

3. **Self-Update Mechanisms (nerveband/cli-best-practices, BetterCLI)**
   - Background version check on every run (async, non-blocking), cached result, display notice on stderr.
   - Dedicated `--update` flag: download latest release, validate checksum, replace binary atomically.
   - For installer scripts that download config files (not binaries): version comparison + prompt + atomic overwrite is sufficient.
   - Current scripts have a working `--update` flag with version comparison but lack: dirty-tree check, atomic write (write to temp then rename), rollback on failure, checksum verification.
   - Resource: [nerveband/cli-best-practices self-update.md](https://github.com/nerveband/cli-best-practices/blob/main/patterns/self-update.md)

4. **Dual-Implementation Maintenance (PS1 + SH)**
   - **Single-file approach**: Use a polyglot script trick (`#` comment in Bash, `<# ... #>` comment in PowerShell) to share common logic. Realistically limited to small scripts.
   - **Code generation**: Maintain a YAML/JSON manifest of all files to install, generate both installers from Jinja/Mustache templates. Keeps logic in sync but adds build step.
   - **Sync checklist**: File arrays, arg parsing, error messages, version file format, path logic must be kept in lockstep. Currently both scripts have near-identical file arrays and logic — manual sync is the key risk.
   - **Shared VERSION file** and `.vibuzo-version` format (`0.x.x | yyyy-MM-dd HH:mm mode`) already work well.
   - Resource: [chrisfcarroll/PowerShell-Bash-Dual-Script-Templates](https://github.com/chrisfcarroll/PowerShell-Bash-Dual-Script-Templates)

5. **Tool Detection & Integration**
   - Current scripts detect only Claude Code (`claude` command) and copy agent files to `.claude/agents/`.
   - Industry patterns (from spec-kit, claude-plugins.dev, Vercel MCP):
     - Detect multiple agents: Claude Code, Cline, opencode, Codex, Cursor, GitHub Copilot, Gemini CLI, Windsurf.
     - Each has a specific config directory: `.claude/`, `.opencode/commands/`, `.github/agents/`, `.windsurf/workflows/`, `.codex/`, etc.
     - `add-mcp` pattern from Vercel: auto-detect installed clients and configure all at once.
   - Should offer optional integration prompts post-install: "Detected Claude Code. Install Vibuzo agents? (Y/n)"
   - Resource: [spec-kit agent directory structures](https://deepwiki.com/github/spec-kit/6.2-cross-platform-script-architecture), [Vercel add-mcp](https://mcp.vercel.com/docs/environment-variables)

6. **Cross-Platform Edge Cases**
   - **Path handling**: Windows uses `\`, Unix uses `/`. Both scripts handle correctly via platform-specific code.
   - **Permission handling**: Linux/macOS need `sudo` for system-wide install (`/usr/local/bin`). PowerShell uses `$env:USERPROFILE\AppData\Local`. Current scripts install to `.opencode/` (local) or `~/.config/opencode/` (global).
   - **Non-interactive/CI mode**: Both scripts have partial support (`[ -t 0 ]` in Bash, `[Console]::IsInputRedirected` in PS) but lack a formal `--yes` / `-y` / `--ci` flag. CI environments need `--yes` to auto-confirm without prompts.
   - **PowerShell execution policy**: `Set-ExecutionPolicy Unrestricted -Scope Process` needed before `iex`. Should document or auto-handle.
   - **curl vs wget**: Bash script should fall back to `wget` if `curl` not available.
   - **Windows ARM64**: No detection in PowerShell script (only checks x64).
   - **Temp directory**: Bash uses `mktemp -d` for downloads; PowerShell should use `[System.IO.Path]::GetTempPath()`.
   - Resource: [Microsoft cross-platform scripting](https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/cross-platform-scripting)

## Current Installer Assessment

| Aspect | Status | Notes |
|--------|--------|-------|
| Visual polish (banner, boxes, sections) | Good | Both scripts have ASCII banner, box renderer, section grouping |
| Color usage | Good | Cyan headers, green success, yellow warnings, red errors |
| Progress indicators | Missing | No spinners or X-of-Y during downloads |
| Checksum verification | Missing | No SHA256 validation of downloaded files |
| Rollback on failure | Missing | No temp-then-move pattern; partial downloads leave partial files |
| `--update` flag | Present | Working version comparison, could be more robust |
| CI/non-interactive mode | Partial | Detection works but no `--yes` flag |
| Tool detection | Limited | Only Claude Code; should detect 5+ more tools |
| Error handling | Good | `set -euo pipefail` / `$ErrorActionPreference="Stop"` |
| Cross-platform arch detection | Partial | PowerShell only checks x64, not ARM64 |
| `NO_COLOR` support | Missing | Should respect the env var |
| `--help` / `--version` | Present | Both flags work |

## Resources

| Title | URL | Description |
|-------|-----|-------------|
| Better CLI — Self-Executing Installers | https://bettercli.org/design/distribution/self-executing-installer/ | Guide on curl-pipe-bash security, versioning, lifecycle support |
| Better CLI — Auto-Updating CLI | https://bettercli.org/design/distribution/auto-updating-cli/ | Patterns for nudging upgrades vs full auto-update |
| clig.dev — CLI Guidelines | https://clig.dev/ | Comprehensive CLI design reference (stdout/stderr, exit codes, flags) |
| nerveband/cli-best-practices — Self-Update | https://github.com/nerveband/cli-best-practices/blob/main/patterns/self-update.md | Background version checks, update commands, version mismatch handling |
| Evil Martians — CLI UX Progress Patterns | https://evilmartians.com/chronicles/cli-ux-best-practices-3-patterns-for-improving-progress-displays | Spinner vs X-of-Y vs progress bar, with code examples |
| Dual Script Templates (PS1+Bash) | https://github.com/chrisfcarroll/PowerShell-Bash-Dual-Script-Templates | Approach for maintaining single file with both Bash and PowerShell |
| spec-kit — Agent Directory Structures | https://deepwiki.com/github/spec-kit/6.2-cross-platform-script-architecture | Maps 30+ AI agent config directories; reference for tool detection |
| Vercel MCP — add-mcp Tool Detection | https://mcp.vercel.com/docs/environment-variables | Auto-detects installed AI clients and configures them all |
| Better CLI — Colors and Formatting | https://bettercli.org/design/using-colors-in-cli/ | ANSI color best practices, `NO_COLOR` convention, TTY detection |
| Microsoft — Cross-Platform Scripting | https://learn.microsoft.com/en-us/azure/devops/pipelines/scripts/cross-platform-scripting | Environment variables, path handling across Windows/macOS/Linux |

## Source Metadata

- Total sources consulted: 20
- Total sources used: 12
- Date range: 2023-09-14 to 2026-05-29
