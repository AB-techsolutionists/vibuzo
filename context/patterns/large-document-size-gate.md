# Large Document Size Gate

When generating large documents (e.g., a comprehensive README, full framework guide, or extensive documentation), always check with the user about size before writing.

## The Pattern

Before writing a file that will exceed ~200 lines:

1. **Preview the scope** — briefly summarize what sections will be included and the estimated line count
2. **Ask permission** — "This will be approximately N lines. Proceed?"
3. **Offer chunking** — if the user hesitates, offer to split into multiple focused files instead

## Why

A 416-line README was generated via a comprehensive plan, approved, written — then immediately discarded by the user with "its too big, nevermind. forget it." The size wasn't surfaced before writing, leading to wasted effort.

## Rule of Thumb

| Size | Action |
|------|--------|
| < 100 lines | Write freely |
| 100–200 lines | Give a heads-up: "~N lines, okay?" |
| > 200 lines | Gate with estimated size and offer to chunk |

## Related

- [`Karpathy Principle 2 — Simplicity First`](../../AGENTS.md#2-simplicity-first) — minimum code that solves the problem
