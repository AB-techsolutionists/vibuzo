---
description: Research a topic via web search using Deepsearcher
agent: Deepsearcher
subtask: true
---

Research the following topic and report back to Vibuzo: $ARGUMENTS

1. Conduct web research on the topic:
   - Use `websearch` to find relevant information. Use multiple search queries if needed to cover different angles.
   - Use `webfetch` on the most promising URLs to get detailed content. Prioritize official documentation, reputable sources, and recent content.
   - Synthesize findings into coherent sections. Cross-reference sources. Identify patterns, conflicts, and gaps.
2. **Do not create any files** — this is a pure research-and-report task.
3. Report back with findings using this format:

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
