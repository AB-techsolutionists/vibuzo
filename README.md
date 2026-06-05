# Vibuzo — Agentic Framework

**Vibuzo is an agentic framework for AI coding agents.** AI agents make two common mistakes: they plan and execute at the same time (leading to half-baked solutions), and they forget everything between sessions (leading to repeated explanations). Vibuzo solves both.

**How it works:**

1. **Planning-first workflow** — Vibuzo always proposes a plan before touching code. You review and approve each step. Complex features are delegated to a dedicated implementation agent (Deepveloper) via `/spec`, with approval gates between every phase.

2. **Persistent context system** — your project's conventions, architecture decisions, and patterns are saved to `context/` via `/add-context`. Every new session and every agent automatically reads them at startup — no more re-explaining your stack.

3. **Session reports** — at natural breakpoints, `/session` generates a full markdown report of everything that happened: what was requested, what was built, every file changed, every decision made, and why. These reports live in `context/sessions/` and are available to future sessions and any agent via `/session view` and `/session timeline`.

Works with 25+ tools (opencode, Claude Code, Cursor, Codex, Copilot, Windsurf, Gemini CLI, and more).

## Installation

```bash
# Local (per project)
cd your-project && curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash

# Global (all projects)
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --global

# Update existing
cd your-project && curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --update
```

**Windows (PowerShell):** Replace `| bash` with `pwsh -c "& { $(irm ...) }"`, use `-Global` / `-Update`.

## Quick Start

1. **Restart opencode** — the installer adds agents to `.opencode/agent/core/`. After restart, select **Vibuzo** from the agent dropdown.

2. **Initialize context** — run `/context init`. This creates `context/` with four directories:
   ```
   context/
   ├── architecture/   ← ADRs and design decisions
   ├── standards/      ← Conventions (naming, testing, style)
   ├── patterns/       ← Reusable idioms
   └── sessions/       ← Session archive (auto-generated)
   ```

3. **Save project context** — tell Vibuzo about your project so every session remembers:
   ```
   /add-context This is a Next.js 14 app with App Router, shadcn/ui, and Prisma
   /add-context We use pnpm, not npm
   ```
   Search later with `/context find (user input)`.

4. **Start building** — Vibuzo handles everyday tasks directly. For complex features use `/spec (user input)` — it runs a 5-phase pipeline (spec → plan → tasks → implement → review), spawning Deepveloper for implementation and asking for your approval between each phase.

5. **Checkpoint with sessions** — at natural breakpoints run `/session`. This creates a full report at `context/sessions/YYYY-MM-DD-<title>.md` with: what was asked for, what was built, every file changed, every decision made, and what's still pending.    Browse past reports with `/session view (user input)` and `/session timeline`.

## What Gets Installed

```
your-project/
├── AGENTS.md                     ← Read by 25+ tools (commit this)
└── .opencode/
    ├── agent/core/vibuzo.md      ← Main agent (pick this from dropdown)
    ├── agent/core/deepveloper.md  ← Subtask agent (/spec)
    └── commands/                  ← 9 command files (spec, context*, session*)
```

## Commands

| Command | What it does |
|---------|-------------|
| `/spec (user input)` | 5-phase feature pipeline with approval gates |
| `/context init` | Scaffold context directory structure |
| `/context find (user input)` | Search saved project knowledge |
| `/context harvest` | Mine session archive for patterns to promote |
| `/context append` | Scan current conversation for knowledge to save |
| `/add-context (user input)` | Save a rule, pattern, or decision to permanent context |
| `/session` | Generate a full session report |
| `/session view (user input)` | Browse past session reports |
| `/session timeline` | Show all session reports chronologically |

## License

MIT
