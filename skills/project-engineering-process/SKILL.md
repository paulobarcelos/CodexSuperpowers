---
name: project-engineering-process
description: Use when coordinating day-to-day work on Runway Compass — defines source-of-truth, branch naming, CI expectations, and how to journal/record decisions in the GitHub Wiki (single Journal page and single Decisions page). Keep Discussions only for Ideas. Issues for executable work; Projects for status.
---

# Project Engineering Process

## Source of Truth
- Wiki → Journal (single page), Decisions (single page)
- Discussions → Ideas (category)
- Issues → Executable work with acceptance criteria
- PRs → Code changes linked to Issues
- Projects v2 → Planning and status (Backlog/Now/Next/Done)
- Milestones/Releases → Cadence and notes

## Branching & Commits
- Branch: `feature/<slug>` or `chore/<slug>`
- Keep commits atomic; reference Issue (and PR auto-closes where appropriate)
- Default merge: squash, PR title as commit subject

## CI Discipline
- PRs must be green (lint/tests/build)
- Treat Vercel preview as deployability check; Actions as regression guard

## Journaling & Decisions
- Journal: append entries to Wiki page `Journal` (timestamped blocks)
- Decisions: append entries to Wiki page `Decisions` (ADR-style blocks)
- Avoid ad‑hoc `.md` notes scattered in the repo; link Wiki anchors from PRs/Issues when relevant

## Working Agreement
1. Ensure an Issue exists for the task (create if missing)
2. Move to In Progress on the Project board
3. Update docs only when system/process actually changes
4. On completion: tests green → PR → merge → close Issue

## Tools
- `gh` CLI for Issues/PRs/Projects/Discussions/Wiki
- Pair with superpowers:github-program-manager (now Wiki-first) and superpowers:tmux-orchestration for parallel agents
