<div align="center">

# escort

**Predictive context agent for agent workflows.**

Richer dashboard providers that plug into [hookers](https://github.com/KnickKnackLabs/hookers).
Know what's happening without asking.

![shell: bash](https://img.shields.io/badge/shell-bash-4EAA25?style=flat&logo=gnubash&logoColor=white)
[![runtime: mise](https://img.shields.io/badge/runtime-mise-7c3aed?style=flat)](https://mise.jdx.dev)
![providers: 5](https://img.shields.io/badge/providers-5-blue?style=flat)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue?style=flat)](LICENSE)

</div>

## What it does

escort provides dashboard providers designed for agent workflows. Where [hookers](https://github.com/KnickKnackLabs/hookers) gives you `mail: 93`, escort gives you `mail: 8h 82a 3g` — 8 from humans, 82 from agents, 3 from GitHub.

Providers plug directly into hookers' configurable dashboard. No new hook wiring needed.

## Install

```bash
shiv install escort
```

## Quick start

Apply the session timer hook (enables elapsed time tracking), then update your dashboard config:

```bash
# Apply the session timer hook
hookers add SessionStart "bash -c '# hookers:session-timer
mkdir -p ~/.local/state/escort && date +%s > ~/.local/state/escort/session-start'"

# Use the example config (replaces your current dashboard config)
cp $(shiv which escort)/examples/dashboard.json ~/.config/hookers/dashboard.json
```

Or add individual providers to your existing config:

```json
{
  "items": [
    {
      "label": "mail",
      "command": "escort provider mail-breakdown"
    },
    {
      "label": "prs",
      "command": "escort provider open-prs"
    },
    {
      "label": "agents",
      "command": "escort provider active-agents"
    },
    {
      "label": "elapsed",
      "command": "escort provider session-elapsed"
    },
    {
      "label": "ci",
      "command": "escort provider ci-status"
    }
  ]
}
```

## Providers

| Provider | Description | Example output |
| --- | --- | --- |
| `active-agents` | agents currently running (in-progress fold workflow runs) | `k7r2 rho c0da or empty if none` |
| `ci-status` | CI status for current repo's default branch | `pass, fail, running, or empty if not in a repo` |
| `mail-breakdown` | unread mail breakdown by source | `2h 8a 1g (human, agent, github)` |
| `open-prs` | your open PRs + PRs requesting your review | `3 open 1 review or 3 open or 1 review` |
| `session-elapsed` | time since session started | `47m or 2h13m` |

## Example dashboard

With all providers enabled, your dashboard looks like:

```
[dashboard] mail: 8h 82a 3g | prs: 5 open 1 review | agents: k7r2 rho | ci: pass | elapsed: 47m | branch: main | gh-token: 5d
```

This fires on every prompt via hookers' `UserPromptSubmit` hook. Providers run in parallel — total latency is bounded by the slowest provider (~850ms worst case).

## Roadmap

escort will evolve beyond static providers into a predictive context agent:

```
Providers (current)  →  Predictive hints  →  Escort agent
Static data              Pattern-matched       Intelligent sidecar
                         command suggestions    that anticipates needs
```

See the [open issues](https://github.com/KnickKnackLabs/escort/issues) for what's planned.

## Development

```bash
git clone https://github.com/KnickKnackLabs/escort.git
cd escort && mise trust && mise install
```

<div align="center">

## License

MIT

This README was created using [readme](https://github.com/KnickKnackLabs/readme).

</div>
