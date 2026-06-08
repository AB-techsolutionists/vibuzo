# Research: Spec Workflow Enhancement

**Date:** 2026-06-08
**Status:** Complete

## Summary

Research into four key patterns from obra/superpowers, ZashBoy, ECC, and other agentic frameworks to enhance the `/spec` pipeline. Superpowers provides the richest reference implementation with its subagent-driven-development skill (two-stage review: spec compliance then code quality), writing-plans skill (bite-sized tasks with exact code/commands), and brainstorming skill (Socratic pre-implementation briefing). ZashBoy contributes multi-tier reviewer agents with parallel quality gates. ECC provides a planner-agent-first architecture with blueprint-style plan generation.

## Key Findings

### 1. Two-Stage Review (Superpowers: subagent-driven-development)

The core loop after each implementation task:

1. **Spec Compliance Review** — `spec-reviewer-prompt.md`: Checks the implementation matches the spec exactly. "Do Not Trust the Report" — reviewer MUST read actual code, compare line-by-line to requirements. Checks: missing requirements, extra/unneeded work, misunderstandings. Returns ✅ Spec compliant or ❌ Issues found with `file:line` references.

2. **Code Quality Review** — `code-quality-reviewer-prompt.md`: Only dispatched after spec passes. Delegates to the `requesting-code-review/code-reviewer.md` template. Checks: single-responsibility per file, unit decomposition, plan structure adherence, file size contributions. Returns: Strengths, Issues (Critical/Important/Minor), Assessment.

3. **Implementer self-reviews before handoff** — catches basic issues before reviewers see it.

4. **Review loops** — If either review fails, the implementer fixes and the same reviewer re-reviews. No human-in-loop between tasks in continuous mode.

5. **Final review** — After all tasks complete, a final code reviewer runs across the entire implementation, then triggers `finishing-a-development-branch`.

Source: [subagent-driven-development/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/SKILL.md), [spec-reviewer-prompt.md](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/spec-reviewer-prompt.md), [code-quality-reviewer-prompt.md](https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/code-quality-reviewer-prompt.md)

### 2. Structured Task Format (Superpowers: writing-plans)

Task template with exacting specificity:

```
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**
      ```python
      def test_specific_behavior():
          result = function(input)
          assert result == expected
      ```
- [ ] **Step 2: Run test to verify it fails**
      Run: `pytest tests/path/test.py::test_name -v`
      Expected: FAIL with "function not defined"
- [ ] **Step 3: Write minimal implementation**
      ```python
      def function(input):
          return expected
      ```
- [ ] **Step 4: Run test to verify it passes**
      Run: `pytest tests/path/test.py::test_name -v`
      Expected: PASS
- [ ] **Step 5: Commit**
      ```bash
      git add tests/path/test.py src/path/file.py
      git commit -m "feat: add specific feature"
      ```
```

**Key rules:**
- **Zero-context assumption** — engineer executing may have never seen the codebase
- **Each step = one action (2-5 minutes)** — if it takes longer, break it down
- **No placeholders** — never write "TBD", "TODO", "add validation" (write the actual code), "similar to Task N" (repeat the code)
- **File structure mapping** — before tasks, map every file with clear boundaries and responsibilities
- **Plan header** includes Goal (1 sentence), Architecture (2-3 sentences), Tech Stack
- **Self-review checklist**: spec coverage (every requirement has a task), placeholder scan, type consistency across tasks

**Plan file saved to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`

Source: [writing-plans/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md), [Writing Plans Guide](https://superpowers-guide.com/en/writing-plans)

### 3. Phase 0 Briefing / Pre-Spec Discovery (Superpowers: brainstorming)

Superpowers' brainstorming skill enforces a **hard gate**: no code until design is approved.

**9-step process:**
1. Explore project context (files, docs, recent commits)
2. Offer visual companion (if visual questions ahead)
3. Ask clarifying questions — one at a time (prefer multiple choice)
4. Propose 2-3 approaches with trade-offs and recommendation
5. Present design in sections (200-300 words each), get approval after each
6. Write design doc to `docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`
7. Spec self-review (placeholders, consistency, scope, ambiguity)
8. User reviews written spec (user gates approval)
9. Transition to writing-plans skill (only next step — no other skills invoked)

**Spec self-review checklist:**
- Placeholder scan (TBD, TODO, incomplete sections)
- Internal consistency (no contradictions)
- Scope check (focused enough for one plan?)
- Ambiguity check (requirements that could be interpreted two ways)

**Anti-pattern called out:** "This Is Too Simple To Need A Design" — the skill says this applies to EVERY project regardless of perceived simplicity.

Source: [brainstorming/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md), [spec-document-reviewer-prompt.md](https://github.com/obra/superpowers/blob/main/skills/brainstorming/spec-document-reviewer-prompt.md)

### 4. Code Review Pipeline Patterns

**Superpowers' requesting-code-review** — dispatches a reviewer subagent with precisely crafted context. Template at `code-reviewer.md` uses placeholders:
- `{WHAT_WAS_IMPLEMENTED}` — what was built
- `{PLAN_OR_REQUIREMENTS}` — what it should do
- `{BASE_SHA}` — commit before task
- `{HEAD_SHA}` — current commit
- `{DESCRIPTION}` — brief summary

Review categories: Code Quality, Architecture, Testing, Requirements. Output: Strengths + Issues by severity (Critical/Important/Minor) + Assessment (Ready to merge? Yes/No/With fixes).

**ZashBoy Planner-Editor-Review pipeline** — 5 execution modes including "swarm" (4 parallel executors per batch, validated by 3 independent architects). Three-tier reviewer agents: `-lite` (Haiku, quick checks), Standard (Sonnet, everyday), `-deep` (Opus, critical). Mandatory quality gates that cannot be skipped. Also features `codebase-analyzer` agent for pre-planning conventions extraction.

**ECC (Everything Claude Code)** — 64 specialized subagents including `planner.md` for feature implementation planning. Workflow: `/ecc:plan → tdd-workflow → /code-review`. Blueprint skill runs 5-phase pipeline: Research → Design → Draft → Review (adversarial by strongest model) → Register. Each step is self-contained for cold-start execution.

**CallSphere 5-agent pipeline** — Planner → Coder → Reviewer → Tester → Deployer. Max 3 revision loops on review failure. Reviewer returns scored JSON (status: passed/needs_revision, issues with severity, score 0-1).

Source: [requesting-code-review/SKILL.md](https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/SKILL.md), [code-reviewer.md](https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/code-reviewer.md), [ZashBoy](https://zashboy.com/articles/claude-code-workflow-plugin-multi-agent-orchestration-evolved), [ECC Blueprint](https://github.com/affaan-m/ecc/blob/main/skills/blueprint/SKILL.md)

## Key Takeaways for Vibuzo Enhancement

| Pattern | Source | Key Adoption Idea |
|---------|--------|-------------------|
| Two-stage review | Superpowers | Add spec-compliance → code-quality review gates after each /spec implement step |
| Bite-sized tasks | Superpowers | Convert current plan tasks to exact-file-path + complete-code + exact-command format |
| Pre-spec briefing | Superpowers | Add a "Phase 0" discovery step before spec writing with clarifying questions |
| Review loops | Superpowers/ZashBoy | Add iterative fix-and-rereview loops, not just pass/fail |
| Reviewer prompt templates | Superpowers | Create `spec-compliance-prompt.md` and `code-quality-prompt.md` as subagent dispatch templates |
| Severity-based issues | Superpowers/ZashBoy | Use Critical/Important/Minor tiers for review output |
| Multi-tier reviewers | ZashBoy | Use cheaper models for lite reviews, strongest for critical |

## Resources

| Title | URL | Description |
|-------|-----|-------------|
| Superpowers: subagent-driven-development | https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/SKILL.md | Two-stage review pipeline with spec compliance then code quality |
| Superpowers: spec-reviewer-prompt | https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/spec-reviewer-prompt.md | Exact prompt template for spec compliance review subagent |
| Superpowers: code-quality-reviewer-prompt | https://github.com/obra/superpowers/blob/main/skills/subagent-driven-development/code-quality-reviewer-prompt.md | Exact prompt template for code quality review subagent |
| Superpowers: writing-plans | https://github.com/obra/superpowers/blob/main/skills/writing-plans/SKILL.md | Bite-sized task format with exact file paths and complete code |
| Superpowers: brainstorming | https://github.com/obra/superpowers/blob/main/skills/brainstorming/SKILL.md | Socratic pre-implementation briefing with hard gate on code |
| Superpowers: spec-document-reviewer-prompt | https://github.com/obra/superpowers/blob/main/skills/brainstorming/spec-document-reviewer-prompt.md | Spec document review prompt for pre-planning validation |
| Superpowers: requesting-code-review | https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/SKILL.md | Code review dispatch with git SHA range and severity output |
| Superpowers: code-reviewer.md template | https://github.com/obra/superpowers/blob/main/skills/requesting-code-review/code-reviewer.md | Reviewer subagent template with placeholders and checklist |
| ZashBoy Multi-Agent Orchestration | https://zashboy.com/articles/claude-code-workflow-plugin-multi-agent-orchestration-evolved | Three-tier reviewer agents, swarm mode, mandatory quality gates |
| ECC Blueprint skill | https://github.com/affaan-m/ecc/blob/main/skills/blueprint/SKILL.md | 5-phase plan generation with adversarial review gate |
| ECC Agent system | https://github.com/affaan-m/ecc | 64 specialized subagents with planner-first architecture |
| CallSphere 5-agent pipeline | https://callsphere.ai/blog/code-generation-pipeline-5-specialized-agents-planner-coder-reviewer-tester-deployer | Planner-Coder-Reviewer-Tester-Deployer with max revision loop |

## Source Metadata

- Total sources consulted: 18
- Total sources used: 12
- Date range: 2025-06 to 2026-06
