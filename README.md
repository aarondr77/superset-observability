# Devin Security Governance for Apache Superset

## What this project solves
AI coding tools are exploding the number of contributors to Apache Superset. In 2024, Superset averaged around 78 contributors per quarter. By 2026-Q2 that number is 111 — an 18% year-over-year increase, and Q1 2026 saw a 45% jump over the previous quarter.

These new contributors are both new to Superset and, in some cases, new to software engineering (hi vibe coders! Welcome!). With that comes, comes the real risk of introducing new security issues into our codebase. 

The standard response to this is static analysis. Run Bandit, tag the findings, open GitHub issues. But that's not enough. You can't trust a vibe coder to fix a security vulnerability they don't fully understand, and you certainly can't let it sit in an open issue while we release vulnerable code.

This system uses the Devin API to automatically detect and fix vulnerabilities in Superset pull requests. It requires to have their code reviewed by the our custom built Devin Vulnerability Remediation Agent before they are able to merge their code. 

## Quick start (simulate the workflow)

No credentials required. The dashboard loads tracked remediation data from the Superset fork.

```bash
docker compose up
```

Open [http://localhost:8888](http://localhost:8888).

You should see a dashboard with:

- **Remediation rate** and average fix time across PRs
- **PR history** with severity breakdown per finding
- **Contributor attribution** (engineer vs. non-engineer, manager rollup)
- Filters by date range, contributor type, severity, and search

Press `Ctrl+C` to stop the container.

## How the system works

1. A developer opens a PR against.
2. Before merging, they are required to run the security scan and remediate the findings. To trigger the agent, they comment `@devin-error-detector` on the PR.
3. The **Security Scan + Auto-Remediation** GitHub Action runs Bandit on `superset/`.
4. Findings are posted as a PR review comment.
5. Devin automatically remediates each finding sequentially, pushing fix commits to the PR branch.
6. Results are logged to `devin-sessions.json` on `master`.

Key files on the Superset fork:

- [`.github/workflows/security-scan.yml`](https://github.com/aarondr77/superset/blob/master/.github/workflows/security-scan.yml) — scan + Devin orchestration
- [`.github/scripts/process_findings.py`](https://github.com/aarondr77/superset/blob/master/.github/scripts/process_findings.py) — filters target findings, triggers Devin, logs sessions

## The 5 security issues

These are the Bandit rules targeted by the GitHub Action (filtered in `process_findings.py`):

| Rule | Severity | File | Issue |
|------|----------|------|-------|
| B324 | Medium | `superset/key_value/utils.py` | Insecure MD5 hash (`hashlib.md5`) |
| B608 | Medium | `superset/views/core.py` | SQL string concatenation |
| B105 | Low | `superset/config.py` | Hardcoded Redis passwords |
| B310 | Medium | `superset/views/core.py` | Unsafe `urllib.request.urlopen` |
| B602 | High | `superset/utils/core.py` | `subprocess` with `shell=True` |

Introduced on the `introduce-vulnerabilities` branch. Remediated by Devin sessions triggered via the GitHub Action — see fix commits (e.g. `fix: remediate B602 in ...`) and entries in `devin-sessions.json`.