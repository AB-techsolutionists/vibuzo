# Vibuzo — Agentic Framework

```
██╗   ██╗██╗██████╗ ██╗   ██╗███████╗ ██████╗ 
██║   ██║██║██╔══██╗██║   ██║╚══███╔╝██╔═══██╗
██║   ██║██║██████╔╝██║   ██║  ███╔╝ ██║   ██║
╚██╗ ██╔╝██║██╔══██╗██║   ██║ ███╔╝  ██║   ██║
 ╚████╔╝ ██║██████╔╝╚██████╔╝███████╗╚██████╔╝
  ╚═══╝  ╚═╝╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝ 
```

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
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash

# Global (all projects)
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --global

# Update existing
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --update
```

**Windows (PowerShell 7+):**
```powershell
# Local (per project)
pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) }"

# Global (all projects)
pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) } -Global"

# Update existing
pwsh -c "& { $(irm https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.ps1) } -Update"
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

5. **Checkpoint with sessions** — at natural breakpoints run `/session`. This creates a full report at `context/sessions/YYYY-MM-DD-<title>.md` with: what was asked for, what was built, every file changed, every decision made, and what's still pending. The file includes a **Session Compaction** section at the bottom — after `/session` completes, run `/compact` in opencode's TUI, copy the output, and paste it there. This block serves as starting context for the next session. Browse past reports with `/session view [session name or date..]` and `/session timeline`.

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
├── AGENTS.md                     ← Universal agent manifest (commit this!)
└── .opencode/
    ├── agent/core/vibuzo.md      ← Main agent — select this from dropdown
    ├── agent/core/deepveloper.md ← Subtask agent (used by /spec)
    └── commands/                 ← 9 command templates
```

**Key file: `AGENTS.md`**

This file tells all 25+ tools (opencode, Claude Code, Cursor, Copilot, etc.) where to find your agents and their instructions. It's read by your editor's agent system at startup.

- **After installation**, restart your editor
- **In the agent dropdown**, you'll see **Vibuzo** — select it
- **AGENTS.md is already set up**, no manual edits needed (unless you customize agents later)
- **Always commit AGENTS.md** to your repo so all agents use the same setup

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

## Version History

| Version | Highlights |
|---------|------------|
| **0.1.3** | Documentation sync: version history in README, fixed `install.sh` syntax corruption, updated agent version check. |
| **0.1.2** | Dynamic version fetching from `VERSION` file on GitHub. Removed commit SHA tracking and 7 wrapper scripts. Fixed PowerShell command syntax. Enhanced success messages with arrow-bulleted guidance. |
| **0.1.1** | Complete installer visual redesign: grouped comma-separated file lists, compact update check box, compact success box, single-line AGENTS.md status, consistent rounded box style. |
| **0.1.0** | Version tracking system (0.x.x semver). Removed source-mirror sync convention. Forward-looking session summary template. Dynamic version reporting. |
| **0.0.1–0.0.19** | Development phase. Two-agent system (Vibuzo + Deepveloper), bash and PowerShell installers, context management commands, session system with compaction workflow, approval gates (levels 0–3), Karpathy behavioral principles, Deepsearcher research agent, installer update mechanism, AGENTS.md preservation convention. |

**Checking your version:**
```bash
# Installed version is in .opencode/.vibuzo-version
cat .opencode/.vibuzo-version

# Latest available on GitHub
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/VERSION

# Update to latest
curl -fsSL https://raw.githubusercontent.com/AB-techsolutionists/vibuzo/main/install.sh | bash -s -- --update
```

## License

MIT
