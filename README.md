# Vibuzo — Agentic Framework

**Vibuzo plans AND executes. Deepveloper handles `/implement` subtasks. Run `/spec` for the full spec-to-implement pipeline.**

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
    ├── agent/core/
    │   ├── vibuzo.md              ← Main agent (plans + executes)
    │   ├── deepveloper.md         ← Execution specialist (/implement)
    │   └── orchestrator.md        ← ⚠️ Deprecated (kept for reference)
    └── commands/
        ├── spec.md               ← Full feature pipeline (/spec)
        ├── context.md             ← Context management (/context)
        ├── add-context.md         ← Save context (/add-context)
        └── session.md             ← Session logging (/session)
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

For complex features, use `/spec`:
You: `/spec "user authentication"`

Vibuzo:
  → Phase 1: Creates spec.md (approve?)
  → Phase 2: Creates plan.md (approve?)
  → Phase 3: Creates tasks.md (approve?)
  → Phase 4: Delegates to Deepveloper (approve between tasks)
  → Phase 5: Saves review.md (approve?)
  → Done. All artifacts in specs/user-authentication/
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

## Approval Gates

Vibuzo supports configurable approval gates (levels 0-3) that control which actions require your confirmation:

| Level | Name | Behavior |
|-------|------|----------|
| 0 | Trusted | No gates. Execute freely. |
| 1 | Safe | File writes/edits/deletes and destructive commands require approval. |
| 2 | Cautious | All file operations, all commands, and `/implement` delegation require approval. |
| 3 | Full Control | Every action requires approval, including planning and large file reads. |

**Set it:** Edit `approval_level` in `agents/vibuzo.md` (or `.opencode/agent/core/vibuzo.md`). Default is 0.
**Override inline:** Add "at gate level X" to any request for a one-time change.

---

## Handoff Protocol ⚠️ DEPRECATED

The handoff protocol was used in the legacy two-agent system. 
Vibuzo now handles everything directly. Deepveloper is triggered automatically by `/implement`.
No manual handoff needed.

## Roadmap

- **v0.1** — Two agents (Vibuzo + Deepveloper) + AGENTS.md + installer
- **v0.2** — Commands (`/spec`, `/plan`, `/tasks`, `/implement`, `/review`)
- **v0.3** — Context system (`/context`, `/session`, `/add-context`)
- **v0.4** — Single-agent restructure (Vibuzo main, Orchestrator deprecated)
- **v0.5** — Approval gates (configurable levels 0-3)
- **v0.6** — `/spec` command (consolidated pipeline) ← current
- **v0.7** — Skills (reusable workflows)
- **v0.8** — Multi-tool auto-detection (Cursor, Windsurf, Codex, Gemini)

## License

MIT
