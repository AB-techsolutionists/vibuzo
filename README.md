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
    │   └── deepveloper.md         ← Execution specialist (/implement)
    └── commands/
        ├── spec.md               ← Full feature pipeline (/spec)
        ├── context.md             ← Context management (/context)
        ├── add-context.md         ← Save context (/add-context)
        └── session.md             ← Session checkpoints (/session)
```

The installer creates `AGENTS.md` in your project root and places agent definitions in `.opencode/agent/core/`. Global install places agents in `~/.config/opencode/agent/core/` so they're available across all your projects.

## Commands

| Command | What it does |
|---------|-------------|
| `/spec <feature>` | 5-phase pipeline: spec → plan → tasks → implement → review |
| `/session` | Scaffold a compaction file (/compact output goes in the body) |
| `/session view <ref>` | Browse past session compactions |
| `/session timeline` | Show master timeline of all compactions |
| `/context init` | Scaffold the context directory structure |
| `/context find <topic>` | Search project context for information |
| `/context harvest` | Mine sessions for patterns worth promoting to permanent context |
| `/add-context <statement>` | Save a rule, pattern, or decision to permanent context |

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

## Context System

Context gives every new session instant access to project conventions, patterns, and architecture.

```
context/
├── index.md                     ← Table of contents (auto-updated)
├── architecture/                ← Architecture Decision Records
├── standards/                   ← Naming, style, conventions
├── patterns/                    ← Reusable patterns and idioms
└── sessions/                    ← Auto-generated compaction archive
```

- **Save knowledge:** `/add-context <statement>` — agent infers type and name
- **Search:** `/context find <topic>` — exact match first, then broader keyword search
- **Harvest:** `/context harvest` — reads all sessions, presents promotion candidates
- **Auto-load:** agents read `context/index.md` at session start

## Session Management

Use `/session` at natural breakpoints to checkpoint your work:

```
/session       → creates context/sessions/YYYY-MM-DD-<title>.md skeleton
/compact       → opencode's built-in compaction → paste output into the file
/session view  → browse past compactions
/session timeline → view all compactions chronologically
```

Each session file uses descriptive title-based names (`session-redesign`, `session-polish`) with automatic collision handling.

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

## Roadmap

- **v0.0.1** — Two agents (Vibuzo + Deepveloper) + AGENTS.md + installer
- **v0.0.2** — Commands (`/spec`, `/plan`, `/tasks`, `/implement`, `/review`)
- **v0.0.3** — Context system (`/context`, `/session`, `/add-context`)
- **v0.0.4** — Single-agent restructure (Vibuzo main, Orchestrator deprecated)
- **v0.0.5** — Approval gates (configurable levels 0-3)
- **v0.0.6** — `/spec` command (consolidated pipeline)
- **v0.0.7** — Session compaction system (title-based, paste workflow)
- **v0.0.8** — Context harvest + imperative command pattern ← current
- **v0.0.9** — Skills (reusable workflows)
- **v0.1.0** — Multi-tool auto-detection (Cursor, Windsurf, Codex, Gemini)

## License

MIT
