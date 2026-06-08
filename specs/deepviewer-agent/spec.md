# Deepviewer Agent — Specification

**Feature:** deepviewer-agent
**Date:** 2026-06-08
**Status:** Draft

---

## Principles

1. **Thoroughness over speed** — Deepviewer's purpose is exhaustive codebase understanding. It must read every relevant file, not skip or summarize prematurely.
2. **Evidence-based findings** — Every issue reported must include file paths, line numbers, and a rationale. No vague claims.
3. **Non-destructive** — Deepviewer is read-only. It never modifies code, only generates audit reports.
4. **Structured output** — Reports follow a consistent template. Machine-parseable sections with human-readable explanations.
5. **Respect existing patterns** — Follows the same agent registration pattern as Deepveloper and Deepsearcher (agent file + command file + inline invocation).
6. **Self-contained** — All logic lives in the agent and command definitions. No external scripts or binaries.

---

## Specification

### Overview

Deepviewer is a codebase analysis agent that performs comprehensive audits of the entire project. It reads every file, every line of code, and all session/context files to build a complete understanding of the project — what it is, what it does, how it's built, why decisions were made, and how it evolved. It then produces a structured `audit-report-<date>.md` in `context/reports/` that surfaces inconsistencies, gaps, security issues, performance problems, duplicated logic, outdated context, and any other actionable findings.

### User Stories

| ID | Story |
|----|-------|
| US-01 | As a developer, I want to run `/deepviewer` to trigger a full codebase audit so I can understand the state of the project. |
| US-02 | As a developer, I want to use `@deepviewer <question>` inline to ask any question about the codebase — structure, history, specific files, patterns, or issues — and get a targeted answer without a full report. |
| US-03 | As a developer, I want the audit report to include an executive summary so I can quickly grasp the most critical findings. |
| US-04 | As a developer, I want findings categorized by type (inconsistency, security, performance, duplication, outdated context, misalignment) so I can prioritize remediation. |
| US-05 | As a developer, I want each finding to include file paths, line numbers, evidence, and a recommended action so I can take immediate next steps. |
| US-06 | As a developer, I want the report to analyze git history and explain how the project evolved, what architectural phases it went through, and what stage it's currently in. |
| US-07 | As a developer, I want the report to cross-reference session files and context files to identify outdated or conflicting information. |
| US-08 | As a developer, I want the report to include a strategic observations section that identifies cross-cutting issues (e.g., "this pattern is broken in 5 places"). |
| US-09 | As a developer, I want the report to include a remediation roadmap with phased recommendations so I can plan work. |
| US-10 | As a developer, I want `/spec` to delegate its Review phase to Deepviewer instead of generic reviewer subagents, so reviews use the same deep codebase understanding. |

### Functional Requirements

| FR ID | Description | Priority |
|-------|-------------|----------|
| FR-01 | Deepviewer is registered as a Vibuzo subagent with `mode: subagent` in `.opencode/agent/core/deepviewer.md` | P0 |
| FR-02 | A `/deepviewer` command file exists at `commands/deepviewer.md` with a single `Do these steps NOW:` block | P0 |
| FR-03 | A `@deepviewer` inline invocation is supported — accepts any natural language question about the codebase (structure, history, specific files, patterns, issues) and returns a targeted analysis in chat without generating a report file | P0 |
| FR-04 | The agent file is mirrored to `.opencode/agent/core/deepviewer.md` | P0 |
| FR-05 | The command file is mirrored to `.opencode/commands/deepviewer.md` | P0 |
| FR-06 | AGENTS.md is updated to list Deepviewer in the Three-Agent System table, file tree, and commands table | P0 |
| FR-06b | `@deepviewer` parses the user's question, determines the scope (single file, module, cross-cutting concern, history, docs, etc.), performs targeted analysis, and returns a concise answer in chat | P0 |
| FR-07 | `context/reports/` directory is created to store audit reports | P0 |
| FR-08 | Deepviewer reads every file in the project (code, config, markdown, scripts) using appropriate reading strategies | P0 |
| FR-09 | Deepviewer runs a multi-phase analysis pipeline: (1) structural scan, (2) pattern-based analysis, (3) session/context cross-reference, (4) git history analysis, (5) report generation | P1 |
| FR-10 | The structural scan phase builds a file tree, analyzes directory structure, maps dependencies between files | P1 |
| FR-11 | The pattern-based analysis phase scans for: hardcoded secrets, security anti-patterns, performance issues, duplicated code blocks, dead code, TODO/FIXME/HACK markers | P1 |
| FR-12 | The session/context cross-reference phase reads all files in `context/sessions/`, `context/architecture/`, `context/standards/`, `context/patterns/` and identifies outdated, conflicting, or orphaned references | P1 |
| FR-13 | The git history analysis phase reads commit log, identifies churn hotspots, architectural rewrite periods, ownership patterns, and project evolution stages | P1 |
| FR-14 | The report generation phase writes `context/reports/audit-report-YYYY-MM-DD.md` with the full structured report | P0 |
| FR-15 | The audit report includes these sections: Executive Summary, Methodology, Project Overview & Evolution, Architecture Map, Findings by Category, Strategic Observations, Outdated Context Inventory, Remediation Roadmap, Appendix | P0 |
| FR-16 | The Findings by Category section includes sub-categories: Inconsistencies, Security Issues, Performance Issues, Duplicated Logic, Misalignments, Dead/Orphaned Code, Documentation Drift | P0 |
| FR-17 | Each finding includes: severity (Critical/High/Medium/Low), affected files (with line numbers), description, evidence, and recommended action | P0 |
| FR-18 | The Outdated Context Inventory section lists context files or session references that no longer match the current codebase state | P1 |
| FR-19 | The Remediation Roadmap organizes fixes into phases: Immediate (quick wins), Phase 1 (short-term), Phase 2 (medium-term), Phase 3 (long-term) | P1 |
| FR-20 | Deepviewer respects the project's approval_level setting when creating the report file | P1 |
| FR-21 | The `context/reports/` directory is listed in `context/index.md` | P2 |
| FR-22 | Deepviewer has a Review mode that performs spec compliance review + code quality review using the same inline prompt structure as the current spec pipeline | P0 |
| FR-23 | The `/spec` command's Review phase delegates to Deepviewer (instead of a "general" subagent) for both compliance and quality review stages | P0 |
| FR-24 | When invoked as Review phase (not standalone audit), Deepviewer receives the spec doc, plan, tasks, and implementation files as context | P0 |
| FR-25 | When invoked as Review phase, Deepviewer outputs in the same format the spec pipeline expects (compliance status + quality assessment) rather than a full audit report | P0 |

### Acceptance Criteria

| AC ID | Criteria |
|-------|----------|
| AC-01 | Running `/deepviewer` produces a complete audit report at `context/reports/audit-report-YYYY-MM-DD.md` |
| AC-02 | The report contains all 9 required sections from FR-15 |
| AC-03 | Each finding in the report includes file paths, line numbers, and evidence |
| AC-04 | git history analysis identifies the number of commits, major contributors, churn hotspots, and architectural phases |
| AC-05 | Session/context cross-reference finds at least one outdated or conflicting reference (if any exist) |
| AC-06 | The `@deepviewer` inline invocation answers a codebase question without producing a report file |
| AC-07 | AGENTS.md correctly lists Deepviewer in the agent table, file tree, and commands table |
| AC-08 | `context/index.md` lists the `reports/` directory |
| AC-09 | All new agent/command files exist in both `commands/` and `.opencode/commands/` |
| AC-10 | All new agent/command files exist in both `.opencode/agent/core/` and `commands/` equivalents are not applicable here (agent files are only in `.opencode/agent/core/`) |
| AC-11 | When `/spec` reaches Review phase, it delegates to Deepviewer instead of a general agent |
| AC-12 | Deepviewer's Review phase output follows the spec pipeline format (compliance + quality status, issues with file:line, assessment) |
| AC-13 | Deepviewer performs both spec compliance and code quality reviews in a single Review phase invocation |

### Out of Scope

- Deepviewer does not automatically fix any issues it finds — it only reports them
- Deepviewer does not modify code, config files, or any project files
- Deepviewer does not run at session start automatically (on-demand only)
- Deepviewer does not require external tools or dependencies (uses built-in bash/tools)
- Deepviewer does not perform runtime analysis or dynamic testing
- Deepviewer's Review mode replaces the existing /spec review logic but does not change the /spec pipeline structure itself (phases, gates, handoff format remain identical)
