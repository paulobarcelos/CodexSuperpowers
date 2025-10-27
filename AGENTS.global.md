<ENABLE_SKILLS>
# Codex Skills — Global Guide (follow strictly)

You are **Codex** running without plugins. This directive defines how you discover, select, and activate **Skills** (self‑contained playbooks).

> **Session obligation:** Run **§3 Startup** at session start, then apply **§4–§7** during work.

## §0 Ground Rules

- **Determinism:** Follow these steps exactly; no shortcuts.
- **Least I/O:** Index front matter only at startup; read full skill files **only when selected**.
- **Announce:** When using a skill, print: `Using <skill> to <goal>.`
- **Plan Sync:** Mirror the skill’s checklist into **Plan/Updated Plan** and keep it current.

## §1 Locations (search both; project wins)

- Global: `~/superpowers/skills/`
- Project: `./skills/` (repo root) If the same skill exists in both, **use the project copy**.

## §2 Skill Structure (contract)

A **skill** is a directory containing `SKILL.md`:

- **YAML front matter (required):**
  - `name:` short **kebab‑case** id
  - `description:` 1–2 sentences starting with “Use when …”
  - (Optional) additional keys allowed; do not assume presence
- **Body:** workflow, checklists, examples.

## §3 Startup — Build the Catalog (front matter only)

At session start, index front matter (name/description/keys) from **both** locations:

```bash
for f in ~/superpowers/skills/*/SKILL.md ./skills/*/SKILL.md; do \
  [ -f "$f" ] || continue; echo "# $f"; \
  awk 'BEGIN{fm=0} /^---[[:space:]]*$/ {fm++; next} fm==1 {print}' "$f"; \
done 2>/dev/null
```

Persist a lightweight map `{name → path, description, extras…}`. **Do not** read bodies yet.

## §4 Selection Algorithm (when to use a skill)

Given the current task:

1. Parse into **goal** + **constraints** + **artifacts** (files/dirs).
2. Rank catalog entries by:
   - **Description match** to goal/constraints.
   - **Project presence** (prefer project skills).
   - **Specificity** (narrow “Use when …” beats generic).
3. If no candidate meets a clear‑fit threshold, proceed **without** a skill and note that choice.
4. Otherwise select the top candidate and continue to **§5**.

## §5 Load On Demand (project copy preferred)

Before acting, read the full `SKILL.md`:

```bash
if [ -f ./skills/<skill>/SKILL.md ]; then
  cat ./skills/<skill>/SKILL.md
else
  cat ~/superpowers/skills/<skill>/SKILL.md
fi
```

Then immediately:

- Print `Using <skill> to <goal>.`
- Extract **checklist** and **workflow steps** from the body.
- Seed **Plan** with one checkbox per checklist item.

## §6 Plan Integration (Plan / Updated Plan)

- **Before execution:** “Create a plan with a checkbox for each checklist item below; execute step‑by‑step; update Plan after each action.”
- **During execution:** Check off items, append discoveries/decisions; when revised, rename to **Updated Plan** and re‑post.
- **After execution:** Verify all required artifacts/tests; note deviations and follow‑ups.

## §7 Failure Modes & Recovery

- **No skills found:** Proceed normally; state “No applicable skills in catalog.”
- **Duplicates/conflicts:** Prefer project copy; if multiple project variants, choose the most specific description and record the choice.
- **Malformed YAML:** Skip that skill; log “Skipped : invalid front matter.”
- **Missing checklist:** Derive a minimal checklist from workflow; document it in Plan.

## §8 Examples

**A) Simple announcement + plan**

- Announcement: `Using deploy-static-site to publish docs to GitHub Pages.`
- **Plan seed (copy into Plan):**
  -  [ ] Build docs
  -  [ ] Link check
  -  [ ] Publish
  -  [ ] Verify URL & cache

**B) Selection demo**

- Task: “Migrate repo CI from CircleCI to GitHub Actions with caching.”
- Catalog hits: `ci-github-actions-migrate` (project), `ci-optimize-caching` (global).
- Ranking: project presence + specific “Use when migrating …” ⇒ pick `ci-github-actions-migrate`.
- Action: load project `SKILL.md`, announce usage, mirror checklist into Plan, execute.

**C) Failure-mode examples**

- Duplicate skills (`lint-python` in both places): pick project version; log decision.
- Malformed YAML in `release-semver`: skip; note: “Skipped release-semver: invalid front matter.”
- No checklist in `hotfix-protocol`: derive minimal checklist from body and document in Plan.

---

**Apply this directive on every session start.** Keep I/O minimal; never run snippets blindly—treat them as steps with safety checks. **Project conventions win** if a skill conflicts.
</ENABLE_SKILLS>