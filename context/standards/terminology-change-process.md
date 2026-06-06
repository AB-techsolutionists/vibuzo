# Terminology Change Process

A repeatable process for renaming a term across the entire codebase without leaving stale references.

## When to Use

- A term was poorly chosen and a better name exists (e.g., `compaction` → `summary`)
- A naming inconsistency was discovered (e.g., `approval_gate` vs `approval_level`)
- A user-facing UI term needs to match documentation terminology

## The Process

### Step 1: Audit

```
grep -ri "old_term" --include="*.md" .    # find ALL occurrences
```

Count total matches. Note which files are:
- Source files (`commands/`, `agents/`, `AGENTS.md`, `README.md`)
- Context docs (`context/architecture/`, `context/standards/`, `context/patterns/`)
- Session archives (`context/sessions/`)
- Spec artifacts (`specs/`)
- Mirror copies (`.opencode/`)

### Step 2: Classify

Group files into categories:

| Category | Action |
|----------|--------|
| **Active source** (`commands/`, `agents/`, root `.md` files) | Rename immediately |
| **Context docs** (`context/`) | Rename immediately |
| **Mirrors** (`.opencode/`) | Sync after source changes |
| **Session archives** (`context/sessions/`) | Rename for consistency (historical accuracy may justify keeping old term) |
| **Spec artifacts** (`specs/`) | Rename for consistency |

### Step 3: Execute

For each file in each category:

1. **Replace** all instances of the old term with the new term
2. **Verify** no instances remain (`grep` again)
3. **Sync mirrors** — copy updated source files to `.opencode/`

### Step 4: Verify

```
grep -ri "old_term" --include="*.md" .    # should return 0
```

Run a second pass if any stragglers found.

## Real-World Examples

| Old Term | New Term | Scope | Effort |
|----------|----------|-------|--------|
| `compaction` | `summary` | 136 instances across 28 files | Large (entire codebase) |
| `approval_gate` | `approval_level` | ~30 instances across 10+ files | Medium |
| `USER_INPUT` | `(user input)` | 9 command files + mirrors | Small |
| `(user input)` | `[descriptive prompts]` | README + command docs | Small |

## Rules

- **Source first, mirrors second** — always update `commands/`/`agents/` before `.opencode/` mirrors
- **Commit separately** — a terminology change should be its own commit with a clear message (e.g., `refactor: replace 'compaction' with 'summary' across the codebase`)
- **Session archives are optional** — old terms in historical session files are acceptable; rename for consistency only
- **Update context/index.md** — if the change affects any file referenced in `context/index.md`, update the index description
