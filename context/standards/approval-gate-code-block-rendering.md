# Approval Gate Code Block Rendering

## Rule

All approval gates MUST be rendered inside a fenced code block (triple backticks) so opencode displays them as a terminal card.

## Correct Format

````
```
── APPROVAL GATE ──────────────────────
Action: <write | edit | delete | command | delegate>
Target: <file path or command string>
Details: <summary of what will change>
───────────────────────────────────────
Approve? (y/N):
```
````

## Incorrect Format

```
── APPROVAL GATE ──────────────────────
Action: edit
Target: some-file.md
Details: change something
───────────────────────────────────────
Approve? (y/N):
```

Rendered as plain markdown text instead of inside a code block.

## Rationale

Opencode renders fenced code blocks as styled terminal cards, making approval gates visually distinct and clearly actionable. Plain text gates blend into the conversation and can be missed or misinterpreted.

## Source

Defined in `agents/vibuzo.md`, section "Gate Behavior", rule #2:
> "Standard prompt format — always render inside a code block so opencode displays it as a terminal card."
