---
name: tmux-orchestration
description: Use when running long processes and coordinating multiple subagents in parallel — sets up named tmux sessions and structured logging via pipe-pane with timestamps; replaces ad-hoc capture-pane polling with durable, greppable logs. No external integrations required.
---

# Tmux Orchestration

## Overview
Coordinate parallel agents and long-running commands with tmux. Name sessions predictably and stream logs to files with timestamps so humans have overview without attaching to panes.

## Quick Start (Copy/Paste)

```bash
# 1) Create logs dir
mkdir -p logs

# 2) Launch a named session (agent-budgets) with durable logging
SESSION=agent-budgets
tmux new-session -d -s "$SESSION" "${CMD:-echo 'set CMD to run'}"

# 3) Pipe pane to timestamped file (survives scroll) and console
tmux pipe-pane -o -t "$SESSION" "ts | tee -a logs/${SESSION}.log"   # requires 'moreutils' for ts; alternatively: awk '{print strftime("[%Y-%m-%d %H:%M:%S] ") $0}'

# 4) Watch all agents in one terminal (non-blocking)
tail -n 50 -F logs/*.log | sed -u 's/^/[log] /'

# 5) Stop an agent
tmux kill-session -t "$SESSION"
```

## Recommended Conventions
- Session name: `<area>-<task>` (e.g., `agent-repair`, `agent-tests`)
- One process per session; prefer logging over capture-pane for progress
- Always `pipe-pane` to `logs/<session>.log` with timestamps
- Set `remain-on-exit` so failures leave evidence: `tmux set-option -t <session> remain-on-exit on`

## Launching Subagents

```bash
# Example: launch a Codex subagent working a specific plan task
SESSION=agent-grid
PROMPT="Execute Task 3 from docs/plans/2025-10-26-grid.md"
tmux new-session -d -s "$SESSION" "codex --yolo \"$PROMPT\" 2>&1"
tmux pipe-pane -o -t "$SESSION" "ts | tee -a logs/${SESSION}.log"
```

### Send follow-ups (canonical two commands)
```bash
tmux send-keys -t "$SESSION" "$MESSAGE" 
tmux send-keys -t "$SESSION" C-m
```

## Optional: Lightweight Dashboards
To watch all agents at once without panes:
```bash
tail -n 50 -F logs/*.log | sed -u 's/^/[log] /'
```

## Why pipe-pane over capture-pane?
- capture-pane is a snapshot; you still need polling and it misses scrollback rotation
- pipe-pane streams output live to a file; tail works even if you reload panes or detach
- Files are greppable, compressible, and easy to ship to CI/artifacts

## Common Tasks
- List sessions: `tmux ls`
- Attach (read-only): `tmux attach -t <session>`
- Tail a specific agent: `tail -n 100 -F logs/<session>.log`
- Kill: `tmux kill-session -t <session>`

## Mistakes to Avoid
- Relying solely on capture-pane for progress
- Unnamed sessions (hard to route logs)
- No timestamps (impossible to correlate events)
- Logs not persisted (lose evidence after detach)

## Integration
- Works with superpowers:subagent-driven-development (one session per subagent)
