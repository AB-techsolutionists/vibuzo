---
description: Research a topic via web search using Deepsearcher
agent: Deepsearcher
subtask: true
---

Research the following topic: $ARGUMENTS

1. Infer the feature name from the research query:
   - Take $ARGUMENTS (the full query) as the feature basis
   - Convert to kebab-case (e.g., "react state management 2026" → "react-state-management-2026")
   - This becomes the `<feature>` name for directory and file creation
2. Create `specs/<feature>/` directory if it doesn't exist.
3. Conduct web research on the topic:
   - Use `websearch` to find relevant information. Use multiple search queries if needed to cover different angles.
   - Use `webfetch` on the most promising URLs to get detailed content. Prioritize official documentation, reputable sources, and recent content.
   - Synthesize findings into coherent sections. Cross-reference sources. Identify patterns, conflicts, and gaps.
4. Save the structured research output to `specs/<feature>/research.md` using this format:

```markdown
# Research: <Feature/Topic Name>

**Date:** YYYY-MM-DD
**Status:** Complete | Partial | Failed

## Summary

<2-3 sentence overview>

## Key Findings

1. **Finding Title**
   - Detail
   - Source: [Title](url)

2. **Finding Title**
   - Detail
   - Source: [Title](url)

## Resources

| Title | URL | Description |
|-------|-----|-------------|
| Title | url | Brief description |

## Source Metadata

- Total sources consulted: N
- Total sources used: N
- Date range: YYYY-MM-DD to YYYY-MM-DD
```

5. Report back with status using this format:

```
Status: ✅ Done | ⚠️ Partial | ❌ Failed
Summary: <2-3 sentence overview of what was found>
Key Findings:
  - Finding 1 (source)
  - Finding 2 (source)
  - Finding 3 (source)
Resources:
  - [Title](url) — description
  - [Title](url) — description
Source Metadata:
  - Total sources consulted: N
  - Total sources used: N
  - Date range: YYYY-MM-DD to YYYY-MM-DD
```
