# Deepveloper

**Deepveloper** is an interactive CLI tool that installs a senior engineer AI agent into a project. It detects the developer's AI coding tools (opencode, Claude Code), writes agent definition files with a Karpathy-principled system prompt, and installs Matt Pocock's engineering skills — all from `npx deepveloper@latest`.

---

## Glossary

### Deepveloper
The npm CLI tool (`deepveloper`) that detects AI coding tools, writes agent definitions, and installs skills. It is run interactively with `npx deepveloper@latest`.
_Avoid_: "the deepveloper agent" (the agent within the tool is the senior engineer, not Deepveloper)

### Senior Engineer Agent
The AI agent persona installed by Deepveloper. Combines Karpathy's four principles with a senior software engineer identity. Lives in agent definition files that the CLI writes.
_Avoid_: "deepveloper agent"

### System Prompt
The 6-section prompt template (`Identity, Core Principles, Communication, Workflow, Code Standards, Tool Usage`) that defines the Senior Engineer Agent's behavior. Packaged in `src/prompt.ts`.

### Karpathy Principles
Behavioral guidelines for AI coding agents: Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution.
_Avoid_: karpathy rules, guidelines

### AI Coding Tool
A supported editor/terminal agent that Deepveloper can configure. Currently: **opencode** and **Claude Code**.
_Avoid_: AI tool, coding agent (ambiguous without context)

### Agent Definition File
A file in the project that configures an AI Coding Tool to use the Senior Engineer Agent. Format differs by tool:
- **opencode**: `.opencode/agent/deepveloper.md` — YAML frontmatter (`mode: primary`, `hidden: false`, `color: emerald`) + System Prompt body
- **Claude Code**: `.claude/deepveloper.md` — raw System Prompt body (no frontmatter)

### Project Context File
A skeleton file at the project root that gives the AI Coding Tool basic project-level instructions:
- **AGENTS.md** — for opencode
- **CLAUDE.md** — for Claude Code

Deepveloper writes the skeleton; the skills setup step (`/setup-matt-pocock-skills`) fills in the skills section.
_Avoid_: project instructions

### Matt Pocock Skills
A collection of engineering workflow skills (code-review, domain-modeling, TDD, grilling, implement, etc.) distributed via `npx skills@latest add mattpocock/skills`. Installed by Deepveloper as part of its flow.
_Avoid_: matt skills, pocock skills

### Skills CLI
The interactive installer at `npx skills@latest`. Discovers AI Coding Tools, lets the user select skills by fuzzy-search, and installs them per-tool or globally. Deepveloper's UI mirrors this UX.
_Avoid_: skills installer

### Installation Flow
The sequence of operations Deepveloper performs:
1. Detect AI Coding Tools (opencode, Claude Code)
2. Show plan: files to write, skills to install
3. Confirm with user (or `--yes` to skip)
4. Write Agent Definition Files and Project Context Files
5. Run `npx skills@latest add mattpocock/skills`
6. Show post-install guidance (run `/setup-matt-pocock-skills`)
