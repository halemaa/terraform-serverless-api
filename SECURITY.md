# Security considerations

Security was designed in, not bolted on. This document explains **what is
protected and how**, and — just as importantly — **what is deliberately left
open and why**, with the fix for each. Being honest about limitations is itself
a security skill: it shows you know where the edges are.

---

## What this project does well

### 1. Least-privilege IAM (the headline)
The Lambda runs under a role that can do **only four DynamoDB actions**
(`GetItem`, `PutItem`, `DeleteItem`, `Scan`) **on only one table** — its own.
It cannot read other tables, cannot delete the table, cannot touch any other
AWS service. See [`terraform/iam.tf`](terraform/iam.tf).

> If this function's code were ever exploited, the attacker inherits these tiny
> permissions and nothing else. That blast-radius thinking is the core of cloud
> security.

### 2. No hard-coded secrets
There are no passwords, keys, or tokens anywhere in the code. The Lambda finds
its table through an **environment variable** set by Terraform, and
authenticates to AWS using its **IAM role** (temporary, auto-rotated
credentials) — never a static key.

### 3. Encryption at rest
The DynamoDB table has `server_side_encryption` enabled, so data is encrypted
on disk by AWS at no extra cost.

### 4. Encryption in transit
API Gateway serves **HTTPS only**. Traffic between the client and AWS is
encrypted automatically.

### 5. Logging & auditability
Both API Gateway (access logs) and Lambda (execution logs) write to CloudWatch,
so every request leaves an audit trail: source IP, route, status, latency. Log
retention is capped at 14 days to limit both cost and data exposure.

### 6. Input validation & safe errors
The handler validates input (`text` is required) and **never returns a raw
stack trace** to the caller — internal errors are logged privately and the
client gets a generic `500`. This avoids leaking implementation details to an
attacker.

### 7. Point-in-time recovery
DynamoDB PITR is on, giving 35 days of continuous backups — protection against
accidental or malicious data loss.

---

## Known limitations (and how to fix each)

These are intentional scope choices for a learning/portfolio project. Each is
called out with its production fix so the trade-off is explicit.

| # | Limitation | Risk | Production fix |
|---|------------|------|----------------|
| 1 | **The API is public and unauthenticated.** Anyone with the URL can read/write items. | Abuse, data tampering | Add a JWT authorizer (Amazon Cognito) or an API-key usage plan in API Gateway. |
| 2 | **CORS allows all origins (`*`).** | A page on any site could call the API from a browser. | Restrict `allow_origins` to your known front-end domain(s). |
| 3 | **No rate limiting / WAF.** | A flood of requests could run up cost or cause abuse. | Add API Gateway throttling limits and/or AWS WAF rules. |
| 4 | **`Scan` is used to list items.** | Reads the whole table; slow and costly at scale. | For large data, redesign access patterns and use `Query` on an index. |
| 5 | **Terraform state may contain sensitive values and is local by default.** | State on a laptop can be lost or leaked. | Use a remote backend (S3 + DynamoDB lock) with encryption and access control. |
| 6 | **No separate dev/prod isolation.** | Changes could affect one environment unexpectedly. | Use Terraform workspaces or separate state per environment. |

---

## Secrets & CI/CD

The GitHub Actions pipeline never prints credentials. AWS access for the
`apply` job comes from repository **secrets** (`AWS_ACCESS_KEY_ID`,
`AWS_SECRET_ACCESS_KEY`), or — better — from **GitHub OIDC** assuming an IAM
role with no long-lived keys at all (recommended next step, noted in the
workflow). The `.gitignore` excludes `*.tfvars`, `*.tfstate`, and the build
directory so no local state or settings are ever committed.

---

## Reporting

This is a personal portfolio project. If you spot a security issue, please open
an issue on the repository.
