---
name: skill-opportunity-scouting
description: Use when conversations surface repeatable insights, frictions, or decisions that should become reusable skills - trains the agent to flag, log, and shepherd emerging patterns into future skill playbooks before they fade.
---

# Skill Opportunity Scouting

## Overview
Treat every recurring friction or breakthrough as a candidate for a future skill. This playbook keeps the agent alert to skill-worthy moments, captures them immediately, and hands them off to the skill authoring pipeline before the insight evaporates.

## When to Use
- You spot teammates repeating the same workaround, reminder, or question within a single session or across days.
- A decision or workaround feels broadly reusable beyond the current task.
- You hear “We should write this down” or notice unresolved confusion that a reusable playbook would dissolve.
- You are finishing any incident, retro, or debrief where new patterns emerged.
- Do **not** use when the issue is project-specific bookkeeping better suited for AGENTS.md or when existing skills already cover the gap (double-check the catalog first).

## Core Workflow
1. **Identify signal quickly**
   - Listen for repeat pain, novel solution, or insight that will recur.
   - Cross-check existing skill catalog titles/descriptions to avoid duplicates.
2. **Qualify the opportunity**
   - Ask: “Would a future agent benefit from a ready-made playbook here?”
   - Validate that the pattern is general (not tied to a one-off constraint).
3. **Capture immediately**
   - Record a one-line stub with: trigger, proposed skill name, and what problem it solves.
   - Choose destination: `journaling-and-decisions` journal entry, task issue, or dedicated TODO list.
4. **Shepherd to creation**
   - Tag responsible owner (yourself or teammate).
   - Schedule follow-up: add to planning backlog or open issue referencing `writing-skills`.
   - When bandwidth allows, run the RED step of `writing-skills` to begin authoring.

## Quick Reference

| Trigger phrase / situation                | Immediate action                          |
|-------------------------------------------|-------------------------------------------|
| “We keep running into…” repeat friction   | Log a skill stub with friction + context. |
| New workaround discovered                 | Check catalog; if absent, flag for skill. |
| Multiple teammates confused simultaneously| Draft shared language and capture signals.|
| Post-incident retrospective               | Extract learnings; convert to skill leads.|

## Rationalization Table

| Rationalization heard                     | Counter baked into this skill                                   |
|-------------------------------------------|------------------------------------------------------------------|
| “We’ll document later.”                   | Step 3 forces immediate stub creation with owner + follow-up.   |
| “This might be a one-off edge case.”      | Step 2 qualification requires assessing generality explicitly.  |
| “Someone else probably has a playbook.”   | Catalog check in Step 1 removes ambiguity and exposes gaps fast.|
| “We’re in the middle of delivery; no time.”| Stub takes <60 seconds; defer full write-up but never the capture.|

## Red Flags
- Meeting notes lack follow-up items despite multiple repeated confusions.
- Incident review ends without any new backlog items or skill stubs.
- You cannot point to a destination for the insight (journal, issue, task).
- You rely on memory to recall “that trick from last time” instead of a playbook.

## Example
During a planning call, the team re-litigates branching strategies for release hotfixes. The agent:
1. Checks the catalog, sees no branching skill.
2. Captures stub: “skill idea: release-branch-guardrails — trigger: hotfix vs mainline confusion.”
3. Logs it in the shared journal with owner and next step: “Run writing-skills RED scenario during Friday cleanup block.”
4. Adds the item to the backlog so the idea survives beyond the meeting.

## Common Mistakes
- Skipping the catalog check and proposing duplicates (wasteful noise).
- Capturing vague stubs without trigger/context, making later authoring impossible.
- Deferring ownership, so nobody drives the skill to completion.
- Treating AGENTS.md updates as substitutes for reusable cross-project skills.

## Implementation Notes
- Stubs can live in any durable tracker (Wiki journal, backlog issue, TODO queue) as long as it is reviewed weekly.
- Pair this skill with `journaling-and-decisions` for reliable storage and `writing-skills` once you commit to authoring.
- Consider reviewing stubs during weekly planning to pick candidates for RED scenarios.

## Verification
- After a session, confirm every flagged friction either mapped to an existing skill or has a recorded stub.
- During follow-up, ensure each stub has an assigned owner and next action toward full skill creation.

