---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements - runs a code-review pass using the code-reviewer template; optionally isolate the reviewer in its own tmux session for parallelism and persistent logs
---

# Requesting Code Review

Run a review using the code-reviewer template; if you want isolation and logs, launch it via tmux (see superpowers:tmux-orchestration).

**Core principle:** Review early, review often.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Run code-reviewer (template-driven):**

Open and fill `skills/requesting-code-review/code-reviewer.md` with the following placeholders:
- `{WHAT_WAS_IMPLEMENTED}` - What you just built
- `{PLAN_OR_REQUIREMENTS}` - What it should do
- `{BASE_SHA}` - Starting commit
- `{HEAD_SHA}` - Ending commit
- `{DESCRIPTION}` - Brief summary

You can run this review in the same session, or isolate it in a tmux session for parallel work and durable logs:

```bash
SESSION=review-$(date +%H%M%S)
tmux new-session -d -s "$SESSION" "codex --yolo 'Use code-reviewer template with WHAT_WAS_IMPLEMENTED=..., PLAN_OR_REQUIREMENTS=..., BASE_SHA=$BASE_SHA, HEAD_SHA=$HEAD_SHA, DESCRIPTION=...'"
tmux pipe-pane -o -t "$SESSION" "ts | tee -a logs/${SESSION}.log"
```

See superpowers:tmux-orchestration for details.

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Run reviewer (template-driven; tmux optional)]
  WHAT_WAS_IMPLEMENTED: Verification and repair functions for conversation index
  PLAN_OR_REQUIREMENTS: Task 2 from docs/plans/deployment-plan.md
  BASE_SHA: a7981ec
  HEAD_SHA: 3df7661
  DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types

[Subagent returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**superpowers:subagent-driven-development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**superpowers:executing-plans:**
- Review after each batch (3 tasks)
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

See template at: requesting-code-review/code-reviewer.md
