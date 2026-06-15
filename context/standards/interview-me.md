---
tags:
  - protocol
  - clarification
  - interview
  - intent
scope: One-question-at-a-time interview protocol for extracting user intent when requests are vague — fires before /spec
when: The user gives an underspecified request, says "interview me" / "grill me" / "are we sure?" / "stress-test my thinking", or the agent catches itself filling in ambiguous requirements
---

# Interview-Me Protocol

## Overview

What people ask for and what they actually want are different things. They ask for "a dashboard" because that's what one asks for, not because a dashboard solves their problem. They say "make it faster" without a number to hit. The cheapest moment to find this gap is before any plan, spec, or code exists — once you've started building, switching costs are real and the misfit gets locked in.

This standard closes the gap between a vague request and a clear spec. It is the "pre-spec" phase, used when the user's intent is underspecified and needs extraction through structured one-question-at-a-time interviewing.

## When to Use

- The ask is missing **who** the user is, **why** they want it, what **success** looks like, or the binding **constraint**
- The request is conventional rather than specific ("build me X", "make it faster") and you can't unpack the convention without guessing
- You're tempted to start with assumptions you haven't surfaced
- The user hasn't said which value they're optimizing for when two reasonable ones are in tension
- The user explicitly says "interview me", "grill me", "are we sure?", "stress-test my thinking"

## When NOT to Use

- The ask is unambiguous and self-contained ("rename this variable", "fix this typo")
- The user has explicitly asked for speed over verification
- Pure information requests ("how does X work?", "what does this code do?")
- Mechanical operations (renames, formats, file moves)
- You already have ≥95% confidence (re-read the stop condition below before assuming you don't)

## The Protocol

### Step 1: Hypothesize with Confidence Number

Before asking anything, write your current best read of what the user wants in **one sentence**, plus an honest confidence number (0–100%):

```
HYPOTHESIS: You want a way to answer "how are we doing?" in standup.
CONFIDENCE: ~30% — missing: who it's for, what "metrics" means, and what success looks like
```

When confidence is below ~70%, append a brief reason — what's still unresolved or missing. The number forces honesty. If you can't predict the user's reactions to the next three questions you'd ask, the number is wrong.

### Step 2: Ask One Question at a Time with Guess Attached

Format:

```
Q: <one focused question>
GUESS: <your hypothesis for the answer, with reasoning>
```

**One at a time, not batched.** The user can't react to your hypotheses if you bury them in a list. The third question often depends on the answer to the first. Attaching a guess commits you to a hypothesis you can be visibly wrong about, keeping you honest. The user reacts faster to a wrong guess than they generate an answer from scratch.

### Step 3: Listen for "Want vs Should Want"

Watch for answers that pattern-match best-practice talk ("scalable", "clean architecture", "robust") without specifics, or phrases like "I should probably…", "the way most apps do it". When you hear these, ask:

> *"If you didn't have to justify this to anyone, what would you actually want?"*

That single question often does more work than the previous five.

### Step 4: Restate Intent in 6-Field Format

When your confidence is high, write back what you now think the user wants using their language:

```
- Outcome:      <one line>
- User:         <one line — who benefits>
- Why now:      <one line — what changed>
- Success:      <one line — how we know it worked>
- Constraint:   <one line — the binding limit>
- Out of scope: <one line — what we're explicitly not doing>
```

Yes / no / refine? Including **Out of scope** is non-negotiable — silent disagreement about non-goals is half of misalignment.

### Step 5: Confirm with Explicit Yes

The gate is an explicit "yes." These are **not** yes:
- "Whatever you think is best." → Re-ask with two concrete options framed as a choice.
- "Sounds good." → Ask: "Anything you'd refine?"
- "Sure, let's go." → Often a polite exit, not an endorsement.

If they correct you, fold the correction in and restate. Loop until you get an explicit yes.

### The 95% Confidence Stop

You're done when you can answer yes to: *"Can I predict the user's reaction to the next three questions I would ask?"* If yes, you have shared understanding. Stop and produce the restate. If no, you're not done — ask the next question. If several rounds pass without rising confidence, tell the user something foundational is missing and ask if they want to step back.

## Red Flags

1. Three or more questions in a single message — that's batching, not interviewing
2. A question without your hypothesis attached — that's surveying, not committing
3. Accepting "whatever you think is best" as a terminal answer
4. Producing a spec or plan before the user has explicitly confirmed your restate
5. Accepting sophistication-signaling answers ("scalable", "clean", "modern") without probing for what the user actually wants
6. Three or more rounds without confidence visibly rising — you're asking the wrong questions
7. Skipping the "Out of scope" line in the restate

## Verification Checklist

- [ ] An explicit hypothesis with a confidence number was stated in the first turn
- [ ] Every confidence number below ~70% was accompanied by a one-line reason
- [ ] Questions were asked one at a time, each with the agent's guess attached
- [ ] The "what would you actually want?" probe ran when the user gave a convention-signaling answer
- [ ] A concrete 6-field restate was written back to the user
- [ ] The user confirmed with an explicit yes (not "whatever you think", not "sounds good")
- [ ] At the stop point, the agent could predict reactions to the next three questions it would ask

## Wiring into Vibuzo

This standard replaces the default behavior of Core Rule 1 (Plan First) in `agents/vibuzo.md` for vague requests — instead of Vibuzo surfacing assumptions on its own, it follows this structured interview protocol. When the routing flowchart in the Skill Discovery & Dynamic Routing section matches "interview-me", this standard is loaded and its 5-step protocol is followed step by step. The output — a confirmed statement of intent — feeds into `/spec` or downstream processing.
