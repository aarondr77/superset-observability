#!/bin/sh
set -e

cat <<'EOF'

================================================================================
  Devin Security Governance Dashboard
================================================================================

  Dashboard is running.

  Next steps:
    1. Open http://localhost:8888 in your browser

    2. You should see a dashboard with:
         • Median time to remediation across PRs
         • PR history with severity breakdown per finding
         • Contributor attribution (engineer vs. non-engineer, manager rollup)
         • Filters by date range, contributor type, severity, and search

    3. Press Ctrl+C in this terminal to stop the container

  No credentials required — data loads live from devin-sessions.json on the Superset fork.

================================================================================

EOF

exec python -u serve.py
