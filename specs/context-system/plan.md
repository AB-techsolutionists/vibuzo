# Context System — Implementation Plan

## Tech Stack

- **Markdown** — all artifacts (context files, commands, session logs) are plain `.md`. Zero dependencies, zero build step.
- **opencode command templates** — each command is a `.md` file in `.opencode/commands/` with YAML frontmatter. Commands use `$ARGUMENTS`, `$1`, `$2` for parameterization.
- **YAML frontmatter** — used for command metadata (`description`, `agent`, `subtask`). Native opencode format.
- **No databases, no CLI tools, no JavaScript/Python scripts** — pure agent-driven I/O via the command templates.

## Architecture

```
                          ┌──────────────────────┐
                          │     AGENTS.md          │
                          │  (auto-load instruction)│
                          └──────┬───────────────┘
                                 │ "read context/index.md"
                                 ▼
  ┌──────────────────────────────────────────────────┐
  │                  context/                         │
  │  ┌──────────┐  ┌──────────┐  ┌──────────────┐   │
  │  │index.md  │  │patterns/ │  │standards/     │   │
  │  │ (TOC)    │  │  *.md    │  │  *.md         │   │
  │  └──────────┘  └──────────┘  └──────────────┘   │
  │  ┌──────────┐  ┌──────────┐                     │
  │  │arch/     │  │sessions/ │                     │
  │  │  *.md    │  │  YYYY-MM-DD.md                 │
  │  └──────────┘  └──────────┘                     │
  └──────────────────────────────────────────────────┘
         ▲ read/write              ▲ read/write
         │                         │
  ┌──────┴──────────────┐  ┌──────┴──────────────┐
  │  /context            │  │  /session            │
  │  (init/find/harvest) │  │  (log/view/list)     │
  └─────────────────────┘  └─────────────────────┘
         ▲                              ▲
         │                              │
  ┌──────┴──────────────┐  ┌───────────┴──────────┐
  │  /add-context         │  │  AGENTS.md auto-load │
  │  (write pattern/     │  │  at session start     │
  │   standard/arch)      │  └──────────────────────┘
  └─────────────────────┘
```

**Data flow:**
- Session starts → agent reads AGENTS.md → sees auto-load instruction → loads `context/index.md` → discovers available context → reads relevant files → has full project memory
- User runs `/add-context pattern foo "desc"` → Vibuzo writes `context/patterns/foo.md` → updates `context/index.md`
- User runs `/session log "Built X"` → Vibuzo appends to `context/sessions/2026-06-03.md`
- User runs `/context harvest` → Orchestrator reads sessions, proposes patterns to promote, writes to permanent dirs

## Components

| Component | Type | Responsibility | Agent |
|-----------|------|---------------|-------|
| `commands/context.md` | Command | `/context init` (scaffold), `/context find` (discovery), `/context harvest` (promotion) | Orchestrator |
| `commands/add-context.md` | Command | `/add-context pattern\|standard\|architecture <name> <desc>` — writes context file + updates index | Vibuzo (subtask) |
| `commands/session.md` | Command | `/session log`, `/session list`, `/session view` — manages session logs | Vibuzo (subtask) |
| `AGENTS.md` auto-load section | Instruction | Tells every agent to load `context/index.md` at session start | Orchestrator + Vibuzo |
| `context/` directory | Data | All context files, organized by type | — |
| `context/index.md` | Index | Auto-maintained table of contents of all context files | — |
| `install.sh` | Installer | Downloads commands to `.opencode/commands/` | — |
| `install.ps1` | Installer | Same for Windows | — |

## Implementation Order

**Phase 1 — Foundation (done)**
1. Write `commands/context.md` — init/find/harvest template
2. Write `commands/add-context.md` — save by type template
3. Write `commands/session.md` — log/view/list template

**Phase 2 — Integration (done)**
4. Add Context Auto-Load section to `AGENTS.md`
5. Add 3 command downloads to `install.sh`
6. Add 3 command downloads to `install.ps1`

**Phase 3 — Testing (pending)**
7. Copy commands to `.opencode/commands/` locally
8. Run `/context init` — verify scaffold creates correctly
9. Run `/add-context standard naming "camelCase for vars"` — verify file created + index updated
10. Run `/session log "Tested context system"` — verify session log created
11. Run `/context find naming` — verify discovery works
12. Run `/context harvest` — verify promotion workflow

**Risk factors:**
- **Command template quality depends on the agent** — the commands are prompts, not code. The agent's interpretation determines output quality. To mitigate, keep templates concise and prescriptive ("do X, then Y, then Z").
- **Index auto-update is agent-driven** — no script enforces it. Each command template must explicitly include "update index.md" in its steps.
- **Session date logic** — `YYYY-MM-DD.md` filename depends on the agent knowing today's date. Most agents do, but inconsistent date formatting could cause fragmented logs.
