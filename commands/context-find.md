---
description: Search project context for a topic
agent: Vibuzo
subtask: true
---

Search project context files for a matching topic.

Do these steps NOW:

1. **Parse the topic** — take the argument text after the "find " prefix. If no topic is present (just "find" with nothing after it), read and display `context/index.md` as a menu.

2. **Exact match (primary)** — search for exact filename or title match in:
   - `context/patterns/*.md`
   - `context/standards/*.md`
   - `context/architecture/*.md`
   - `context/sessions/*.md`
   
   A file matches if the topic appears in the filename (case-insensitive, partial match is fine) OR the first heading (`# Title`) of the file contains the topic.

   If match found: read the file(s) and present full content to the user. Stop here.

3. **Broader search (fallback)** — if no exact match, scan all `.md` files in the same four directories for keyword matches in both filenames and file content:
   - Rank results: filename matches rank higher than content matches
   - For each result present:
     - File path
     - Brief content summary (first 1-2 lines or a relevant excerpt containing the keyword)

4. **No results** — if nothing found, inform the user and suggest `/add-context <statement about topic>` with an example relevant to their search.
