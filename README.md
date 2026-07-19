```
  ____                     _                  _
 |  _ \  ___  ___ ___  __| | ___ _ __ ___   | |_   ___  _ __
 | | | |/ _ \/ __/ _ \/ _` |/ _ \ '__/ _ \  | | | / _ \| '_ \
 | |_| |  __/ (_|  __/ (_| |  __/ | | (_) | | | |_| (_) | |_) |
 |____/ \___|\___\___|\__,_|\___|_|  \___/  |_|\__,_\___/| .__/
                                                           |_|
```

# Deepveloper

[![npm version](https://img.shields.io/npm/v/deepveloper)](https://www.npmjs.com/package/deepveloper)
[![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org)

**Interactive CLI for installing the Deepveloper senior engineer AI agent into your repo.**

Deepveloper detects which AI coding tools you have installed (opencode, Claude Code), writes agent definition files with a senior engineer system prompt based on [Karpathy's principles](https://x.com/karpathy), and installs [Matt Pocock's engineering skills](https://github.com/mattpocock/skills) — all from a single command.

---

## Quickstart

```bash
npx deepveloper
```

The CLI will:
1. Display an ASCII art banner and explain what it will do
2. Detect your installed AI coding agents
3. Show you which files will be created
4. Prompt you to confirm before making changes
5. Write agent definition files and project context files
6. Install Matt Pocock's engineering skills
7. Guide you to run `/setup-matt-pocock-skills` in your agent

To skip prompts:

```bash
npx deepveloper --yes
```

## What It Does

Deepveloper configures a **senior engineer AI agent** with proper guardrails — Karpathy's four principles (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) — combined with a pragmatic senior software engineer persona.

**For opencode users:**
- Creates `.opencode/agent/deepveloper.md` with YAML frontmatter and the full system prompt
- Creates `AGENTS.md` with a project context skeleton

**For Claude Code users:**
- Creates `.claude/deepveloper.md` with the system prompt
- Creates `CLAUDE.md` with a project context skeleton

**For everyone:**
- Installs Matt Pocock's engineering skills (code-review, TDD, domain-modeling, grilling, and more) via `npx skills@latest add mattpocock/skills`
- Guides you to run `/setup-matt-pocock-skills` to configure the issue tracker, triage labels, and domain docs

## Why Deepveloper Exists

Setting up an AI coding agent with proper engineering practices requires wiring together multiple configuration files, understanding different agent definition formats, and running separate installation commands. There is no unified, guided experience.

Deepveloper solves this by providing a single, interactive command that:

### Eliminates the setup tax

Instead of reading docs for opencode, Claude Code, and Matt Pocock's skills individually, you run one command and get everything configured.

### Embeds engineering discipline

The system prompt is not a generic "you are an expert" — it's a carefully designed prompt based on Karpathy's principles and years of engineering experience. It covers identity, core principles, communication, workflow, code standards, and tool usage.

### Works with your tools

Detects which AI coding agents you actually use and only configures those. Run once per repo.

## System Prompt Design

The agent prompt follows a 6-section structure:

| Section | Purpose |
|---|---|
| **Identity** | "Senior software engineer — pragmatic, precise, responsible" |
| **Core Principles** | The four Karpathy principles verbatim |
| **Communication** | Concise, honest, don't over-apologize |
| **Workflow** | Understand → Plan → Implement → Verify → Iterate |
| **Code Standards** | Follow conventions, no comments unless needed, security first |
| **Tool Usage** | Precise tools, batch parallel ops, ask before destructive actions |

## CLI

```
deepveloper — Install the Deepveloper senior engineer AI agent

USAGE
  npx deepveloper         Run the interactive installer
  npx deepveloper --help  Show this help
  npx deepveloper --yes   Skip confirmation prompts

FLAGS
  --yes, -y   Skip all confirmation prompts
  --help, -h  Show this help message
  --version   Show the version number
```

## Development

```bash
# Install dependencies
npm install

# Build TypeScript
npm run build

# Run tests
npm test

# Watch mode
npm run test:watch
```

### Project structure

```
├── src/
│   ├── cli.ts           CLI entry point
│   ├── detect.ts        Tool detection module
│   ├── install.ts       Installation module
│   ├── prompt.ts        System prompt template
│   ├── types.ts         Shared types
│   └── utils/
│       └── fs.ts        File system utilities
├── tests/
│   ├── cli.test.ts
│   ├── detect.test.ts
│   ├── install.test.ts
│   ├── prompt.test.ts
│   └── utils/
│       └── fs.test.ts
├── docs/
│   ├── deepveloper-spec.md
│   └── senior-engineer-prompt-research.md
├── package.json
├── tsconfig.json
└── vitest.config.ts
```

### Requirements

- Node.js 18+

## Prior Art

The system prompt draws on research across Claude Code, Cursor, Aider, OpenCode, Cline, and GitHub Copilot — documented in `docs/senior-engineer-prompt-research.md`.

This project is built as an npm package and published as `deepveloper`.
