---
name: tmux-orchestration
description: Use when running long processes and coordinating multiple subagents in parallel — sets up named tmux sessions and structured logging via pipe-pane with timestamps; replaces ad-hoc capture-pane polling with durable, greppable logs. No external integrations required.
---

# Tmux Orchestration

## Overview
Coordinate parallel agents and long-running commands with tmux. Name sessions predictably and stream logs to files with timestamps so humans have overview without attaching to panes.

## Quick Start (Copy/Paste)

```bash
# 1) Create hidden logs dir (ensure .tmux-logs/ is gitignored)
LOG_ROOT="$(pwd)/.tmux-logs"
mkdir -p "$LOG_ROOT"
touch "$LOG_ROOT/.gitkeep"
touch .gitignore
if ! grep -q '^\\.tmux-logs/\\*$' .gitignore; then
  {
    echo '.tmux-logs/*'
    echo '!.tmux-logs/.gitkeep'
  } >> .gitignore
  echo 'Added .tmux-logs ignore rules (commit this change).'
fi

# 2) Launch a named session (agent-budgets) with durable logging
SESSION=agent-budgets
tmux new-session -d -s "$SESSION" -c "$(pwd)"
tmux pipe-pane -o -t "$SESSION:0.0" "ts | tee -a ${LOG_ROOT}/${SESSION}.log"
tmux send-keys -t "$SESSION" "${CMD:-echo 'set CMD to run'}" Enter

# 3) Logging now streams to "$LOG_ROOT/${SESSION}.log" (ts requires moreutils; fallback: awk '{print strftime("[%Y-%m-%d %H:%M:%S] ") $0}')

# 4) Watch all agents in one terminal (non-blocking)
tail -n 50 -F "$LOG_ROOT"/*.log | sed -u 's/^/[log] /'

# 5) Stop an agent
tmux kill-session -t "$SESSION"
```

## Recommended Conventions
- Session name: `<area>-<task>` (e.g., `agent-repair`, `agent-tests`)
- One process per session; prefer logging over capture-pane for progress
- Always `pipe-pane` to `.tmux-logs/<session>.log` with timestamps
- Set `remain-on-exit` so failures leave evidence: `tmux set-option -t <session> remain-on-exit on`
- Launch sessions with `tmux new-session -c "$(pwd)"` so they inherit the current repo as working directory

## Launching Subagents

```bash
# Example: launch a Codex subagent working a specific plan task
SESSION=agent-grid
PROMPT="Execute Task 3 from docs/plans/2025-10-26-grid.md"
LOG_ROOT="$(pwd)/.tmux-logs"
tmux new-session -d -s "$SESSION" -c "$(pwd)"
tmux send-keys -t "$SESSION" "cd /path/to/location"
tmux send-keys -t "$SESSION" Enter
tmux send-keys -t "$SESSION" "codex --yolo"
tmux send-keys -t "$SESSION" Enter
tmux send-keys -t "$SESSION" "'$PROMPT'"
tmux send-keys -t "$SESSION" C-m
tmux pipe-pane -o -t "$SESSION:0.0" "ts | tee -a ${LOG_ROOT}/${SESSION}.log"
```

### Send follow-ups (canonical two commands)
```bash
tmux send-keys -t "$SESSION" "$MESSAGE" 
tmux send-keys -t "$SESSION" C-m
```

## Optional: Lightweight Dashboards
To watch all agents at once without panes:
```bash
LOG_ROOT="$(pwd)/.tmux-logs"
tail -n 50 -F "$LOG_ROOT"/*.log | sed -u 's/^/[log] /'
```

## Why pipe-pane over capture-pane?
- capture-pane is a snapshot; you still need polling and it misses scrollback rotation
- pipe-pane streams output live to a file; tail works even if you reload panes or detach
- Files are greppable, compressible, and easy to ship to CI/artifacts

## Common Tasks
- List sessions: `tmux ls`
- Attach (read-only): `tmux attach -t <session>`
- Tail a specific agent: `tail -n 100 -F $(pwd)/.tmux-logs/<session>.log`
- Kill: `tmux kill-session -t <session>`

## Mistakes to Avoid
- Relying solely on capture-pane for progress
- Unnamed sessions (hard to route logs)
- No timestamps (impossible to correlate events)
- Logs not persisted (lose evidence after detach)
- `.tmux-logs/` missing from `.gitignore` (risk leaking logs into commits)
- Relative log paths in `pipe-pane` (logs end up in $HOME or disappear)

## Integration
- Works with superpowers:subagent-driven-development (one session per subagent)
