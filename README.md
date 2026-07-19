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

## Quickstart

```bash
npx deepveloper
```

> [!TIP]
> Run `npx deepveloper --yes` to skip all confirmation prompts.

## What It Creates

| When you use… | Agent file | Project file |
|---|---|---|
| **opencode** | `.opencode/agent/deepveloper.md` (YAML frontmatter + prompt) | `AGENTS.md` |
| **Claude Code** | `.claude/deepveloper.md` (raw prompt body) | `CLAUDE.md` |
| **Both** | Files for both | Both project files |

The CLI also runs `npx skills@latest add mattpocock/skills` to install engineering skills like code-review, TDD, domain-modeling, and grilling.

## Why It Exists

Setting up an AI coding agent with proper engineering practices means wiring together multiple configuration files and running separate installation commands. Deepveloper replaces that with a single command.

The system prompt is a carefully designed prompt based on [Karpathy's four principles](https://x.com/karpathy) — Think Before Coding, Simplicity First, Surgical Changes, Goal-Driven Execution — combined with a senior software engineer persona.

## System Prompt

| Section | Purpose |
|---|---|
| **Identity** | Senior software engineer — pragmatic, precise, responsible |
| **Core Principles** | Karpathy's four principles |
| **Communication** | Concise, honest, don't over-apologize |
| **Workflow** | Understand → Plan → Implement → Verify → Iterate |
| **Code Standards** | Follow conventions, security first |
| **Tool Usage** | Precise tools, batch parallel ops |

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
npm install       # Install dependencies
npm run build     # Build TypeScript
npm test          # Run tests
```

**Structure:**

```
src/          cli, detect, install, prompt, types, utils/
tests/        cli, detect, install, prompt, utils/
docs/         deepveloper-spec.md, senior-engineer-prompt-research.md
```

Requires Node.js 18+.
