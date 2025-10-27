---
name: git-rules
description: Use when staging, committing, or manipulating history — safe, atomic workflow: no destructive resets, coordinate on others’ work, stage exact paths, quote globs, and avoid amends unless explicitly requested.
---

# Git Rules

## Safety
- No destructive operations (`reset --hard`, force-push, mass deletes) without explicit approval
- Coordinate before altering others’ in‑flight work

## Commits
- Keep commits atomic and scoped; stage exact file paths
- Keep commit messages extremely concise, sacrifice grammar if needed.
- Quote bracketed/glob paths in the shell
- Prefer squash merge; avoid `--amend` unless explicitly requested

## Hygiene
- Double-check `git status` before every commit
- Separate refactor-only commits from behavior changes when feasible

