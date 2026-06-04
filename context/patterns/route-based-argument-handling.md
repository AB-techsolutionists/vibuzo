# Route-Based Argument Handling

## Pattern

Parse `$ARGUMENTS` at the top of the command file with a clear switch/route block, then section each subcommand under a `## RUN:` header.

## Structure

```markdown
---
description: <what the command does>
agent: Vibuzo
---

<command description>: $ARGUMENTS

Route by $ARGUMENTS:
- Empty → <default action>
- Starts with "subcommand1" → run `<command> subcommand1`
- Starts with "subcommand2" → run `<command> subcommand2`
- Natural language match → infer intent from keywords
- Anything else → <fallback action>

---

## RUN: `/command` Default Action

Do these steps NOW:

1. <step 1>
2. <step 2>

---

## RUN: `/command subcommand1`

Do these steps NOW:

1. <step 1>
2. <step 2>

---

## RUN: `/command subcommand2`

...

---
```

## Examples

- **`commands/session.md`** — Routes: empty → compaction, "view" → view, "timeline" → timeline
- **`commands/context.md`** — Routes: empty → show options, "init" → init, "find" → find, "harvest" → harvest, NL → infer

## Rules

1. Route block must be the FIRST thing after YAML frontmatter
2. Each subcommand gets its own `## RUN:` section
3. Execution sections start with `Do these steps NOW:`
4. Use `---` horizontal rules to separate subcommand sections
5. Add a `## Backward Compatibility` section at the end for legacy behaviors

## Rationale

Single-file commands with routing are simpler than multi-file command systems. The route block at the top gives immediate visibility into all supported subcommands without reading the entire file.
