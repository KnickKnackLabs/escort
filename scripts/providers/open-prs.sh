#!/usr/bin/env bash
# Dashboard provider: your open PRs + PRs requesting your review
# Output: "3 open 1 review" or "3 open" or "1 review"

OPEN=$(gh search prs --state=open --author=@me --json number --jq 'length' 2>/dev/null || echo "")
REVIEW=$(gh search prs --state=open --review-requested=@me --json number --jq 'length' 2>/dev/null || echo "")

PARTS=()
[ -n "$OPEN" ] && [ "$OPEN" -gt 0 ] && PARTS+=("${OPEN} open")
[ -n "$REVIEW" ] && [ "$REVIEW" -gt 0 ] && PARTS+=("${REVIEW} review")

[ ${#PARTS[@]} -eq 0 ] && exit 0

IFS=" "
echo "${PARTS[*]}"
