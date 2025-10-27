---
name: using-superpowers
description: Use when starting any conversation - establishes mandatory workflows for finding and using skills in Codex CLI, including invoking Skill files before announcing usage, following brainstorming before coding, and mirroring every checklist inside Codex's Plan / Updated Plan blocks
---

<EXTREMELY-IMPORTANT>
If you think there is even a 1% chance a skill might apply to what you are doing, you ABSOLUTELY MUST read the skill.

IF A SKILL APPLIES TO YOUR TASK, YOU DO NOT HAVE A CHOICE. YOU MUST USE IT.

This is not negotiable. This is not optional. You cannot rationalize your way out of this.
</EXTREMELY-IMPORTANT>

# Getting Started with Skills

## MANDATORY FIRST RESPONSE PROTOCOL

Before responding to ANY user message, you MUST complete this checklist:

1. ☐ List available skills in your mind (re-index if you need a refresher)
2. ☐ Ask yourself: "Does ANY skill match this request?"
3. ☐ If yes → Load the actual `SKILL.md` file before taking action
4. ☐ Announce which skill you're using
5. ☐ Follow the skill exactly

**Responding WITHOUT completing this checklist = automatic failure.**

## Critical Rules

1. **Follow mandatory workflows.** Brainstorming before coding. Check for relevant skills before ANY task.
2. Execute skills by literally showing Codex the file contents (copy the relevant section or run `cat ./skills/<skill>/SKILL.md || cat ~/.codex/skills/<skill>/SKILL.md`). Codex must see the current instructions before touching the repo.
3. Keep Codex's plan (`Plan` / `Updated Plan` blocks) perfectly synced with every checklist.

## Triggering Codex Plan Mode

Codex CLI surfaces plan blocks whenever you explicitly ask for them. Use phrases like "make a plan first", "maintain a plan", and "update the plan before/after each action" to keep the planner active. If Codex offers its own plan, replace it with the skill-aligned checklist immediately and continue revising it as you work.

## Common Rationalizations That Mean You're About To Fail

If you catch yourself thinking ANY of these thoughts, STOP. You are rationalizing. Check for and use the skill.

- "This is just a simple question" → WRONG. Questions are tasks. Check for skills.
- "I can check git/files quickly" → WRONG. Files don't have conversation context. Check for skills.
- "Let me gather information first" → WRONG. Skills tell you HOW to gather information. Check for skills.
- "This doesn't need a formal skill" → WRONG. If a skill exists for it, use it.
- "I remember this skill" → WRONG. Skills evolve. Run the current version.
- "This doesn't count as a task" → WRONG. If you're taking action, it's a task. Check for skills.
- "The skill is overkill for this" → WRONG. Skills exist because simple things become complex. Use it.
- "I'll just do this one thing first" → WRONG. Check for skills BEFORE doing anything.

**Why:** Skills document proven techniques that save time and prevent mistakes. Not using available skills means repeating solved problems and making known errors.

If a skill for your task exists, you must use it or you will fail at your task.

## Skills with Checklists

If a skill has a checklist, YOU MUST mirror every item inside Codex CLI's `Plan` UI.

**Workflow:**
1. Tell Codex: `Create a plan with a checkbox for each checklist item below, then execute step-by-step, updating the plan after each action.`
2. Paste the checklist items verbatim as bullet points under `Plan`.
3. Before **each** command or edit, update the plan (rename it to `Updated Plan`, check off completed items, and add any discoveries).
4. After the command or edit finishes, reflect on outcomes and revise the plan again.

**Don't:**
- Work through checklist mentally
- Skip plan updates to "save time"
- Batch multiple items into one checkbox
- Mark complete without evidence

**Why:** If the Codex's planner falls out-of-sync with the skill checklist, Codex will skip steps and fail audits.

## Announcing Skill Usage

Before using a skill, announce that you are using it.
"I'm using [Skill Name] to [what you're doing]."

**Examples:**
- "I'm using the brainstorming skill to refine your idea into a design."
- "I'm using the test-driven-development skill to implement this feature."

**Why:** Transparency helps your human partner understand your process and catch errors early. It also confirms you actually read the skill.

# About these skills

**Many skills contain rigid rules (TDD, debugging, verification).** Follow them exactly. Don't adapt away the discipline.

**Some skills are flexible patterns (architecture, naming).** Adapt core principles to your context.

The skill itself tells you which type it is.

## Instructions ≠ Permission to Skip Workflows

Your human partner's specific instructions describe WHAT to do, not HOW.

"Add X", "Fix Y" = the goal, NOT permission to skip brainstorming, TDD, or RED-GREEN-REFACTOR.

**Red flags:** "Instruction was specific" • "Seems simple" • "Workflow is overkill"

**Why:** Specific instructions mean clear requirements, which is when workflows matter MOST. Skipping process on "simple" tasks is how simple tasks become complex problems.

## Summary

**Starting any task:**
1. If relevant skill exists → Use the skill
3. Announce you're using it
4. Follow what it says

**Skill has checklist?** Mirror it in the plan and keep it synced until handoff.

**Finding a relevant skill = mandatory to read and use it. Not optional.**
