#!/usr/bin/env bash
# Dashboard provider: agents currently running (in-progress fold workflow runs)
# Output: "k7r2 rho c0da" or empty if none

RUNS=$(gh api /repos/ricon-family/fold/actions/runs?status=in_progress --jq '.workflow_runs[].triggering_actor.login' 2>/dev/null || true)
[ -z "$RUNS" ] && exit 0

# Strip -ricon suffix, deduplicate, exclude self
AGENTS=$(echo "$RUNS" | sed 's/-ricon$//' | sort -u | grep -v "^$(whoami | sed 's/-ricon$//')$" || true)
[ -z "$AGENTS" ] && exit 0

echo "$AGENTS" | tr '\n' ' ' | sed 's/ $//'
