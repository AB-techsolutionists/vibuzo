# session-routing-architecture — Session command routing architecture

*Paste opencode /compact output below this line*
────────────────────────────────────────
## Goal
- Refactor the Vibuzo framework: remove broken routing-only command files, fix the session summary workflow, update installers and documentation, and change context/session commands to run in main agent session instead of as subtasks.

## Constraints & Preferences
- Commands must run in main agent session (Vibuzo), not as subtasks
- Remove `subtask: true` from all context and session command YAML frontmatter
- Install scripts must not download deleted files (404s)
- README must reflect actual file structure and available commands
- /compact is a real built-in OpenCode TUI command — don't treat it as nonexistent
- session.md must generate body content directly, not rely on paste workflow

## Progress
### Done
- Deleted `commands/session.md` and `commands/context.md` — routing-only files don't work (agent reads as plain text, no imperative instructions)
- Rewrote `AGENTS.md` as compact, repo-specific guidance (114 lines, removed stale Handoff Protocol, corrected approval_level to 3, added Critical Gotchas)
- Investigated `/compact`: confirmed real built-in OpenCode TUI command (summarizes session for model, not content-export tool)
- Rewrote `session.md`: generates body (Goal/Progress/Key Decisions/Critical Context) directly from conversation analysis
- Performed comprehensive codebase analysis: identified 5 issues
- Fixed `install.ps1` and `install.sh`: replaced `context.md`/`session.md` downloads with 8 sub-command files
- Deleted stale mirrors: `.opencode/commands/context.md` and `.opencode/commands/session.md`
- Fixed `README.md`: updated "What Gets Installed" tree, commands table, removed /compact paste workflow, removed "Default is 0" claim
- Removed `subtask: true` from all 7 context/session command files (now run in main agent session)
- Synced all 7 updated command files to `.opencode/commands/` mirrors

### In Progress
- (none)

### Blocked
- (none)

## Key Decisions
- **Routing-only main files removed permanently**: Agents need `Do these steps NOW:` imperative instructions to act; routing text is ignored
- **/compact is a real built-in command**: The paste workflow in session.md was based on a misunderstanding of what it does
- **session.md generates body directly**: Vibuzo fills in Goal/Progress/Key Decisions/Critical Context from conversation analysis
- **Context/session commands run in main agent session**: Removed `subtask: true` so they execute inline in Vibuzo's session instead of spawning separate agent
- **Install scripts must only download existing files**: Previous scripts would 404 on `context.md`/`session.md` after deletion

## Next Steps
1. Commit current working tree changes (install.ps1, install.sh, README.md, context/sessions/index.md, session-compact-fix.md)
2. Push local HEAD (874dd71) + working tree fixes to origin/main
3. Consider lowering `approval_level` in agents/vibuzo.md from 3 to 0 for development
4. Clean up `agents/orchestrator.md` if still committed

## Critical Context
- Local HEAD (874dd71) is 1 commit ahead of origin/main — NOT pushed
- If HEAD is pushed without install script fixes, users get 404s (downloading deleted context.md/session.md)
- approval_level in agents/vibuzo.md is 3 (Full Control) — gates every action including planning
- All 9 command files in commands/ now have no subtask: true — they run inline in the main agent
- .opencode/commands/ mirrors are now synced and match commands/ source exactly (9 files each)
- AGENTS.md, agent files, context knowledge base, and sub-commands are all committed in HEAD

## Relevant Files
- `commands/` (9 files): All context/session/spec/add-context commands — subtask: true removed from 7 files
- `.opencode/commands/`: Mirrors now in sync — stale context.md and session.md deleted
- `install.ps1`: Fixed — downloads 8 sub-commands instead of 2 routing files
- `install.sh`: Fixed — same as install.ps1
- `README.md`: Fixed — tree, commands table, session management, approval gates
- `AGENTS.md`: Rewritten — compact repo-specific guidance
- `commands/session.md`: Rewritten — generates body directly
────────────────────────────────────────
*Paste opencode /compact output above this line*

## Relevant Files
- ~~`commands/session.md`~~: **REMOVED** — routing-only main files don't work (no imperative instructions)
- ~~`commands/context.md`~~: **REMOVED** — same reason
- `commands/session.md`: Scaffolds new summary files
- `commands/session-view.md`: Views existing summary files
- `commands/session-timeline.md`: Shows session timeline
- `context/sessions/`: Auto-generated summary archives
- `context/sessions/index.md`: Master timeline of all summaries

## Timeline
| 2026-06-05 | 19:15 | `session-split-file-pattern` | Session split-file pattern |
| 2026-06-05 | 14:30 | `session-routing-architecture` | Session routing architecture — routing files removed |
