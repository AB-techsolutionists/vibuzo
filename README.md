# Vibuzo — Agentic Framework

**Orchestrator plans. Vibuzo executes. Together they build better software.**

A minimal, universal agentic framework that works with ANY AI coding tool (opencode, Claude Code, Cursor, Codex, Gemini CLI, Copilot, Windsurf, and 20+ more).

## Philosophy

Most AI coding mistakes come from one root cause: **planning and executing at the same time.**

Vibuzo separates the two:

- **Orchestrator** (plan mode) — thinks, analyzes, plans, delegates, reviews. Never touches code.
- **Vibuzo** (execute mode) — implements precisely what it's told. Never plans or adds scope.

This separation forces intentionality. Every line of code is planned before it's written. Every change is verified before it's complete.

## Install

### Global (available in ALL projects)

```bash
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --global
```

### Per-project

```bash
cd your-project
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash
```

## What Gets Installed

```
your-project/
├── AGENTS.md                     ← Universal rules (read by 25+ tools)
└── .opencode/
    └── agent/core/
        ├── orchestrator.md        ← Plan-mode agent definition
        └── vibuzo.md              ← Execute-mode agent definition
```

Global install places agents in `~/.config/opencode/agent/core/` so they're available across all your projects.

## How It Works

```
You: "Add a dark mode toggle"

Orchestrator:
  → Analyzes: "I see Tailwind + React. Option A: dark: prefix. Option B: CSS vars."
  → Proposes plan, gets your approval
  → Delegates: [SWITCH TO VIBUZO]

Vibuzo:
  → Reads current code for patterns
  → Creates the toggle component
  → Verifies it works
  → Reports: [DONE] Component created at src/DarkModeToggle.tsx

Orchestrator:
  → Reviews, summarizes
  → "Done. Uses Tailwind dark: prefix. 3 files changed."
```

## Supported Tools

| Tool | How it reads Vibuzo |
|------|---------------------|
| **opencode** | Native agents (orchestrator.md + vibuzo.md) |
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

## Handoff Protocol

The text-based `[SWITCH TO VIBUZO]` / `[SWITCH TO ORCHESTRATOR]` protocol works in ANY tool:

```
[SWITCH TO VIBUZO]
Task: Create a user profile card component
Files: src/components/ProfileCard.tsx
Steps:
  1. Create component with avatar, name, email props
  2. Style with Tailwind classes
  3. Export default
Acceptance:
  ✅ Component renders with all props
  ✅ TypeScript compiles without errors
```

## Roadmap

- **v0.1** — Two agents + AGENTS.md + installer ← current
- **v0.2** — Commands (`/plan`, `/execute`, `/review`)
- **v0.3** — Context patterns (reusable rules)
- **v0.4** — Skills (reusable workflows)
- **v0.5** — Multi-tool auto-detection (Cursor, Windsurf, Codex, Gemini)

## License

MIT
