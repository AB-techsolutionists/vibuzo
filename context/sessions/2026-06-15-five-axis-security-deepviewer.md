---
title: five-axis-security-deepviewer
date: 2026-06-15
tags:
  - deepviewer
  - code-review
  - security
  - versioning
  - agent-skills
  - spec
status: complete
---

# Five-Axis Security Deepviewer

*Session summary — 2026-06-15 | ~30 messages | 9 files touched | 1 commit*

## Session Summary

Researched addyosmani/agent-skills repo and integrated two high-value capabilities into Vibuzo's code review pipeline. Upgraded Deepviewer's Review phase from a generic checklist to a structured Five-Axis Review Framework (Correctness → Readability → Architecture → Security → Performance) with severity labels (Critical/Important/Nit/Optional/FYI) and change sizing gates. Deepened the Security axis with OWASP-informed patterns covering injection, SSRF prevention, AI/LLM security, supply chain analysis, and a three-tier boundary system. Created two new context standards (code-review-framework.md and security-review-checklist.md) with code examples and dependency audit triage flow. Bumped version 0.0.16 → 0.0.17 and pushed to origin/main.

## Constraints & Preferences

- **Source over mirror:** Agent source files live in `agents/` — `.opencode/` mirrors are installer-managed copies, not the canonical source. Edits must go to the source first.
- **Never push without approval:** Custom rule enforced — push was gated via chat approval before execution.
- **agent-skills as reference, not replacement:** The addyosmani/agent-skills repo provided workflow patterns (five-axis, security checklist) but Vibuzo's explicit /spec pipeline with subagents was preferred over agent-skills' implicit intent-mapping approach.

## Forward Decisions

| # | Decision | Rationale |
|---|----------|-----------|
| 1 | **Five-Axis Review Framework adopted** — Deepviewer now evaluates code across Correctness, Readability, Architecture, Security, and Performance with severity labels | Replaces the previous generic checklist; provides more actionable, structured review output with clear priorities (Critical→Important→Nit→Optional→FYI) |
| 2 | **Security axis deepened with OWASP patterns** — SSRF, AI/LLM security, supply chain, and three-tier boundary system added to the review framework | The previous 7-item security checklist missed entire vulnerability categories (SSRF, supply-chain, AI/LLM) that agent-skills' security-and-hardening skill covered |
| 3 | **Change sizing gate added to reviews** — code changes exceeding ~300 lines flagged for splitting | Prevents unwieldy PRs and enforces focused, reviewable changesets |

## Forward Context

- Working tree is clean — all changes committed and pushed to `3f70902`
- Version is 0.0.17 on main branch, up to date with origin
- Both source (`agents/deepviewer.md`) and mirror (`.opencode/agent/core/deepviewer.md`) are in sync with identical five-axis content
- Two new context standards are available: `code-review-framework.md` (five-axis reference) and `security-review-checklist.md` (OWASP security reference)
- The next-highest-ROI integration from agent-skills would be importing `debugging-and-error-recovery` or `git-workflow-and-versioning` as standards — not done this session

## Hot Files

| File | Why Hot |
|------|---------|
| `agents/deepviewer.md` | Source agent file — just received the five-axis framework and security depth; likely to be modified if review axes are refined |
| `commands/spec.md` | Stage 2 Review phase upgraded — next /spec run will use the new format; may need tweaks |
| `context/standards/security-review-checklist.md` | New file — may need refinement after real review usage |
| `VERSION` | Freshly bumped to 0.0.17 — next release starts from here |

## Timeline Entry

| 2026-06-15 | ~18:00 | `five-axis-security-deepviewer` | Integrated Five-Axis Review Framework and OWASP security depth from agent-skills into Deepviewer; bumped 0.0.16→0.0.17 |

## Session Compaction

````
╭─────── Session Compaction ───────────────────────────────────────╮
│                                                                   │
│  Session:    five-axis-security-deepviewer                        │
│  Date:       2026-06-15                                           │
│  Messages:   ~30                                                  │
│                                                                   │
├─────── Goal ──────────────────────────────────────────────────────┤
│                                                                   │
│  • Upgrade Deepviewer's Review phase with the Five-Axis Review    │
│    Framework and OWASP-informed security depth from agent-skills  │
│                                                                   │
├─────── Constraints & Preferences ─────────────────────────────────┤
│                                                                   │
│  • Source files in agents/, not .opencode/ (mirror is installer-  │
│    managed copy)                                                  │
│  • Never push without explicit approval (custom rule)             │
│  • agent-skills patterns imported as reference standards, not     │
│    replacing Vibuzo's explicit /spec pipeline                     │
│                                                                   │
├─────── Progress ──────────────────────────────────────────────────┤
│                                                                   │
│  Done:                                                            │
│  • Researched addyosmani/agent-skills repo — 24 structured        │
│    skills, OpenCode setup via AGENTS.md + skill tool               │
│  • Added Five-Axis Review Framework (Correctness, Readability,    │
│    Architecture, Security, Performance) to deepviewer.md          │
│  • Added severity labels (Critical/Important/Nit/Optional/FYI)    │
│    and change sizing (~100/~300/~1000+ lines)                    │
│  • Deepened Security axis: injection, auth, XSS, SSRF,            │
│    supply-chain, AI/LLM, three-tier boundary system               │
│  • Created context/standards/code-review-framework.md              │
│  • Created context/standards/security-review-checklist.md with    │
│    code examples, dependency audit triage, anti-rationalization   │
│  • Updated commands/spec.md Stage 2 to five-axis output format    │
│  • Updated context/index.md with both new file listings           │
│  • Bumped VERSION 0.0.16 → 0.0.17                                 │
│  • Updated versioning.md and README.md version history            │
│  • Committed and pushed: 10 files, 556 insertions, 42 deletions   │
│                                                                   │
│  In Progress:                                                     │
│  • None                                                           │
│                                                                   │
│  Blocked:                                                         │
│  • None                                                           │
│                                                                   │
├─────── Key Decisions ─────────────────────────────────────────────┤
│                                                                   │
│  • Five-Axis Review Framework replaces generic checklist — every  │
│    finding gets a severity label                                  │
│  • Security axis now covers OWASP patterns, SSRF, AI/LLM,         │
│    supply-chain — not just "secrets and injection"                │
│  • Change sizing gate prevents PRs >300 lines without             │
│    justification                                                  │
│  • agent-skills used as reference import, not pipeline            │
│    replacement                                                    │
│                                                                   │
├─────── Next Steps ────────────────────────────────────────────────┤
│                                                                   │
│  • Next /spec run will use the new five-axis output — verify      │
│    format works end-to-end                                        │
│  • Consider importing debugging-and-error-recovery or             │
│    git-workflow-and-versioning from agent-skills as next standard │
│  • Start new session with /new → /session-init                   │
│                                                                   │
├─────── Critical Context ──────────────────────────────────────────┤
│                                                                   │
│  • Git: working tree clean, up to date with origin/main           │
│  • Version: 0.0.17 on main                                        │
│  • Last commit: 3f70902                                           │
│  • Both source (agents/) and mirror (.opencode/) agent files are  │
│    in sync                                                        │
│  • Two new context standards created — auto-loaded next session   │
│                                                                   │
├─────── Relevant Files ────────────────────────────────────────────┤
│                                                                   │
│  agents/deepviewer.md                  │ Five-axis + security     │
│  commands/spec.md                      │ Stage 2 five-axis output │
│  context/standards/code-review-        │ Five-axis reference      │
│    framework.md                        │                          │
│  context/standards/security-review-    │ OWASP security reference │
│    checklist.md                        │                          │
│  VERSION                               │ 0.0.17                   │
│  README.md                             │ Version history updated  │
│                                                                   │
╰───────────────────────────────────────────────────────────────────╯
````

## Context Candidates

| # | Type | Name | Status |
|---|------|------|--------|
| 1 | pattern | `external-skill-integration.md` | ✅ Saved |
