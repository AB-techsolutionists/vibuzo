---
description: Bump version, update release notes, and commit with detailed message (no push)
agent: Vibuzo
---

## RUN: `/commit`

> Bumps the version, updates release notes, commits with a structured message, then tells you to push manually. Every step is gated.

Do these steps NOW:

1. **Parse arguments** — read `$ARGUMENTS` (the text after `/commit`):

   - If `$ARGUMENTS` matches `^(feat|fix|refactor|chore|docs|style|test|perf):\s*(.+)$`, extract:
     - `commit_type` = the matched prefix + colon (e.g., `feat:`)
     - `description` = the text after the colon + space
   - Otherwise, set `description` = `$ARGUMENTS` (full text), `commit_type` = empty (will prompt later)
   - If `$ARGUMENTS` is empty, set both to empty

2. **Display intent** — show what was parsed:

   ```
   ── /commit ──────────────────────────────
   Starting commit workflow.
   <if commit_type> Type:    <commit_type>
   <if description>  Description: <description>
   <if both empty>   No description provided.
   ──────────────────────────────────────────
   ```

   Use a code block. Omit fields that are empty.

3. **Ask bump type** — prompt the user inside a code block:

   ```
   ── Bump Type ──────────────────────────────
   What kind of bump?
     (p)atch   — +1 to patch (0.1.5 → 0.1.6)
     (m)inor   — +1 to minor (0.1.5 → 0.2.0)
     (c)ustom  — specify exact version
   ───────────────────────────────────────────
   Choice [p]:
   ```

   Read user response. Default to `patch` if empty. Store as `$bumpType`.

4. **Calculate new version** — read `VERSION` and apply the bump:

   - Read `VERSION` file, parse into `$major.$minor.$patch` integers
   - If `patch`: increment `$patch` by 1. If `$patch > 19`, set `$patch = 0`, increment `$minor` by 1.
   - If `minor`: increment `$minor` by 1, set `$patch = 0`. If `$minor > 9`, set `$minor = 0`, set `$major = 1`.
   - If `custom`: ask user for exact version string, use as-is without validation
   - Store `$oldVersion` = original semver, `$newVersion` = computed semver

5. **Bump approval gate** — show the proposed bump and wait:

   ```
   ── APPROVAL GATE ──────────────────────
   Action: Version bump
   Target: VERSION → context/standards/versioning.md
   Details: Bump <oldVersion> → <newVersion> (<bumpType>)
   ───────────────────────────────────────
   Approve? (y/N):
   ```

   If approved, continue. If rejected, print "Commit cancelled." and stop.

6. **Write VERSION** — write `$newVersion` to the `VERSION` file at repo root:

   - Use the write tool to overwrite `VERSION` with the single line `$newVersion`

7. **Get release notes description** — if `description` is empty (no args), prompt:

   ```
   ── Release Notes ─────────────────────────
   Describe the changes (single line):
   ───────────────────────────────────────────
   ```

   Read user response. If still empty, use "No description provided." Store as `$releaseNotes`.

8. **Update versioning.md** — prepend a new entry under "Current Version":

   - Read `context/standards/versioning.md`
   - Find the exact line `### Current Version`
   - Insert a new line immediately after it with the format:
      `**<newVersion>** — <releaseNotes> (YYYY-MM-DD).`
   - Use the edit tool to add the line (insert as new line after the header)

9. **Commit type selection** — if `commit_type` was not auto-detected in step 1, prompt:

   ```
   ── Commit Type ──────────────────────────
   Conventional commit type:
     feat:     New feature
     fix:      Bug fix
     refactor: Code restructuring
     chore:    Maintenance, tooling, config
     docs:     Documentation only
     style:    Formatting, linting
     test:     Adding/fixing tests
     perf:     Performance improvement
   ─────────────────────────────────────────
   Type [chore]:
   ```

   Read user response. Default to `chore` if empty. Format as `<type>:` (append colon) and store in `commit_type`.

10. **Build commit message** — construct a structured commit message:

    - **Subject**: `<commit_type> <description>` (or "No description provided" if both empty)
      Example: `feat: add dark mode toggle`

    - **Body**: auto-generate a structured natural-language description of the changes made so far in this workflow:
      - List each file that was modified with a brief human-readable explanation:
        - `VERSION` → describe the old→new version
        - `context/standards/versioning.md` → describe the new release notes entry
      - Write in present tense, imperative mood, for developers to read smoothly
      - End with a summary paragraph explaining the change holistically
      - Example body:
        ```
        - Modified VERSION: bumped 0.1.5 → 0.1.6
        - Updated versioning.md: added 0.1.6 entry
          documenting the hotfix
        
        This bumps the version and updates release notes
        for the hotfix. The patch increment reflects a
        backward-compatible bug fix.
        ```
      - Note: this is an instruction for what the agent will build at runtime — the body describes the actual changes just made

    - **Footer**: `Part of the \`/commit\` workflow.`

    - Store the parts as `$commitSubject`, `$commitBody`, `$fullCommitMessage` (subject + blank line + body + blank line + footer)

11. **Commit approval gate** — display the full commit message and wait for approval:

    ```
    ── APPROVAL GATE ──────────────────────
    Action: Git commit
    Target: VERSION + context/standards/versioning.md
    Details:
    Subject: <commitSubject>
    
    Body:
    <commitBody>
    
    Part of the `/commit` workflow.
    ───────────────────────────────────────
    Approve commit? (y/N):
    ```

    If approved, continue. If rejected, print "Commit cancelled." and stop.

12. **Git commit** — stage and commit:

    - Run these bash commands (in sequence, one call):
      ```bash
      git add VERSION context/standards/versioning.md && git commit -m "<commitSubject>" -m "<commitBody>"
      ```
    - DO NOT include `git push` under any circumstances
    - If the commit fails (e.g., nothing to commit), print the error and stop

13. **Report box** — show the result inside a VIBUZO-style box:

    - Get the abbreviated commit hash: run `git rev-parse --short HEAD` and capture the output
    - Render this box (printed as text, not via installer functions):

    ```
    ╔══════ Commit Complete ══════════════════════════════════╗
    ║                                                         ║
    ║  Commit:    <hash>                                      ║
    ║  Version:   <oldVersion> → <newVersion>                 ║
    ║  Files:     VERSION, versioning.md                      ║
    ║  Subject:   <commitSubject>                             ║
    ║                                                         ║
    ║  ─────────────────────────────────────────────           ║
    ║                                                         ║
    ║  Push manually when ready:                              ║
    ║    git push                                             ║
    ║                                                         ║
    ╚═════════════════════════════════════════════════════════╝
    ```
