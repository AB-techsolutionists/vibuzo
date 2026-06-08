# Deepviewer Agent — Technical Implementation Plan

**Feature:** deepviewer-agent
**Date:** 2026-06-08
**Status:** Draft

---

## Tech Stack

| Component | Technology | Justification |
|-----------|------------|---------------|
| Agent definition | `.md` with YAML frontmatter | Follows existing Vibuzo agent pattern (Deepveloper, Deepsearcher) |
| Command file | `.md` with YAML frontmatter + `Do these steps NOW:` block | Follows existing Vibuzo command pattern (split-file convention) |
| Codebase scanning | Built-in tools (glob, grep, read, bash, git) | No external dependencies needed — all analysis uses agent's native toolset |
| Report format | Markdown (`.md`) | Consistent with rest of project documentation; readable by humans and tools |

No new programming languages, binaries, or packages are introduced. Deepviewer operates entirely through the agent tool system (bash, read, write, edit, glob, grep, git, webfetch).

---

## Architecture

### Component Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     Deepviewer Agent                         │
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  /deepviewer  │  │ @deepviewer  │  │  deepviewer.md   │   │
│  │  command.md   │  │  (inline)    │  │  (agent def)     │   │
│  │               │  │              │  │                  │   │
│  │  Full audit   │  │  Targeted    │  │  mode: subagent  │   │
│  │  pipeline     │  │  Q&A mode    │  │                  │   │
│  └──────┬───────┘  └──────┬───────┘  └──────────────────┘   │
│         │                 │                                   │
│         └────────┬────────┘                                   │
│                  │                                            │
│         ┌────────▼────────┐                                   │
│         │  Analysis Core  │                                   │
│         │  (shared logic) │                                   │
│         └────────┬────────┘                                   │
│                  │                                            │
│    ┌─────────────┼─────────────┬────────────────┐            │
│    ▼             ▼             ▼                ▼            │
│ ┌──────┐   ┌──────────┐ ┌──────────┐   ┌──────────────┐     │
│ │Structural│ │Pattern   │ │Session/  │   │Git History   │     │
│ │Scan     │ │Analysis  │ │Context   │   │Analysis      │     │
│ └────────┘ └──────────┘ │Cross-Ref │   └──────────────┘     │
│                         └──────────┘                         │
│    ┌───────────────────────────────────────────────────┐     │
│    │              Report Generator                      │     │
│    │  audit-report-YYYY-MM-DD.md (full)  |  chat (inline)│     │
│    └───────────────────────────────────────────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Data Flow

```
/deepviewer command (full audit):
  1. Parse feature description from $ARGUMENTS
  2. Phase 1 — Structural Scan:
     - glob **/* to get complete file tree
     - Analyze directory structure, file types, sizes
     - Map module boundaries and entry points
  3. Phase 2 — Pattern-Based Analysis:
     - grep for security patterns (hardcoded keys, tokens, env vars)
     - grep for performance concerns (n+1 queries, large loops)
     - grep for TODO/FIXME/HACK/XXX markers
     - grep for duplicated code blocks (similar patterns)
     - grep for dead code markers / orphaned exports
  4. Phase 3 — Session/Context Cross-Reference:
     - Read all files in context/sessions/, context/architecture/,
       context/standards/, context/patterns/
     - Compare references against actual codebase state
     - Flag files/APIs/concepts referenced in context but absent from code
     - Flag code patterns that contradict stated standards
     - Flag session decisions that don't match current implementation
  5. Phase 4 — Git History Analysis:
     - git log --oneline for commit count and density
     - git log --format="%an" for contributor analysis
     - git diff --stat per major commit for churn hotspots
     - git log --format="%s" for commit message trend analysis
     - Identify architectural rewrite periods (large deltas, renames)
     - Assess project maturity and active development stage
  6. Phase 5 — Report Generation:
     - Synthesize all findings into structured audit-report-YYYY-MM-DD.md
     - Categorize by severity and type
     - Include evidence (file:line references)
     - Generate remediation recommendations

Deepviewer in Review Mode (/spec pipeline):
  1. Receives from /spec: spec document, plan, tasks, implemented files
  2. Stage 1 — Spec Compliance Review:
     - Read spec, plan, tasks
     - Read all implemented files using Read tool
     - Compare each piece of functionality against spec requirements
     - Check no extra unintended functionality added
     - Output: compliance status + issues with file:line references
  3. Stage 2 — Code Quality Review:
     - Read all implemented files
     - Check: structure, naming, error handling, dead code, hardcoded secrets
     - Reference project patterns (context/patterns/, context/standards/)
     - Output: quality status + top 3 critical issues
  4. Return structured output in format expected by /spec pipeline
     (No report file — results go back to calling pipeline)

@deepviewer inline:
  1. Parse user's natural language question
  2. Determine scope: specific file, module, cross-cutting, history, etc.
  3. Run targeted analysis (subset of phases 1-4 as needed)
  4. Return concise answer in chat (no file written)
```

### Integration Points

| Integration | Details |
|-------------|---------|
| AGENTS.md | Three-Agent System table gets 4th row: Deepviewer. File tree updated. Commands table gets `/deepviewer` row. |
| .opencode/agent/core/deepviewer.md | New agent definition file; mirrors existing subagent pattern |
| commands/deepviewer.md | New command file with `Do these steps NOW:` block |
| .opencode/commands/deepviewer.md | Mirror copy of command file |
| context/reports/ | New directory for audit report output |
| context/index.md | Updated to list `reports/` directory |
| commands/spec.md | Review phase updated to delegate to Deepviewer instead of "general" subagent |

---

## Components

| Component | File | Responsibility | Interface |
|-----------|------|----------------|-----------|
| Agent definition | `.opencode/agent/core/deepviewer.md` | Declares Deepviewer as a subagent with metadata | YAML frontmatter: name, description, mode, temperature, approval_level |
| Command file | `commands/deepviewer.md` | Contains the full audit pipeline instructions + @deepviewer inline logic | `Do these steps NOW:` block reads $ARGUMENTS |
| Mirror agent | `.opencode/agent/core/deepviewer.md` | Same as agent definition (synced by installer) | — |
| Mirror command | `.opencode/commands/deepviewer.md` | Same as command file (synced by installer) | — |
| AGENTS.md | `AGENTS.md` | Updated to reference Deepviewer | Three-Agent System table, file tree, commands table |
| Context index | `context/index.md` | Lists `reports/` directory | Updated in ## Files > sessions section or new entry |
| Reports directory | `context/reports/` | Stores audit report files | Created directory (initially empty) |

---

## Implementation Order

| Step | Component | Dependencies | Risk | Effort |
|------|-----------|--------------|------|--------|
| 1 | `.opencode/agent/core/deepviewer.md` | None | Low | Small — template copy from existing subagent |
| 2 | `commands/deepviewer.md` | Step 1 | Medium — most complex file | Large — full pipeline logic |
| 3 | `commands/deepviewer.md` — mirror | Step 2 | Low | Small — file copy |
| 4 | `AGENTS.md` update | Steps 1-2 | Low | Small — table + tree additions |
| 5 | `context/index.md` update | Step 4 | Low | Small — add reports/ entry |
| 6 | `context/reports/` directory creation | None | Low | Small — mkdir |
| 7 | Installer updates (install.ps1, install.sh) | Steps 1-2 | Medium — both installers must be updated consistently | Medium |
| 7b | `commands/spec.md` — delegate Review phase to Deepviewer | Steps 1-2 | Medium — must maintain existing review prompt format | Medium |
| 8 | Installer updates (install.ps1, install.sh) | Steps 1-2, 7b | Medium — both installers must be updated consistently | Medium |
| 9 | Verify end-to-end | All above | Medium — manual verification | Medium |

### Risk Factors

1. **Command file complexity** — The `commands/deepviewer.md` is the most complex component. It must orchestrate 5 analysis phases using only agent tool calls. Risk: a phase might time out or exceed context limits.
   - **Mitigation:** Each phase runs independently. If one fails, the report documents the gap and continues.
2. **Context window limits** — Reading every file in the project may exceed context window.
   - **Mitigation:** Use three-phase scanning strategy from research: structural query first (glob/grep), then targeted reads for high-priority files only. Session/context files are read in separate passes.
3. **Git history** — On repos with very long commit histories, `git log` output may be large.
   - **Mitigation:** Use `--max-count=100` and date filtering. Focus on recent 6-9 months for detailed analysis.
4. **.opencode mirror sync** — Installer manages mirror files; manual direct edits violate the standard.
   - **Mitigation:** Create mirror files directly during implementation (they don't exist yet, so no overwrite). Standard says "never modify" existing mirrors, but creating new ones is safe.
