# Commit Command — Implementation Plan

*Plan — 2026-06-07*

## Tech Stack

| Component | Technology | Justification |
|-----------|-----------|---------------|
| Command file | Markdown + YAML frontmatter | Standard Vibuzo command pattern — all 10 existing commands use this format |
| Execution | Vibuzo agent interprets steps | No new dependencies; commands are instruction files the agent reads and executes |
| Bump logic | Bash + PowerShell versioning rules | Versioning logic is simple arithmetic; agent handles the calculation inline using semver parse/split |
| Gates | Standard approval gates (level 3) | Already supported by Vibuzo agent rules — no new gate infrastructure needed |
| Commit | `git add` + `git commit` via bash | Standard git CLI, no libraries |
| Box rendering | Existing `Write-Box`/`print_box` from installers | But the command runs in the agent context (terminal output), not inside installer scripts. Agent uses its own box drawing |

## Architecture

### Component Diagram

```
User runs /commit [description]
        │
        ▼
  ┌─────────────────┐
  │  commands/       │  ← YAML frontmatter: agent reads instructions
  │  commit.md       │     steps: interpret → execute
  └────────┬────────┘
           │
           ▼
  ┌─────────────────────────────────────────┐
  │          Vibuzo Agent                    │
  │                                          │
  │  ┌──────────┐  ┌──────────┐  ┌───────┐  │
  │  │ Step 1   │→│ Step 2   │→│ ...   │  │
  │  │ Parse    │  │ Gate     │  │       │  │
  │  │ args     │  │ approve  │  │       │  │
  │  └──────────┘  └──────────┘  └───────┘  │
  └─────────────────────────────────────────┘
           │
           ▼
  ┌─────────────────────────────────────────┐
  │  File mutations (via agent tools)       │
  │  - Read VERSION                          │
  │  - Write VERSION                         │
  │  - Edit versioning.md                    │
  │  - git add / git commit (bash)           │
  └─────────────────────────────────────────┘
```

### Data Flow

1. **Input**: User runs `/commit` or `/commit "description of changes"`
2. **Read**: Agent reads `VERSION` (current semver), `context/standards/versioning.md` (current entry)
3. **Gate 1**: Agent asks user for bump type (patch/minor/custom) → shows proposed new version
4. **Write**: Agent updates `VERSION` file → prepends entry to `versioning.md`
5. **Gate 2**: Agent constructs commit message → shows to user for approval
6. **Commit**: Agent runs `git add VERSION context/standards/versioning.md` → `git commit`
7. **Report**: Agent shows commit hash, changed files, new version, push instructions — no push

### Integration Points

- **VERSION file** at repo root — read + write
- **versioning.md** at `context/standards/versioning.md` — prepend entry to "Current Version" section
- **Git CLI** — `git add`, `git commit` (no `git push`)
- **Approval gates** — standard Vibuzo gate format printed as code blocks

## Components

| # | Component | Responsibility | Interface |
|---|-----------|---------------|-----------|
| 1 | `commands/commit.md` | Command file — defines the step-by-step instructions for the agent | YAML frontmatter + markdown steps |
| 2 | Bump calculator (inline in command steps) | Parse VERSION, apply bump rules, return new version | Semver arithmetic (integer parse + increment + rollover) |
| 3 | Release notes updater (inline) | Prepend a new bullet entry to versioning.md "Current Version" section | Edit tool: insert line after section header |
| 4 | Commit message builder (inline) | Combine bump type + user description into conventional commit format | String construction |
| 5 | Report renderer (inline) | Show final commit report box with hash, files, version, push instruction | Printed as text (not box function — this is agent output, not installer) |

## Implementation Order

| Step | Task | Depends On | Risk |
|------|------|-----------|------|
| 1 | Create `commands/commit.md` with full step-by-step instructions | None | Low — well-defined command pattern |
| 2 | Implement bump calculator step: parse VERSION → compute bump → gate | Task 1 | Low — simple arithmetic |
| 3 | Implement VERSION write step | Task 2 | Low — single-line write |
| 4 | Implement versioning.md prepend step | Task 2 | Medium — needs to find the right insertion point in the markdown |
| 5 | Implement commit message builder + gate + git commit | Task 3, 4 | Low — git commands are standard |
| 6 | Implement report box display | Task 5 | Low — text rendering only |

## Risk Factors

- **versioning.md insertion point**: The "Current Version" section has a specific format with `**0.x.x** — description` bullet entries. The insertion must match existing formatting. Low risk if using exact text matching to find the section header line.
- **No push enforcement**: Simple — just don't include any `git push` step. The instruction set deliberately omits it.
- **Gate integration**: Vibuzo already supports approval gates at level 3. The command file includes step instructions to present gates — the agent handles the mechanics.
