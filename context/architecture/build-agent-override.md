> 🗑️ **DEPRECATED** — `opencode.jsonc` has been removed from the repo (it was a local-only config, not distributed by installers). Neither the `agent.build` override nor `default_agent` are used anymore. Users select Vibuzo from the agent dropdown in the TUI.

# Build Agent Override — Architecture Decision

## Date
2026-06-05

## Context
Opencode's `/new` command always creates a new session with the built-in **Build** agent — that's hardcoded default behavior. Custom primary agents (like Vibuzo) are added to the Tab rotation but are never the default. This meant every new session started with a generic Build agent instead of Vibuzo, forcing users to Tab-switch on every new session.

Additionally, the deprecated Orchestrator agent still had `mode: primary`, creating two competing custom primary agents (Orchestrator alphabetically before Vibuzo). This risked opencode defaulting to Orchestrator (deprecated) instead of Vibuzo (active).

## Decision
Two changes to make `/new` start with Vibuzo:

### 1. Override the built-in `build` agent via `opencode.jsonc`
Create `opencode.jsonc` at the project root that overrides the `build` agent's config:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "agent": {
    "build": {
      "description": "Main agent — plans, analyzes, delegates, reviews, and executes everyday tasks.",
      "mode": "primary",
      "temperature": 0.1,
      "prompt": "{file:./.opencode/prompts/vibuzo.txt}",
      "permission": { ... }
    }
  }
}
```

### 2. Demote Orchestrator from `primary` to `subagent` + `hidden`
Changed `mode: primary` → `mode: subagent` + `hidden: true` in both copies (`agents/orchestrator.md` and `.opencode/agent/core/orchestrator.md`). This removes Orchestrator from the primary agent rotation entirely, leaving Vibuzo as the only custom primary agent.

## Architecture

### After
```
/new → build (overridden with Vibuzo prompt/permissions)
         │
         ├── Tab → vibuzo (original custom agent, identical behavior)
         ├── Tab → plan (opencode built-in)
         └── @deepveloper (subtask)
```

### File Structure

| File | Purpose |
|------|---------|
| `opencode.jsonc` | Project-root config — overrides built-in `build` agent |
| `.opencode/prompts/vibuzo.txt` | Clean system prompt (no YAML frontmatter) referenced by the override |
| `agents/orchestrator.md` | Demoted to `subagent` + `hidden` — not in primary rotation |
| `.opencode/agent/core/orchestrator.md` | Same demotion (mirror copy) |

### Prompt Extraction
The `prompt: "{file:...}"` reference points to a clean `.txt` file rather than the markdown agent file. This avoids including YAML frontmatter (`--- name, mode, permission ---`) as part of the system prompt, keeping the LLM's instructions clean.

## Key Principles

1. **Override, don't replace** — The built-in `build` agent is overridden in config, not deleted. Opencode's built-in agents remain available.
2. **Single primary** — Orchestrator demoted to `subagent` + `hidden` so only Vibuzo occupies the custom primary slot.
3. **Clean prompts** — Extract prompt text from agent markdown files (stripping YAML frontmatter) when using `{file:...}` references in JSON config.
