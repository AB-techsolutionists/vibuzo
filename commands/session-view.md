---
description: View session compaction files
agent: Vibuzo
---

## RUN: `/session view <ref>`

Do these steps NOW:

Parse the `<ref>` after "view" and do ONE of:

- **Exact filename match** (e.g., `2026-06-04-session-redesign`) → read and print that file's full content
- **Date only** (e.g., `2026-06-04`) → list all compactions for that date with one-line summaries. Include legacy `YYYY-MM-DD.md` files too.
- **`yesterday`** → same as date-only with yesterday's date
- **`today`** → same as date-only with today's date
- **`last`** → find the most recent compaction file (sort by filename descending) and print it
- **`recent`** → find the 3 most recent compaction files and print summaries
- **`all`** → list every compaction across all dates with one-line summaries
- **Empty** → show the timeline and offer to pick one
