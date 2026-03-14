#!/usr/bin/env bash
# Dashboard provider: CI status for current repo's default branch
# Output: "pass", "fail", "running", or empty if not in a repo

REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null || true)
[ -z "$REPO" ] && exit 0

BRANCH=$(gh repo view --json defaultBranchRef --jq '.defaultBranchRef.name' 2>/dev/null || true)
[ -z "$BRANCH" ] && exit 0

STATUS=$(gh api "/repos/${REPO}/commits/${BRANCH}/check-runs?per_page=1" --jq '
  .check_runs[0] |
  if .status == "completed" then
    if .conclusion == "success" then "pass"
    elif .conclusion == "failure" then "fail"
    else .conclusion
    end
  else .status
  end
' 2>/dev/null || true)

[ -n "$STATUS" ] && echo "$STATUS"
