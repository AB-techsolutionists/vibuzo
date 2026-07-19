<p align="center">
  <pre>
██████╗ ███████╗███████╗██████╗ ██╗   ██╗███████╗██╗      ██████╗ ██████╗ ███████╗██████╗
██╔══██╗██╔════╝██╔════╝██╔══██╗██║   ██║██╔════╝██║     ██╔═══██╗██╔══██╗██╔════╝██╔══██╗
██║  ██║█████╗  █████╗  ██████╔╝██║   ██║█████╗  ██║     ██║   ██║██████╔╝█████╗  ██████╔╝
██║  ██║██╔══╝  ██╔══╝  ██╔═══╝ ╚██╗ ██╔╝██╔══╝  ██║     ██║   ██║██╔═══╝ ██╔══╝  ██╔══██╗
██████╔╝███████╗███████╗██║      ╚████╔╝ ███████╗███████╗╚██████╔╝██║     ███████╗██║  ██║
╚═════╝ ╚══════╝╚══════╝╚═╝       ╚═══╝  ╚══════╝╚══════╝ ╚═════╝ ╚═╝     ╚══════╝╚═╝  ╚═╝
  </pre>
</p>

# Deepveloper

![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen)
![TypeScript](https://img.shields.io/badge/typescript-5.8-blue)
[![License: MIT](https://img.shields.io/badge/license-MIT-yellow)](LICENSE)

Interactive CLI for installing the Deepveloper senior engineer AI agent into your repo — with a Karpathy-principled system prompt and Matt Pocock's engineering skills.

---

## Quickstart (30-second setup)

```bash
npx deepveloper
```

The CLI will:
1. Display the banner and explain what it will do
2. Detect which AI coding tools you have installed (opencode, Claude Code)
3. Show which files will be created and which skills will be installed
4. Prompt you to confirm before making changes
5. Write agent definition files and project context files
6. Install Matt Pocock's engineering skills
7. Guide you to run `/setup-matt-pocock-skills` in your agent

> [!TIP]
> Run `npx deepveloper --yes` to skip all confirmation prompts and accept defaults.

## What Gets Created

| If you use… | Agent file | Project file |
|---|---|---|
| **opencode** | `.opencode/agent/deepveloper.md` — YAML frontmatter + full prompt | `AGENTS.md` — skeleton |
| **Claude Code** | `.claude/deepveloper.md` — raw prompt body | `CLAUDE.md` — skeleton |
| **Both** | Both agent files | Both project files |

The CLI also runs `npx skills@latest add mattpocock/skills` to install engineering skills (code-review, TDD, domain-modeling, grilling, and more).

## Why Deepveloper Exists

Setting up an AI coding agent with proper engineering practices is a manual, fragmented process — write config files for each tool, understand different agent definition formats, install skills separately. Deepveloper replaces all of that with one command.

### System prompt you'd trust

The agent prompt isn't a generic "you are an expert." It's a 6-section prompt combining [Karpathy's four principles](https://x.com/karpathy) (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) with a senior software engineer persona:

| Section | Purpose |
|---|---|
| **Identity** | Senior software engineer — pragmatic, precise, responsible |
| **Core Principles** | Karpathy's principles verbatim |
| **Communication** | Concise, honest, no over-apologizing |
| **Workflow** | Understand → Plan → Implement → Verify → Iterate (max 3 retries) |
| **Code Standards** | Conventions over comments, security first |
| **Tool Usage** | Precise tools, batch parallel ops, ask before destructive actions |

### No config sprawl

Instead of managing separate configs for opencode and Claude Code, Deepveloper detects what you have and writes the right files for each — with the same prompt, same persona, same principles across all your tools.

### Engineering skills included

Matt Pocock's skills (code-review, TDD, domain-modeling, grilling, and more) are installed automatically. After installation, run `/setup-matt-pocock-skills` in your agent to configure your issue tracker, triage labels, and domain docs.

## CLI Reference

```
deepveloper — Install the Deepveloper senior engineer AI agent

USAGE
  npx deepveloper         Run the interactive installer
  npx deepveloper --help  Show this help
  npx deepveloper --yes   Skip confirmation prompts

FLAGS
  --yes, -y   Skip all confirmation prompts and auto-overwrite
  --help, -h  Show this help message
  --version   Show the version number
```

## Development

```bash
npm install       # Install dependencies
npm run build     # Build TypeScript
npm test          # Run tests (42 tests, 5 files)
```

### Project structure

```
src/
├── cli.ts        Entry point — arguments, prompts, orchestration
├── detect.ts     Tool detection (opencode, Claude Code)
├── install.ts    File writing, skills installation
├── prompt.ts     6-section system prompt template
├── types.ts      Shared types
└── utils/
    └── fs.ts     writeFileSafe, ensureDir
tests/
├── cli.test.ts
├── detect.test.ts
├── install.test.ts
├── prompt.test.ts
└── utils/
    └── fs.test.ts
docs/
├── deepveloper-spec.md
└── senior-engineer-prompt-research.md
```

Requires Node.js 18+.

## Prior Art

The system prompt draws on research across Claude Code, Cursor, Aider, OpenCode, Cline, and GitHub Copilot — documented in `docs/senior-engineer-prompt-research.md`.
