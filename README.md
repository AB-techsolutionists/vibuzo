<p align="center">
  <pre>
  ____                     _                  _
 |  _ \  ___  ___ ___  __| | ___ _ __ ___   | |_   ___  _ __
 | | | |/ _ \/ __/ _ \/ _` |/ _ \ '__/ _ \  | | | / _ \| '_ \
 | |_| |  __/ (_|  __/ (_| |  __/ | | (_) | | | |_| (_) | |_) |
 |____/ \___|\___\___|\__,_|\___|_|  \___/  |_|\__,_\___/| .__/
                                                           |_|
  </pre>
</p>

# Deepveloper

[![npm version](https://img.shields.io/npm/v/deepveloper)](https://www.npmjs.com/package/deepveloper)
[![Node.js](https://img.shields.io/badge/node-%3E%3D18-brightgreen)](https://nodejs.org)

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
> Run `npx deepveloper --yes` to skip all confirmation prompts.

## What It Creates

| Tool | Agent file | Project file |
|---|---|---|
| **opencode** | `.opencode/agent/deepveloper.md` (YAML frontmatter + prompt) | `AGENTS.md` |
| **Claude Code** | `.claude/deepveloper.md` (raw prompt body) | `CLAUDE.md` |
| **Both** | Files for both tools | Both project files |

It also runs `npx skills@latest add mattpocock/skills` to install skills like code-review, TDD, domain-modeling, and grilling.

## Why Deepveloper Exists

Setting up an AI coding agent with proper engineering practices currently means wiring together multiple configuration files, understanding different agent definition formats, and running separate installation commands. Deepveloper replaces that with a single, interactive command.

### Embeds engineering discipline from day one

The system prompt is not a generic "you are an expert" — it's a carefully designed prompt based on [Karpathy's four principles](https://x.com/karpathy) (Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution) combined with a senior software engineer persona. It covers identity, core principles, communication, workflow, code standards, and tool usage.

### Detects your tools automatically

Works with opencode and Claude Code. Only configures what you actually use. Run once per repo.

## System Prompt Structure

```
Identity         → Senior software engineer — pragmatic, precise, responsible
Core Principles  → Karpathy's four principles verbatim
Communication    → Concise, honest, don't over-apologize
Workflow         → Understand → Plan → Implement → Verify → Iterate
Code Standards   → Follow conventions, no comments unless needed, security first
Tool Usage       → Precise tools, batch parallel ops, ask before destructive actions
```

## CLI Reference

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
npm install       # Install dependencies
npm run build     # Build TypeScript
npm test          # Run tests
npm run test:watch  # Watch mode
```

### Project structure

```
├── src/
│   ├── cli.ts           CLI entry point
│   ├── detect.ts        Tool detection
│   ├── install.ts       Installation orchestration
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

Requires Node.js 18+.

## Prior Art

The system prompt draws on research across Claude Code, Cursor, Aider, OpenCode, Cline, and GitHub Copilot — documented in `docs/senior-engineer-prompt-research.md`.
