# Session Summary Forward Template

The session summary file (`context/sessions/YYYY-MM-DD-<title>.md`) uses a forward-looking 7-section template designed to complement `/compact` output — never duplicate it.

## Core Rule

**If `/compact` covers it well, the agent sections don't repeat it.**

| `/compact` Domain | Agent Responsibility |
|---|---|
| Chronological log of every message | ❌ Omitted — compaction captures this exhaustively |
| Every file touched with content | ❌ Omitted — compaction lists every read/write |
| Every tool call / command invoked | ❌ Omitted — compaction records all tool uses |
| Git state, config, deps, env | ❌ Omitted — compaction reports live state |
| Intent, constraints, big picture | ✅ Agent writes this — compaction is message-level |
| Categorized progress (done/in-progress/blocked) | ✅ Agent writes this — compaction is linear |
| Curated decisions that shape next session | ✅ Agent writes this — compaction dumps every decision |
| Forward context and gotchas | ✅ Agent writes this — compaction reports raw state |
| Files most likely touched next session | ✅ Agent writes this — compaction lists all files |

## Template Structure

```
## Session Summary           ← 3-5 sentence changelog. Facts only.
## Constraints & Preferences ← Format rules, conventions that governed the session.
## Progress                  ← Done / In Progress / Blocked. Reference specific files.
## Forward Decisions         ← Curated decisions that shape NEXT session. Table format.
## Forward Context           ← State, gotchas, unfinished work next session MUST know. 2-5 items.
## Next Steps                ← Standard workflow instructions.
## Hot Files                 ← Max 8 files likely touched next session. Curated, not exhaustive.
## Timeline Entry            ← Single row for the master index.
## Session Compaction        ← Paste target for /compact output.
```

## Section Details

### Session Summary
A tight 3-5 sentence paragraph telling the complete story. Changelog-style — specific, factual, no fluff. Example:
> "Added version tracking (0.x.x semver) to Vibuzo, removed the source-mirror sync convention, and saved the large-document-size-gate pattern. Three commits pushed."

### Constraints & Preferences
Rules and preferences that governed the session's decisions. Bullet list with bold topics. Only include what actually shaped decisions — don't list every preference the user has ever stated.

### Progress
Three subsections: Done, In Progress, Blocked. Done items reference specific files and features. Use *(none)* for empty sections.

### Forward Decisions
Table format with #, Decision, and Rationale columns. Only include decisions that will matter in the next session. If a decision was made but won't affect future work, omit it.

### Forward Context
2-5 bullet points that the next session MUST know. Focus on:
- Unfinished work and where to pick up
- Gotchas and hard-won lessons
- State that compaction won't capture (e.g., "this pattern isn't wired into agent rules yet")
- Relationships between changed files

### Next Steps
Standard three-step workflow:
1. Run `/compact` in opencode TUI
2. Copy output and paste into Session Compaction section
3. That block becomes starting context for next `/new` session

### Hot Files
Table with File and Why Hot columns. Curated to 5-8 files most likely to be edited or read next session. Not every file touched this session. The "Why Hot" column should be specific — e.g., "4 strings to bump — highest miss risk" not just "needs update."

## Naming Convention

Agent-curated sections use forward-looking names to distinguish them from compaction's exhaustive sections:

| Agent Section | Compaction Equivalent | Why Different |
|---|---|---|
| **Forward Decisions** | Decisions (in chron log) | Agent curates only the ones that shape next session; compaction dumps every decision inline |
| **Forward Context** | State / env info | Agent synthesizes what matters next; compaction reports raw state |
| **Hot Files** | File manifest | Agent lists likely touch targets (max 8); compaction lists everything |

## Origin

Established in `versioning-mirror-cleanup` (2026-06-07) when the 11-section template was consolidated to 7 sections to eliminate duplication with `/compact` output. Codified in `commands/session.md` (the template) and `agents/vibuzo.md` (the agent behavioral rules).
