# Deepsearcher Invocation Modes

**Date:** 2026-06-06
**Status:** Active

Deepsearcher has three distinct invocation modes, each with different file-creation and reporting behavior.

## The Three Modes

| Mode | Spawns Subtask? | Creates File? | Reports To |
|------|----------------|---------------|------------|
| `@Deepsearcher <query>` | ✅ Deepsearcher | ❌ No | Vibuzo → main session |
| `/research <query>` | ✅ Deepsearcher | ❌ No | Vibuzo → main session |
| `/spec` Research stage | ✅ Deepsearcher | ✅ `specs/<feature>/research.md` | Vibuzo → main session |

### `@Deepsearcher` — Inline Ad-Hoc Research

- Invoked directly in conversation via `@agent` mention
- Deepsearcher spawns as subtask, researches, reports back to Vibuzo
- Vibuzo presents findings in the main session
- **No files created**

### `/research` — Standalone Research Command

- Invoked via the `/research` command
- Deepsearcher spawns as subtask, researches, reports back to Vibuzo
- Vibuzo presents findings in the main session
- **No files created**

### `/spec` Research Stage — Pipeline Research

- Invoked as the optional Research stage of the `/spec` pipeline
- Deepsearcher spawns as subtask, researches, **saves to `specs/<feature>/research.md`**, reports back
- Vibuzo reads the saved file during Specification phase
- File becomes a permanent project artifact for future reference

## Rationale

- **`/research` and `@Deepsearcher`** are lightweight lookups — the user wants quick answers, not permanent artifacts. File creation would be overhead for ad-hoc queries.
- **`/spec` Research stage** feeds into a multi-stage pipeline where the specification needs a reference artifact. The research file is read during Specification, Plan, and Review phases.

## Related

- [`architecture/deepsearcher-research-stage.md`](../architecture/deepsearcher-research-stage.md) — Architecture decision for the Deepsearcher agent and pipeline
- `commands/research.md` — The `/research` command definition
- `commands/spec.md` — The `/spec` pipeline with Research stage
