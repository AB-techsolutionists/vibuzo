---
feature: new-release-command
created: 2026-06-07
---

# /new-release Command — Implementation Plan

## Tech Stack

- **Command format**: Markdown with YAML frontmatter (same as all existing commands)
- **Execution agent**: Vibuzo (main agent) — reads the command file and executes steps directly
- **Version source**: `VERSION` file at repo root

No new languages, dependencies, or tooling. Pure agent-instruction file.

## Architecture

```
commands/new-release.md          ← New command file (agent reads & executes)
├── YAML frontmatter             ← description, agent fields
├── Do these steps NOW:          ← Imperative instruction block
│   1. Read VERSION
│   2. Calculate new version (patch auto-increment with rollover)
│   3. Approval gate
│   4. Write VERSION
│   5. Report box
└── 

commands/commit.md               ← Modified: remove steps 1-6 (bump logic)
├── Starts at step 1: release notes prompt
├── Continues through git commit
└── 

SYNC:
  .opencode/commands/new-release.md  ← Mirrors commands/new-release.md
  .opencode/commands/commit.md       ← Mirrors updated commands/commit.md
```

## Components

| Component | File | Responsibility |
|-----------|------|---------------|
| New command file | `commands/new-release.md` | Contains all steps for auto version bump |
| Modified command | `commands/commit.md` | Stripped of bump logic, retains release→commit flow |
| Sync target | `.opencode/commands/new-release.md` | Installer-managed copy |
| Sync target | `.opencode/commands/commit.md` | Installer-managed copy of updated file |
| README update | `README.md` | Add `/new-release` to commands table, update count |
| AGENTS.md update | `AGENTS.md` | Update command count if referenced |

## Implementation Order

### Phase 1: Create `/new-release` command (no deps)
1. Write `commands/new-release.md` with full bump logic
2. Sync to `.opencode/commands/new-release.md`

### Phase 2: Simplify `/commit` (depends on Phase 1)
3. Edit `commands/commit.md` — remove steps 1–6
4. Update step numbering (old 7→14 becomes new 1→8)
5. Update `/commit` description and approval gate targets
6. Sync to `.opencode/commands/commit.md`

### Phase 3: Update references (depends on Phase 2)
7. Add `/new-release` to `README.md` commands table
8. Update command count: "11 command files" → "12 command files" in `AGENTS.md` and `README.md`

## Risk Factors

| Risk | Likelihood | Mitigation |
|------|-----------|------------|
| Removing bump logic from `/commit` breaks it | Low | Keep the spec as reference; test by reading the file after edit |
| Command count references missed | Medium | Grep for "11 command" across the repo |
| `.opencode/` sync missed | Low | Explicit step in tasks |
