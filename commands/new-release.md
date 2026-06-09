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
── APPROVAL GATE ──────────────────────
Action: Version bump
Target: VERSION → versioning.md → README.md
Details: Bump <oldVersion> → <newVersion>
───────────────────────────────────────
Approve? (y/N):
```
If rejected, print "Release cancelled." and stop.

### Step 4: Write VERSION

Use the write tool to overwrite `VERSION` with `$newVersion`.

### Step 5: Get release description

Synthesize a brief description from the conversation (what was built, changed, or decided this session). Scan the most recent user requests and your own actions to extract 5-10 key words summarizing the work. Do NOT read any session file — the session may not exist yet. If the conversation has no clear work (e.g. just questions or planning), use "No description provided." Store as `$releaseNotes`.

### Step 6: Update versioning.md

Read `context/standards/versioning.md`. Find the exact line `### Current Version`. Insert a new line immediately after it with the format:
   `**<newVersion>** — <releaseNotes> (YYYY-MM-DD).`
Use the edit tool.

### Step 7: Update README.md

Read `README.md`. Find the Version History table (the line starting with `| **0.x.x** |`). Insert a new row immediately after the header row with the format:
   `| **<newVersion>** | <releaseNotes> |`
Use the edit tool.

### Step 8: Report box

Render:
```
╔══════ Release Complete ════════════════════════════════════╗
║                                                           ║
║  Version:   <oldVersion> → <newVersion>                   ║
║  Files:     VERSION, versioning.md, README.md             ║
║                                                           ║
╚═══════════════════════════════════════════════════════════╝
```
