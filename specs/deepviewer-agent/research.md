# Research: Deepviewer Agent — Codebase Analysis Agent

**Date:** 2026-06-08
**Status:** Complete

## Summary

Research into design patterns, existing tools, and best practices for building a specialized LLM-driven codebase analysis agent ("deepviewer"). Covers static analysis tool approaches, multi-agent auditing architectures, git history analysis for project evolution tracking, stale documentation detection, audit report structuring, and scanning strategies. Key insight: hybrid approaches combining AST/graph-based structural analysis with LLM reasoning consistently outperform pure LLM or pure rule-based approaches.

## Key Findings

1. **Existing SAST Tools Take Four Approaches**
   - Rule-based AST analysis (SonarQube) — mature, high ruleset (6,500+), good code quality focus but shallower security. Requires Java expertise for custom rules.
   - Lightweight pattern matching (Semgrep) — fast (20k-100k LOC/s), accessible YAML rules, 2.4x better detection than SonarQube on benchmarks but single-file only in OSS version.
   - Database query approach (CodeQL) — treats code as a queryable database with QL DSL. Deepest semantic analysis with cross-file taint tracking. Requires compilation step (minutes to hours).
   - AI/ML-powered analysis (Snyk Code, Rafter) — context-aware, lower false positives, but opaque reasoning.
   - Benchmark finding (arXiv 2508.04448): LLMs achieve higher F1 (0.75-0.80) vs SAST tools (0.26-0.55) for vulnerability detection, but with higher false positives and imprecise line-level localization. **Best results come from hybrid pipelines.**
   - Source: [Static Code Analysis Tools Comparison](https://rafter.so/blog/static-code-analysis-tools-comparison), [LLMs vs SAST Benchmark](https://arxiv.org/html/2508.04448v1)

2. **Agent-Driven Codebase Auditing Patterns**
   - **Role-Based Cooperation** (most common pattern at 46.8%): Specialized agents with distinct personas. Example: Aegis-Wilwatikta uses Scout (data gatherer) + Architect (deep reviewer) + Diplomat (communication formatter).
   - **Planner → Critic → Rewriter** loop: ChuksForge/code-review-agent uses a critic pass to score findings on severity × confidence, achieving 90%+ precision vs ~30% without critic.
   - **Self-Reflection** (36.2% adoption): Agent reviews its own outputs before finalizing. Useful for audit reliability.
   - **Tool-Agent Registry** (14.9%): Agents dynamically discover and invoke analysis tools (AST parsers, linters, semgrep).
   - **Two-agent architecture**: SWE-Adept uses a localization agent (depth-first dependency traversal) + resolution agent (checkpointed fix implementation), improving resolve rates by 4.3%.
   - Source: [Designing LLM-based MAS for SE Tasks](https://arxiv.org/html/2511.08475v2), [SWE-Adept](https://arxiv.org/html/2603.01327), [code-review-agent-public](https://github.com/ChuksForge/code-review-agent-public)

3. **Graph-Based Code Representation Is Critical for Scalability**
   - Tree-Sitter-based knowledge graphs (Codebase-Memory) achieve 83% answer quality at 10x fewer tokens and 2.1x fewer calls vs file-exploration agents across 31 repos.
   - Structural graphs expose 14 query types (call-path tracing, impact analysis, hub detection) with sub-millisecond latency.
   - GraphCodeAgent uses dual graphs (requirement graph + structural-semantic code graph) for multi-hop code retrieval.
   - CodeQL's data-flow graph (DFG) separates syntactic AST view from semantic data-flow view — best practice is to use AST for surface queries, DFG for deep analysis.
   - **Recommendation**: Deepviewer should use Tree-Sitter AST parsing + graph-based storage for efficient structural queries, with LLM fallback for source-level reasoning.
   - Source: [Codebase-Memory](https://arxiv.org/pdf/2603.27277), [GraphCodeAgent](https://arxiv.org/html/2504.10046), [CodeQL Library for Go](https://codeql.github.com/docs/codeql-language-guides/codeql-library-for-go/)

4. **Git History Analysis for Project Evolution**
   - **Historex**: AI-powered repo archaeology — extracts commits, computes churn per file, detects architectural rewrite periods, ownership shifts, technical debt language ("hack", "legacy", "temporary", "quick fix"). Architecture: Python extracts facts → LLM interprets patterns → reports rendered deterministically (hallucination-safe design).
   - **RepoGraph (FalkorDB)**: Turns git history into a knowledge graph. Key metrics: bus factor, blast radius (co-change relationships), knowledge silos, module coupling, risk hotspots (topology + temporal combined).
   - **git-forensics**: Lightweight TypeScript library. Percentile-based classification (self-calibrating across any codebase size). Composite risk scoring combining churn, coupling, code age, ownership fragmentation.
   - **GitVoyant**: Time-series cyclomatic complexity tracking — trend analysis (improving/declining/stable) with confidence scoring.
   - **Recommendation**: Analyze git history through commit ingestion → fact extraction (churn, coupling, ownership) → LLM interpretation → report generation pipeline. Focus on recent 6-9 months to reduce noise.
   - Source: [Historex](https://github.com/beingbiplov/Historex), [RepoGraph](https://github.com/FalkorDB/RepoGraph), [git-forensics](https://github.com/itaymendel/git-forensics), [GitVoyant](https://github.com/Cre4T3Tiv3/gitvoyant)

5. **Stale Documentation Detection Techniques**
   - **Semantic extraction approach** (living-docs): Extract semantic markers from code changes (function names, params, env vars, endpoints), glob doc files, spawn staleness-detector subagent per file that compares doc content vs current code. Classifies: outdated / missing / broken-link / wrong-example. Surgical fix — edits only stale lines.
   - **Three-layer hybrid** (veritas): Embedding-based screening (handles 85%, 10ms per comparison) → LLM analysis (edge cases, 2s per comparison) → adaptive routing. 88% cost reduction vs LLM-only at 92% accuracy.
   - **21 detection categories** (doc-freshness-analyzer): FILE_NOT_FOUND, VERSION_MISMATCH, IMPORT_PATH_WRONG, FUNCTION_RENAMED, etc. Produces freshness score (0-100) with SmartMode (77% token reduction) prioritizing "active" files.
   - **AI context drift detection** (ctxharness): Three-layer approach — L1: fact drift (file existence, scripts, versions), L2: instruction quality (vague language, token budget), L3: context assembly (hook validity, skill loading).
   - **Recommendation**: Hybrid approach — fast embedding screening for 85% of comparisons, LLM for edge cases. Categorize drift types. Produce quantitative freshness scores.
   - Source: [living-docs](https://github.com/phlx0/living-docs), [doc-freshness-analyzer](https://github.com/Tenormusica2024/doc-freshness-analyzer), [veritas](https://github.com/niloy-saha-123/veritas), [ctxharness](https://github.com/FlorianBruniaux/ctxharness)

6. **Audit Report Structure Standards**
   - **Executive Summary** (1-2 pages): Severity distribution table (Critical/High/Medium/Low), risk assessment, recommendation, key metrics (files analyzed, test gaps, blast radius).
   - **Findings**: Each finding needs severity + CVSS score, affected component (file:line), description, business impact, reproduction steps, evidence, root cause, remediation.
   - **Attack chain narratives**: For chained vulnerabilities — describe the full exploitation path, not just individual issues.
   - **12-section comprehensive audit checklist** (ForaSoft): Architecture → Code Quality → Security → Performance → Database → Infrastructure → Tests → Documentation → Compliance → Tech Debt → Team Skills → Cost of Ownership.
   - **Strategic observations**: Pattern-level findings across issues (e.g., "authorization broken in 5 places = missing auth layer, not 5 independent bugs").
   - **Remediation plan**: Phased (Immediate / Phase 1 / Phase 2 / Phase 3) with effort estimates.
   - **Recommendation**: Deepviewer report should follow: Executive Summary → Methodology → Architecture Map → Findings by Category (with severity + evidence) → Strategic Observations → Remediation Roadmap → Appendices.
   - Source: [AI Code Audit Report Template](https://www.romanticode.com/templates/ai-code-audit-report-template/), [Trail of Bits Reporting](https://github.com/trailofbits/skills/blob/main/plugins/differential-review/skills/differential-review/reporting.md), [12-Section Audit Checklist](https://www.forasoft.com/blog/article/software-code-audit-checklist-2026), [VAPT Report Template](https://ringsafe.in/vapt-report-sample/)

7. **Scanning Strategies: File-by-File vs. Pattern-Based**
   - **Agent-directed depth-first traversal** (SWE-Adept): Agent follows dependency paths selectively, defers full code loading to final re-ranking stage. Lightweight structural info during traversal, full content only for shortlisted locations. Minimizes context window consumption.
   - **File-by-file with key file prioritization** (project-review-agent): Uses code2prompt for structure, detects key files via importance scoring (entry points +50, imported by other files +30/file, modified within 30 days +20).
   - **Graph-based with community detection** (Codebase-Memory): Louvain community detection identifies module clusters. Structural queries (call-path, impact analysis) in sub-millisecond vs iterative file reading.
   - **Batch processing for large codebases**: Production systems use batching for 100k+ LOC. Confucius Code Agent uses hierarchical working memory with adaptive context compression to handle long sessions.
   - **Recommendation**: Three-phase strategy — (1) Graph-based structural scan for dependency/coupling analysis, (2) Pattern-based grep for cross-cutting concerns (security patterns, duplicated logic), (3) Targeted file-by-file deep read for high-priority files only.
   - Source: [SWE-Adept](https://arxiv.org/html/2603.01327), [Codebase-Memory](https://arxiv.org/pdf/2603.27277), [Confucius Code Agent](https://arxiv.org/pdf/2512.10398v6), [project-review-agent](https://github.com/elveder-ai/project-review-agent)

## Resources

| Title | URL | Description |
|-------|-----|-------------|
| LLM-based MAS for SE Tasks | https://arxiv.org/html/2511.08475v2 | Catalog of 16 design patterns for LLM multi-agent systems, role-based cooperation most common at 46.8% |
| SWE-Adept | https://arxiv.org/html/2603.01327 | Two-agent framework (localization + resolution) with depth-first codebase traversal and checkpointed fixes |
| Codebase-Memory | https://arxiv.org/pdf/2603.27277 | Tree-Sitter knowledge graphs via MCP — 10x token reduction vs file-exploration agents, 66 languages |
| Historex | https://github.com/beingbiplov/Historex | AI-powered repo archaeology — reconstructs architectural evolution from git history |
| RepoGraph | https://github.com/FalkorDB/RepoGraph | Git history as knowledge graph — bus factor, blast radius, knowledge silos via FalkorDB |
| Semgrep vs SonarQube (2026) | https://konvu.com/compare/semgrep-vs-sonarqube | Head-to-head SAST comparison — Semgrep 46% vs SonarQube 19% detection rate on security benchmarks |
| LLMs vs SAST Benchmark | https://arxiv.org/html/2508.04448v1 | Systematic comparison: LLMs achieve higher recall but higher false positives — hybrid pipeline recommended |
| living-docs | https://github.com/phlx0/living-docs | Semantic stale-doc detection plugin — extracts code markers, compares docs, surgically fixes stale lines |
| doc-freshness-analyzer | https://github.com/Tenormusica2024/doc-freshness-analyzer | 21 detection categories for doc drift, freshness scores, SmartMode for token efficiency |
| AI Code Audit Report Template | https://www.romanticode.com/templates/ai-code-audit-report-template/ | Production-ready audit report structure: overview, architecture map, inspection areas, cleanup priorities, handoff notes |

## Source Metadata

- Total sources consulted: 30+
- Total sources used: 10 primary (listed above) + 15 supplementary
- Date range: 2025-07 to 2026-06
