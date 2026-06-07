---
tags:
  - arguments
  - command-templates
  - routing
  - template-engine
scope: Editing command template files that use $ARGUMENTS
when: Creating or editing command template .md files that use $ARGUMENTS
---

# $ARGUMENTS Usage in Command Templates

## Rule

`$ARGUMENTS` must only appear in the **routing section header** and the **first description line** of a command template. It must **never** appear in any section body or execution instruction.

## Allowed Locations

| Location | Example | Purpose |
|----------|---------|---------|
| First description line | `Manage project context: $ARGUMENTS` | Shows user what arguments were received |
| Routing header | `Route by $ARGUMENTS:` | Introduces the routing rules |
| Routing rules (literal strings) | `- Starts with "init" → ...` | Literal "init" is fine, not a `$ARGUMENTS` reference |

## Forbidden Locations

- Section body text (e.g., `extract everything after "find " from $ARGUMENTS`)
- Guard clauses (use literal description instead)
- Status output templates

## Rationale

Opencode's template engine substitutes `$ARGUMENTS` with the user's actual input **everywhere** in the file before the agent reads it. When `$ARGUMENTS` appears in a non-matching section's body, the substitution creates text like `extract everything after "find " from append` which can confuse the agent into executing that section.

## Enforcement

When editing command templates, grep for `$ARGUMENTS` after changes. It should only appear in the routing section and the first line. Any occurrence below the `---` separator after the routing section is a violation.
