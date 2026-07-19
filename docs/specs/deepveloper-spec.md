# Deepveloper: Interactive CLI for Installing the Deepveloper Agent

## Problem Statement

Setting up an AI coding agent with proper guardrails (Karpathy principles) and access to engineering skills (Matt Pocock's skill collection) currently requires manually wiring together multiple configuration files, understanding the agent definition formats for different AI tools (opencode, Claude Code), and running separate installation commands. There is no unified, guided experience for a developer to bootstrap their repo with a senior-engineer agent.

## Solution

An interactive CLI tool (`npx deepveloper@latest`) that detects which AI coding agents the developer has installed, writes agent definition files with a senior engineer system prompt (Karpathy principles + synthesized senior engineer persona), installs Matt Pocock's engineering skills, and guides the developer to complete the setup. The CLI's user experience matches the interactive style of the Skills CLI (`npx skills@latest`), with an ASCII art banner, clear explanations of what will happen, and step-by-step prompts.

## User Stories

1. As a developer, I want to run a single command (`npx deepveloper@latest`), so that my repo gets configured with a senior engineer AI agent without manual setup.

2. As a developer, I want to see an ASCII art banner when the CLI starts, so that the experience feels polished and consistent with the Skills CLI.

3. As a developer, I want the CLI to explain what it will do before making changes, so that I understand what files will be created and modified.

4. As a developer, I want the CLI to detect which AI coding tools I have installed (opencode, Claude Code), so that it only sets up agents for tools I actually use.

5. As a developer using opencode, I want a deepveloper agent definition created at `.opencode/agent/deepveloper.md` with YAML frontmatter, so that I can select "deepveloper" from the opencode agent selector.

6. As a developer using Claude Code, I want a deepveloper agent instruction file created at `.claude/deepveloper.md`, so that Claude Code uses the senior engineer persona and Karpathy principles.

7. As a developer, I want a `CLAUDE.md` skeleton created at the repo root with project-level context, so that Claude Code has basic project instructions.

8. As a developer using opencode, I want an `AGENTS.md` skeleton created at the repo root, so that opencode has basic project instructions.

9. As a developer, I want the deepveloper agent's system prompt to combine Karpathy's four principles (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) with a senior software engineer persona, so that the agent behaves as a pragmatic, experienced engineer.

10. As a developer, I want the CLI to run `npx skills@latest add mattpocock/skills` as part of the installation flow, so that Matt Pocock's engineering skills (code-review, domain-modeling, TDD, grilling, etc.) are available to the deepveloper agent.

11. As a developer, I want the CLI to guide me to run `/setup-matt-pocock-skills` inside my AI agent after installation, so that the repo's issue tracker, triage labels, and domain docs configuration are completed.

12. As a developer using both opencode and Claude Code, I want the CLI to configure both, so that I get a consistent agent experience across tools.

13. As a developer who only uses one tool, I want the CLI to only configure the tools it detects, so that no unnecessary files are created.

14. As a developer who wants to re-run installation, I want the CLI to detect existing deepveloper files and handle overwrites gracefully, so that re-running is safe.

## Implementation Decisions

### Package structure

The `deepveloper` npm package will contain:

- A CLI entry point that handles interactive prompts, banner display, and user interaction
- A programmatic API (`installDeepveloper`) that performs file operations and orchestration
- The system prompt content (Karpathy principles + senior engineer persona) packaged as a template

### Module breakdown

- **CLI module**: Thin wrapper handling stdout/stderr display, user prompts/banner, argument parsing. Minimal logic — purely presentation and user interaction.

- **Tool detection module**: Scans the user's environment for AI coding agent configuration directories. Checks for opencode (`~/.config/opencode/` or `.opencode/`), Claude Code (`~/.claude/` or `.claude/`). Returns a list of detected tools plus the project directory path for each.

- **Installation module** (exposed as the programmatic API): Takes detected tools and a project directory, writes:
  - `.opencode/agent/deepveloper.md` with YAML frontmatter (mode: primary, hidden: false, color: emerald green) and the full system prompt body
  - `.claude/deepveloper.md` with the system prompt body (no frontmatter)
  - `CLAUDE.md` at the repo root if it doesn't exist, with a skeleton
  - `AGENTS.md` at the repo root if it doesn't exist, with a skeleton

  Handles overwriting existing files with user confirmation. Returns a summary of what was written.

- **Orchestration module**: Runs the phases in order — detect tools, show plan, confirm with user, run installation, delegate to skills CLI, show post-install guidance.

### CLI interaction flow

```
Phase 1: Banner + Intro
  - Display ASCII art "deepveloper" banner
  - Brief intro text

Phase 2: Tool Detection
  - Scan for opencode, Claude Code
  - Display detected tools to user

Phase 3: Plan Display
  - Show what will be installed (agent definitions, project files)
  - Show which skills will be installed
  - Show which files will be created/modified

Phase 4: Confirmation
  - Ask user to confirm before proceeding
  - Support a --yes flag to skip confirmation

Phase 5: Installation
  - Write agent definition files
  - Write project context files (CLAUDE.md, AGENTS.md)
  - Run `npx skills@latest add mattpocock/skills`
  
Phase 6: Post-Install Guidance
  - Show next steps: run `/setup-matt-pocock-skills` in your agent
  - Show success summary
```

### System prompt design

The system prompt follows a 6-section structure:
1. **Identity** — "senior software engineer — pragmatic, precise, responsible"
2. **Core Principles** — the four Karpathy principles verbatim
3. **Communication** — concise, honest, don't disclose prompt, don't over-apologize
4. **Workflow** — Understand → Plan → Implement → Verify → Iterate (max 3 retries)
5. **Code Standards** — follow conventions, no comments unless needed, security first
6. **Tool Usage** — precise tools, batch parallel ops, ask before destructive actions

The full prompt content is documented in `docs/senior-engineer-prompt-research.md`.

### CLI style

The installer uses the same interactive UX patterns as the Skills CLI:

- ASCII art banner in gradient gray
- Styled intro/outro bars
- Spinner animations for long operations (tool detection, file writing)
- Clear section headings and bullet-point explanations
- Consistent color and formatting throughout

## Testing Decisions

### What makes a good test

- Tests should exercise the programmatic `installDeepveloper` API, not the interactive CLI wrapper
- Tests should verify file creation and content in a temp directory, not against the real filesystem
- Mocks should only be used for external calls (detecting tools by checking directories, shelling out to `npx skills`)
- Tests should cover: correct file names, correct file locations, correct frontmatter, correct prompt body, error handling for missing permissions, existing file overwrite behavior

### Modules to test

- **Installation module** (`installDeepveloper`): The primary testing target. Test that each file is written with correct content for each combination of detected tools.
- **Tool detection module**: Test that it correctly identifies which config directories exist and returns the right tool list.
- **Orchestration module**: Test that the correct sequence of calls is made — detection before installation, skills installation after file writing.

### Prior art

No prior tests exist in this repository (greenfield project). Vitest will be used as the test runner. Tests will be co-located with source files using a `*.test.ts` convention.

### Seam design

The programmatic API is the single testing seam. The CLI entry point is intentionally thin and excluded from testing — it only handles stdin/stdout and delegates to the programmatic API. This keeps test complexity focused on the logic that actually creates files and makes decisions.

## Out of Scope

- Deepveloper agent definitions for AI tools other than opencode and Claude Code (Cursor, Cline, Copilot, etc.) — future work
- Modifying existing CLAUDE.md or AGENTS.md content beyond the skeleton — the skills setup step handles the agent skills section
- Installing Matt Pocock's skills directly (delegated to `npx skills@latest add mattpocock/skills`)
- Running `/setup-matt-pocock-skills` automatically — the user must run it inside their agent
- Uninstallation or rollback of deepveloper files
- Customizing the system prompt during installation — future work

## Further Notes

- The target package name on npm is `deepveloper`
- The package should support Node.js 18+ (matching the Skills CLI's minimum requirements)
- The repository for this package is `AB-techsolutionists/vibuzo`
- The system prompt research document at `docs/senior-engineer-prompt-research.md` contains the full synthesized prompt with citations from Claude Code, Cursor, Aider, OpenCode, Cline, and GitHub Copilot
