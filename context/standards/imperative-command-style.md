# Imperative Command Style

## Rule

All command files in `commands/` (and mirrored in `.opencode/commands/`) MUST be written as **imperative step-by-step instructions**, not as behavioral specifications.

## Format

| Bad (spec-style) | Good (imperative) |
|---|---|
| "The agent should analyze the conversation and extract key points..." | "Do these steps NOW: 1. Analyze this conversation — read the last 10+ messages..." |
| "Behavior: if no arguments, show options." | "Route by $ARGUMENTS: Empty → show options" |
| "The command shall support natural language inference..." | "Route by $ARGUMENTS: Natural language match → infer intent from keywords" |

## Rationale

Imperative commands instruct the agent to **execute immediately** rather than design or implement behavior. This prevents the agent from treating the command file as a feature spec to be coded.

## Conventions

- Start execution sections with `Do these steps NOW:`
- Use numbered steps for sequential operations
- Include `agent: Vibuzo` in YAML frontmatter
- `subtask: true` only for commands needing isolated execution (`/spec`, `/add-context`)
