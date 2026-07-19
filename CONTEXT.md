# Deepveloper

A framework for installing and configuring an opencode agent that behaves as a senior AI engineer / software developer, following Matt Pocock's engineering skills patterns.

## Language

**Deepveloper**:
An opencode agent definition installed via `npx deepveloper@latest`.
_Avoid_: deepveloper agent, deepveloper framework

**Karpathy Principles**:
Behavioral guidelines for AI coding agents: Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution.
_Avoid_: karpathy rules, guidelines

**Matt Pocock skills**:
A collection of engineering workflow skills (code-review, domain-modeling, grilling, TDD, etc.) distributed as `npx skills@latest add mattpocock/skills`.
_Avoid_: matt skills, pocock skills, engineering skills

**Skills CLI**:
The interactive installer tool at `npx skills@latest` that discovers installed AI coding agents, lets the user select skills by fuzzy-search, and installs them per-agent or globally. deepveloper's CLI mirrors this user experience.
_Avoid_: skills installer, npx skills

**Agent definition**:
An entry in `.opencode/agent/*.md` containing YAML frontmatter and a system prompt body. For deepveloper: mode=primary, no model lock, emerald green color.
_Avoid_: agent config, agent setup

**CLAUDE.md**:
Project-level context file at the repo root. deepveloper writes a skeleton; `/setup-matt-pocock-skills` fills in the `## Agent skills` section.
_Avoid_: claude instructions, project instructions

**AGENTS.md**:
Project-level context file for opencode. Same pattern as CLAUDE.md — skeleton by deepveloper, skills section by setup skill.
_Avoid_: agent instructions

**Installation flow**:
1. `npx deepveloper@latest` — detects tools (opencode, Claude Code), writes agent definitions to `.opencode/agent/deepveloper.md` and `.claude/deepveloper.md`, writes `CLAUDE.md` and `AGENTS.md` skeletons
2. Calls `npx skills@latest add mattpocock/skills` — user selects which skills
3. Guides user to run `/setup-matt-pocock-skills` inside their agent
