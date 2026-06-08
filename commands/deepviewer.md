---
description: "Run a full codebase audit or ask a question about the project"
agent: Deepviewer
---

Do these steps NOW: $ARGUMENTS

## Mode Determination

Parse `$ARGUMENTS` to determine the operating mode:

- **Mode A — Full Audit**: If `$ARGUMENTS` is empty, "audit", or unspecified — run the full 5-phase pipeline and save the report.
- **Mode B — Inline Q&A**: If `$ARGUMENTS` contains a question (starts with what/why/how/when/where/who/is/are/can/does/do or contains "?"), answer the question using targeted analysis. **Do not create any files.**

---

## Mode A — Full Audit

Execute all five phases in order.

### Phase 1 — Structural Scan

1. Run `glob **/*` from the project root to get the full file tree.
   - Exclude `.git/`, `node_modules/`, `.opencode/` from results.
2. Categorize files by type:
   - Markdown (.md)
   - PowerShell (.ps1, .psm1, .psd1)
   - Shell (.sh)
   - JSON (.json, .jsonc)
   - TypeScript/JavaScript (.ts, .tsx, .js, .jsx)
   - YAML (.yml, .yaml)
   - Other
3. Identify key files:
   - Entry points (main scripts, root-level files)
   - Configuration files (package.json, tsconfig.json, etc.)
   - Agent definitions (.opencode/agent/core/*.md)
   - Command definitions (commands/*.md)
4. Record: total file count, count by category, directory depth, unusual naming patterns.

### Phase 2 — Pattern-Based Analysis

1. **Hardcoded secrets scan:**
   - `grep` for patterns: `password`, `api_key`, `api-key`, `token`, `secret`, `BEGIN (RSA|DSA|EC|PGP|OPENSSH) PRIVATE KEY`
   - Exclude false positives from test files, sample data, and documentation if clearly labeled as examples.
2. **TODO/FIXME/HACK/XXX/NOTE markers:**
   - `grep` for `TODO|FIXME|HACK|XXX|NOTE` across the codebase.
   - Count total occurrences and list by file with line numbers.
3. **Security issue scan:**
   - `grep` for `eval(`, `Invoke-Expression`, backtick execution, `Start-Process` with user input, SQL injection patterns.
   - Check for unsafe path handling (string concatenation in file paths).
4. **Dead code / orphaned references:**
   - Check imports that point to non-existent files.
   - Look for defined but unused functions/variables.
   - Identify files in the tree that are not referenced anywhere.

### Phase 3 — Session/Context Cross-Reference

1. Read all files in:
   - `context/sessions/` — all session summaries
   - `context/architecture/` — all ADRs
   - `context/standards/` — all standards
   - `context/patterns/` — all patterns
2. For each context file, extract:
   - File paths mentioned (e.g., `commands/spec.md`, `.opencode/agent/core/vibuzo.md`)
   - API names, concept names, component names
   - Dependencies or relationships described
3. Cross-reference each extracted mention against actual files in the codebase:
   - Does the file exist at the expected path?
   - Has the file changed significantly since the context was written?
   - Is the described behavior still accurate?
4. Flag documentation drift and orphaned references.

### Phase 4 — Git History Analysis

1. Run `git log --oneline --since="6 months ago"` to analyze commit density and frequency.
2. Run `git shortlog -sn` to identify contributors and commit counts.
3. Run `git log --format="%s"` to analyze commit message patterns and project evolution.
4. Identify:
   - Project evolution phases (initial build, feature additions, maintenance, refactoring)
   - Commit frequency trends (increasing, decreasing, stable)
   - Concerning patterns (large monolithic commits, long gaps, frequent reverts)
   - Type distribution (features vs fixes vs refactors vs docs)

### Phase 5 — Report Generation

1. Construct the report using this exact template:

```markdown
# Audit Report: <Project Name>

**Date:** YYYY-MM-DD
**Audit Scope:** Full codebase
**Status:** Complete | Partial | Failed

## Executive Summary

<3-5 sentence overview of findings, overall health, and critical issues>

## Methodology

Phases executed: Structural Scan, Pattern-Based Analysis, Session/Context Cross-Reference, Git History Analysis

## Project Overview & Evolution

<Brief description of project structure, file counts, language breakdown, and evolution phases from git history>

## Architecture Map

<Key directories, entry points, data flow, dependencies>

## Findings by Category

### Inconsistencies

| Severity | File | Line | Description | Evidence | Recommended Action |
|----------|------|------|-------------|----------|-------------------|

### Security

| Severity | File | Line | Description | Evidence | Recommended Action |
|----------|------|------|-------------|----------|-------------------|

### Performance

| Severity | File | Line | Description | Evidence | Recommended Action |
|----------|------|------|-------------|----------|-------------------|

### Duplication

| Severity | File | Line | Description | Evidence | Recommended Action |
|----------|------|------|-------------|----------|-------------------|

### Misalignments

| Severity | File | Line | Description | Evidence | Recommended Action |
|----------|------|------|-------------|----------|-------------------|

### Dead Code

| Severity | File | Line | Description | Evidence | Recommended Action |
|----------|------|------|-------------|----------|-------------------|

### Documentation Drift

| Severity | File | Line | Description | Evidence | Recommended Action |
|----------|------|------|-------------|----------|-------------------|

## Strategic Observations

<High-level observations about codebase health, architectural strengths/weaknesses, team practices>

## Outdated Context Inventory

| Context File | Referenced Entity | Current Status | Recommended Action |
|--------------|-------------------|----------------|-------------------|

## Remediation Roadmap

| Priority | Category | Issue | Effort | Impact |
|----------|----------|-------|--------|--------|

## Appendix

<Tool versions, scan parameters, exclusions>
```

2. Write the report to `context/reports/audit-report-YYYY-MM-DD.md` (replace YYYY-MM-DD with today's date).
3. Report back to Vibuzo with:
   ```
   Status: ✅ Done | ⚠️ Partial | ❌ Failed
   Summary: <2-3 sentence overview of audit findings>
   Report: context/reports/audit-report-YYYY-MM-DD.md
   ```

---

## Mode B — Inline Q&A

1. Parse the user's question from `$ARGUMENTS`.
2. Determine scope:
   - **Specific file**: Read the file and answer
   - **Module/directory**: Use `glob` and `grep` to analyze the area
   - **Cross-cutting**: Search across the codebase with `grep`
   - **History**: Run `git log` commands
   - **Pattern**: Search context files for relevant standards/patterns
3. Run targeted subset of phases 1-4 as needed to answer the question.
4. Return a concise answer in chat.
5. **Do not create any files** — report findings inline.

Report back in this format:

```
Status: ✅ Done | ⚠️ Partial | ❌ Failed
Answer: <direct answer to the question>
Sources:
  - file:line — relevant finding
  - file:line — relevant finding
```
