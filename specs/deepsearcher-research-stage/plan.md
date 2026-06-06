# Deepsearcher Research Stage — Implementation Plan

## Tech Stack

| Technology | Choice | Justification |
|------------|--------|---------------|
| **Markdown** | Content format | All agents, commands, and specs are already plain `.md` files. No runtime code needed. |
| **YAML Frontmatter** | Agent/command metadata | Required by opencode for both agent definitions and command files. |
| **Websearch/Webfetch tools** | Research tools | Already available as opencode built-in tools (`websearch`, `webfetch`). Deepsearcher uses these directly. |

No new languages, dependencies, build steps, or external services.

## Architecture

### Current Pipeline (Before)

```
User: /spec "feature description"

Vibuzo:
  Phase 1 ── Create spec.md ──────────→ Gate
  Phase 2 ── Create plan.md ──────────→ Gate
  Phase 3 ── Create tasks.md ─────────→ Gate
  Phase 4 ── Delegate to Deepveloper ─→ Gate
  Phase 5 ── Generate review.md ──────→ Gate
  Done.
```

### Target Pipeline (After)

```
User: /spec "feature description"

Vibuzo:
  Phase 0 [OPTIONAL] ── Research?
    │                   ├── No ──→ skip to Phase 1
    │                   └── Yes ──→ Spawn Deepsearcher subtask
    │                                └── Deepsearcher uses websearch/webfetch
    │                                └── Saves specs/<feature>/research.md
    │                                └── Reports back ──→ Gate
    │
  Phase 1 ── Read research.md (if exists) ──→ Create spec.md ──→ Gate
  Phase 2 ── Create plan.md ──────────────────────────────────→ Gate
  Phase 3 ── Create tasks.md ─────────────────────────────────→ Gate
  Phase 4 ── Delegate to Deepveloper ─────────────────────────→ Gate
  Phase 5 ── Generate review.md ──────────────────────────────→ Gate
  Done.
```

### Data Flow

1. User invokes `/spec <description>`
2. Vibuzo derives feature name (kebab-case), creates `specs/<feature>/`
3. **Phase 0 (Research)** — Vibuzo asks "Research this feature? (y/N)"
   - If **No**: Skip to Phase 1
   - If **Yes**: Spawn Deepsearcher via `task()` with subagent_type "Deepsearcher"
     - Deepsearcher receives the feature description as query
     - Uses `websearch` + `webfetch` to gather relevant info
     - Saves structured output to `specs/<feature>/research.md`
     - Reports back to Vibuzo with status
     - Phase gate: "Research complete. Proceed to Phase 1?"
4. **Phase 1 (Spec)** — Vibuzo reads `research.md` if it exists, incorporates findings into spec
5. Phases 2-5 proceed exactly as today

### Standalone `/research` Flow

```
User: /research "topic"

Deepsearcher:
  └── Infers feature name from query (kebab-case)
  └── Creates specs/<feature>/research.md
  └── Uses websearch + webfetch to gather info
  └── Writes structured output to file
  └── Reports back with summary
```

### Inline `@deepsearcher` Flow

```
User: @deepsearcher "query"

Session:
  └── Spawns Deepsearcher inline
  └── Deepsearcher uses websearch + webfetch
  └── Returns results inline in conversation
  └── Offers to save results to file (optional)
```

### Integration Points

| Integration | Affected Files | Nature of Change |
|-------------|---------------|------------------|
| **New agent** | `.opencode/agent/core/deepsearcher.md` | Create new subagent definition |
| **New command** | `commands/research.md`, `.opencode/commands/research.md` | Create new command file pair |
| **Update /spec command** | `commands/spec.md`, `.opencode/commands/spec.md` | Add Phase 0 (Research) with skip logic |
| **Architecture decision** | `context/architecture/deepsearcher-research-stage.md` | New — capture the decision |
| **Context index** | `context/index.md` | Add reference to new ADR |
| **AGENTS.md** | `AGENTS.md` | Add Deepsearcher to the Two-Agent System table (making it three agents) |

## Components

### New Components

| Component | File(s) | Responsibility |
|-----------|---------|---------------|
| **Deepsearcher agent** | `.opencode/agent/core/deepsearcher.md` | Subagent definition — uses `websearch`/`webfetch` tools for web research. Follows same pattern as Deepveloper (mode: subagent, report-back format, permission model). |
| **/research command** | `commands/research.md`, `.opencode/commands/research.md` | Standalone command — accepts query, spawns Deepsearcher, saves results to `specs/<feature>/research.md` |

### Modified Components

| Component | File(s) | Change |
|-----------|---------|--------|
| **/spec command** | `commands/spec.md`, `.opencode/commands/spec.md` | Add Phase 0 (Research) at the beginning — "Research this feature? (y/N)" with skip logic. Research output feeds into Phase 1 context. |
| **AGENTS.md** | `AGENTS.md` | Update the Two-Agent System table to a Three-Agent System, adding Deepsearcher. |

### Documentation Components

| Component | File(s) | Responsibility |
|-----------|---------|---------------|
| **Architecture decision** | `context/architecture/deepsearcher-research-stage.md` | Capture the decision, agent design, pipeline integration, and rationale |
| **Context index update** | `context/index.md` | Add reference to the new ADR |

### Interfaces

```
┌─────────────────────────────────────────────────────────────┐
│                      User Invocations                        │
├─────────────────────────────────────────────────────────────┤
│  /spec "feature"    /research "query"    @deepsearcher q    │
└──────────┬─────────────────────┬──────────────────┬─────────┘
           │                     │                  │
           ▼                     ▼                  ▼
    ┌──────────┐         ┌────────────┐     ┌──────────────┐
    │  Vibuzo  │         │Deepsearcher│     │Deepsearcher  │
    │(main)    │         │(subtask)   │     │(inline -     │
    │          │         │            │     │ main session)│
    └────┬─────┘         └─────┬──────┘     └──────┬───────┘
         │                     │                    │
         │  Phase 0            │                    │
         │  ┌──────────────────┘                    │
         │  │                                       │
         ▼  ▼                                       │
    ┌──────────┐                                    │
    │Deepsearcher◄───────────────────────────────────┘
    │(subtask)  │
    └─────┬─────┘
          │ Uses: websearch(), webfetch()
          │ Writes: specs/<feature>/research.md
          ▼
    ┌──────────┐
    │ Research │
    │ Output   │
    │ (.md)    │
    └────┬─────┘
         │
         ▼ (read by Vibuzo in Phase 1)
    ┌──────────┐
    │  Spec    │
    │  Phase   │
    └──────────┘
```

## Implementation Order

### Phase 1 — Create Deepsearcher Agent (Critical Path)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 1 | **Create Deepsearcher agent definition** | `.opencode/agent/core/deepsearcher.md` | Low — follows Deepveloper pattern exactly, swap name and tool access |

### Phase 2 — Create /research Command (Critical Path)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 2 | **Create /research command** | `commands/research.md`, `.opencode/commands/research.md` | Low — standard command file, agent: Deepsearcher, subtask: true |

### Phase 3 — Update /spec Command (Critical Path)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 3 | **Update /spec with Phase 0** | `commands/spec.md`, `.opencode/commands/spec.md` | Medium — must add Phase 0 cleanly without breaking existing phases. Must correctly handle skip logic and research context injection. |

### Phase 4 — Documentation (Parallel)

| Step | Task | Files | Risk |
|------|------|-------|------|
| 4 | **Create architecture decision** | `context/architecture/deepsearcher-research-stage.md` | Low — new file |
| 5 | **Update AGENTS.md** | `AGENTS.md` | Low — add Deepsearcher to the table |
| 6 | **Update context/index.md** | `context/index.md` | Low — add reference |

### Phase 5 — Verification

| Step | Task | Files | Risk |
|------|------|-------|------|
| 7 | **Final review** | All modified files | Low — read through and verify against acceptance criteria |

### Dependency Graph

```
Step 1 (agent) ──┐
                  ├──► Step 2 (command) ──┐
Step 4 (doc) ────┘                         ├──► Step 3 (update /spec) ──┐
Step 5 (AGENTS) ───────────────────────────┘                             ├──► Step 7 (review)
Step 6 (index) ──────────────────────────────────────────────────────────┘
```

- Step 1, 4, 5, 6 are fully parallel
- Step 2 depends on Step 1 (command needs the agent to exist)
- Step 3 depends on Step 2 (spec update uses the pattern established by the command)
- Step 7 depends on all prior steps

### Risk Factors

1. **`@deepsearcher` inline invocation** — This depends on opencode's support for `@agent` inline mentions. If opencode doesn't support this natively, we may need to document it as a future enhancement or find an alternative approach. **Mitigation**: Verify opencode capabilities; if unsupported, document as planned but note the limitation.

2. **Phase 0 integration in `/spec`** — Adding a conditional phase at the beginning of an existing 5-phase command without breaking anything. **Mitigation**: The phase is fully optional — the skip path (No) bypasses all new code and drops directly into the existing Phase 1. The new code path (Yes) runs the agent, saves output, then continues to Phase 1 as normal.

3. **Deepsearcher needs clear research instructions** — The agent must know how to structure its output. **Mitigation**: The agent definition includes explicit research steps and output format in its core rules.
