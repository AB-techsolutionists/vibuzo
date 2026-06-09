# Vibuzo — Agentic Framework for AI Coding

```
██╗   ██╗██╗██████╗ ██╗   ██╗███████╗ ██████╗ 
██║   ██║██║██╔══██╗██║   ██║╚══███╔╝██╔═══██╗
██║   ██║██║██████╔╝██║   ██║  ███╔╝ ██║   ██║
╚██╗ ██╔╝██║██╔══██╗██║   ██║ ███╔╝  ██║   ██║
 ╚████╔╝ ██║██████╔╝╚██████╔╝███████╗╚██████╔╝
  ╚═══╝  ╚═╝╚═════╝  ╚═════╝ ╚══════╝ ╚═════╝ 
```

Vibuzo is an agentic workflow system for LLM-powered coding — it uses a primary orchestrator (Vibuzo) with three specialized agents (Deepveloper, Deepsearcher, Deepviewer) through a structured pipeline of research → plan → execute → review, backed by persistent project context and session memory with approval gates.

| Mechanism | What it does |
|-----------|-------------|
| **Multi-agent orchestration** | Vibuzo (primary orchestrator) delegates to three specialized sub-agents: Deepveloper (implementation), Deepsearcher (web research), and Deepviewer (codebase analysis & review). All three are spawned as subtasks via commands or inline `@` mentions. |
| **/spec engineering pipeline** | 5-phase feature pipeline (Research → Spec → Plan → Implement → Review) with approval gates between every phase. Spawns Deepsearcher for research, Deepveloper for implementation, and Deepviewer for review — you approve before each handoff. |
| **Persistent context system** | Save conventions, decisions, and patterns via `/add-context`. All context files carry YAML frontmatter (`tags`, `scope`, `when`) enabling auto-load at session start and auto-query scoring before every implementation task. |
| **Context auto-query** | Before any implementation task, Vibuzo automatically scans `context/index.md`, scores each file for relevance (TF-IDF + Levenshtein + keyword matching), and loads high-scoring files into working context. No manual prompting needed. |
| **Session reports** | `/session` generates a full markdown report of everything built, changed, and decided — including a **Session Compaction** block (styled box with Goal, Constraints, Progress, Key Decisions, Next Steps, Critical Context, Relevant Files). `/session-init` initializes agent context at session start with a unified summary box. |
| **Session continuity chain** | Every new session auto-loads the chain: `context/index.md` → `context/sessions/index.md` (timeline) → latest session file's Compaction block. The `/session` command also scans for new patterns and presents them as save candidates. |
| **Approval gates (hybrid)** | Mechanical actions (file writes, commands, task delegation) gated via native opencode Desktop popups with Approve/Reject buttons. Conceptual actions (plan approval, push approval) use custom chat gates. All sub-agents have independent permission blocks. |
| **Web research** | Three modes: `@deepsearcher <query>` for inline ad-hoc research (no file created), `/research <query>` for standalone research (no file created), and the `/spec` Research stage which saves to `specs/<feature>/research.md` as a permanent artifact. |
| **Codebase analysis** | `/deepviewer <query>` runs a full audit pipeline (structural scan, pattern analysis, session/context cross-reference, git history). `@deepviewer <query>` answers codebase questions inline. Also powers the Review phase of `/spec`. |
| **Karpathy behavioral principles** | Built-in agent guidelines: Think Before Coding (surface tradeoffs, push back), Simplicity First (minimal code), Surgical Changes (touch only what you must), Goal-Driven Execution (define success criteria, loop until verified). |
| **Structured commit messages** | Commits use conventional commit types (`feat:`, `docs:`, `refactor:`, `fix:`, etc.) derived from actual changes — single type for uniform commits, stacked types for mixed commits, with a `## Summary` overview section and categorized bullet points. |


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

## What Gets Installed

```
your-project/
├── AGENTS.md                     ← Universal agent manifest (commit this!)
└── .opencode/
    ├── agent/core/vibuzo.md      ← Main agent — select this from dropdown
    ├── agent/core/deepveloper.md ← Implementation sub-agent (used by /spec)
    ├── agent/core/deepsearcher.md← Research sub-agent (used by /research, @deepsearcher)
    ├── agent/core/deepviewer.md  ← Codebase analysis agent (used by /spec Review, @deepviewer)
    └── commands/                 ← 7 command templates
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
| `/context init` | Scaffold context directory structure | `/context init` |
| `/add-context` | Save a rule, pattern, or decision to permanent context | `/add-context always follow the same pattern of x,y,z` |
| `/spec` | Full feature pipeline (research → briefing → specification → plan → tasks → implementation → review) with approval gates between every phase | `/spec add a new dark mode toggle` |
| `/deepviewer` | Full codebase audit and analysis via Deepviewer | `/deepviewer audit the error handling pattern` |
| `/research` | Web research via Deepsearcher, saves to `specs/<feature>/research.md` | `/research best React state management 2026` |
| `/session` | Generate a comprehensive session summary capturing every action, change, and decision | `/session` |
| `/session-init` | Initialize agent context — discover, verify, scaffold, report loaded state | `/session-init` |

## Quick Start

### First-Time Setup

Run these once per project:

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
   /add-context We use the pattern ... and follow the standard ...
   ```

### The Golden Workflow (Repeat)

Steps 4–10 form a continuous cycle. Each step feeds into the next — building creates knowledge worth saving, sessions checkpoint that knowledge, and the next session picks up exactly where the last left off.

4. **Build** — Vibuzo handles everyday tasks directly. For complex features use `/spec [enter complete feature specification]` — it runs the full feature pipeline (research → briefing → specification → plan → tasks → implementation → review), spawning subagents for each phase with approval gates between them.

5. **Save context as you go** — when you discover a convention, pattern, or decision worth keeping, run `/add-context <statement>`. Vibuzo infers the type (architecture/standard/pattern) and file name, generates YAML frontmatter, and updates `context/index.md`. This knowledge persists across every future session — you never re-explain your stack or decisions.

6. **Monitor the context window** — the agent's context window fills up as you work. Watch for when it reaches ~75% capacity. That's your checkpoint signal — don't wait until it auto-compacts and loses the conversation history.

7. **Run `/session`** — captures everything before the window resets. It creates a full report at `context/sessions/YYYY-MM-DD-<title>.md` with: what was asked for, what was built, every file changed, every decision made, and what's still pending. The file includes a **Session Compaction** block — a styled box with Goal, Constraints, Progress, Key Decisions, Next Steps, Critical Context, and Relevant Files.

8. **Promote patterns** — `/session` doesn't just save a report. It scans the session's conversation for new patterns, conventions, and decisions, then presents them as save candidates with auto-generated frontmatter (`tags`, `scope`, `when`). Approve the ones worth keeping — they get saved to `context/` and the index updates automatically. No separate harvest step needed.

9. **Open a fresh session** — after `/session` completes, run `/new` or open a new session. Never `/compact` without running `/session` first — compaction loses the conversation history and anything in it.

10. **Run `/session-init`** — at the start of every new session, this reinitializes the agent. It auto-loads two things: `context/index.md` (all permanent context built up across every `/add-context` and `/session` promote cycle) and the latest session's Compaction block (where you left off). This is the continuity chain:

    ```
    context/index.md  ← permanent knowledge (never forgets)
          ↓
    sessions/index.md  ← timeline of all past sessions
          ↓
    latest compaction  ← where you left off (last session's state)
    ```

    That's the golden workflow in full — **build → context → session → promote → resume**. Context is your persistent memory, sessions are your episodic memory, and `/session-init` bridges both at every start.

## How Vibuzo Learns Over Time

Vibuzo doesn't learn on its own — you teach it as you work. The more context you save, the smarter it gets across sessions.

**Two learning mechanisms:**

1. **Saved context (`context/`)** — every time you run `/add-context`, you save a permanent rule, pattern, or decision. At the start of every new session, Vibuzo reads `context/index.md` and loads everything your project knows. You never re-explain your stack, conventions, or architecture decisions.

2. **Session summaries (`context/sessions/`)** — every `/session` generates a full report of what was built, what was decided, and why. At the start of every new session, Vibuzo automatically reads the latest session summary to pick up where you left off. The `/session` command itself scans for patterns and presents them as save candidates — no separate harvest step needed.

**The result:** the first session starts from scratch. By session 10, Vibuzo knows your architecture, your naming conventions, your testing style, your past decisions, and why they were made. New agents on your team get the same knowledge instantly because it's all committed to the repo.


## Version History

| Version | Highlights |
|---------|------------|
| **0.3.6** | **README restructure, new-release detailed release notes, internal command cleanup — 3 files changed, 17 insertions, 7 deletions** |
| | Expanded README mechanism table to 12 rows covering all system capabilities, reordered commands table with context commands first, restructured Quick Start into First-Time Setup and Golden Workflow sections with continuity chain diagram, moved What Gets Installed and Commands under Installation, added detailed multi-line release notes format to new-release command with diffstat and structured descriptions, and removed new-release from user-facing docs as an internal command. |
| **0.3.5** | **Documentation drift fixes — 16 files changed, 634 insertions, 67 deletions** |
| | Unified session-init output into single codeblock, rewrote spec pipeline gating, switched new-release to conversation-derived notes, migrated commit messages to conventional types, cleansed stale approval_level references, filled missing agent references, and removed dead command refs and stale counts. |
| **0.3.4** | Approval gate refactor (native popups), created agents/deepviewer.md source, synced installers |
| **0.3.3** | Deepviewer codebase audit, 3 remediation fixes (docs drift, legacy header), version bump 0.3.2→0.3.3 |
| **0.3.2** | Created Deepviewer codebase analysis and review agent: full audit pipeline (structural scan, pattern analysis, session/context cross-reference, git history), /spec Review phase delegation, updated AGENTS.md, context index, and installers. |
| **0.3.1** | Session auto-compaction: `/session` auto-generates compaction block (styled box), eliminating manual paste. Updated all docs. |
| **0.3.0** | Split session command into two standalone files: session.md (report generation) and session-init.md (agent context initialization). Removed routing logic, updated all docs and installers. |
| **0.2.9** | Context command consolidation: deleted context-append/harvest/find, kept context-init as the only context command. Saved context-init-standalone architecture record from session scan. |
| **0.2.8** | Context command consolidation: deleted context-append/harvest/find, kept context-init as the only context command (harvesting is now built into `/session`). | 
| **0.2.7** | Session management enhancement: restructured session.md (report + init only), deleted session-view/timeline, updated installers and docs, added YAML frontmatter to reports. |
| **0.2.6** | Synced versioning.md rollover scheme to match /new-release (patch 0→9, minor 0→19). |
| **0.2.5** | Finalize session documentation and save installer-content-preservation-dedup pattern. |
| **0.2.4** | Fixed installer AGENTS.md rules duplication: added dedup guard to both installers; cleaned up duplicate rule in AGENTS.md. |
| **0.2.3** | Restructured AGENTS.md with updated tagline, tree, and commands section; added README step to `/commit` bump workflow; added command execution instructions. |
| **0.2.2** | Fixed missing `agents/deepsearcher.md` causing installer 404; added deepsearcher to path-rewriting and Claude Code copy in both installers. |
| **0.2.1** | Context system enhancement: YAML frontmatter (tags/scope/when) on all 27 context files, 3-factor semantic search, auto-pattern scanning after sessions, and Context Auto-Query before implementations. |
| **0.2.0** | New `/commit` command — 13-step automation for version bump → release notes → structured commit → no-push report. Fixed `/spec` feature naming (short kebab-case extraction). Saved 4 context files (3 new standards + commit workflow pattern). |
| **0.1.5** | Box renderer double-line borders — all installer boxes now use `╔═╗║╚═╝` matching the VIBUZO banner, fixed 59-char width, status lines wrapped in header boxes, emoji icons removed from update status. |
| **0.1.4** | Box renderer emoji width fix — `Write-Box` and `print_box` handle emoji double-width rendering (U+2700–U+27BF), right border alignment fixed in both installers. |
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
