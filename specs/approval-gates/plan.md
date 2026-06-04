# Approval Gates — Implementation Plan

## Tech Stack

| Technology | Choice | Justification |
|------------|--------|---------------|
| **Markdown** | Content format | All agent definitions, commands, and docs are already plain `.md`. Zero dependencies, zero build step. |
| **YAML Frontmatter** | Gate level config | The `approval_level` setting is added to Vibuzo's existing YAML frontmatter. No new config files needed. |
| **Agent behavioral rules** | Gate logic | All gate behavior is encoded as natural-language rules in agent definitions. The LLM interprets and enforces them. No runtime code. |

The entire change is text-based configuration. No new languages, frameworks, or dependencies.

## Architecture

### Before (Current)

```
User → Vibuzo (executes freely after plan approval)
         │
         └──→ Deepveloper (executes freely as subtask)
```

Vibuzo's only approval checkpoint is the "Plan first" rule (restate, surface tradeoffs, get approval). No formal gate system exists — once the plan is approved, all execution proceeds without further checkpoints.

### After (Target)

```
User → Vibuzo (approval_level: 0-3)
         │
         ├──→ Gate check: "Approve? (y/N)" before each action
         │      (level determines which actions are gated)
         │
         └──→ Deepveloper (inherits same level)
                  │
                  └──→ Gate check: "Proceed to next task? (y/N)"
```

Each gate check pauses execution, presents the proposed action in a standard format, and waits for user input before proceeding.

### Data Flow

1. User configures `approval_level` in Vibuzo's YAML frontmatter (or overrides inline)
2. Before any gated action, Vibuzo checks the level:
   - If level ≥ threshold → present approval prompt and wait for y/N
   - If level < threshold → execute freely
3. When delegating to Deepveloper, Vibuzo includes the gate level in the handoff
4. Deepveloper checks the same level before gated actions during execution
5. Between tasks, Deepveloper pauses and asks to proceed
6. On rejection ("N"), the agent offers modify / skip / abort

### Integration Points

| Integration | Affected Files | Nature of Change |
|-------------|---------------|------------------|
| **Vibuzo agent** | `agents/vibuzo.md`, `.opencode/agent/core/vibuzo.md` | Add `approval_level` to YAML frontmatter + approval gate rules section + standard prompt format |
| **Deepveloper agent** | `agents/deepveloper.md`, `.opencode/agent/core/deepveloper.md` | Add approval gate rules for subtask execution + between-task gating |
| **Project rules** | `AGENTS.md` | Add Approval Gates section to Universal Project Rules |
| **Architecture decision** | `context/architecture/approval-gates.md` | New — capture the architectural decision |

## Components

### Modified Components

| Component | File(s) | Change |
|-----------|---------|--------|
| **Vibuzo agent** | `agents/vibuzo.md`, `.opencode/agent/core/vibuzo.md` | Add `approval_level: 0` to YAML frontmatter. Add new section "## Approval Gates" with level table, standard prompt format, rejection handling, and inline override rules. Update "When to Execute vs. Delegate" to note gate level. |
| **Deepveloper agent** | `agents/deepveloper.md`, `.opencode/agent/core/deepveloper.md` | Add new section "## Approval Gates" with between-task gating, destructive action gating, and the rule that gates are inherited from Vibuzo's handoff. |
| **AGENTS.md** | `AGENTS.md` | Add "### Approval Gates" subsection under Universal Project Rules explaining the gate system. |

### New Components

| Component | File(s) | Responsibility |
|-----------|---------|---------------|
| **Architecture decision record** | `context/architecture/approval-gates.md` | Capture the decision, level definitions, and design rationale for future sessions. |

### Interfaces

```
User ←→ Vibuzo (with approval gates at configured level)
         │
         ├──→ Approval prompt (standard format, y/N)
         │      ── APPROVAL GATE ────────────
         │      Action: write/edit/delete/command/delegate
         │      Target: <path or command>
         │      Details: <summary>
         │      ─────────────────────────────
         │      Approve? (y/N):
         │
         ├──→ On "y" → proceed with action
         ├──→ On "N" → offer modify / skip / abort
         └──→ Inline override: "at gate level 0" → temporary level change
```

```
Vibuzo → Deepveloper (handoff includes approval_level)
         │
         ├──→ Before each task: "Task N complete. Proceed to Task N+1? (y/N)"
         └──→ Before destructive ops: standard approval prompt
```

## Implementation Order

### Phase 1 — Agent Rules (parallel)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 1 | **Add approval gates to Vibuzo** | `agents/vibuzo.md`, `.opencode/agent/core/vibuzo.md` | Medium — must integrate gates without breaking existing rules |
| 2 | **Add approval gates to Deepveloper** | `agents/deepveloper.md`, `.opencode/agent/core/deepveloper.md` | Low — additive rules, no existing behavior changed |

### Phase 2 — Documentation (depends on Phase 1)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 3 | **Update AGENTS.md** | `AGENTS.md` | Low — additive section in Universal Project Rules |
| 4 | **Create architecture decision** | `context/architecture/approval-gates.md` | Low — new file, no risk |

### Phase 3 — Verification

| Step | Task | Files | Risk |
|------|------|-------|------|
| 5 | **Final review** | All modified files | Low — read through and verify against acceptance criteria |

### Risk Factors

1. **Gate rules could make Vibuzo overly cautious at all levels** — Solution: Rules must clearly state "at level 0, skip all gates." Level 0 behavior must match current behavior exactly.
2. **Inline override could be forgotten mid-session** — Solution: Rule states "inline override lasts for one interaction only, then resets to configured level."
3. **Deepveloper could ignore gates during fast execution** — Solution: Gate rules are Deepveloper's first listed rule in its new section. Temperature 0 ensures strict adherence.
4. **Users may not know about the feature** — Solution: AGENTS.md documentation and architecture decision record make it discoverable.

### Dependency Graph

```
Step 1 (Vibuzo gates) ──┐
                         ├──► Step 3 (AGENTS.md) ──► Step 5 (Review)
Step 2 (Deepveloper)  ──┘
                         └──► Step 4 (arch decision)
```

Steps 1 and 2 are fully parallel. Steps 3 and 4 depend on both. Step 5 depends on 3 and 4.
