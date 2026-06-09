---
description: Auto-bump version (no prompts, no git)
agent: Vibuzo
---

> Auto-bumps the version, updates versioning.md and README.md. No git, no commit.

Do these steps NOW:

### Step 1: Read current version

Read `VERSION` file. Parse into `$major.$minor.$patch` integers. Store as `$oldVersion`.

### Step 2: Calculate new version

Increment `$patch` by 1. Apply rollover rules:
- If `$patch > 9`: set `$patch = 0`, increment `$minor` by 1
- If `$minor > 19`: set `$minor = 0`, increment `$major` by 1
- Format as `$newVersion = "$major.$minor.$patch"`
- Store both `$oldVersion` and `$newVersion`

### Step 3: Approval gate

Present:
```
── VERSION BUMP GATE ──────────────────
Bump <oldVersion> → <newVersion>
───────────────────────────────────────
Approve? (y/N):
```
If rejected, print "Release cancelled." and stop.

### Step 4: Write VERSION

Use the write tool to overwrite `VERSION` with `$newVersion`.

### Step 5: Get release description

Read the latest session summary from `context/sessions/` (the most recently modified file) to extract a brief description of what was built/changed. Synthesize it into a structured release description with:

- **One-line summary** — a short headline like "Documentation drift fixes, README restructure"
- **Detailed changes** — a single sentence covering what changed in commands, context/standards, fixes, features, and anything else. Describe functional changes, not file paths. Use commas to separate items, with "and" before the last item.

Also capture the git diffstat by running `git diff --stat HEAD` and store the file count/insertions/deletions numbers. If no session context is available, use "No description provided." Store all of this as `$releaseNotes`.

### Step 6: Update versioning.md

Read `context/standards/versioning.md`. Find the exact line `### Current Version`. Insert a new line immediately after it with the format:
   `**<newVersion>** — <one-line summary> (YYYY-MM-DD).`
Use the edit tool.

### Step 7: Update README.md

Read `README.md`. Find the Version History table (the line starting with `| **0.x.x** |`). Insert the release entry as a two-line row immediately after the header row:

```
| **<newVersion>** | **<one-line summary> — <diffstat>** |
| | <detailed paragraph> |
```

The second line starts with `| |` — the first cell is empty, creating a grouped visual under the version number. Use the edit tool.

### Step 8: Check installer status

Check if `install.ps1` or `install.sh` have uncommitted changes by running `git diff --stat HEAD -- install.ps1 install.sh`. If they have changes, store `$installerStatus = "⚠️  Needs update"`. Otherwise store `$installerStatus = "✅ Up to date"`.

### Step 9: Report box

Render:
```
╔══════ Release Complete ════════════════════════════════════╗
║                                                           ║
║  Version:        <oldVersion> → <newVersion>              ║
║  Files updated:  VERSION, versioning.md, README.md        ║
║  Installers:     <installerStatus>                        ║
║                                                           ║
║  To update:      Run install.ps1 --update or              ║
║                  ./install.sh --update                    ║
║                  then restart your editor                 ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```
