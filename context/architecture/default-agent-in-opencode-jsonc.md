# Default Agent in opencode.jsonc

## Date
2026-06-05

## Context
Opencode's `/new` command always opens the built-in **Build** agent by default. To make `/new` open a custom primary agent (Vibuzo), a `default_agent` property must be set at the root of `opencode.jsonc`.

## Previous (Wrong) Approach

The file `build-agent-override.md` described overriding the built-in `build` agent via `agent.build` in `opencode.jsonc`. This approach was **incorrect** — `agent.build` only changes the Build agent's prompt, description, and permissions. It does NOT change which agent `/new` selects. The agent remains named "Build" in the UI, and `/new` still opens the Build agent.

## Correct Approach

Set `default_agent` at the root of `opencode.jsonc`:

```jsonc
{
  "$schema": "https://opencode.ai/config.json",
  "default_agent": "vibuzo",
  "permission": {
    "bash": { "*": "allow", "**/*.env": "deny", ... },
    "edit": { "*": "allow", ... },
    "write": { "*": "allow", ... },
    "task": { "*": "allow" }
  }
}
```

### What changed
- Removed the misleading `agent.build` section entirely
- Added `"default_agent": "vibuzo"` so `/new` opens the Vibuzo custom agent
- Hoisted `permission` to root level so it applies to all agents

## How It Works

The opencode config schema defines `default_agent` as:
> "Default agent to use when none is specified. Must be a primary agent. Falls back to 'build' if not set or if the specified agent is invalid."

With `"default_agent": "vibuzo"`, `/new` opens the Vibuzo agent defined in `.opencode/agent/core/vibuzo.md`. No overrides needed.

## Verification

After setting `default_agent`, running `/new` should show "Vibuzo" as the active agent (not "Build"). If it still shows "Build", the `default_agent` value may be wrong or the named agent may not have `mode: primary`.
