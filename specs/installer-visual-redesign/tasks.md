# Installer Visual Redesign — Task Breakdown

## Task 1: File arrays + download loop — install.ps1

**Description:** Replace 11 repeated `Write-Host + Invoke-WebRequest` pairs with arrays and a foreach loop for agents and commands. The download logic stays the same, only the code structure changes.

**Files:**
- `install.ps1`

**Dependencies:** None

**Steps:**
1. Add `$AgentFiles` array with name/description pairs
2. Add `$CommandFiles` array with command stem names (no `.md`)
3. Replace agent download block with `foreach ($file in $AgentFiles) { Invoke-WebRequest ... }`
4. Replace command download block with `foreach ($file in $CommandFiles) { Invoke-WebRequest ... "$RawUrl/commands/$file.md" ... }`

**Acceptance:**
- ✅ install.ps1 no longer has repeated Write-Host/Invoke-WebRequest pairs
- ✅ All agents and commands still download correctly

---

## Task 2: File arrays + download loop — install.sh

**Description:** Same as Task 1 but for `install.sh` (Bash arrays and for loop).

**Files:**
- `install.sh`

**Dependencies:** None (parallel with Task 1)

**[P] Parallel with Task 1**

**Steps:**
1. Add `AGENT_FILES` bash array with agent file names
2. Add `COMMAND_FILES` bash array with command stem names
3. Replace agent download block with `for f in "${AGENT_FILES[@]}"; do curl ... done`
4. Replace command download block with loop

**Acceptance:**
- ✅ install.sh no longer has repeated printf/curl pairs
- ✅ All agents and commands still download correctly

---

## Task 3: Grouped section display — install.ps1

**Description:** Render agents and commands as grouped comma-separated lines instead of individual checkmark lines. Section headers show item counts.

**Files:**
- `install.ps1`

**Dependencies:** Task 1

**Steps:**
1. Create `Write-Section` helper that renders:
   ```
     ── <Name> (<Count>) ────────────────────
     ✓ <item1, item2, item3, ...>
   ```
2. For commands, wrap at 4 items with 4-space indent on continuation lines
3. Apply to Agents section
4. Apply to Commands section
5. Replace the `─── Agents ──` style headers with `── Agents (N) ──` style

**Acceptance:**
- ✅ Install output shows `✓ vibuzo.md, deepveloper.md` on one line
- ✅ Install output shows `✓ spec, add-context, ...` with wrapping
- ✅ Section headers show item count

---

## Task 4: Grouped section display — install.sh

**Description:** Same as Task 3 for `install.sh`.

**Files:**
- `install.sh`

**Dependencies:** Task 2

**[P] Parallel with Task 3**

**Steps:**
1. Create `print_section()` bash function
2. Apply to Agents and Commands sections
3. Handle comma-separated rendering with wrapping

**Acceptance:**
- ✅ Bash install output matches PowerShell output visually

---

## Task 5: AGENTS.md single-line status — both installers

**Description:** Replace the 12-16 line AGENTS.md info box with a single status line.

**Files:**
- `install.ps1`
- `install.sh`

**Dependencies:** Tasks 1-4

**Steps:**
1. Consolidate the 3-case AGENTS.md branching into a helper
2. Replace all `Write-Host "╭── AGENTS.md box..."` blocks with a single line:
   - `✓ AGENTS.md (fresh copy)` — no existing file
   - `✓ AGENTS.md (with custom rules preserved)` — Vibuzo file with rules
   - `✓ AGENTS.md (your content preserved at top)` — user's own AGENTS.md
3. Keep the interactive prompt (`Proceed with AGENTS.md?`) but remove the decorative box around it
4. Mirror in install.sh

**Acceptance:**
- ✅ No more AGENTS.md decorative boxes
- ✅ Single status line under Project section
- ✅ Interactive prompt still works
- ✅ Custom rules preservation still works

---

## Task 6: Compact update check box — both installers

**Description:** Redesign the update version check display into a single compact rounded box.

**Files:**
- `install.ps1`
- `install.sh`

**Dependencies:** None

**Steps:**
1. Create a box renderer function (or inline strings) for the update check box
2. Box format:
   ```
   ╭────── Vibuzo Update Check ──────╮
   │  Current:  0.x.x   (sha)        │
   │  Latest:   0.x.x   (sha)        │
   │  Status:   ✅ Up to date         │
   │                                  │
   │  Installed: Mon DD at HH:MM     │
   │  Location:  .opencode/           │
   ╰──────────────────────────────────╯
   ```
3. For "up to date": show box, exit 0
4. For "update available": show box, then prompt
5. For "could not check": show Current + ⚠️ line only, then prompt
6. Use short date format (e.g., `Jun 07 at 02:23`)
7. Mirror in install.sh

**Acceptance:**
- ✅ Update check display is a single compact box
- ✅ Three status modes render correctly (up to date, available, could not check)
- ✅ Date uses short format
- ✅ Box width fits content

---

## Task 7: Compact success box — both installers

**Description:** Simplify the success box to be more compact with cleaner layout.

**Files:**
- `install.ps1`
- `install.sh`

**Dependencies:** None

**Steps:**
1. Redesign success box:
   - Top line: `╭───── ✅ Vibuzo 0.1.0 installed successfully! ─────╮`
   - Location line
   - Next Steps (install only, 3 steps compact) or blank (update)
   - GitHub link
2. Install success box includes next steps
3. Update success box is just version + location (no next steps)
4. Tighter overall width and height
5. Mirror in install.sh

**Acceptance:**
- ✅ Install success box is ~9 lines (down from ~20)
- ✅ Update success box is ~5 lines
- ✅ Next steps shown only on fresh install
- ✅ Both installers match

---

## Task 8: Update installer-visual-language.md

**Description:** Update the visual language standard doc to match the new design.

**Files:**
- `context/standards/installer-visual-language.md`

**Dependencies:** Tasks 3-7 (must match final output)

**Steps:**
1. Update section header format examples
2. Update grouped file listing examples
3. Update AGENTS.md display (single line instead of box)
4. Update update check box format
5. Update success box format
6. Remove any references to old per-file listing style

**Acceptance:**
- ✅ Doc matches actual installer output exactly
- ✅ All code examples in doc reflect the new format

---

## Implementation Order (DAG)

```
Task 1 ──→ Task 3 ──→ Task 5 ──→ Task 8
Task 2 ──→ Task 4 ──→  │
                        ↓
Task 6 ──────────────→ Task 7 (can run anytime, no deps)
```
