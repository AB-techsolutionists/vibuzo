---
tags:
  - architecture
  - spec
  - pipeline
  - phases
  - feature-development
scope: Feature development pipeline and the /spec command flow
when: Running or modifying the /spec command pipeline
---

# `/spec` Command — Architecture Decision

## Date
2026-06-04

## Context
The original spec framework required 5 separate commands (`/spec` → `/plan` → `/tasks` → `/implement` → `/review`) to develop a feature. Users had to remember the correct order and manually invoke each command. This created friction and context-switching overhead.

## Decision
Consolidate the 5-command spec framework into a single `/spec` command that runs the full pipeline (spec → plan → tasks → implement → review) sequentially, with phase gates for user approval at each step. The old commands have been removed.

## Architecture

### Pipeline Flow

```
User: /spec "dark mode toggle"

Vibuzo (orchestrates pipeline):
  Phase 1 ── spec.md  ────────── Gate: Proceed? ──┐
  Phase 2 ── plan.md  ────────── Gate: Proceed? ──┤
  Phase 3 ── tasks.md ────────── Gate: Proceed? ──┤
  Phase 4 ── Deepveloper (task)── Gate: Proceed? ──┤
  Phase 5 ── review.md ───────── Gate: Done ───────┘
```

### Phase Gates

Each phase ends with a standard gate prompt:

```
── PHASE GATE ─────────────────────────
Phase <N>: <name> complete.
Summary: <what was created>
───────────────────────────────────────
Proceed to next phase? (y/N):
```

On rejection: (r)etry phase, (s)kip to next, (a)bort entire pipeline.

### Feature Name Derivation

| Input | Feature Name | Spec Directory |
|-------|-------------|----------------|
| `/spec auth` | `auth` | `specs/auth/` |
| `/spec "dark mode toggle"` | `dark-mode-toggle` | `specs/dark-mode-toggle/` |
| `/spec "user auth"` | `user-auth` | `specs/user-auth/` |

### Integration with Approval Gates

The `/spec` command uses the hybrid approval model — native opencode permission popups for mechanical gates, custom chat gates for conceptual approval (plan/push). Each phase presents a gate prompt for user approval before proceeding.

### Deprecation

The original 5-command spec framework (`/plan`, `/tasks`, `/implement`, `/review`) has been fully consolidated into `/spec`. The individual command files have been removed. `/spec` is the single entry point for all feature development.

### File Structure

| File | Change |
|------|--------|
| `commands/spec.md` | 5-phase pipeline definition |
| `.opencode/commands/spec.md` | Mirror copy |

### Key Principles

1. **Single entry point** — One command replaces five. The pipeline is guided, not manual.
2. **Gate-driven progression** — Each phase completes before the next begins. User approves or redirects.
3. **Approval gate integration** — Uses the hybrid model: native popups for mechanical gates, custom chat for conceptual gates.
4. **Zero runtime deps** — All behavior is command instructions in Markdown/YAML. No code.
