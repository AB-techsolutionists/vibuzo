# Title-Based Session Naming

## Pattern

Session compaction files use descriptive title-based filenames instead of opaque sequence numbers.

## Format

```
context/sessions/YYYY-MM-DD-<title>.md
```

- **Date prefix** — `YYYY-MM-DD` (e.g., `2026-06-04`)
- **Title** — 2-4 key words extracted from conversation content, converted to kebab-case
- **Extension** — `.md`

## Title Generation

1. Analyze the conversation for 2-4 key concepts
2. Convert to kebab-case (lowercase, hyphens between words)
3. Example: session about redesigning compaction → `session-redesign`

## Collision Handling

| Scenario | Result |
|----------|--------|
| No existing file with same title today | `YYYY-MM-DD-<title>.md` |
| One existing file with same title today | `YYYY-MM-DD-<title>-2.md` |
| Two existing files | `YYYY-MM-DD-<title>-3.md` |

Check is scoped to the current date only — titles reset each day.

## Examples

| File | Content |
|------|---------|
| `2026-06-04-session-redesign.md` | First compaction — session redesign spec |
| `2026-06-04-session-polish.md` | Second compaction — session command refinement |

## Rationale

Title-based names are human-readable at a glance. You know what a session contains just from the filename, unlike sequence numbers (`001`, `002`) or single-date files (`2026-06-04.md`).
