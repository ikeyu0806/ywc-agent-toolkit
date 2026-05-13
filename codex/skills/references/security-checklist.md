# Security Checklist

Load this reference when the implementation touches authentication, authorization, external input, sensitive data, or externally reachable endpoints.

## OWASP-Oriented Checks

| Area | Inspection points |
|---|---|
| Broken Access Control | Missing auth middleware, insufficient authorization checks, IDOR |
| Cryptographic Failures | Plaintext storage, weak hashing, exposed secrets |
| Injection | SQL injection, command injection, XSS, unsafe template rendering |
| Insecure Design | Business logic bypass, missing rate limits, unsafe trust boundaries |
| Misconfiguration | CORS, debug mode, overly broad permissions, default credentials |
| Vulnerable Components | Risky dependency versions or unmaintained packages |
| Auth Failures | Session management, token expiry, password reset flows |
| Data Integrity | Missing validation, unsafe deserialization, tamper-prone callbacks |
| Logging Failures | Missing security audit logs, sensitive data in logs |
| SSRF | Unvalidated external URLs or internal network access |

## Severity Guide

| Severity | Criteria |
|---|---|
| Critical | Directly exploitable auth bypass, injection, secret exposure, or data loss |
| High | Conditionally exploitable issue or broad unauthorized access risk |
| Medium | Plausible security weakness with limited exploitability |
| Low | Hardening or best-practice improvement |

## Finding Format

```text
[Severity] path:line
OWASP: A0X or category name
Risk: concrete exploit or failure mode
Fix: specific remediation
```

Avoid speculative findings without a reachable path.
