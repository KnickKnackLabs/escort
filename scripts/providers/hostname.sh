#!/usr/bin/env bash
# Dashboard provider: short hostname
# Output: "macbook-pro" or similar
set -euo pipefail

hostname -s 2>/dev/null || true
