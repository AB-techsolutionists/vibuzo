# `/spec` Command — Specification

## Principles

- **Single entry point for features** — One command replaces five. The entire spec-driven workflow (spec → plan → tasks → implement → review) is launched from a single `/spec` command with a user-provided description.
- **Guided pipeline with gates** — Each phase completes before the next begins. The user approves each phase before proceeding, compatible with the approval gates system (level 0-3).
- **Backward compatibility** — The old commands (`/spec`, `/plan`, `/tasks`, `/implement`, `/review`) are deprecated, not deleted. Existing references and scripts continue to work.
- **Zero new dependencies** — The command is pure Markdown + YAML frontmatter. No runtime code. The pipeline is driven by Vibuzo's behavioral rules at each phase.

## Specification

### Overview

Replace the five-command spec framework (`/spec` → `/plan` → `/tasks` → `/implement` → `/review`) with a single `/spec` command. The user provides a feature description, and Vibuzo walks through each phase sequentially — creating the spec, plan, tasks, delegating implementation to Deepveloper, and saving a final review report. Each phase pauses for user approval before proceeding, giving full control at the configured gate level.

### User Stories

1. As a user starting a new feature, I want to run one command with a description and have Vibuzo handle the entire pipeline, so I don't need to remember and type 5 separate commands.
2. As a user who wants control, I want to approve each phase before Vibuzo proceeds, so I can catch issues early or redirect the approach.
3. As a user who skips straight to a specific phase in rare cases, I want the old commands to still work (deprecated), so I'm not blocked if I need them.

### Functional Requirements

1. **Single command** — `/spec <description>` shall be the only command needed to run the full spec-driven workflow.
2. **Pipeline phases** — The command shall execute these phases in order:
   - **Phase 1 — Spec**: Create `specs/<feature>/spec.md`
   - **Phase 2 — Plan**: Create `specs/<feature>/plan.md`
   - **Phase 3 — Tasks**: Create `specs/<feature>/tasks.md`
   - **Phase 4 — Implement**: Delegate to Deepveloper (reads tasks.md, executes in order)
   - **Phase 5 — Review**: Generate and save `specs/<feature>/review.md`
3. **Phase gating** — After each phase completes, Vibuzo shall present a summary and ask for approval before proceeding to the next phase. The prompt format:
   ```
   ── PHASE GATE ─────────────────────────
   Phase <N>: <name> complete.
   Summary: <what was created / changed>
   ───────────────────────────────────────
   Proceed to next phase? (y/N):
   ```
4. **Rejection handling** — If the user says "N" at a phase gate, Vibuzo shall offer options: (r)etry the phase, (s)kip to next, or (a)bort the entire feature pipeline.
5. **Feature name extraction** — The first argument to `/spec` shall be used as the feature directory name (under `specs/`). If multi-word, use kebab-case (e.g., `/spec "dark mode toggle"` → `specs/dark-mode-toggle/`).
6. **/implement delegation** — Phase 4 shall delegate to Deepveloper using the same handoff format as the current `/implement` command. Deepveloper executes tasks from `tasks.md` in dependency order, with between-task gating.
7. **Review auto-save** — Phase 5 shall generate a review report and save it to `specs/<feature>/review.md` without requiring a separate command.
8. **Respect approval gates** — The `/spec` command's phase gating shall integrate with Vibuzo's `approval_level` setting. At level 0, phase gates are skipped (auto-proceed). At level ≥ 1, each phase requires approval.

### Deprecation of Old Commands

- `/spec`, `/plan`, `/tasks`, `/implement`, `/review` — deprecated but preserved
- Each deprecated command file shall have a DEPRECATED banner at the top: "⚠️ DEPRECATED — Use `/spec <description>` instead. This file is kept for reference."
- Full original content preserved below the banner
- Both `commands/` and `.opencode/commands/` copies shall receive identical banners
- The deprecated commands shall continue to work if invoked directly (no functional removal)

### Acceptance Criteria

- ✅ `/spec <description>` creates `specs/<feature>/spec.md`, `plan.md`, `tasks.md`, `review.md` in sequence
- ✅ `/spec <description>` delegates Phase 4 to Deepveloper, which executes all tasks
- ✅ After each phase, Vibuzo pauses and asks for approval before proceeding (at level ≥ 1)
- ✅ Rejection at a phase gate offers (r)etry, (s)kip, or (a)bort
- ✅ Multi-word descriptions are converted to kebab-case for directory naming
- ✅ Feature name is derived from the first argument (e.g., `/spec auth` → `specs/auth/`)
- ✅ Review report is automatically saved to `specs/<feature>/review.md`
- ✅ `/spec`, `/plan`, `/tasks`, `/implement`, `/review` files display DEPRECATED banners (both `commands/` and `.opencode/commands/` copies)
- ✅ All deprecated command files preserve their original content below the banner
- ✅ At `approval_level: 0`, phase gates are skipped and the pipeline runs uninterrupted
- ✅ `/context`, `/session`, `/add-context` remain completely unchanged

### Out of Scope

- Modifying the context system (`/context`, `/session`, `/add-context`)
- Adding runtime code or dependencies
- Removing or deleting old command files
- Changing the approval gates system
- Interactive editing of spec content mid-pipeline (rejection → retry re-runs the phase)
