# Vibuzo — Agentic Framework

**Vibuzo is an agentic framework for AI coding agents.** AI agents make two common mistakes: they plan and execute at the same time (leading to half-baked solutions), and they forget everything between sessions (leading to repeated explanations). Vibuzo solves both.

**How it works:**

1. **Planning-first workflow** — Vibuzo always proposes a plan before touching code. You review and approve each step. Complex features are delegated to a dedicated implementation agent (Deepveloper) via `/spec`, with approval gates between every phase.

2. **Persistent context system** — your project's conventions, architecture decisions, and patterns are saved to `context/` via `/add-context`. Every new session and every agent automatically reads them at startup — no more re-explaining your stack.

3. **Session reports** — at natural breakpoints, `/session` generates a full markdown report of everything that happened: what was requested, what was built, every file changed, every decision made, and why. These reports live in `context/sessions/` and are available to future sessions and any agent via `/session view` and `/session timeline`.

Works with 25+ tools (opencode, Claude Code, Cursor, Codex, Copilot, Windsurf, Gemini CLI, and more).

## Installation

**macOS / Linux (bash):**
```bash
# Local (per project)
cd your-project && curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash

# Global (all projects)
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --global

# Update existing
cd your-project && curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --update
```

**Windows (PowerShell 7+):**
```powershell
# Local (per project)
cd your-project; pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }"

# Global (all projects)
pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }" -Global

# Update existing
cd your-project; pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }" -Update
```

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
   Search later with `/context find [type your search..]`.

4. **Start building** — Vibuzo handles everyday tasks directly. For complex features use `/spec [enter complete feature specification]` — it runs a 5-phase pipeline (spec → plan → tasks → implement → review), spawning Deepveloper for implementation and asking for your approval between each phase.

5. **Checkpoint with sessions** — at natural breakpoints run `/session`. This creates a full report at `context/sessions/YYYY-MM-DD-<title>.md` with: what was asked for, what was built, every file changed, every decision made, and what's still pending.    Browse past reports with `/session view [session name or date..]` and `/session timeline`.

## How Vibuzo Learns Over Time

Vibuzo doesn't learn on its own — you teach it as you work. The more context you save, the smarter it gets across sessions.

**Three learning mechanisms:**

1. **Saved context (`context/`)** — every time you run `/add-context`, you save a permanent rule, pattern, or decision. At the start of every new session, Vibuzo reads `context/index.md` and loads everything your project knows. You never re-explain your stack, conventions, or architecture decisions.

2. **Session summaries (`context/sessions/`)** — every `/session` generates a full report of what was built, what was decided, and why. At the start of every new session, Vibuzo automatically reads the latest session summary to pick up where you left off. Run `/context harvest` to promote patterns discovered in sessions into permanent context files.

3. **Harvest pipeline** — `/context append` scans your current conversation for anything worth saving and asks if you want to add it to context. `/context harvest` reads all your session summaries and presents patterns worth promoting. You approve what gets saved — nothing is automatic.

**The result:** the first session starts from scratch. By session 10, Vibuzo knows your architecture, your naming conventions, your testing style, your past decisions, and why they were made. New agents on your team get the same knowledge instantly because it's all committed to the repo.

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

| Command | What it does | Example |
|---------|-------------|---------|
| `/spec` | 5-phase feature pipeline with approval gates | `/spec dark mode toggle` |
| `/context init` | Scaffold context directory structure | `/context init` |
| `/context find` | Search saved project knowledge | `/context find naming conventions` |
| `/context harvest` | Mine session summaries for patterns to promote | `/context harvest` |
| `/context append` | Scan current conversation for knowledge to save | `/context append` |
| `/add-context` | Save a rule, pattern, or decision to permanent context | `/add-context We use pnpm not npm` |
| `/session` | Generate a full session report | `/session` |
| `/session view` | Browse past session reports | `/session view dark-mode` or `/session view 2026-06-05` |
| `/session timeline` | Show all session reports chronologically | `/session timeline` |

## License

MIT
