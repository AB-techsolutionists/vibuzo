---
description: Create a functional specification for a feature
---

You are creating a feature specification for: $ARGUMENTS

If the description is vague, ask clarifying questions about what problem it solves, who the users are, key user journeys, and what success looks like.

Once clear, generate a specification document with these sections:

## Principles
- Code quality standards for this feature
- Testing expectations
- Performance requirements
- UX consistency guidelines

## Specification
- **Overview**: 2-3 sentence description of what we're building and why
- **User Stories**: List of user stories in "As a... I want... So that..." format
- **Functional Requirements**: Numbered list of what the system must do
- **Acceptance Criteria**: Specific, testable conditions for each requirement
- **Out of Scope**: What this feature explicitly does NOT include

Write to `specs/$1/spec.md`. Create the specs/$1/ directory if it doesn't exist.
