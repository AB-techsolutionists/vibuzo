# Documentation Drift Fixes

## Principles

- **Surgical changes only** — touch only the drifted lines, not adjacent content. No refactoring, rewording, or "improving" undrifted sections.
- **Match existing style** — each file's existing tone, formatting, and structure is preserved. Only the stale content is replaced.
- **Accuracy over completeness** — every edit must reflect the actual current system state. When uncertain, reference source files (`agents/vibuzo.md`, `commands/spec.md`, etc.) for truth.
- **No mirror edits** — `.opencode/` mirror copies are installer-managed and must NOT be touched.
- **No commit/push** — cleanup only. Working tree is left dirty.

## Specification

### Overview

The Vibuzo codebase has accumulated 22 documentation drift findings across 15 files following recent system changes — the approval gate refactor (hybrid native popup model), the addition of Deepviewer and Deepsearcher agents, command consolidation, and version bumps. This feature fixes all drift by aligning documentation with the current system state.

### User Stories

- As a contributor reading `commands/spec.md`, I want the pipeline gating instructions to reference the current hybrid model, not the deleted `approval_level` system.
- As a new user reading `AGENTS.md`, I want the approval gates section to consistently describe the hybrid model without a contradictory old level table.
- As a maintainer reading the architecture docs, I want all 4 agents (Vibuzo, Deepveloper, Deepsearcher, Deepviewer) properly documented.
- As a developer reading `README.md`, I want correct agent/command counts and file tree entries.
- As anyone referencing standards/patterns, I want dead references to deleted commands (`/commit`) removed.

### Functional Requirements

#### FR1 — Stale `approval_level` references (Cluster 1)

| ID | File | What to Fix | Severity |
|----|------|-------------|----------|
| FR1.1 | `commands/spec.md` | Replace 6 references to `approval_level` with current hybrid model gating (native popups for mechanical, chat gates for plan/push) | HIGH |
| FR1.2 | `AGENTS.md` (lines 172-189) | Remove the old 4-level approval table and old gate prompt template; replace with accurate hybrid model description | HIGH |
| FR1.3 | `AGENTS.md` (line 189) | Remove stale override instruction "at gate level X" | MEDIUM |
| FR1.4 | `context/architecture/spec-command.md` (lines 60-65, 81) | Update "Integration with Approval Gates" section to hybrid model; remove `approval_level` references | MEDIUM |
| FR1.5 | `commands/new-release.md` (lines 24-32) | Update custom gate format to align with current "only 2 custom gates" convention | LOW |
| FR1.6 | `context/standards/terminology-change-process.md` (line 68) | Update `approval_level` example to reflect that it's now removed | LOW |

#### FR2 — Missing agent references (Cluster 2)

| ID | File | What to Fix | Severity |
|----|------|-------------|----------|
| FR2.1 | `README.md` | Update agent count from 3 to 4; add Deepviewer to file tree; correct agent role descriptions | MEDIUM |
| FR2.2 | `context/architecture/agent-restructure.md` | Add Deepsearcher and Deepviewer to agent table and architecture diagram text | MEDIUM |
| FR2.3 | `context/architecture/deepsearcher-research-stage.md` | Update "three-agent system" references to four-agent system | MEDIUM |
| FR2.4 | `context/standards/vibuzo-main-session-only.md` | Add Deepviewer to agent table and subtask rule | MEDIUM |
| FR2.5 | `context/index.md` (line 38) | Update architecture entry description to mention all 4 agents | LOW |

#### FR3 — Dead references and stale counts (Cluster 3)

| ID | File | What to Fix | Severity |
|----|------|-------------|----------|
| FR3.1 | `README.md` | Fix command count in file tree (6 → 8); add `/deepviewer` to commands table | MEDIUM |
| FR3.2 | `context/patterns/internal-commands-convention.md` (line 38) | Update file count from 11 to 8 | LOW |
| FR3.3 | `context/standards/structured-commit-body-convention.md` (lines 80-81) | Remove or update references to deleted `commands/commit.md` | LOW |
| FR3.4 | `context/patterns/commit-workflow-pattern.md` (lines 78-89) | Update references from `/commit` to note it's historical or redirect to applicable pattern | LOW |
| FR3.5 | `context/index.md` (line 79) | Replace `/context find` reference with current equivalent or remove | LOW |
| FR3.6 | `context/patterns/session-workflow-discipline.md` (line 57) | Fix or remove reference to non-existent `timestamp-reliability.md` | LOW |
| FR3.7 | `context/standards/versioning.md` (line 75) | Update example VERSION content from 0.2.5 to current version | LOW |

### Excluded from Scope

- Session files (`context/sessions/*.md`) — historical artifacts, intentionally not updated
- Audit reports (`context/reports/*.md`) — historical artifacts, intentionally not updated
- `.opencode/` mirror copies — installer-managed per `opencode-mirror-files-integrity.md` standard
- Installer scripts (`install.ps1`, `install.sh`) — confirmed clean with 0 drift
- `context/standards/semantic-context-search.md` and `context/standards/yaml-frontmatter-convention.md` — already fixed in prior audit

### Acceptance Criteria

- ✅ `commands/spec.md` has zero references to `approval_level` — pipeline gating reflects hybrid model
- ✅ `AGENTS.md` lines 172-189 no longer contain the old 4-level table, old gate template, or stale override
- ✅ `context/architecture/spec-command.md` approval gates section references hybrid model
- ✅ `README.md` says 4 agents, correct command count (8 + 2 inline = 10), file tree includes `deepviewer.md`
- ✅ `context/architecture/agent-restructure.md` mentions all 4 agents
- ✅ `context/architecture/deepsearcher-research-stage.md` references 4-agent system
- ✅ `context/standards/vibuzo-main-session-only.md` agent table includes Deepviewer
- ✅ All dead references to `/commit` and stale counts resolved
- ✅ `context/index.md` entries are up to date
- ✅ `.opencode/` files are NOT modified
- ✅ Working tree is left dirty (no commit/push)
