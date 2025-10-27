# Superpowers for Codex CLI

Give Codex CLI (GPT-5) superpowers with a comprehensive skills library of proven techniques, patterns, and workflows tuned for the CLI’s planning-first workflow.

> Fork notice: This is an independent fork of obra/superpowers. It adapts the original Claude-focused skills to Codex CLI (GPT‑5). See NOTICE and FORK-INFO.md. MIT license preserved with additional contributor notice.

## What You Get

- **Testing Skills** - TDD, async testing, anti-patterns
- **Debugging Skills** - Systematic debugging, root cause tracing, verification
- **Collaboration Skills** - Brainstorming, planning, code review, parallel agents
- **Development Skills** - Git worktrees, finishing branches, subagent workflows
- **Meta Skills** - Creating, testing, and sharing skills

Plus:
- **Structured Playbooks** - Brainstorming, planning, executing, and debugging recipes you can load on demand
- **Codex Planning Hooks** - Every checklist maps 1:1 into Codex’s `Plan` / `Updated Plan` blocks
- **Manual Activation** - You stay in control of which skills Codex reads and when
- **Consistent Workflows** - Systematic approaches to common engineering tasks

## Learn More

Read the introduction: [Superpowers for Claude Code](https://blog.fsck.com/2025/10/09/superpowers/)

Codex CLI differs from Claude Code in three critical ways:

1. GPT-5 agents already maintain an internal checklist UI. To stay aligned, this repo ships an `AGENTS.md` file that forces Codex to mirror every skill checklist verbatim.
2. There is no first-party plugin or Skill tool. You must manually show Codex the skills you want it to follow.
3. Codex does not expose Claude’s TodoWrite/TodoRead tools. Anywhere the skills previously said “create TodoWrite todos,” the instructions now explicitly command Codex to update the `Plan` / `Updated Plan` blocks instead.

## Manual Setup (No Plugin System Yet)

Until we build a Codex CLI harness, follow this ritual at the start of every session:

1. **Clone or sync the repo** to a path Codex can read (for example `~/codex-superpowers`).
2. **Install the instructions + index script** so Codex can find them automatically (the end of the instructions file will load Superpowers):
   ```bash
   mkdir -p ~/.codex/skills
   cp ./skills/INSTRUCTIONS.md ~/.codex/skills/INSTRUCTIONS.md
   cp ./skills/index_skills.sh ~/.codex/skills/index_skills.sh
   ```
3. **Add a minimal `AGENTS.md`** to your project root containing only:
   ```
   Read ~/.codex/skills/INSTRUCTIONS.md now.

   If missing, read ./skills/INSTRUCTIONS.md.
   ```
4. **Optionally copy `skills/` into the project** (project skills override global ones).
5. **Surface skill metadata** by running:
   ```bash
   bash ~/.codex/skills/index_skills.sh || bash ./skills/index_skills.sh
   ```
   This preloads the catalog—Codex now knows which skills exist (global and project).
6. **Load skills on demand**. When a skill applies, tell Codex “I’m loading [skill] now,” then show it the file (prefer project override if present):
   ```bash
   cat ./skills/systematic-debugging/SKILL.md || cat ~/.codex/skills/systematic-debugging/SKILL.md
   ```

That’s it—the rest of the workflow happens through Codex’s own planning UI.

## Quick Start

### Loading Skills Manually

**Brainstorm a design**
1. Say: “I’m using the brainstorming skill to refine this idea.”
2. Run `cat skills/brainstorming/SKILL.md` (or paste the relevant section) before writing any code.

**Create an implementation plan**
1. Announce the `writing-plans` skill.
2. Show Codex `skills/writing-plans/SKILL.md` and mirror its checklist in the `Plan` UI.

**Execute the plan**
1. Announce the `executing-plans` skill.
2. Show Codex `skills/executing-plans/SKILL.md`, work in the prescribed batches, and keep the plan updated.

### Manual Skill Activation + Planning

Codex only follows a skill after you show it the file. Once loaded, `AGENTS.md` ensures that every checklist item appears inside the `Plan` / `Updated Plan` UI. Examples:
- `test-driven-development` injects RED → GREEN → REFACTOR steps when you load it before writing code.
- `systematic-debugging` adds instrumentation + verification tasks when you load it during an incident.
- `verification-before-completion` keeps verification unchecked until evidence exists when you load it before handoff.

## What's Inside

### Skills Library

**Testing** (`skills/testing/`)
- **test-driven-development** - RED-GREEN-REFACTOR cycle
- **condition-based-waiting** - Async test patterns
- **testing-anti-patterns** - Common pitfalls to avoid

**Debugging** (`skills/debugging/`)
- **systematic-debugging** - 4-phase root cause process
- **root-cause-tracing** - Find the real problem
- **verification-before-completion** - Ensure it's actually fixed
- **defense-in-depth** - Multiple validation layers

**Collaboration** (`skills/collaboration/`)
- **brainstorming** - Socratic design refinement
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **requesting-code-review** - Pre-review checklist
- **receiving-code-review** - Responding to feedback
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with quality gates

**Meta** (`skills/meta/`)
- **writing-skills** - Create new skills following best practices
- **sharing-skills** - Contribute skills back via branch and PR
- **testing-skills-with-subagents** - Validate skill quality
- **using-superpowers** - Introduction to the skills system

### Commands

All commands are thin wrappers that activate the corresponding skill:

- **brainstorm.md** - Activates the `brainstorming` skill
- **write-plan.md** - Activates the `writing-plans` skill
- **execute-plan.md** - Activates the `executing-plans` skill

## How It Works

1. **Session Ritual** - You run the “Manual Setup” routine (list skills, show `AGENTS.md`).
2. **Front-Matter Discovery** - Listing each `SKILL.md` line mimics the preload Claude’s Skill tool used to handle.
3. **On-Demand Loading** - When a skill applies, you explicitly show Codex the file so it can operate with full instructions.
4. **Mandatory Workflows** - When a skill exists for your task, using it becomes required; Codex’s plan UI enforces the checklists.

## Philosophy

- **Test-Driven Development** - Write tests first, always
- **Systematic over ad-hoc** - Process over guessing
- **Complexity reduction** - Simplicity as primary goal
- **Evidence over claims** - Verify before declaring success
- **Domain over implementation** - Work at problem level, not solution level

## Contributing

Skills live directly in this repository. To contribute:

1. Fork the repository
2. Create a branch for your skill
3. Follow the `writing-skills` skill for creating new skills
4. Use the `testing-skills-with-subagents` skill to validate quality
5. Submit a PR

See `skills/meta/writing-skills/SKILL.md` for the complete guide. Put personal or organization-specific skills inside `~/.codex/skills/` so Codex CLI can discover them automatically.

## Updating

Just pull the repo (or the fork you track):

```bash
git pull
```

## License

MIT License - see LICENSE file for details

