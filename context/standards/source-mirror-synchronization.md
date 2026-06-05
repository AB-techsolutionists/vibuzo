# Source/Mirror Synchronization

## Rule

Every command file and agent definition MUST exist in **two locations**:

| Role | Path |
|------|------|
| **Source** | `commands/<file>.md` |
| **Mirror** | `.opencode/commands/<file>.md` |

| Role | Path |
|------|------|
| **Source** | `agents/<file>.md` |
| **Mirror** | `.opencode/agent/core/<file>.md` |

## Enforcement

- The two copies must be **byte-identical** at all times
- Every edit to a source file must be applied to its mirror immediately
- Verification: `if ((Get-Content <source> -Raw) -eq (Get-Content <mirror> -Raw)) { "MATCH" }`

## Current Active Files

| Source | Mirror |
|--------|--------|
| `agents/vibuzo.md` | `.opencode/agent/core/vibuzo.md` |
| `agents/deepveloper.md` | `.opencode/agent/core/deepveloper.md` |
| `commands/spec.md` | `.opencode/commands/spec.md` |
| `commands/add-context.md` | `.opencode/commands/add-context.md` |
| `commands/context-init.md` | `.opencode/commands/context-init.md` |
| `commands/context-find.md` | `.opencode/commands/context-find.md` |
| `commands/context-harvest.md` | `.opencode/commands/context-harvest.md` |
| `commands/context-append.md` | `.opencode/commands/context-append.md` |
| `commands/session.md` | `.opencode/commands/session.md` |
| `commands/session-view.md` | `.opencode/commands/session-view.md` |
| `commands/session-timeline.md` | `.opencode/commands/session-timeline.md` |

## Rationale

The `.opencode/` directory is what the opencode runtime reads to register commands and agents. The `commands/` and `agents/` directories are the human-readable source of truth. Keeping them synchronized ensures both the runtime and documentation stay in sync.
