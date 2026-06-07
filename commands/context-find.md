---
description: Search project context for a topic
agent: Vibuzo
---

Search project context files using semantic relevance scoring.

Do these steps NOW:

1. **Parse query** — take the argument text after the "find " prefix. If no topic is present (just "find" with nothing after it), read and display `context/index.md` as a menu. Otherwise, parse the query into lowercase tokens (split on whitespace and punctuation).

2. **Collect context files** — gather all `.md` files from:
   - `context/patterns/*.md`
   - `context/standards/*.md`
   - `context/architecture/*.md`
   - `context/sessions/*.md`

3. **Score each file** — for every file, extract searchable text and compute a composite relevance score (0.0–1.0):

   a. **Extract searchable text** — read the file's frontmatter (if present) for `tags:`, `scope:`, `when:` fields, plus the file title (derived from filename or first `#` heading). If no frontmatter exists, use the filename + first 200 characters of content.

   b. **Keyword overlap score (40%)** — fraction of query tokens found anywhere in the searchable text (tags, scope, when, title). Example: query "naming" with 1 token → 1.0 if "naming" appears in any field, 0.0 otherwise. For multiple tokens: count of matched tokens / total tokens.

   c. **TF-IDF-like score (30%)** — for each query token, compute term frequency within the file's searchable text vs. corpus frequency across all files. Tokens that are rare in the corpus but common in this file score higher. Simplified: `score = sum over tokens of (tf_in_file / total_tokens_in_file) * log(total_files / (1 + files_containing_token))`.

   d. **Fuzzy/Levenshtein similarity score (30%)** — for each query token, compute the normalized Levenshtein similarity against each tag/scope/when word. Take the highest match per token. `similarity = 1 - (edit_distance / max(len(a), len(b)))`. If similarity > 0.7, consider it a match at partial weight.

   e. **Combine**: `final_score = 0.4 * keyword + 0.3 * tfidf + 0.3 * fuzzy`

4. **Sort and display** — sort results by score descending. Display each as:
   ```
   [0.85] filename.md — scope description, tags, when
   ```
   Show the top 10 results maximum. If any file has score > 0.5, mark it as a "strong match" and offer to read it. Cap processing at 100 files for performance.

5. **No frontmatter fallback** — for files without YAML frontmatter, compute score based on filename token matching + content word frequency. These files will still appear in results but will have lower scores.

6. **No results** — if all scores are below 0.1, inform the user and suggest `/add-context <statement about topic>` with an example relevant to their search.
