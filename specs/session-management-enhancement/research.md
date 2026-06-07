# Research: Session Management Enhancement

**Date:** 2026-06-07
**Status:** Complete

## Summary

Investigated session management patterns across 8+ AI coding tools (opencode, Claude Code, Cursor, Windsurf, Copilot, SESH, SessionFS, Codex). Found strong convergence on filesystem-native architectures, YAML frontmatter for metadata, and flag-based rather than subcommand-heavy UX. Cross-session search leans on file-based approaches (ripgrep/SQLite FTS5) with optional semantic layers, not vector DBs. Auto-hinting patterns exist in Claude Code (session recap) and Windsurf (Flow tracking) but remain nascent.

## Key Findings

1. **Init is separate from session start** — Every tool separates project/agent initialization from session creation. opencode has `/init` (scans repo, creates AGENTS.md), Claude Code has `claude --init`/`/init`, SESH has `sesh init`. The init action configures context for future sessions; it is not a session itself. This validates Vibuzo's current `/init` + session pattern.

2. **Subcommands are giving way to flags and internal commands** — Claude Code eliminated session subcommands entirely: `--resume`, `--continue`, `--fork-session`, `--name` are all top-level flags. Session management happens via `/resume`, `/clear`, `/branch` inside sessions. opencode's session operations are HTTP API endpoints, not CLI subcommands. SESH is the outlier with explicit subcommands (`sesh new`, `sesh complete`, `sesh list`), justified by its file-creation workflow. The trend: avoid nested subcommand trees (`session list` → just `--list` or `/list`).

3. **YAML frontmatter is the universal metadata layer** — SESH, Minutes, Memstone, and the Memory Bank pattern all use YAML frontmatter in markdown files. Common fields: `title`, `date`, `created_at`, `updated_at`, `status` (in_progress|complete|paused|idea), `tags`, `parent`, `related[]`. Frontmatter enables grep/search without a parser. Filesystem IS the API — no database needed.

4. **Cross-session search is file-based, not vector-DB-based** — Three dominant approaches exist:
   - **Pure grep/ripgrep** (FFF pattern): `agent-session-search` fans out grep across agent session directories. Fast, stateless, no indexing. Used by SessionFS (`sfs search`).
   - **SQLite FTS5** (ctxgrep, cass): Incremental indexing with full-text search. Optional ONNX-based semantic layer (local MiniLM model) for concept search.
   - **Frontmatter-only** (SESH, dru89/sesh): Simple YAML field search, fuzzy matching over titles/summaries. Lightest weight.
   - No tool uses a vector DB (Pinecone/Weaviate) for session search. Local-only, file-first.

5. **Auto-generated session hints exist but are basic** — Three patterns found:
   - **Session recap** (Claude Code): Auto-generates one-line recap when terminal unfocused for 3+ mins. Available on refocus or via `/recap`.
   - **Prompt suggestions** (Claude Code): At session start, shows a grayed-out example prompt derived from git history.
   - **Flow awareness** (Windsurf Cascade): Tracks IDE actions (file saves, terminal commands) and auto-updates context window — the model knows what you just did without you saying it.
   - **Auto-compaction** (opencode): Session auto-summarizes when token usage exceeds 90% of context window.
   - No tool auto-surfaces session compaction content from *previous* sessions at start time — this is an open opportunity.

6. **Parent/child session hierarchies are standard** — opencode, Claude Code, SESH all support forking/branching sessions. opencode uses `parentID` in session schema; Claude Code uses `/branch` + `/resume`; SESH uses `parent:` field in frontmatter. Child sessions inherit context from parent but diverge independently.

7. **Metadata search is a key UX gap** — Claude Code users explicitly requested `--list-all` and `--remove` flags for session management (GitHub issue #30452). Current session pickers show name, summary, timestamp, message count, and git branch. Cross-tool search (SessionFS, cass, agent-session-search) is an emerging category solving this fragmentation.

## Resources

| Title | URL | Description |
|-------|-----|-------------|
| OpenCode Session Management (DeepWiki) | https://deepwiki.com/sst/opencode/2.1-session-management | Session lifecycle, CRUD, parent/child hierarchy, SQLite storage |
| Claude Code Sessions Docs | https://code.claude.com/docs/en/sessions | Session naming, resuming, branching, picker UI, transcript storage |
| SESH — Session Tracking | https://kurtheinrich.com/blog/sesh-the-blueprint | YAML frontmatter session files, parent/child relationships, file-based search |
| Minutes Frontmatter Schema | https://github.com/silverstein/minutes/blob/main/docs/frontmatter-schema.md | Structured YAML frontmatter standard for meeting/session files |
| agent-session-search | https://github.com/benvenker/agent-session-search | MCP server for grep-based cross-agent session search (FFF engine) |
| cass (coding agent session search) | https://github.com/Dicklesworthstone/coding_agent_session_search | Unified TUI/CLI indexing 20 agent formats, SQLite + optional semantic |
| ctxgrep | https://github.com/yetone/ctxgrep | Local-first CLI search with FTS5, memory extraction, context packing |
| SessionFS | https://github.com/SessionFS/sessionfs | Cross-tool session capture/resume with portable .sfs format |
| dru89/sesh | https://github.com/dru89/sesh | Unified fuzzy picker across opencode/Claude Code sessions |
| Windsurf Flow Context Engine | https://markaicode.com/windsurf-flow-context-engine | RAG-based codebase indexing, real-time action tracking, Memories |

## Source Metadata

- Total sources consulted: 25+
- Total sources used: 10 (key references)
- Date range: 2025-09 to 2026-06
