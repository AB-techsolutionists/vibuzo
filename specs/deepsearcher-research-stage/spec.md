# Deepsearcher Research Stage — Specification

## Principles

- **Composable pipeline stage** — The Research stage is an optional Phase 0 in the existing 5-phase spec pipeline. It must integrate cleanly without breaking existing phases.
- **Agent parity with Deepveloper** — Deepsearcher is a new subagent, following the same pattern as Deepveloper (subtask invocation, report-back format, permission model).
- **Minimal surface area** — A single new command (`/research`), one new agent definition, and one inline invocation method (`@deepsearcher`). No changes to existing agents or commands beyond adding the Research phase to `/spec`.
- **Research as context** — Research output is saved as structured Markdown and feeds into the Spec phase as contextual input. It should not replace or duplicate the spec.
- **Opt-in, not required** — The Research stage is always skippable. Users who already know what they want should not be forced through a web research step.

## Specification

### Overview

Add a **Research stage** to the beginning of Vibuzo's feature development pipeline. This stage introduces a new agent called **Deepsearcher** — a web research specialist that runs as a subtask, uses the `websearch` and `webfetch` tools to gather the latest information, links, and resources about a given topic, and saves the results to `specs/<feature>/research.md`.

The Research stage is accessible in three ways:
1. **Pipeline integration** — Automatically offered as Phase 0 when running `/spec`, skippable by the user.
2. **Standalone command** — `/research <query>` creates a research document directly.
3. **Inline invocation** — `@deepsearcher <query>` spawns Deepsearcher inline in the current session.

### User Stories

1. As a developer starting a new feature, I want Vibuzo to search the web for relevant information before writing the spec, so the specification is informed by current best practices and resources.
2. As a developer who already knows exactly what I want, I want to skip the research stage so I'm not delayed by unnecessary web searches.
3. As a developer exploring a new technology, I want to run `/research <topic>` standalone to get a structured summary of resources without going through the full pipeline.
4. As a developer in the middle of a session, I want to use `@deepsearcher <query>` to spawn a research agent inline and get answers without leaving the conversation.
5. As a developer, I want Deepsearcher's output saved to a file so I can reference it later or share it with my team.

### Functional Requirements

1. **Deepsearcher agent definition** — A new agent file at `.opencode/agent/core/deepsearcher.md` with:
   - `name: Deepsearcher`
   - `mode: subagent` (runs as subtask)
   - Access to `websearch` and `webfetch` tools
   - A report format that returns structured research (summary, key findings, links, resources)
   - Same permission model as Deepveloper
   - Between-task gating rules inherited from Vibuzo's `approval_level`

2. **`/research` command** — A new command file at `commands/research.md` and `.opencode/commands/research.md` with:
   - `agent: Deepsearcher`
   - `subtask: true`
   - Accepts a query via `$ARGUMENTS`
   - Saves research output to `specs/<feature>/research.md` (feature name derived from query, kebab-case)
   - If `specs/<feature>/` already exists, uses it; otherwise creates it

3. **`@deepsearcher` inline invocation** — Support for invoking Deepsearcher directly in the main session using `@deepsearcher <query>`. This spawns Deepsearcher with the query and returns results inline (no file save required for inline mode, but a file save is offered as an option).

4. **Pipeline integration (Phase 0)** — The existing `/spec` command gains an optional Research phase:
   - **Phase 0 — Research**: Before Phase 1 (Spec), offer the user the option to research the feature.
     - If accepted: spawn Deepsearcher with the feature description as query, save to `specs/<feature>/research.md`, present phase gate
     - If declined: skip to Phase 1 directly
   - The existing phases (1-5) remain unchanged.
   - Research output is available as context for Phase 1 (Vibuzo reads `research.md` before generating spec).

5. **Research output format** — `specs/<feature>/research.md` shall contain:
   - **Summary**: 2-3 sentence overview of findings
   - **Key Findings**: Bullet points of the most important information
   - **Resources**: Curated list of links with descriptions
   - **Source Metadata**: When the research was conducted, what queries were used

6. **Approval gate integration** — The new Phase 0 respects Vibuzo's `approval_level` setting:
   - At level ≥ 1: Phase gates pause for approval before and after Research
   - At level 0: Phase gates are skipped, auto-proceed
   - Between-task gating within Deepsearcher follows the same rules as Deepveloper

7. **Skip logic** — At the start of Phase 0, Vibuzo asks: "Research this feature? (y/N)". If "N", skip to Phase 1.

### Acceptance Criteria

- ✅ `.opencode/agent/core/deepsearcher.md` exists with agent definition (name: Deepsearcher, mode: subagent, tool access)
- ✅ `commands/research.md` exists with `agent: Deepsearcher`, `subtask: true`
- ✅ `.opencode/commands/research.md` exists with identical content
- ✅ `/research <query>` creates `specs/<feature>/research.md` with structured research output
- ✅ `/research <query>` infers feature name from query (kebab-case, multi-word supported)
- ✅ `@deepsearcher <query>` spawns Deepsearcher inline in the main session
- ✅ `/spec` with `$ARGUMENTS` offers Research phase (Phase 0) before Spec phase
- ✅ Declining research at Phase 0 skips directly to Phase 1 (Spec)
- ✅ Research output (`research.md`) is read as context before Spec phase if it exists
- ✅ Phase gates for Research respect `approval_level` (skip at level 0, gate at level ≥ 1)
- ✅ Deepsearcher uses `websearch` and `webfetch` tools for research
- ✅ Deepsearcher returns structured results (summary, findings, resources, metadata)
- ✅ Existing pipeline phases (1-5) remain unchanged and functional
- ✅ Existing commands (`/spec`, `/context`, `/session`, `/add-context`) continue to work

### Out of Scope

- Modifying the existing Deepveloper agent
- Removing or deprecating any existing commands or agents
- Adding runtime dependencies or third-party libraries
- Persistent research cache or index across sessions
- Multi-query or iterative deep research (single query per invocation)
- Crawling or scraping websites beyond `websearch`/`webfetch` capabilities
- Changes to the approval gates system itself
- Modifying the context system (`/context`, `/session`, `/add-context`)
