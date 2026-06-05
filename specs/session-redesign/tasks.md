# Session Redesign — Tasks

## Task 1: Rewrite session command with summary logic
- **File:** `commands/session.md`
- **Actions:**
  - Add routing for $ARGUMENTS (empty → summary, "view" → view, "timeline" → timeline)
  - Write "RUN: `/session` summary" section with 5 numbered steps
  - Write "RUN: `/session view <ref>`" section with all ref types
  - Write "RUN: `/session timeline [month]`" section
  - Add backward compatibility note for legacy YYYY-MM-DD.md files
  - Include agent: Vibuzo in YAML frontmatter

## Task 2: Mirror to .opencode/commands/session.md
- **Actions:** Copy identical content from `commands/session.md` to `.opencode/commands/session.md`

## Task 3: Verify functionality
- **Actions:**
  - Run `/session` with empty args → verify summary saves correctly
  - Run `/session view` → verify view subcommands work
  - Run `/session timeline` → verify timeline displays
  - Confirm both source and mirror match

## Task 4: Backward compatibility check
- **Actions:**
  - Verify legacy `context/sessions/2026-06-04.md` and `2026-06-03.md` are preserved
  - Verify `/session view 2026-06-04` lists legacy files alongside title-based ones
