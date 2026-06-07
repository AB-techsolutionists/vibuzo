# Specification: Context System Enhancement

**Date:** 2026-06-07
**Status:** Draft
**Feature:** context-system-enhancement

## Principles

- **Backward compatibility** — Existing context files must work without changes. Frontmatter is additive.
- **Surgical scope** — Improve existing commands and files; no new commands unless essential.
- **Agent-first design** — Context must be discoverable by the agent without user prompting.
- **Minimal configuration** — No new config files, environment variables, or external services required.
- **No external dependencies** — All enhancements must work without npm packages or third-party APIs.
- **File-based** — All data lives in the repo as plain files. No databases.

## Overview

Vibuzo's context system currently loads at session start via `context/index.md` and supports manual search (`/context find`) and manual harvest (`/context harvest`). This spec enhances it with:

1. **Mid-session context auto-query** — Agent auto-searches `context/` when starting new tasks
2. **Semantic context search** — Vector-like search without external dependencies for fuzzy matching
3. **Structured YAML frontmatter** — Standardized metadata on all context files for filtering
4. **Auto-scan after `/session`** — Automatic pattern extraction and promotion from session summaries

## User Stories

### US1: Mid-Session Context Auto-Query
As a user, I want the Vibuzo agent to automatically find relevant context files when I start a new task (e.g., "implement auth" → auto-finds naming conventions, architecture decisions, security standards) so I don't have to remember to run `/context find`.

### US2: Semantic Context Search
As a user, I want to search context with natural language queries ("how do we name things?", "what's our testing style?") and get relevant results even if my wording doesn't match the file names, so I don't need to guess exact keywords.

### US3: Structured Frontmatter
As a user, I want context files to have standardized YAML frontmatter (`tags:`, `scope:`, `when:`) so the auto-query system can accurately match context to tasks and filtering works reliably.

### US4: Auto-Scan After Session
As a user, I want the `/session` command to automatically detect patterns worth saving as permanent context and promote them without me needing to run `/context harvest` separately.

## Functional Requirements

### FR1: Mid-Session Context Auto-Query

| ID | Requirement | Priority |
|----|-------------|----------|
| FR1.1 | Before starting any implementation task (any task beyond simple analysis/read), the Vibuzo agent MUST scan `context/index.md` and all `context/standards/` files for relevance to the task | High |
| FR1.2 | Scanning uses keyword overlap between the task description and context file frontmatter (tags, scope) AND title/content keywords | High |
| FR1.3 | Files with >2 keyword matches are loaded into context (their content summarized). Files with 1-2 matches are listed as "possibly relevant" for user to opt-in | High |
| FR1.4 | The scan MUST complete without user prompting — it fires automatically when the agent determines a new implementation task has started | High |
| FR1.5 | The scan MUST NOT fire for simple queries, analysis requests, or conversational exchanges — only when file modifications or new code generation is imminent | Medium |
| FR1.6 | Results are presented as: `[Context] Found 3 relevant files: naming.md (naming conventions), auth-architecture.md (auth flow), security.md (best practices). Loaded.` | Medium |
| FR1.7 | The agent MUST NOT modify Vibuzo's own agent instructions to implement this — the behavior is driven by the spec.md pipeline artifact and agent training | Low |

### FR2: Semantic Context Search (/context find enhancement)

| ID | Requirement | Priority |
|----|-------------|----------|
| FR2.1 | `/context find <query>` performs BOTH exact keyword match AND fuzzy matching using simple algorithms (Levenshtein distance, TF-IDF scoring, or word embeddings via bag-of-words TF-IDF) — no external vector DB | High |
| FR2.2 | Fuzzy matching compares the query against file titles, frontmatter tags, and content keywords extracted from each file | High |
| FR2.3 | Results are ranked by relevance score (0.0–1.0) and displayed with the score | High |
| FR2.4 | Files must have YAML frontmatter (FR3) for optimal fuzzy matching — fall back to title/content matching for files without frontmatter | Medium |
| FR2.5 | `/context find` remains a single-file command — no new command files created | High |
| FR2.6 | Performance: queries must return in under 2 seconds for repos with up to 100 context files | Medium |

### FR3: Structured YAML Frontmatter

| ID | Requirement | Priority |
|----|-------------|----------|
| FR3.1 | All existing context files in `context/standards/`, `context/patterns/`, `context/architecture/` MUST gain YAML frontmatter with `tags:`, `scope:`, and `when:` fields | High |
| FR3.2 | `tags:` is a YAML list of keywords (e.g., `[naming, conventions, typescript, style]`) that describe the file's domain | High |
| FR3.3 | `scope:` is a single line describing what kind of task this applies to (e.g., "code review", "naming decisions", "testing", "architecture design") | High |
| FR3.4 | `when:` is a brief trigger description — describes when the agent should consult this file. Follows the Superpowers pattern: describes **when**, not **how** (e.g., "when naming variables, functions, or components") | High |
| FR3.5 | The `/add-context` command MUST auto-generate frontmatter fields when saving new context files | Medium |
| FR3.6 | Existing files without frontmatter continue to work — frontmatter is optional for backward compatibility | High |
| FR3.7 | `context/index.md` is updated to reflect that files now have frontmatter | Low |

### FR4: Auto-Scan After /session

| ID | Requirement | Priority |
|----|-------------|----------|
| FR4.1 | After generating a session summary, the `/session` command MUST automatically scan the conversation history for patterns, decisions, or conventions worth saving as permanent context | High |
| FR4.2 | Scanning analyzes: new conventions established during the session, repeated patterns, architecture decisions, and tooling preferences | High |
| FR4.3 | Candidates are presented to the user as save prompts (one at a time or batched list) with: detected pattern, suggested file name, suggested tags/scope/when | High |
| FR4.4 | The user can approve, edit, or reject each candidate — nothing is saved automatically | High |
| FR4.5 | The scan MUST NOT add latency to the `/session` command generation — it runs as a post-generation step | Medium |
| FR4.6 | Results are appended to the session summary as a "Patterns detected" section (even if user rejects them, they're recorded) | Low |

## Acceptance Criteria

| AC | Criterion | FR Covered |
|----|-----------|------------|
| AC1 | Starting a task like "implement user authentication" causes the agent to list and load relevant context files without being asked | FR1.1–FR1.4 |
| AC2 | Simple queries like "what does this function do?" do NOT trigger context auto-query | FR1.5 |
| AC3 | `/context find "how do we name things"` returns naming.md with score ≥0.5 | FR2.1–FR2.4 |
| AC4 | `/context find` with exact keywords still works identically to current behavior | FR2.1 |
| AC5 | Every file in context/standards/, context/patterns/, context/architecture/ has tags/scope/when frontmatter | FR3.1–FR3.4 |
| AC6 | Files without frontmatter are still readable and searchable | FR3.6 |
| AC7 | After `/session`, the user is presented with pattern candidates with suggested file names and metadata | FR4.1–FR4.3 |
| AC8 | User can reject all candidates and the session summary still completes normally | FR4.4 |

## Out of Scope

- **External vector database** (Chroma, Pinecone, etc.) — semantic search uses in-file TF-IDF/Levenshtein only
- **LLM-powered embedding generation** — no embedding API calls
- **New CLI commands** — all changes modify existing commands or agent behavior
- **Cross-session vector memory** — addressed in future session-management spec
- **Plugin/marketplace system** — addressed in future work
- **MCP server** — addressed in future work
- **Agent federation** — entirely out of scope
