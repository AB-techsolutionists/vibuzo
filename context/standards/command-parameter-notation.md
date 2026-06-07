---
tags:
  - parameters
  - notation
  - command-syntax
  - documentation
scope: All command files, README, and documentation referencing command parameters
when: Writing command documentation or defining command parameters
---

# Command Parameter Notation

All Vibuzo command parameters use `[descriptive prompts]` inside square brackets. This notation applies across every command file, README, and documentation reference.

## Canonical Form

```
/command [what to do or what to provide]
```

## Examples

| Command | Example |
|---------|---------|
| `/spec` | `/spec [enter complete feature specification]` |
| `/context find` | `/context find [type your search..]` |
| `/context append` | `/context append [enter context]` |
| `/add-context` | `/add-context [enter statement]` |
| `/session-view` | `/session-view [enter topic, type your search..]` |

## Rules

1. **Always use square brackets** — `[ ]`, not `( )`, `< >`, or bare words
2. **Always descriptive** — `[type your search..]`, `[enter complete feature specification]`, not `[input]` or `[args]`
3. **Consistent across all surfaces** — commands files (`commands/`), context docs, AGENTS.md, and installers all use the same notation
4. **Added pipe-dots** — end prompts with `..` to indicate open-ended input: `[type your search..]`

## Rationale

- Square brackets visually separate the prompt from command syntax
- Descriptive text guides the user on what to provide
- Consistent notation reduces cognitive load across commands
