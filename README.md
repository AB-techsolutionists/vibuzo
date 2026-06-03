# Vibuzo — Agentic Framework

**Vibuzo plans AND executes. Deepveloper handles only `/implement`.**

A minimal, universal agentic framework that works with ANY AI coding tool (opencode, Claude Code, Cursor, Codex, Gemini CLI, Copilot, Windsurf, and 20+ more).

## Philosophy

Most AI coding mistakes come from one root cause: **planning and executing at the same time.**

Vibuzo separates the two with a clear role split:

- **Vibuzo** (main agent) — plans, analyzes, delegates, reviews, AND executes everyday tasks. The single entry point for everything.
- **Deepveloper** (subtask agent) — execution specialist. Triggered only by `/implement`. Never plans.

This separation forces intentionality. Every line of code is planned before it's written. Every change is verified before it's complete.

## Install

### macOS / Linux (bash)

```bash
# Global (all projects)
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --global

# Per-project
cd your-project && curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash
```

### Windows (PowerShell)

```powershell
# Global (all projects)
pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) } -Global"

# Per-project
cd your-project
pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }"
```

## What Gets Installed

```
your-project/
├── AGENTS.md                     ← Universal rules (read by 25+ tools)
└── .opencode/
    └── agent/core/
        ├── vibuzo.md              ← Main agent (plans + executes)
        └── deepveloper.md         ← Execution specialist (/implement only)
```

The installer creates `AGENTS.md` in your project root and places the agent definitions in `.opencode/agent/core/`.

Global install places agents in `~/.config/opencode/agent/core/` so they're available across all your projects.


## How It Works

```
You: "Add a dark mode toggle"

Vibuzo:
  → Analyzes: "I see Tailwind + React. Option A: dark: prefix. Option B: CSS vars."
  → Proposes plan, gets your approval
  → Implements the toggle component directly
  → Verifies it works
  → "Done. Component created at src/DarkModeToggle.tsx"

For complex features, Vibuzo delegates:
You: "Implement user authentication"

Vibuzo:
  → Breaks down into tasks
  → Runs `/implement auth`
  → Deepveloper implements exactly per the spec
  → Vibuzo reviews, summarizes, reports to you
```

## Supported Tools

| Tool | How it reads Vibuzo |
|------|---------------------|
| **opencode** | Native agents (vibuzo.md + deepveloper.md) |
| **Claude Code** | AGENTS.md + .claude/agents/ (auto-created by installer) |
| **Codex CLI** | AGENTS.md — uses built-in `/plan` + `/implement` modes |
| **Cursor** | AGENTS.md (project rules) |
| **Gemini CLI** | AGENTS.md (native support) |
| **Copilot** | AGENTS.md (`.github/copilot-instructions.md`) |
| **Windsurf** | AGENTS.md (native support) |
| **Amp / Devin / 20+ more** | AGENTS.md (universal standard) |

## Customize

Add your own rules by editing `AGENTS.md` under the "Universal Project Rules" section:

- Your tech stack conventions
- Your naming conventions
- Your error handling patterns
- Your testing requirements

## Handoff Protocol ⚠️ DEPRECATED

The handoff protocol was used in the legacy two-agent system. 
Vibuzo now handles everything directly. Deepveloper is triggered automatically by `/implement`.
No manual handoff needed.

## Roadmap

- **v0.1** — Two agents (Vibuzo + Deepveloper) + AGENTS.md + installer ← current
- **v0.2** — Commands (`/plan`, `/implement`, `/review`)
- **v0.3** — Context patterns (reusable rules)
- **v0.4** — Skills (reusable workflows)
- **v0.5** — Multi-tool auto-detection (Cursor, Windsurf, Codex, Gemini)

## License

MIT
