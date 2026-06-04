# `/spec` Command — Implementation Plan

## Tech Stack

| Technology | Choice | Justification |
|------------|--------|---------------|
| **Markdown** | Content format | All commands, agent definitions, and specs are already plain `.md`. |
| **YAML Frontmatter** | Command metadata | Required by opencode for command definitions. The `/spec` command uses `agent: Vibuzo` (Vibuzo orchestrates the pipeline) and `subtask: true` so it runs as a guided workflow. |

No new languages, dependencies, or build steps.

## Architecture

### Before (Current)

```
User runs 5 separate commands:
  /spec "dark mode"       → spec.md
  /plan dark-mode         → plan.md
  /tasks dark-mode        → tasks.md
  /implement dark-mode    → Deepveloper executes
  /review dark-mode       → review.md

Manual handoff between each. User must remember the order.
```

### After (Target)

```
User runs 1 command:
  /spec "dark mode toggle"

Vibuzo walks through pipeline, pausing at each phase:
  Phase 1 ── Create spec.md ──────────────→ Approve? (y/N)
  Phase 2 ── Create plan.md ──────────────→ Approve? (y/N)
  Phase 3 ── Create tasks.md ─────────────→ Approve? (y/N)
  Phase 4 ── Delegate to Deepveloper ─────→ Approve between tasks
  Phase 5 ── Generate review.md ──────────→ Approve? (y/N)
  Done.
```

### Data Flow

1. User invokes `/spec <description>`
2. Vibuzo reads the description and derives feature name (kebab-case)
3. Creates `specs/<feature>/` directory
4. **Phase 1**: Generates spec.md (same logic as current `/spec`)
5. Presents phase gate: "Spec complete. Proceed? (y/N)"
6. If approved → **Phase 2**: Generates plan.md (same logic as current `/plan`)
7. Presents phase gate: "Plan complete. Proceed? (y/N)"
8. If approved → **Phase 3**: Generates tasks.md (same logic as current `/tasks`)
9. Presents phase gate: "Tasks complete. Proceed? (y/N)"
10. If approved → **Phase 4**: Spawns Deepveloper with task handoff
11. Deepveloper executes tasks, pausing between each
12. Reports back to Vibuzo when done
13. Presents phase gate: "Implementation complete. Proceed to review? (y/N)"
14. If approved → **Phase 5**: Generates review report, saves to review.md
15. Presents final gate: "Review saved. Done."
16. On any rejection, offers (r)etry, (s)kip, (a)bort

### Integration Points

| Integration | Affected Files | Nature of Change |
|-------------|---------------|------------------|
| **New command** | `commands/spec.md`, `.opencode/commands/spec.md` | Create new command file with pipeline instructions |
| **Deprecate old commands** | `commands/{spec,plan,tasks,implement,review}.md` + `.opencode/commands/{spec,plan,tasks,implement,review}.md` | Add DEPRECATED banner to each (10 files total) |
| **Architecture decision** | `context/architecture/spec-command.md` | New — capture the decision |
| **AGENTS.md** | `AGENTS.md` | Maybe — add note in Universal Project Rules if needed |

## Components

### New Components

| Component | File(s) | Responsibility |
|-----------|---------|---------------|
| **/spec command** | `commands/spec.md`, `.opencode/commands/spec.md` | Defines the 5-phase pipeline. Routes to `agent: Vibuzo` since Vibuzo orchestrates the phases. Each phase step references the same logic as the deprecated commands. |

### Deprecated Components

| Component | File(s) | Change |
|-----------|---------|--------|
| **/spec command** | `commands/spec.md`, `.opencode/commands/spec.md` | Add DEPRECATED banner, preserve content |
| **/plan command** | `commands/plan.md`, `.opencode/commands/plan.md` | Add DEPRECATED banner, preserve content |
| **/tasks command** | `commands/tasks.md`, `.opencode/commands/tasks.md` | Add DEPRECATED banner, preserve content |
| **/implement command** | `commands/implement.md`, `.opencode/commands/implement.md` | Add DEPRECATED banner, preserve content |
| **/review command** | `commands/review.md`, `.opencode/commands/review.md` | Add DEPRECATED banner, preserve content |

### New Components (Documentation)

| Component | File(s) | Responsibility |
|-----------|---------|---------------|
| **Architecture decision** | `context/architecture/spec-command.md` | Capture the decision, pipeline design, and deprecation rationale |

### Interfaces

```
User: /spec "dark mode toggle"

Vibuzo (/spec command):
  ├── Phase 1: spec.md  →  Gate: "Proceed?"
  ├── Phase 2: plan.md  →  Gate: "Proceed?"
  ├── Phase 3: tasks.md →  Gate: "Proceed?"
  ├── Phase 4: task() → Deepveloper
  │                      └── task 1 → Gate → task 2 → Gate → ...
  └── Phase 5: review.md → Gate: "Done"
```

Deprecated commands still function if invoked directly:
```
User: /spec "dark mode"   → works (DEPRECATED banner shown)
User: /plan dark-mode     → works (DEPRECATED banner shown)
```

## Implementation Order

### Phase 1 — Create /spec command

| Step | Task | Files | Risk |
|------|------|-------|------|
| 1 | **Create /spec command** | `commands/spec.md`, `.opencode/commands/spec.md` | Medium — must correctly sequence 5 phases and handle gates |

### Phase 2 — Deprecate old commands (parallel)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 2 | **Deprecate spec, plan, tasks** | `commands/{spec,plan,tasks}.md` + `.opencode/commands/{spec,plan,tasks}.md` | Low — just adding banners |
| 3 | **Deprecate implement, review** | `commands/{implement,review}.md` + `.opencode/commands/{implement,review}.md` | Low — just adding banners |

### Phase 3 — Documentation

| Step | Task | Files | Risk |
|------|------|-------|------|
| 4 | **Architecture decision** | `context/architecture/spec-command.md`, `context/index.md` | Low — new file + index update |

### Phase 4 — Verification

| Step | Task | Files | Risk |
|------|------|-------|------|
| 5 | **Final review** | All modified files | Low — read through and verify against acceptance criteria |

### Dependency Graph

```
Step 1 (create /spec) ──┐
                            ├──► Step 4 (arch decision) ──► Step 5 (review)
Step 2 (deprecate 3 cmd) ──┤
Step 3 (deprecate 2 cmd) ──┘
```

Step 1, 2, and 3 are fully parallel. Step 4 depends on all three. Step 5 depends on Step 4.

### Risk Factors

1. **/spec command must know the spec/plan/tasks format** — Solution: The command embeds the phase instructions inline, referencing the same logic that the deprecated commands used.
2. **Pipeline could be slow with all gates** — Solution: At approval_level 0, gates are skipped and pipeline runs uninterrupted. User controls the speed.
3. **Deepveloper must still receive precise handoff** — Solution: Phase 4 uses the existing handoff format, passing feature name and task list.
4. **Deprecated commands could still be used accidentally** — Solution: DEPRECATED banner is clearly visible at the top, and the banner explains the replacement.
