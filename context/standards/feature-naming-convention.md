---
tags:
  - feature-naming
  - kebab-case
  - spec
  - naming
scope: Running /spec command and creating feature specifications
when: Running /spec to create a new feature from a description
---

# Feature Naming Convention

**Date:** 2026-06-07
**Status:** Active

## Rule

When running `/spec [description]`, the agent MUST derive a **short, meaningful kebab-case feature name** from the description — not blindly convert the entire description string to kebab-case.

## Examples

| Description | ✅ Correct Name | ❌ Wrong Name |
|-------------|----------------|---------------|
| `add user authentication with JWT and refresh tokens` | `user-authentication` | `add-user-authentication-with-jwt-and-refresh-tokens` |
| `i wanna introduce a new /commit command that bumps version` | `commit-command` | `i-wanna-introduce-a-new-commit-command-that-bumps-version` |
| `dark mode toggle` | `dark-mode-toggle` | `dark-mode-toggle` (same — already short) |
| `auth` | `auth` | — |

## How to Derive

1. **Analyze** the description to find the core feature intent — what is actually being built?
2. **Extract** 2-4 key words that uniquely identify the feature
3. **Convert** those key words to kebab-case only
4. **Verify** the result is readable at a glance — if it's longer than ~30 characters, it's too long

## Purpose

- Directory paths under `specs/` stay manageable and human-readable
- Commands and references stay short in documentation
- Prevents absurdly long directory names that break terminal layouts or cause display truncation

## Related

- [`commands/spec.md`](../../commands/spec.md) — The `/spec` pipeline command file (defines the naming step)
