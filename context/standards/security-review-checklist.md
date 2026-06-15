---
tags:
  - security
  - review
  - deepviewer
  - OWASP
  - checklist
scope: Detailed security review reference for Deepviewer — OWASP-informed prevention patterns, code examples, dependency audit triage, and AI/LLM security.
when: Running /spec Review phase Security axis, security-focused @deepviewer analysis, or /deepviewer audit
---

# Security Review Checklist

## Overview

Deep reference for evaluating code security during review. Covers OWASP Top 10 prevention patterns, supply-chain hygiene, secrets management, and AI/LLM security. Use alongside the five-axis framework's Security axis.

## OWASP Prevention Patterns

### Injection (SQL, NoSQL, OS Command)

Check that queries are parameterized — never concatenated:

```typescript
// BAD: SQL injection via string concatenation
const query = `SELECT * FROM users WHERE id = '${userId}'`;

// GOOD: Parameterized query
const user = await db.query('SELECT * FROM users WHERE id = $1', [userId]);
```

**Review checklist:**
- All database queries use parameterized statements or a safe ORM
- No string concatenation in query building
- User input never reaches shell commands (`exec`, `spawn`, `child_process`)
- Stored procedures are parameterized, not dynamically constructed

### Cross-Site Scripting (XSS)

Check that output is encoded at the framework level:

```typescript
// BAD: Rendering user input as HTML
element.innerHTML = userInput;

// GOOD: Framework auto-escaping (React does this by default)
return <div>{userInput}</div>;

// If HTML MUST be rendered, sanitize first
import DOMPurify from 'dompurify';
const clean = DOMPurify.sanitize(userInput);
```

**Review checklist:**
- Framework auto-escaping is used (not bypassed with `dangerouslySetInnerHTML` or `v-html`)
- No `innerHTML`, `outerHTML`, `document.write` with untrusted data
- CSP headers are configured to restrict script sources
- User-generated content in href/src attributes is validated (no `javascript:` URLs)

### Broken Access Control

Check authorization, not just authentication:

```typescript
// Always check authorization, not just authentication
app.patch('/api/tasks/:id', authenticate, async (req, res) => {
  const task = await taskService.findById(req.params.id);

  // Check that the authenticated user owns this resource
  if (task.ownerId !== req.user.id) {
    return res.status(403).json({
      error: { code: 'FORBIDDEN', message: 'Not authorized' }
    });
  }
  const updated = await taskService.update(req.params.id, req.body);
  return res.json(updated);
});
```

**Review checklist:**
- Every protected endpoint has an authorization check (not just authentication)
- Object-level access control enforced (users access only their own resources)
- Admin routes verify admin role
- No IDOR (Insecure Direct Object Reference) vulnerabilities
- API routes don't leak unauthorized data via response fields

### Security Misconfiguration

```typescript
// Security headers (use helmet for Express)
import helmet from 'helmet';
app.use(helmet());

// CORS — restrict to known origins
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(',') || 'http://localhost:3000',
  credentials: true,
}));
```

**Review checklist:**
- Security headers set: CSP, HSTS, X-Frame-Options, X-Content-Type-Options
- CORS restricted to specific origins (not `*`)
- No debug/development endpoints exposed in production
- Error responses don't include stack traces
- HTTPS enforced (HTTP redirects or HSTS)

### Server-Side Request Forgery (SSRF)

Any server-side fetch of user-influenced URLs needs protection:

```typescript
// BAD: fetch whatever the user gives you
await fetch(req.body.webhookUrl);

// GOOD: allowlist scheme + host, reject private IPs, forbid redirects
import { lookup } from 'node:dns/promises';
const ALLOWED_HOSTS = new Set(['hooks.example.com']);

async function assertSafeUrl(raw) {
  const url = new URL(raw);
  if (url.protocol !== 'https:') throw new Error('https only');
  if (!ALLOWED_HOSTS.has(url.hostname)) throw new Error('host not allowed');
  const addrs = await lookup(url.hostname, { all: true });
  if (addrs.some((a) => ipaddr.parse(a.address).range() !== 'unicast')) {
    throw new Error('private/reserved IP');
  }
  return url;
}
```

**Review checklist:**
- User-supplied URLs are not fetched directly
- URL allowlist covers scheme, host, and resolved IP ranges
- Redirects are forbidden or validated
- Cloud metadata IP (`169.254.169.254`) is blocked

## Dependency Audit Triage

When `npm audit` or equivalent reports vulnerabilities:

```
npm audit reports a vulnerability
├── Severity: critical or high
│   ├── Reachable in your app?
│   │   ├── YES → Fix immediately (update, patch, replace)
│   │   └── NO (dev-only, unused path) → Fix soon, not a blocker
│   └── Fix available?
│       ├── YES → Update to patched version
│       └── NO → Check workarounds, consider replacement, or add to
│                allowlist with a review date
├── Severity: moderate
│   ├── Reachable in production? → Fix next release cycle
│   └── Dev-only? → Fix when convenient, track in backlog
└── Severity: low → Track during regular dependency updates
```

**Review checklist:**
- Lockfile is committed and `npm ci` is used in CI
- No dependencies with critical/high reachable vulnerabilities
- New dependencies are reviewed for maintenance and download counts
- Postinstall scripts in unfamiliar packages are flagged
- Typosquatting risks considered (e.g., `cross-env` vs `crossenv`)

## Secrets Management

```
.gitignore must include:
  .env, .env.local, .env.*.local, *.pem, *.key, *.secret*
```

**Review checklist:**
- No secrets in source code or git history (API keys, passwords, tokens)
- `.env.example` exists with placeholder values; real `.env` is gitignored
- Secrets loaded from environment variables or a secrets manager, not hardcoded
- No secrets in logs, error messages, or debug output
- If a secret was ever committed, assume compromised — rotate it

## Rate Limiting

**Review checklist:**
- Auth endpoints have rate limiting (login, password reset, registration)
- General API rate limiting is configured
- Rate limit errors are handled gracefully (not revealing user existence)

## AI/LLM Security (if applicable)

Treat model output as untrusted — it's a new attack surface:

```typescript
// BAD: trusting model output as a command or markup
const sql = await llm.generate(`Write SQL for: ${userQuestion}`);
await db.query(sql);                                     // arbitrary query execution
container.innerHTML = await llm.reply(userMessage);      // stored XSS via model

// GOOD: model output is data — parse, validate, encode
let intent;
try {
  intent = CommandSchema.parse(JSON.parse(await llm.replyJson(userMessage)));
} catch {
  throw new ValidationError('unexpected model output');
}
await runAllowlistedAction(intent.action, intent.params);
container.textContent = await llm.reply(userMessage);
```

**Review checklist:**
- Model output treated as untrusted input (no eval/SQL/innerHTML/shell)
- Secrets and other users' data kept out of prompts (anything in context can be echoed)
- Tool/agent permissions scoped to minimum; destructive actions require confirmation
- Token caps and rate limits applied to LLM calls
- RAG vector store partitioned per tenant (one user can't retrieve another's data)
- System prompt is not a security boundary — enforce permissions in code

## Full Security Review Checklist

```markdown
### Authentication
- [ ] Passwords hashed with bcrypt/scrypt/argon2 (salt rounds ≥ 12)
- [ ] Session tokens are httpOnly, secure, sameSite
- [ ] Login has rate limiting
- [ ] Password reset tokens expire

### Authorization
- [ ] Every endpoint checks user permissions
- [ ] Users can only access their own resources
- [ ] Admin actions require admin role verification

### Input & Output
- [ ] All user input validated at the system boundary
- [ ] SQL/NoSQL queries are parameterized
- [ ] HTML output is encoded/escaped (framework auto-escaping)
- [ ] No innerHTML/dangerouslySetInnerHTML with untrusted data
- [ ] Server-side URL fetches allowlisted (no SSRF)
- [ ] CSP headers configured
- [ ] File uploads restricted by type and size

### Data
- [ ] No secrets in code or version control
- [ ] Sensitive fields excluded from API responses
- [ ] PII encrypted at rest (if applicable)
- [ ] Stack traces not exposed to users

### Infrastructure
- [ ] Security headers configured (CSP, HSTS, X-Frame-Options, X-Content-Type-Options)
- [ ] CORS restricted to known origins
- [ ] Dependencies audited for known vulnerabilities
- [ ] Rate limiting on auth endpoints

### Supply Chain
- [ ] Lockfile committed; CI uses `npm ci`
- [ ] New dependencies reviewed (maintenance, downloads, postinstall scripts)

### AI / LLM (if applicable)
- [ ] Model output treated as untrusted (no eval/SQL/innerHTML/shell)
- [ ] Secrets and other users' data kept out of prompts
- [ ] Tool permissions scoped; destructive actions require confirmation
- [ ] Consumption bounded (token caps, rate limits, loop depth)
```

## Common Rationalizations to Watch For

| Rationalization | Reality |
|----------------|---------|
| "This is internal, security doesn't matter" | Internal tools get compromised. Attackers target the weakest link. |
| "We'll add security later" | Security retrofitting is 10x harder than building it in. |
| "No one would exploit this" | Automated scanners will find it. Security by obscurity is not security. |
| "The framework handles security" | Frameworks provide tools, not guarantees. You still need to use them correctly. |
| "It's just a prototype" | Prototypes become production. Security habits from day one. |
| "It's just LLM output, it's only text" | That text can be a SQL statement, a script tag, or a shell command. |

## Red Flags

- User input passed directly to database queries, shell commands, or HTML rendering
- Secrets in source code or commit history
- API endpoints without authentication or authorization checks
- CORS configured with wildcard (`*`) origins
- No rate limiting on authentication endpoints
- Stack traces exposed to users
- Dependencies with known critical vulnerabilities
- Server fetches user-supplied URLs without an allowlist (SSRF)
- LLM/model output passed into eval/SQL/the DOM/a shell
- Secrets or PII inside LLM context windows
