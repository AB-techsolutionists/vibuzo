---
tags:
  - code-review
  - quality
  - deepviewer
  - spec
  - five-axis
scope: Code review framework for evaluating implementation quality across five axes with severity labels.
when: Running /spec Review phase, @deepviewer code analysis, or /deepviewer audit
---

# Code Review Framework (Five-Axis)

## Overview

Standardized code review framework for evaluating every implementation across five axes: Correctness, Readability, Architecture, Security, and Performance. Every finding includes a severity label.

## The Five Axes

### 1. Correctness
Does the code do what it claims?
- Matches spec/task requirements
- Edge cases handled (null, empty, boundary values)
- Error paths handled
- Tests pass and cover the change adequately
- No off-by-one, race conditions, or state inconsistencies

### 2. Readability & Simplicity
Can another engineer understand this without explanation?
- Names are descriptive and consistent
- Control flow is straightforward
- Code is organized logically with clear module boundaries
- No "clever" tricks needing simplification
- Abstractions earn their complexity
- No dead code artifacts

### 3. Architecture
Does the change fit the system's design?
- Follows existing patterns or justifies new ones
- Maintains clean module boundaries
- No unnecessary coupling or circular dependencies
- Appropriate abstraction level
- No code duplication that should be shared

### 4. Security
Does the change introduce vulnerabilities? Apply the OWASP-informed checklist:

**Threat model** — Are trust boundaries mapped where untrusted data enters the system? Quick STRIDE lens applied.

**Injection** — All SQL/NoSQL queries parameterized. No OS commands built from user input. No user input in file paths or shell commands.

**Authentication & Sessions** — Passwords hashed (bcrypt/scrypt/argon2, rounds ≥ 12). Session tokens httpOnly, secure, sameSite. Login rate-limited. Reset tokens expire.

**Authorization** — Every endpoint checks permissions. Users access only their own resources. Admin actions verified.

**XSS** — Output encoded/escaped. No innerHTML/dangerouslySetInnerHTML with untrusted data. CSP headers present.

**Sensitive Data** — No secrets in code/logs. Sensitive fields excluded from API responses. No stack traces exposed to users.

**SSRF** — Server-fetched user URLs allowlisted by scheme, host, and resolved IP. Redirects forbidden.

**Misconfiguration** — Security headers present (CSP, HSTS, X-Frame-Options, X-Content-Type-Options). CORS restricted (not `*`). Rate limits on auth endpoints.

**Supply Chain** — Lockfile committed. No deps with known critical vulnerabilities. New deps reviewed.

**AI/LLM** — Model output treated as untrusted. Secrets kept out of prompts. Tool permissions scoped. Consumption bounded.

**Boundary system:** Always (validate, parameterize, encode, HTTPS, hash, headers, audit) / Ask first (new auth flows, sensitive data, integrations, CORS) / Never (secrets in code, log sensitive data, trust client-side, eval/innerHTML, localStorage for auth tokens, expose stack traces)

### 5. Performance
Does the change introduce performance problems?
- No N+1 query patterns
- No unbounded loops or unconstrained data fetching
- No sync operations that should be async
- Pagination on list endpoints
- No large objects in hot paths

## Severity Labels

| Label | Meaning | Required Action |
|-------|---------|----------------|
| **Critical:** | Blocks merge — security, data loss, broken functionality | Must fix before merge |
| **Important:** | Should be addressed before merge | Fix recommended |
| **Nit:** | Minor, optional — formatting, style | May ignore |
| **Optional:** / **Consider:** | Suggestion | Evaluate |
| **FYI** | Informational only | Note for future reference |

## Change Sizing

- **~100 lines** — Good. Reviewable in one sitting.
- **~300 lines** — Acceptable if single logical change.
- **~1000+ lines** — Too large. Flag for splitting.

## Review Output Template

```
## Code Quality Review
**Status:** ✅ Approved | ❌ Changes Required
**Five-Axis Results:**
- Correctness: ✅ Pass | ❌ Issues
- Readability: ✅ Pass | ❌ Issues
- Architecture: ✅ Pass | ❌ Issues
- Security: ✅ Pass | ❌ Issues
- Performance: ✅ Pass | ❌ Issues
- Change Sizing: ✅ OK | ❌ Too Large
**Issues:**
- [Critical] <issue> — <file:line>
- [Important] <issue> — <file:line>
- [Nit] <issue> — <file:line>
**Strengths:** <what was done well>
**Assessment:** approved or changes required
```

## Dead Code Hygiene

After any review, check for orphaned code:
1. Identify code that is now unreachable or unused
2. List it explicitly with file:line references
3. Flag for user decision before deletion
