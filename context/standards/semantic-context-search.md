---
tags:
  - context-search
  - semantic-search
  - tf-idf
  - levenshtein
  - fuzzy-matching
scope: Search behavior for the /context find command
when: Enhancing or debugging the context search system
---

# Semantic Context Search

**Date:** 2026-06-07
**Status:** Active

## Overview

Vibuzo's `/context find` command uses a 3-factor semantic scoring system to rank context files by relevance. This replaces simple keyword grep with ranked results (0.0–1.0).

## Scoring Formula

| Factor | Weight | Description |
|--------|--------|-------------|
| Keyword overlap | 40% | Fraction of query tokens found in file's frontmatter (tags, scope, when) + title |
| TF-IDF-like | 30% | Term frequency within file vs. corpus frequency across all files |
| Levenshtein similarity | 30% | Normalized edit distance between query tokens and tags/scope/when words |

**Final score:** `0.4 × keyword + 0.3 × tfidf + 0.3 × fuzzy`

## How It Works

1. **Parse query** into lowercase tokens (split on whitespace and punctuation)
2. **Extract searchable text** from each file: frontmatter `tags:`, `scope:`, `when:` fields + filename + first `#` heading
3. **Score each file** using the 3-factor formula
4. **Sort by score descending**, show top 10 results
5. **Fallback**: Files without YAML frontmatter use filename + first 200 chars of content

## Display Format

```
[0.85] filename.md — scope description, tags, when
```

Scores > 0.5 are marked as "strong matches." Performance is capped at 100 files for sub-2-second response.

## No External Dependencies

Semantic search uses in-file algorithms only — no vector database, no embedding API, no npm packages. This keeps the system file-based and portable.

## Related

- [`context/index.md`](../index.md) — context file index
