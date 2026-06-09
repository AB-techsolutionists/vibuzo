---
tags:
  - installer
  - wizard
  - detection
  - progress
  - CLI
  - UX
scope: Designing interactive CLI installers with detection, progress indicators, and guided wizards
when: Adding new installer features or restructuring the install/update experience
---

# Interactive Installer Wizard

> Pattern for an 8-step interactive CLI installer wizard with modular detection, progress indicators, and structured summary.

## Architecture

The installer is organized as a linear wizard with numbered steps:

```
Banner → Detection Steps → Preview → Confirmation → Execution → Summary
```

### Wizard Steps (Fresh Install)

| Step | Name | Purpose |
|------|------|---------|
| 1 | Detect Environment | OS, arch, shell version, available tools, terminal capabilities |
| 2 | Detect Install State | Existing install version, date, file integrity (fresh/uptodate/outdated/partial) |
| 3 | Detect AI Tools | Scan for 8 AI coding agents (Claude Code, opencode, Cline, Cursor, Copilot CLI, Gemini CLI, Windsurf, Codex CLI) |
| 4 | Installation Preview | Show summary of detected state + what will be installed → confirm |
| 5 | Download Agents | X-of-Y progress with per-file status and retry |
| 6 | Download Commands | Same X-of-Y pattern for command files |
| 7 | Configure Integrations | Copy agent files to detected AI tool config directories |
| 8 | Post-Install Summary | Multi-section box with details and next steps |

### Wizard Steps (Update Flow)

| Step | Name | Purpose |
|------|------|---------|
| 1 | Check Version | Compare current install vs latest available |
| 2 | Download Agents | X-of-Y progress |
| 3 | Download Commands | X-of-Y progress |
| 4 | Configure Integrations | Same as fresh install |

## Detection Modules

Each module is a standalone function that:
1. Shows a step header via `Write-Step`/`write_step`
2. Runs a spinner animation during each check via `Write-Spinner`/`write_spinner`
3. Returns a structured result (hashtable in PS1, globals in Bash)
4. Displays results in a formatted block with checkmarks

### Environment Detection

Checks: OS, architecture (x64/ARM64), shell version, tool availability (curl/wget/git/pwsh), terminal width, TTY status, PowerShell execution policy.

### Install State Detection

Checks: `.opencode/.vibuzo-version` existence and parsing, file integrity (4 agents + 7 commands present), AGENTS.md status.

### AI Tool Detection

Tool | Detection Method
-----|----------------
Claude Code | `claude` command in PATH, `.claude/` directory
opencode | `opencode` command in PATH, `.opencode/` directory
Cline | `.cline/` or `.github/agents/` directory
Cursor | `cursor` command in PATH, `.cursor/` directory
Copilot CLI | `gh copilot --help` exit code
Gemini CLI | `gemini` command in PATH
Windsurf | `.windsurf/` directory
Codex CLI | `codex` command in PATH

## Progress Indicators

### Spinner (Indeterminate)

Uses Braille dot character set: `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏`. Cycle advances on each call (not timer-based) so stalls are visible. On completion, replaces spinner char with `✓`.

### X-of-Y Counter (Determinate)

Format: `[N/M] filename... ✓/✗`

Shows current file name being downloaded, checkmark on success, X on failure with retry. Uses atomic writes (download to `.tmp`, rename on success).

## Flag Support

| Flag/Env Var | Effect |
|---|---|
| `--no-color` | Suppress all ANSI color codes |
| `NO_COLOR` env var | Same as `--no-color` |
| `--yes` / `-y` | Auto-confirm all interactive prompts |
| Non-TTY detection | Auto-use defaults when piped |

## Post-Install Summary

Multi-section box with `═══` dividers separating details section (location, version, counts) from next-steps section (restart, context init, spec, learn more).

## Related

- [`patterns/session-workflow.md`](session-workflow.md) — Session workflow discipline
- [`patterns/large-document-size-gate.md`](large-document-size-gate.md) — Gating large outputs
