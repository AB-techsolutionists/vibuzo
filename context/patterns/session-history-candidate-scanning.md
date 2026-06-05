# Session History Candidate Scanning

> Extract context-worthy knowledge from the current conversation and save it to permanent project context.

## Pattern

After completing a feature or reaching a natural breakpoint, scan the conversation history for content worth preserving:

1. **Scan** — review session messages for:
   - **Architectural decisions** — design choices, tradeoffs, system architecture, component relationships
   - **Recurring patterns** — techniques, approaches, idioms established during the conversation
   - **Conventions** — rules, standards, naming conventions agreed upon or demonstrated
   - **Key insights** — important findings, gotchas, lessons learned, contextual rationale

2. **Categorize** — use the same type classification as `/add-context`:
   - `pattern` → `context/patterns/<name>.md`
   - `standard` → `context/standards/<name>.md`
   - `architecture` → `context/architecture/<name>.md`

3. **Name** — derive a kebab-case name from the core concept

4. **Present** — show one candidate at a time with type, evidence, and target path. Ask for approval before saving.

5. **Create or Append**:
   - If target file exists → append as a new `## <heading>` section
   - If new → create the file with a markdown note
   - Update `context/index.md` only for newly created files

6. **Close** — print a status summary with counts

## Usage

Via `/context append` command, which automates this pattern.

## Related

- `/context harvest` — same pattern but scans past session files instead of current conversation
- `/add-context` — saves a single statement directly
