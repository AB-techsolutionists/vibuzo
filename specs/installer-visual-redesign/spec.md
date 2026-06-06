# Installer Visual Redesign

## Principles

- **Simplicity** — Output should be compact and scannable. No line should be purely decorative.
- **Consistency** — One box style (rounded: ╭╮╰╯) everywhere. One color scheme. One spacing rhythm.
- **Signal over noise** — Remove per-file noise, show grouped summaries. Every line carries information.
- **Code simplicity** — Redesign should also simplify the installer code, not just the output. Use arrays/loops where possible.

## Specification

### Overview

Redesign the visual output of `install.ps1` and `install.sh` (mirrored implementations) to be simpler, prettier, and more compact. The redesign covers the install flow, update flow, and the "up to date" case. Both installers must remain visually identical.

This is purely a visual/cosmetic change. No functional changes to what gets installed, how files are downloaded, or how version checking works.

### User Stories

1. As a user running a fresh install, I see a clean compact output with grouped file lists instead of a long scroll of individual file lines.
2. As a user checking for updates, I see a compact box comparing current vs latest version with status, not a multi-line details dump.
3. As a user who already has the latest version, I see a clean "up to date" confirmation, not a partial comparison.
4. As a developer maintaining the installers, the output code is simpler — using arrays/loops instead of repeated Write-Host/printf + Invoke-WebRequest/curl pairs.

### Functional Requirements

#### FR1: Fresh Install Output

After the existing VIBUZO banner:

```
🔧 Installing Vibuzo 0.1.0 (local)...

  ── Agents (2) ──────────────────────
  ✓ vibuzo.md, deepveloper.md

  ── Commands (9) ────────────────────
  ✓ spec, add-context, context-init, context-find,
    context-harvest, context-append, session,
    session-view, session-timeline

  ── Project ────────────────────────
  ✓ AGENTS.md (fresh copy)

╭───── ✅ Vibuzo 0.1.0 installed successfully! ─────╮
│                                                     │
│  Location:  local (.opencode/)                      │
│                                                     │
│  ── Next Steps ──                                   │
│  1. Restart opencode → select Vibuzo               │
│  2. Run /context init to scaffold project memory    │
│  3. Start building with /spec [feature description] │
│                                                     │
│  💡 github.com/AB-techsolutionists/vibuzo          │
│                                                     │
╰─────────────────────────────────────────────────────╯
```

- Section headers use `── Agents (N) ──────` format with item count
- Files listed comma-separated on one line after the checkmark
- Commands listed without `.md` extension (just the stem name)
- After 3-4 items, wrap to next line with indent
- AGENTS.md shows a single status line instead of the 12-16 line info box:
  - `✓ AGENTS.md (fresh copy)` — no existing file
  - `✓ AGENTS.md (with custom rules preserved)` — Vibuzo file with user rules
  - `✓ AGENTS.md (your content preserved at top)` — user's own AGENTS.md
- Success box uses rounded corners (╭╮╰╯), compact layout with location, next steps, link
- Tight spacing — no double blank lines

#### FR2: Update Flow Output

After the banner:

```
╭────── Vibuzo Update Check ──────╮
│  Current:  0.0.19  (04638cc)    │
│  Latest:   0.1.0   (bac3e89)    │
│  Status:   ⬆️ Update available  │
│                                  │
│  Installed: Jun 07 at 00:42     │
│  Location:  .opencode/           │
╰──────────────────────────────────╯

Proceed with update? (y/N): y

⬆️  Updating Vibuzo 0.1.0 (local)...

  ── Agents (2) ──────────────────────
  ✓ vibuzo.md, deepveloper.md

  ── Commands (9) ────────────────────
  ✓ spec, add-context, context-init, context-find,
    context-harvest, context-append, session,
    session-view, session-timeline

  ── Project ────────────────────────
  ✓ AGENTS.md (updated)

╭───── ✅ Vibuzo 0.1.0 updated successfully! ──────╮
│                                                     │
│  Location:  local (.opencode/)                      │
│                                                     │
╰─────────────────────────────────────────────────────╯
```

- Version check is a single compact box
- Current and Latest on separate lines with version + SHA
- Status line: `✅ Up to date`, `⬆️ Update available`, or `⚠️ Could not check`
- Date uses short format (e.g., `Jun 07 at 00:42`)
- Download sections use same grouped format as install
- Success box is compact (location only, no next steps for updates)

#### FR3: Up-to-Date Output

```
╭────── Vibuzo Update Check ──────╮
│  Current:  0.1.0   (bac3e89)    │
│  Latest:   0.1.0   (bac3e89)    │
│  Status:   ✅ Up to date         │
│                                  │
│  Installed: Jun 07 at 02:23     │
│  Location:  .opencode/           │
╰──────────────────────────────────╯
```

Then exit 0, no download.

#### FR4: Failed Check Output

```
╭────── Vibuzo Update Check ──────╮
│  Current:  0.1.0   (bac3e89)    │
│  Status:   ⚠️ Could not check   │
│                                  │
│  Installed: Jun 07 at 02:23     │
│  Location:  .opencode/           │
╰──────────────────────────────────╯

Proceed with update? (y/N): [user decides]
```

- If remote check fails, show only Current line + Status warning
- Still allow user to proceed (they may want to reinstall)

#### FR5: Code Simplification

- Store agent files and command files in arrays/hashtables so the download loop is a single `foreach`
- Eliminate 11 repeated `Write-Host + Invoke-WebRequest` pairs
- AGENTS.md logic: consolidate the 3-case branching into a function
- Box-drawing: create a helper function for boxes (or use pre-built strings)

### Acceptance Criteria

1. ✅ Fresh install output is ~20 lines (down from ~50)
2. ✅ Both installers produce visually identical output
3. ✅ Per-file download lines are replaced with grouped comma-separated lists
4. ✅ Commands shown without `.md` extension
5. ✅ AGENTS.md status is a single line, not a 12-16 line box
6. ✅ Update check displays in a single compact box with current, latest, status
7. ✅ "Up to date" case exists cleanly after the box
8. ✅ `installer-visual-language.md` standard is updated to match new design
9. ✅ Both installers still work end-to-end (install, update, up-to-date, global mode)

### Out of Scope

- Changing the VIBUZO banner
- Changing how files are downloaded (still Invoke-WebRequest/curl per file)
- Changing AGENTS.md preservation logic (only its display format)
- Changing the version bump mechanism
- Adding new features like progress bars or spinners
