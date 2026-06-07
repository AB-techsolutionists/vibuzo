# Vibuzo — Agentic Framework

Vibuzo is an agentic framework for AI coding agents — it gives you a planning-first workflow, persistent project context, session summaries, and a dedicated implementation agent for complex features.

## Three-Agent System

| Agent | Role | Mode |
|-------|------|------|
| **Vibuzo** | Plans, executes everyday tasks, runs `/spec` pipeline | Main (`mode: primary`) |
| **Deepveloper** | Pure implementation — spawned as subtask via `/spec` | Subtask (`mode: subagent`) |
| **Deepsearcher** | Web research — spawned as subtask via `/research` or inline via `@deepsearcher` | Subtask (`mode: subagent`) |

## Agent Structure

```
├── AGENTS.md              ← Universal entry point (read by 25+ tools)
├── .opencode/
│   ├── agent/core/vibuzo.md      ← Main agent (approval_level: 3)
│   ├── agent/core/deepveloper.md ← Implementation sub-agent
│   ├── agent/core/deepsearcher.md← Research sub-agent
│   ├── commands/                 ← 11 command files (commit, research, spec, context*, session*)
│   └── .vibuzo-version           ← Version marker
├── context/                      ← Project knowledge base (auto-loaded on /new)
│   ├── index.md                  ← Auto-updated table of contents
│   ├── architecture/             ← Architecture Decision Records
│   ├── standards/                ← Rules and conventions
│   ├── patterns/                 ← Reusable idioms
│   └── sessions/                 ← Summary archives (via /session)
└── specs/                        ← Created on demand by /spec
```

## How Commands Work

Every command file follows this pattern:

```yaml
---
description: <what it does>
agent: Vibuzo
---
Do these steps NOW:
1. ...
```

- `subtask: true` (optional) tells opencode to run this via the task tool. **Not used** for context/session commands — they run in the main session to access conversation history. Used for `/spec`, `/add-context`, and `/research`.
- `Do these steps NOW:` is the only imperative instruction — one file, one purpose
- `$ARGUMENTS` is substituted at the top of the file (parsed from the user's `/command ...` text)
- `/research [query]` routes to Deepsearcher for structured web research, saving results to `specs/<feature>/research.md`
- `@deepsearcher` invokes Deepsearcher inline for ad-hoc research without the full pipeline

## Context Auto-Load

At session start, read `context/index.md` to discover project conventions. This file also chains to the latest session summary:

1. `context/index.md` → lists all architecture, standards, patterns
2. `context/sessions/index.md` → master timeline of all summaries
3. Latest session file → previous session's state, decisions, pending work

This chain ensures every new session automatically picks up where the last one left off — no manual prompting needed.

## Working With the Context System

- **Scaffold:** `/context init` — ensures all 4 directories exist
- **Add knowledge:** `/add-context <statement>` — agent infers type (architecture/standard/pattern) and file name
- **Scan conversation:** `/context append` — scan current conversation for context-worthy patterns and save them
- **Mine sessions:** `/context harvest` — read all session summaries and present patterns worth promoting to permanent context
- **Search:** `/context find <topic>` — exact match first, then broader keyword search
- **Update index:** After creating, modifying, or deleting any file under `context/`, update `context/index.md` immediately

## Context Auto-Query

Before starting ANY implementation task (file creation, modification, deletion, or code generation), the agent MUST auto-scan the context system for relevant knowledge. This does NOT apply to simple queries, analysis-only requests, conversation, or `/` commands.

### Auto-Scan Rules

1. **Read context/index.md** to discover all available context files
2. **For each file listed**, read its YAML frontmatter to extract `tags:`, `scope:`, `when:` fields
3. **Score relevance** by counting keyword/tag overlap between the task description and each file's scope/tags/when:
   - Each matching tag/keyword = +1 score point
   - Matching scope description = +2 score points
   - Matching when trigger = +2 score points
4. **Act on score**:
   - **>2 matches**: Load the full file content into working context. Present as:
     ```
     [Context] Found <N> relevant files: loading <file1>, <file2>...
     ```
   - **1-2 matches**: List as "Possibly relevant" with the file name and scope, allowing the user to opt-in
   - **No matches** (>2 threshold): Still list the top 3 scoring candidates with their scope so the user knows what's available
5. **Skip cases** — Do NOT trigger auto-scan for:
   - Simple questions or analysis requests
   - Conversation-only interactions
   - `/` commands (context commands, session commands, spec, etc.)
6. **Presentation** — Results are displayed inline without user prompting. The loaded context becomes part of the working session for the implementation task.

## Session Management

At natural breakpoints:
1. Run `/session` to create `context/sessions/YYYY-MM-DD-<title>.md` with a comprehensive summary — full narrative summary, chronological log of every request/action/file/decision, file manifest, commands invoked, and git state
2. `/session` then scans the new summary for context-worthy patterns and presents them as save candidates (you approve before anything is saved)
3. The timeline at `context/sessions/index.md` auto-updates

**Each session file includes a Session Compaction section at the bottom** — a placeholder where you paste opencode's `/compact` output after running `/session`. This block is then copy-pasted as starting context for the next session.

**Golden workflow:** `/session → /compact → paste into Session Compaction → /new` in that order. After `/session` completes, run `/compact` in opencode's TUI, copy the output, and paste it into the Session Compaction section in the session file. When starting a new session, copy that block as your starting context. Never `/compact` without `/session` first.

**Session sub-commands:**
- `/session` — generate and save a comprehensive summary
- `/session view [session name or date..]` — browse past summaries
- `/session timeline` — show all summaries chronologically

## Approval Gates

`approval_level` in the Vibuzo agent file controls strictness (0-3). Current value: **3** (Full Control).

| Level | Name | What's Gated |
|-------|------|-------------|
| 0 | Trusted | Nothing |
| 1 | Safe | File mutations + destructive commands |
| 2 | Cautious | All file ops + all commands + delegation |
| 3 | Full Control | Everything including planning and large reads |

Gate prompts use this format inside a code block:
```
── APPROVAL GATE ──────────────────────
Action: <write | edit | delete | command | delegate>
Target: <file path or command string>
Details: <summary of what will change>
───────────────────────────────────────
Approve? (y/N):
```

Override inline: add "at gate level X" to any request.

## Karpathy Principles (Guidelines)

Behavioral guidelines to reduce common AI coding mistakes, derived from [Andrej Karpathy's observations](https://x.com/karpathy) on LLM coding pitfalls.

### 1. Think Before Coding
**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- **State your assumptions explicitly.** If uncertain, ask rather than guess.
- **Present multiple interpretations.** If ambiguity exists, enumerate options — don't pick silently.
- **Push back when warranted.** If a simpler approach exists, say so.
- **Stop when confused.** Name what's unclear and ask for clarification.

### 2. Simplicity First
**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: *"Would a senior engineer say this is overcomplicated?"* If yes, simplify.

### 3. Surgical Changes
**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it — don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

**The test:** Every changed line should trace directly to the user's request.

### 4. Goal-Driven Execution
**Define success criteria. Loop until verified.**

Transform imperative tasks into verifiable goals:

| Instead of... | Transform to... |
|---|---|
| "Add validation" | "Write tests for invalid inputs, then make them pass" |
| "Fix the bug" | "Write a test that reproduces it, then make it pass" |
| "Refactor X" | "Ensure tests pass before and after" |

For multi-step tasks, state a brief plan with verification at each step:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

> **📝 Note for your project:** This file was installed by Vibuzo.  
> Add your custom project rules below the marker — they will be preserved across updates.

─── PASTE YOUR CUSTOM RULES BELOW THIS LINE ───

