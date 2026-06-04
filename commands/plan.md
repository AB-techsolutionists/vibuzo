⚠️ **DEPRECATED** — Use `/spec <description>` instead. This file is kept for reference.

---

---
description: Create a technical implementation plan
---

Create a technical implementation plan for the feature described in the spec.

Read `specs/$1/spec.md` first. If it doesn't exist, tell the user to run `/spec $1` first.

Once you have the spec, generate a plan with:

## Tech Stack
- Languages, frameworks, libraries to use
- Justification for each choice

## Architecture
- High-level component diagram (text-based)
- Data flow between components
- Integration points with existing code

## Components
- List of components/modules to create or modify
- Responsibility of each
- Interfaces between them

## Implementation Order
- Recommended order of implementation
- Dependencies between components
- Risk factors to address first

Write to `specs/$1/plan.md`.
