---
name: subagent-driven-development
description: Use when executing implementation plans with independent tasks in the current session - dispatches fresh subagent for each task with code review between tasks, enabling fast iteration with quality gates
---

# Subagent-Driven Development

Execute plan by dispatching fresh subagent per task, with code review after each.

**Core principle:** Fresh subagent per task + review between tasks = high quality, fast iteration

## Overview

**vs. Executing Plans (parallel session):**
- Same session (no context switch)
- Fresh subagent per task (no context pollution)
- Code review after each task (catch issues early)
- Faster iteration (no human-in-loop between tasks)

**When to use:**
- Staying in this session
- Tasks are mostly independent
- Want continuous progress with quality gates

**When NOT to use:**
- Need to review plan first (use superpowers:executing-plans)
- Tasks are tightly coupled (manual execution better)
- Plan needs revision (brainstorm first)

## The Process

### 1. Load Plan

Read the implementation plan, then instruct Codex to mirror every task inside the `Plan` UI:

```
Plan
- [ ] Task 1: …
- [ ] Task 2: …
```

Tell Codex explicitly: "Create a plan with a checkbox for each task below, then execute them step-by-step, updating the plan after each action."

### 2. Execute Task with Subagent

For each task, dispatch a fresh subagent via the orchestration skill so context and logs stay isolated (one orchestration session per task).

**REQUIRED SUB-SKILL:** Use superpowers:tmux-orchestration

Implementation flow per task (process only; see tmux-orchestration for commands):
1. Initialize orchestration once if needed (per its Quick Start).
2. Create a uniquely named session for the task (`task-<n>-<slug>`); do not reuse sessions across tasks.
3. Ensure logging is active from the start of the session; do not proceed without it.
4. Send clear, scoped instructions to the subagent: goal, acceptance criteria, constraints, and timebox.
5. Monitor the run through the orchestration logs/dashboard; intervene if stuck, escalate if blocked, and record notable decisions.

The worker (you or another Codex session) follows the task’s instructions, writes tests (TDD), implements the change, verifies, and reports back. Keep the session’s log as the subagent report.

### 3. Review Subagent's Work

Run a review using the template in `skills/requesting-code-review/code-reviewer.md`. Launch the reviewer in its own orchestration session (e.g., `review-<task>`), with logging enabled, using superpowers:tmux-orchestration.

Reviewer returns Strengths, Issues (Critical/Important/Minor), and an Assessment. Capture the output in the log and paste highlights back into the main plan.

### 4. Apply Review Feedback

**If issues found:**
- Fix Critical issues immediately
- Fix Important issues before next task
- Note Minor issues

**Dispatch follow-up subagent if needed:** create a new tmux session focused on fixing the specific issues found.

### 5. Mark Complete, Next Task

- Check off the task inside the `Plan` / `Updated Plan` block
- Move to the next task
- Repeat steps 2-5

### 6. Final Review

After all tasks complete, dispatch final code-reviewer:
- Reviews entire implementation
- Checks all plan requirements met
- Validates overall architecture

### 7. Complete Development

After final review passes:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## Example Workflow

```
You: I'm using Subagent-Driven Development to execute this plan.

[Plan mirrored from checklist]

Task 1: Hook installation script

[Dispatch implementation subagent]
Subagent: Implemented install-hook with tests, 5/5 passing

[Get git SHAs, dispatch code-reviewer]
Reviewer: Strengths: Good test coverage. Issues: None. Ready.

[Updated Plan: Task 1 checked off]

Task 2: Recovery modes

[Dispatch implementation subagent]
Subagent: Added verify/repair, 8/8 tests passing

[Dispatch code-reviewer]
Reviewer: Strengths: Solid. Issues (Important): Missing progress reporting

[Dispatch fix subagent]
Fix subagent: Added progress every 100 conversations

[Verify fix, check off Task 2]

...

[After all tasks]
[Dispatch final code-reviewer]
Final reviewer: All requirements met, ready to merge

Done!
```

## Advantages

**vs. Manual execution:**
- Subagents follow TDD naturally
- Fresh context per task (no confusion)
- Parallel-safe (subagents don't interfere)

**vs. Executing Plans:**
- Same session (no handoff)
- Continuous progress (no waiting)
- Review checkpoints automatic

**Cost:**
- More subagent invocations
- But catches issues early (cheaper than debugging later)

## Red Flags

**Never:**
- Skip code review between tasks
- Proceed with unfixed Critical issues
- Dispatch multiple implementation subagents in parallel (conflicts)
- Implement without reading plan task

**If subagent fails task:**
- Dispatch fix subagent with specific instructions
- Don't try to fix manually (context pollution)

## Integration

**Required workflow skills:**
- **superpowers:writing-plans** - REQUIRED: Creates the plan that this skill executes
- **superpowers:requesting-code-review** - REQUIRED: Review after each task (see Step 3)
- **superpowers:finishing-a-development-branch** - REQUIRED: Complete development after all tasks (see Step 7)
- **superpowers:tmux-orchestration** - REQUIRED: One session per subagent and persistent logs

**Subagents must use:**
- **superpowers:test-driven-development** - Subagents follow TDD for each task

**Alternative workflow:**
- **superpowers:executing-plans** - Use for parallel session instead of same-session execution

See reviewer template in superpowers:requesting-code-review (file: requesting-code-review/code-reviewer.md)
