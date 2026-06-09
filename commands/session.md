---
description: Generate a session report — full summary with YAML frontmatter, timeline update, context scan (patterns/architecture/standards)
agent: Vibuzo
---

Do these steps NOW:

1. **Analyze the entire conversation** — read ALL messages in this session. Distill into the forward-looking template below. ALSO reconstruct the compaction output from the conversation and git state — the Session Compaction section must be auto-filled with the styled box format (see step 4). The compaction captures Goal, Constraints, Progress, Key Decisions, Next Steps, Critical Context, and Relevant Files — complementary to your forward-looking sections, not redundant.

2. **Generate a title** — extract 2-4 key words from the session, convert to kebab-case. Check `context/sessions/` for existing files with the same title today. If collision, append `-2`, `-3`, etc.

3. **Generate YAML frontmatter** — before writing the file, construct a frontmatter block with:

    - `title:` — the kebab-case title from step 2 (same as the filename)
    - `date:` — today's date in YYYY-MM-DD format
    - `tags:` — derive from the session content: include file types changed, keywords from summaries, and common vibuzo tags (versioning, commands, context, installer, docs, sessions, compaction, agent, spec). Pick 3-6 relevant tags.
    - `status:` — `complete` (always, since this runs at session end)

    The frontmatter block looks like:
    ```yaml
    ---
    title: <kebab-case-title>
    date: YYYY-MM-DD
    tags:
      - <tag1>
      - <tag2>
      - <tag3>
    status: complete
    ---
    ```

4. **Create the file** `context/sessions/YYYY-MM-DD-<title>.md` — prepend the frontmatter block from step 3 above the template below, with a blank line separating them. Fill **EVERY section** (including Session Compaction — auto-generate it using the styled box format). If a section has no entries, write "None" explicitly.

    ```markdown
    # <title>

    *Session summary — YYYY-MM-DD | <N> messages | <N> files touched | <N> commits*

    ## Session Summary

    <3-5 sentence paragraph. What was built, changed, or decided? Changelog-style — specific, factual, no fluff.>

    ## Constraints & Preferences

    - **<Topic>:** <rule that governed this session's decisions>
    - **<Topic>:** <same format — only the ones that shaped the session>

    ## Forward Decisions

    | # | Decision | Rationale |
    |---|----------|-----------|
    | 1 | **<Title>** — <concise statement> | <why it was decided this way> |

    Only decisions that shape NEXT session's work. If it won't matter next session, don't include it.

    ## Forward Context

    - <What the next session MUST know — unfinished work, gotchas, state that compaction won't capture>
    - <Keep it to the 2-5 items that are actually actionable next session>

    ## Hot Files

    | File | Why Hot |
    |------|---------|
    | `<path>` | <why it's likely to be touched next session — be specific> |

    Only files likely to be edited/read next session. Not every file touched this session.

    ## Timeline Entry

    | YYYY-MM-DD | HH:MM | `<title>` | <one-line summary> |

    ## Session Compaction

    ````
    ╭─────── Session Compaction ───────────────────────────────────────╮
    │                                                                   │
    │  Session:    <title>                                               │
    │  Date:       YYYY-MM-DD                                            │
    │  Messages:   <N>                                                   │
    │                                                                   │
    ├─────── Goal ──────────────────────────────────────────────────────┤
    │                                                                   │
    │  • <one-line summary of what was achieved>                         │
    │                                                                   │
    ├─────── Constraints & Preferences ─────────────────────────────────┤
    │                                                                   │
    │  • <rules that governed the session>                               │
    │  • <...>                                                           │
    │                                                                   │
    ├─────── Progress ──────────────────────────────────────────────────┤
    │                                                                   │
    │  Done:                                                             │
    │  • <completed items>                                               │
    │  • <...>                                                           │
    │                                                                   │
    │  In Progress:                                                      │
    │  • <...>                                                           │
    │                                                                   │
    │  Blocked:                                                          │
    │  • <...>                                                           │
    │                                                                   │
    ├─────── Key Decisions ─────────────────────────────────────────────┤
    │                                                                   │
    │  • <decisions that shape next session>                             │
    │  • <...>                                                           │
    │                                                                   │
    ├─────── Next Steps ────────────────────────────────────────────────┤
    │                                                                   │
    │  • <actionable steps>                                              │
    │  • <...>                                                           │
    │                                                                   │
    ├─────── Critical Context ──────────────────────────────────────────┤
    │                                                                   │
    │  • <git state, gotchas, unfinished work the next session needs>    │
    │  • <...>                                                           │
    │                                                                   │
    ├─────── Relevant Files ────────────────────────────────────────────┤
    │                                                                   │
    │  <path>                  │ <why it's hot next session>             │
    │  <path>                  │ <...>                                   │
    │                                                                   │
    ╰───────────────────────────────────────────────────────────────────╯
    ````
    ```

5. **Update the timeline** at `context/sessions/index.md` — if it doesn't exist, create it with:
    ```
    # Session Timeline

    Auto-generated by `/session`. Updated on every summary.

    | Date | Time | File | Summary |
    |------|------|------|---------|
    ```
    Then append the new row:
    ```
    | YYYY-MM-DD | HH:MM | `<title>` | <one-line summary> |
    ```

6. **Print this status box**:
    ```
    ── SESSION ──────────────────────────────────────
    Saved:   context/sessions/YYYY-MM-DD-<title>.md
    Files:   <N> touched
    Commits: <N>
    Timeline: updated (N total summaries)
    Compaction: auto-generated
    ────────────────────────────────────────────────
    ```

7. **Scan for context candidates (patterns, architecture, or standards)** — using the session file and conversation history, scan for knowledge worth preserving permanently across all three context types:

    - Read the **Forward Decisions** section — any decision that is a new rule, convention, or architectural choice belongs in `context/standards/` or `context/architecture/`
    - Read the **Session Summary** and **Progress** — any workaround, trick, or insight that isn't documented elsewhere
    - Check if any **Hot Files** were newly created context files — already saved; skip. But if new patterns, architecture insights, or standards emerged from modifications, they may be candidate material
    - Also scan the conversation for:
      - **Standards:** New conventions, naming rules, process preferences (e.g., "we use pnpm not npm")
      - **Architecture:** System design decisions, component relationships, data flow choices
      - **Patterns:** Repeated code patterns, reusable idioms, workflow templates
      - Tooling preferences discovered

    For each candidate, generate:
    - Suggested file name (kebab-case, under `context/standards/`, `context/architecture/`, or `context/patterns/`)
    - Suggested frontmatter (tags, scope, when)
    - Brief content summary

    Then present candidates **one at a time** in this format:
    ```
    ── CONTEXT CANDIDATE ──────────────────
    Candidate 1 of <N>
    Type: <standard | architecture | pattern>
    Name: <filename.md>
    Tags: <tag1, tag2, tag3>
    Scope: <description>
    When: <trigger>
    Content: <1-2 sentence summary>
    ───────────────────────────────────────
    Save to context? (y/N/edit):
    ```
    - If "y": save the file to the appropriate `context/` directory with generated frontmatter + content, update `context/index.md`
    - If "edit": let the user modify name/tags/scope/when, then save
    - If "N" (or anything else): skip to next candidate
    - After all candidates are processed, append a `## Context Candidates` section to the session file listing each candidate with its type and whether it was saved or skipped

8. **Instruct the user on the workflow** — after the pattern scan, print:

    ```
    ── NEXT STEPS ──────────────────────────
    Your session file is ready at context/sessions/YYYY-MM-DD-<title>.md

    Next steps:
    - /new => Switch to Vibuzo => /session-init
    ─────────────────────────────────────────
    ```
