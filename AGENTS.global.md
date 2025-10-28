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

- Global: `'~/.codex/skills'`, `~/superpowers/skills/`,`/Lab/Agents/superpowers/skills`
- Project: `./skills/` (project root) If the same skill exists in both, **use the project copy**.

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
python3 - <<'PY'
import glob, os
cwd = os.getcwd()
candidates = [
    ('project', os.path.join(cwd, 'skills'), 0),
    ('global', os.path.expanduser('~/Lab/Agents/superpowers/skills'), 1),
    ('global', os.path.expanduser('~/superpowers/skills'), 1),
    ('global', os.path.expanduser('~/.codex/skills'), 1),
]
records = {}

for scope, directory, priority in candidates:
    if not os.path.isdir(directory):
        continue
    for path in glob.glob(os.path.join(directory, '*/SKILL.md')):
        try:
            with open(path, 'r', encoding='utf-8') as handle:
                text = handle.read()
        except OSError:
            continue
        if not text.startswith('---'):
            continue
        parts = text.split('---', 2)
        if len(parts) < 3:
            continue
        front = parts[1]
        name = ''
        desc = ''
        for line in front.splitlines():
            line = line.strip()
            if not line:
                continue
            if line.startswith('name:') and not name:
                name = line[5:].strip()
            elif line.startswith('description:') and not desc:
                desc = line[12:].strip()
        if not name:
            continue
        current = records.get(name)
        if current and priority >= current['priority']:
            continue
        records[name] = {
            'priority': priority,
            'scope': scope,
            'path': path,
            'description': desc,
        }

if not records:
    raise SystemExit('No skills found')

name_width = max(len(name) for name in records)

for name in sorted(records):
    entry = records[name]
    desc = entry['description'] or '-'
    rel_path = entry['path']
    if rel_path.startswith(cwd):
        rel_path = '.' + rel_path[len(cwd):]
    print(f"{name.ljust(name_width)} | {entry['scope']:<7} | {rel_path} | {desc}")
PY
```

The script emits a single, sorted line per skill (preferring project copies when duplicates exist) so the catalog stays compact. Persist a lightweight map `{name → path, description, extras…}` from that output. **Do not** read bodies yet.

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

Before acting, read the full `SKILL.md`, example:

```bash
cat ./skills/<skill>/SKILL.md
## or
cat ~/Lab/Agents/superpowers/skills/<skill>/SKILL.md
## or
cat ~/superpowers/skills/<skill>/SKILL.md
## or
cat ~/.codex/skills/<skill>/SKILL.md
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
