# Dashboard for Devin Bandit Review Bot

## What this project solves
AI coding tools are exploding the number of contributors to Apache Superset. In 2024, Superset averaged around 78 contributors per quarter. By 2026-Q2 that number is 111 — an 18% year-over-year increase, and Q1 2026 saw a 45% jump over the previous quarter.

These new contributors are both new to Superset and, in some cases, new to software engineering (hi vibe coders! Welcome!). With that comes, comes the real risk of introducing new security issues into our codebase. 

The standard response to this is static analysis. Run Bandit, tag the findings, open GitHub issues. But that's not enough. You can't trust a vibe coder to fix a security vulnerability they don't fully understand, and you certainly can't let it sit in an open issue while we release vulnerable code.

This system uses the Devin API to automatically detect and fix vulnerabilities in Superset pull requests. It requires to have their code reviewed by the our custom built Devin Vulnerability Remediation Agent before they are able to merge their code. 

## Quick start (simulate the workflow)

No credentials required. The dashboard loads tracked remediation data from the Superset fork.

Clone this repo and then run this enviornment

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

## Testing the full system (not just a simulation)

Run the full security scan and auto-remediation workflow on **your own fork** of the [Superset demo repo](https://github.com/aarondr77/superset) with your own Devin API key.

### 1. Fork and configure GitHub Actions

1. Fork [github.com/aarondr77/superset](https://github.com/aarondr77/superset) to your GitHub account.
2. On your fork, go to **Settings → Actions → General** and enable workflows. **I've disabled all of the workflows in this fork other than the new Devin security agent**.
3. Go to **Settings → Secrets and variables → Actions** and add a repository secret:
   - Name: `DEVIN_API_KEY`
   - Value: your [Devin API key](https://docs.devin.ai/)
4. Sync your fork's `master` with upstream (GitHub **Sync fork** button, or `git pull upstream master` after cloning). The demo branch only contains the injected vulnerabilities — the workflow pulls `.github/scripts/process_findings.py` from your fork's default branch at runtime.

### 2. Create your branch, push, and open a PR

Branch off `introduce-vulnerabilities` into a timestamped `demo-{time}` branch. That branch contains five intentionally injected Bandit findings (B324, B608, B105, B310, B602).

```bash
git clone https://github.com/<your-username>/superset.git
cd superset
git remote add upstream https://github.com/aarondr77/superset.git
git fetch upstream introduce-vulnerabilities
git checkout -b demo-$(date +%Y%m%d-%H%M%S) upstream/introduce-vulnerabilities
git push -u origin HEAD
```

Open the PR against **your fork's `master`**, not the upstream repo.

### 3. Trigger the security scan

When the PR opens, a bot comment will appear with instructions. 

If the bot does not leave the comment, click on the GitHub Actions tab and make sure the workflow is enabled.

Then, comment `@devin-error-detector` on the PR:

That triggers the **Security Scan + Auto-Remediation** GitHub Action. It runs Bandit, posts findings as a PR review comment, and kicks off Devin to remediate each issue sequentially.

### 4. Watch remediation and review results

- Follow the PR for Bandit findings, Devin fix commits (e.g. `fix: remediate B602 in ...`), and the final scan summary.
- Session data is logged to `devin-sessions.json` on your fork's `master`.

## How the system works

1. A developer opens a PR against the Superset fork.
2. Before merging, they are required to run the security scan and remediate the findings. To trigger the agent, they comment `@devin-error-detector` on the PR.
3. The **Security Scan + Auto-Remediation** GitHub Action runs Bandit on `superset/`.
4. Findings are posted as a PR review comment.
5. Devin automatically remediates each finding sequentially, pushing fix commits to the PR branch.
6. Results are logged to `devin-sessions.json` on `master`.

Key files on the Superset fork:

- [`.github/workflows/security-scan.yml`](https://github.com/aarondr77/superset/blob/master/.github/workflows/security-scan.yml) — scan + Devin orchestration
- [`.github/scripts/process_findings.py`](https://github.com/aarondr77/superset/blob/master/.github/scripts/process_findings.py) — filters target findings, triggers Devin, logs sessions
