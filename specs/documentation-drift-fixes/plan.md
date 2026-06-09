# Documentation Drift Fixes — Implementation Plan

## Tech Stack

| Layer | Technology | Justification |
|-------|-----------|---------------|
| Format | Markdown | All documentation files are `.md` — no code changes needed |
| Tooling | Standard text editing via agent | All edits are surgical find-and-replace with verification |

## Architecture

This is a documentation-only cleanup. No code changes, no structural changes, no file creation or deletion. The architecture is simply the dependency order of the files being edited.

### Cluster Dependency Graph

```
Cluster 1 (approval_level)          Cluster 2 (agents)        Cluster 3 (dead refs)
  │                                   │                         │
  ├── commands/spec.md (HIGH)         ├── README.md             ├── README.md
  ├── AGENTS.md (HIGH)                ├── agent-restructure.md  ├── internal-commands-convention.md
  ├── spec-command.md (MEDIUM)        ├── deepsearcher-         ├── structured-commit-body-convention.md
  ├── new-release.md (LOW)            │   research-stage.md     ├── commit-workflow-pattern.md
  └── terminology-change-process      ├── vibuzo-main-          ├── index.md
      .md (LOW)                       │   session-only.md       ├── session-workflow-discipline.md
                                      └── index.md              └── versioning.md
```

**Key insight:** README.md appears in both Cluster 2 and Cluster 3. To avoid conflicts, it should be edited once with all changes applied simultaneously.

## Implementation Order

Clusters are independent and can be executed in any order, but the recommended order prioritizes impact:

| Order | Cluster | Rationale |
|-------|---------|-----------|
| 1 | **Cluster 1 — approval_level refs** | HIGH severity — broken pipeline gating instructions |
| 2 | **Cluster 2 — missing agents** | MEDIUM severity — misleading architecture docs |
| 3 | **Cluster 3 — dead refs & stale counts** | LOW severity — cosmetic/dead references |

## Components

### Cluster 1: Stale `approval_level` References (6 files, 8 edits)

| Component | File | Edits Needed | Risk |
|-----------|------|-------------|------|
| C1.1 | `commands/spec.md` | 6 stale refs → replace with hybrid model | HIGH — core pipeline doc |
| C1.2 | `AGENTS.md` (lines 172-189) | Remove old table + template + override | HIGH — universal entry point |
| C1.3 | `context/architecture/spec-command.md` | Update gates section | MEDIUM |
| C1.4 | `commands/new-release.md` | Align gate format | LOW |
| C1.5 | `context/standards/terminology-change-process.md` | Update example | LOW |

### Cluster 2: Missing Agent References (5 files, 5 edits)

| Component | File | Edits Needed | Risk |
|-----------|------|-------------|------|
| C2.1 | `README.md` | Fix agent count, file tree, command count, commands table | MEDIUM — user-facing |
| C2.2 | `context/architecture/agent-restructure.md` | Add 2 missing agents | MEDIUM |
| C2.3 | `context/architecture/deepsearcher-research-stage.md` | 3→4 agents | MEDIUM |
| C2.4 | `context/standards/vibuzo-main-session-only.md` | Add Deepviewer to table | MEDIUM |
| C2.5 | `context/index.md` (line 38) | Update architecture entry | LOW |

### Cluster 3: Dead References & Stale Counts (7 files, 7 edits)

| Component | File | Edits Needed | Risk |
|-----------|------|-------------|------|
| C3.1 | `README.md` (combined with C2.1) | Fix command count | MEDIUM |
| C3.2 | `context/patterns/internal-commands-convention.md` | Fix file count | LOW |
| C3.3 | `context/standards/structured-commit-body-convention.md` | Remove /commit refs | LOW |
| C3.4 | `context/patterns/commit-workflow-pattern.md` | Update /commit refs | LOW |
| C3.5 | `context/index.md` (line 79) | Remove /context find ref | LOW |
| C3.6 | `context/patterns/session-workflow-discipline.md` | Fix broken ref | LOW |
| C3.7 | `context/standards/versioning.md` | Update version example | LOW |

## Verification Strategy

1. **After each cluster:** grep for remaining stale patterns to confirm no missed occurrences
2. **After all clusters:** re-read each edited file at the changed lines to verify correctness
3. **Cross-check:** verify agent count (4), command count (8 + 2 inline = 10), and no `approval_level` remains in any documentation file
