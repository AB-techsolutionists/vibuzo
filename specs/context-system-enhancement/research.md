# Research: Context System Enhancement for Vibuzo

**Date:** 2026-06-07
**Status:** Complete

## Summary

Research into 4 context system enhancements for Vibuzo, drawing from obra/superpowers (auto-triggering skills), ruvnet/ruflo (HNSW vector search + trajectory learning), nexu-io/open-design (structured DESIGN.md schema), affaan-m/ECC (memory hooks + continuous learning), and multica-ai/multica (YAML-frontmatter skills with filtering). Core insight: the best implementations use hooks (sessionStart/sessionEnd) for automation, YAML frontmatter for discoverability, and agent-native discovery paths rather than inlined context.

## Key Findings

### 1. Mid-Session Context Auto-Query

- **Superpowers pattern**: SessionStart hook injects a meta-skill (`using-superpowers`) that forces the agent to check for relevant skills BEFORE any response — even clarifying questions. The "1% rule" says if there's even a 1% chance a skill applies, invoke it. Skills use YAML `description` field (trigger-only, never workflow-summary) so the agent must open the file to learn steps.
  - Source: [Superpowers Skills System](https://obra-superpowers.mintlify.app/concepts/overview)

- **Multica approach**: `SkillManager` with lazy loading, multi-source precedence (bundled < extra < profile), eligibility filtering by platform/binary/env. Skills injected at task execution time, not session start. Optionally user-invocable or AI-only via `disable-model-invocation` and `user-invocable` flags.
  - Source: [multica-ai/multica commit 50ae997](https://github.com/multica-ai/multica/commit/50ae997ab4c3e1ea814c8c29225cbcbead9ef217)

- **ECC memory persistence**: Uses hooks (`session-start.js`, `stop-hook`) to save/load context across sessions. PreCompact hooks save state before compaction; Stop hooks persist learnings at session end. System prompt injection via CLI flags for surgical context loading.
  - Source: [affaan-m/ECC Longform Guide](https://github.com/affaan-m/ECC/blob/main/the-longform-guide.md)

- **Anti-pattern identified**: Superpowers deliberately avoids summarizing workflow in frontmatter descriptions — if the description tells the agent what the skill does, the agent skips the body. Description must describe only **when**, not **how**.
  - Source: [Anatomy of an Agent Skill](https://www.akashtandon.in/interactive-explainers/superpowers/)

### 2. Semantic Context Search

- **Ruflo AgentDB (HNSW)**: Uses HNSW indexing with ONNX 384-dim embeddings (all-MiniLM-L6-v2). Achieves 150x-12,500x speedup over brute force, sub-millisecond retrieval. RaBitQ 1-bit quantization delivers 32x memory reduction. Hierarchical memory tiers: working (1h TTL), episodic (7d), semantic (infinite). Bidirectional bridge to Claude Code auto-memory via SessionStart hook.
  - Source: [ruvnet/ruflo Memory and Graph](https://github.com/ruvnet/ruflo/wiki/Memory-and-Graph)

- **Redis Iris / Context Retriever**: Unified real-time context engine with hybrid search (vector + structured + BM25). Redis Agent Memory splits working memory (session-scoped) from long-term memory (cross-session). Context Retriever auto-generates MCP tools from entity schemas for controlled agent access.
  - Source: [Redis Context Retrieval Guide](https://redis.io/blog/context-retrieval-for-ai-agents/)

- **CODITECT Memory Context Agent**: Multi-granular search (RAG + decisions + patterns + errors) with relevance scoring — boosts same-project/recent items, penalizes old/completed work. Signal-over-volume principle: a few highly relevant items beat many marginal ones. Token budget enforcement with hierarchical expansion.
  - Source: [CODITECT Memory Context Agent](https://docs.coditect.ai/reference/agents/memory-context-agent)

- **Anti-pattern**: Linear scan for search (current Vibuzo grep-only approach). Ruflo's benchmarks show brute-force goes from 5ms at 1K vectors to 100s at 1M vectors, while HNSW stays at ~5ms. Without vector search, the system doesn't scale.

### 3. Structured YAML Frontmatter

- **Superpowers minimal frontmatter**: Only 2 required fields (`name`, `description`). `allowed-tools` and `model` optional but Claude Code-specific. Deliberate minimalism for cross-harness portability. Key design rule: description is trigger-only — never summarize the workflow.
  - Source: [Creating Skills - Superpowers](https://obra-superpowers.mintlify.app/development/creating-skills)

- **Multica structured frontmatter**: Richer schema with `name`, `description`, `version`, `color`, `metadata` (v3_role, agent_id, priority, domain, phase), `hooks` (pre_execution, post_execution), and invocation control fields (`user-invocable`, `disable-model-invocation`).
  - Source: [multica-ai/multica commit 20b45c0](https://github.com/multica-ai/multica/commit/20b45c0bcfcae1b62869725f75ac70fa47d2c107)

- **pi-superagents scope field**: Adds `scope: root` to restrict skills to root-planning agents only. Agent definitions use `kind`, `entrySkill`, `skills` fields. Superpowers skill selection is trigger-driven, not preloaded.
  - Source: [pi-superagents docs/skills.md](https://github.com/teelicht/pi-superagents/blob/main/docs/skills.md)

- **Open Design DESIGN.md**: 9-section schema (Color, Typography, Spacing, Layout, Components, Motion, Voice, Brand, Anti-patterns). YAML frontmatter for staleness detection (`generatedAt`, `projectMtime`). Markdown-first philosophy — human+agent readable.
  - Source: [Open Design 9-section Schema](https://opendesigner.io/blog/design-md-9-section-schema-explained)

- **Anti-pattern**: Too many frontmatter fields = non-portable skills. Superpowers intentionally rejects Claude Code-specific fields (`allowed-tools`, `model`) to stay cross-harness. Finding the right balance between descriptive metadata and portability is critical.

### 4. Auto-Scan After `/session`

- **Ruflo trajectory learning**: 4-step pipeline — trajectory recording (start/step/end), pattern learning (confidence-updating mutable patterns), SONA self-optimization (<0.05ms adaptation), EWC++ consolidation (prevents catastrophic forgetting). Post-task hooks record outcomes and quality scores. Background workers analyze and optimize.
  - Source: [ruvnet/ruflo Intelligence Pipeline](https://github.com/ruvnet/ruflo/wiki/Intelligence-Pipeline)

- **Ruflo hook system**: 17 hooks + 12 background workers. Key hooks: `pre-task` (routing recommendation), `post-task` (record outcome + train patterns), `session-start` (restore state + load patterns), `session-end` (persist + consolidate), `intelligence` (trajectory tracking). Learning loop: task → route → execute → record → train → consolidate → improve.
  - Source: [ruvnet/ruflo Hooks and Workers](https://github.com/ruvnet/ruflo/wiki/Hooks-and-Workers)

- **ECC continuous learning**: Stop hook (not UserPromptSubmit — avoids per-message latency) persists learnings at session end. `continuous-learning` skill auto-extracts patterns from sessions into reusable skills. Next session loads learned skills automatically. Memory persistence hooks save state before compaction.
  - Source: [affaan-m/ECC README](https://github.com/affaan-m/ECC)

- **Anti-pattern**: ECC explicitly warns against using UserPromptSubmit for learning (adds latency to every prompt). Use Stop hook instead — runs once at session end. Also: not every session produces context-worthy patterns. Ruflo uses confidence thresholds and quality scoring to filter noise before pattern promotion.

## Resources

| Title | URL | Description |
|-------|-----|-------------|
| Superpowers Skills System Overview | https://obra-superpowers.mintlify.app/concepts/overview | Auto-triggering skills via SessionStart hook + YAML frontmatter |
| Anatomy of an Agent Skill (Superpowers) | https://www.akashtandon.in/interactive-explainers/superpowers/ | Deep dive on bootstrap mechanism, trigger-only descriptions |
| Ruflo Memory and Graph (HNSW) | https://github.com/ruvnet/ruflo/wiki/Memory-and-Graph | Vector search with HNSW, 3-tier memory, causal knowledge graphs |
| Ruflo Intelligence Pipeline | https://github.com/ruvnet/ruflo/wiki/Intelligence-Pipeline | Trajectory learning, SONA self-optimization, pattern extraction |
| Ruflo Hooks and Workers | https://github.com/ruvnet/ruflo/wiki/Hooks-and-Workers | 17 hooks + 12 workers, learning loop automation |
| ECC (affaan-m) Longform Guide | https://github.com/affaan-m/ECC/blob/main/the-longform-guide.md | Memory persistence hooks, continuous learning, context management |
| Open Design DESIGN.md Schema | https://opendesigner.io/blog/design-md-9-section-schema-explained | 9-section structured Markdown, YAML staleness frontmatter |
| Multica Skills System (commit) | https://github.com/multica-ai/multica/commit/50ae997ab4c3e1ea814c8c29225cbcbead9ef217 | SkillManager, multi-source loading, eligibility filtering, YAML frontmatter |
| Redis Context Retrieval Guide | https://redis.io/blog/context-retrieval-for-ai-agents/ | Agent context retrieval patterns, hybrid search, memory tiers |
| Superpowers writing-skills guide | https://github.com/obra/superpowers/blob/main/skills/writing-skills/SKILL.md | Frontmatter rules, trigger-only descriptions, skill TDD methodology |

## Source Metadata

- Total sources consulted: 20+
- Total sources used: 10 (cited above)
- Date range: 2025-10 to 2026-05
