# Interview-Idea-Refine — Task Breakdown

## Task 1: Create context/standards/interview-me.md

**Description:** Create the interview-me protocol standard under context/standards/, adapted from the addyosmani/agent-skills source. The standard defines a one-question-at-a-time interview protocol for extracting user intent when requests are vague.

**Files:**
- `context/standards/interview-me.md` — new file

**Steps:**
1. Read `context/standards/yaml-frontmatter-convention.md` to understand the required YAML frontmatter format (tags, scope, when fields)
2. Create `context/standards/interview-me.md` with the following structure:
   - YAML frontmatter with tags: `[protocol, clarification, interview, intent]`, scope: `One-question-at-a-time interview protocol for extracting user intent when requests are vague — fires before /spec`, when: `The user gives an underspecified request, says "interview me" / "grill me" / "are we sure?" / "stress-test my thinking", or the agent catches itself filling in ambiguous requirements`
   - Overview section explaining the gap it fills (between vague request and spec)
   - When to Use / When NOT to Use sections
   - The protocol: Step 1 (Hypothesize with confidence number), Step 2 (Ask one question at a time with guess attached), Step 3 (Listen for "want vs should want"), Step 4 (Restate intent in 6-field format: Outcome/User/Why now/Success/Constraint/Out of scope), Step 5 (Confirm — explicit yes, not "whatever you think"). Include the 95% confidence stop condition.
   - Red Flags section (trimmed to most important 5-7 items)
   - Verification checklist
   - Wiring into Vibuzo section: explains that this standard augments Core Rule 1 — when the routing flowchart matches interview-me, load this standard and follow it step by step. The output (confirmed statement of intent) feeds into /spec or downstream processing.
3. Verify the file is under ~200 lines
4. Verify YAML frontmatter is valid

**Verification:**
- File exists at `context/standards/interview-me.md`
- File has valid YAML frontmatter
- File is under ~200 lines
- All 5 protocol steps are present
- Wiring into Vibuzo section explains the routing integration

**Acceptance:**
- ✅ `context/standards/interview-me.md` exists with YAML frontmatter and complete protocol

---

## Task 2: Create context/standards/idea-refine.md

**Description:** Create the idea-refine protocol standard under context/standards/, adapted from the addyosmani/agent-skills source. The standard defines a divergent→convergent thinking framework for sharpening vague ideas into actionable concepts.

**Files:**
- `context/standards/idea-refine.md` — new file

**Steps:**
1. Read `context/standards/yaml-frontmatter-convention.md` to understand the required YAML frontmatter format
2. Create `context/standards/idea-refine.md` with the following structure:
   - YAML frontmatter with tags: `[protocol, ideation, refinement, divergent-convergent]`, scope: `Divergent→convergent thinking framework for refining raw ideas into actionable concepts — fires before /spec when the user has a rough concept`, when: `The user says "refine this idea" / "ideate" / "stress-test my plan", or has a rough concept that needs shaping before spec writing`
   - Overview section explaining the purpose (turn raw ideas into sharp, actionable concepts)
   - Phase 1 — Understand & Expand (Divergent): Restate as How Might We problem statement, ask 3-5 sharpening questions, generate 5-8 idea variations using lenses (inversion, constraint removal, audience shift, combination, simplification, 10x version, expert lens)
   - Phase 2 — Evaluate & Converge: Cluster into 2-3 directions, stress-test against User value / Feasibility / Differentiation, surface hidden assumptions
   - Phase 3 — Sharpen & Ship: Produce markdown one-pager with Problem Statement, Recommended Direction, Key Assumptions, MVP Scope, Not Doing list, Open Questions
   - Anti-patterns section (trimmed to most important 5-7 items)
   - Verification checklist
   - Wiring into Vibuzo section: explains that this standard fires when the routing flowchart matches idea-refine. The agent loads this standard and follows the three-phase protocol. The output one-pager feeds into /spec.
3. Verify the file is under ~200 lines
4. Verify YAML frontmatter is valid

**Verification:**
- File exists at `context/standards/idea-refine.md`
- File has valid YAML frontmatter
- File is under ~200 lines
- All 3 phases are present
- Wiring into Vibuzo section explains the routing integration

**Acceptance:**
- ✅ `context/standards/idea-refine.md` exists with YAML frontmatter and complete protocol

---

## Task 3: Update agents/vibuzo.md routing and wiring

**Description:** Update the routing flowchart in agents/vibuzo.md to show both skills as imported (✅) and add a Protocol Implementation Notes subsection.

**Files:**
- `agents/vibuzo.md` — edit

**Steps:**
1. Read the Skill Discovery & Dynamic Routing section of `agents/vibuzo.md`
2. Change line 57 from `├── Unsure what you want / "interview me" ──→ interview-me (🔲)` to `├── Unsure what you want / "interview me" ──→ interview-me (✅)`
3. Change line 58 from `├── Have a rough concept / "refine this" ──→ idea-refine (🔲)` to `├── Have a rough concept / "refine this" ──→ idea-refine (✅)`
4. After the Routing Rules subsection (the one that ends with "See `context/standards/skill-routing-vibuzo.md` for the full reference..."), insert a new subsection:

   ```
   ### Protocol Implementation Notes
   
   When the flowchart matches a specific protocol skill:
   
   - **interview-me (✅)** — Load `context/standards/interview-me.md` and follow its protocol step by step. This extracts clear intent from vague requests via structured one-question-at-a-time interviewing. Output is a confirmed statement of intent that feeds into `/spec`.
   
   - **idea-refine (✅)** — Load `context/standards/idea-refine.md` and follow its protocol step by step. This sharpens rough concepts into actionable one-pagers through divergent→convergent thinking. Output is a markdown one-pager that feeds into `/spec`.
   ```

**Verification:**
- Both flowchart lines show ✅ instead of 🔲
- Protocol Implementation Notes subsection exists with both entries

**Acceptance:**
- ✅ `agents/vibuzo.md` shows `interview-me (✅)` and `idea-refine (✅)` in the flowchart
- ✅ `agents/vibuzo.md` has a Protocol Implementation Notes section

---

## Task 4: Update skill-routing-vibuzo.md status table

**Description:** Update the skill status table to mark interview-me and idea-refine as imported (✅).

**Files:**
- `context/standards/skill-routing-vibuzo.md` — edit

**Steps:**
1. Read the Skill Status Table section of `context/standards/skill-routing-vibuzo.md`
2. Change row 2 (| 2 | interview-me | Not yet imported | 🔲 | 1 |) to: `| 2 | interview-me | Load context/standards/interview-me.md | ✅ | 1 |`
3. Change row 3 (| 3 | idea-refine | Not yet imported | 🔲 | 1 |) to: `| 3 | idea-refine | Load context/standards/idea-refine.md | ✅ | 1 |`

**Verification:**
- Row 2 shows ✅ for interview-me
- Row 3 shows ✅ for idea-refine
- Both rows reference the correct file paths

**Acceptance:**
- ✅ `context/standards/skill-routing-vibuzo.md` shows ✅ for both skills in rows 2-3

---

## Task 5: Update context/index.md

**Description:** Add both new standard files to the Standards listing in context/index.md.

**Files:**
- `context/index.md` — edit

**Steps:**
1. Read the Standards section of `context/index.md`
2. Add two new entries in alphabetical order under the Standards list:
   - `- \`standards/idea-refine.md\` — Divergent→convergent thinking protocol for refining raw ideas into actionable concepts`
   - `- \`standards/interview-me.md\` — One-question-at-a-time interview protocol for extracting user intent from vague requests`
3. Ensure entries are placed in correct alphabetical order among existing entries

**Verification:**
- Both new files are listed under the Standards section
- Entries are in alphabetical order
- Descriptions match the scope from each file's YAML frontmatter

**Acceptance:**
- ✅ `context/index.md` lists both new files under Standards
