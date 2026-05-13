# Tenancy and Billing Checklist

Use this checklist when reviewing a SaaS architecture.

- Is the tenant model explicit and stable?
- Can a user belong to multiple tenants, and is switching behavior defined?
- Is tenant identity carried through every read, write, job, and event?
- Is there one clear source of truth for plan entitlements?
- Are upgrades, downgrades, trials, cancellation, and grace periods defined?
- Are billing webhooks idempotent and replay-safe?
- Are seat counts or usage metrics computed from auditable inputs?
- Can support operations be performed without bypassing normal audit trails?
- Are privileged operator actions logged with actor and target tenant context?
- Is cross-tenant reporting or analytics isolated deliberately instead of accidentally?
