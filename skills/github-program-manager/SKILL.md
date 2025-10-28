---
name: github-program-manager
description: Use when running a project entirely inside GitHub (Issues, Discussions, Wiki, PRs, Milestones, Projects, Releases) via the GitHub CLI and API. Lean rituals and commands let a solo dev or consultant plan, execute, and release without the web UI. Wiki-first for Journal/Decisions; Discussions only for Ideas; Issues for work.
---

# GitHub Program Manager

## Overview
Run project management entirely in GitHub using `gh` and the API. Source of truth: Wiki (Journal single page, Decisions single page), Discussions (Ideas only), Issues (work), PRs (change), Projects v2 (planning), Milestones/Releases (cadence). Prefer Wiki/Issues over ad‑hoc `.md` notes in the repo.

## When to Use
- Solo or consulting projects managed inside a single repo (repo‑local).
- You want an agent to operate without the web UI.

## Principles (Short)
- Status from evidence (Issues/PRs/Project items).
- Link everything (PRs ↔ Issues ↔ Project ↔ Milestone ↔ Release).
- CLI/API first; UI only as last resort.
- Keep artifacts repo‑local; avoid stray `.md` notes.

## Rituals (Lean)
- Bootstrap (once): labels, Wiki enabled and seeded with Journal.md and Decisions.md, Discussions enabled with category (Ideas), Issue forms (bug/feature), branch protection, Projects v2 board with Status/Priority/Size.
- Intake: use Wiki for journal/decisions; Discussions for ideas; Issues for executable work. Label, size, and add Issues to Project (Status=Backlog).
- Plan: pick scope by Milestone; save views (Backlog/Now/Next).
- Execute: draft PRs early; “Closes #<id>”; update Status when PR opens/merges.
- Review: checks green; at least one review.
- Release: tag, generate notes, close milestone, announce.

## Quick Reference
- Wiki enable: `gh repo edit <owner>/<repo> --enable-wiki`
- Seed Wiki pages: `OWNER=<o> REPO=<r> bash scripts/wiki-ensure-pages.sh`
- Wiki append (Journal): `OWNER=<o> REPO=<r> PAGE=Journal TITLE="<topic>" BODY_FILE=<file> bash scripts/wiki-append-entry.sh`
- Wiki append (Decision): `OWNER=<o> REPO=<r> PAGE=Decisions TITLE="ADR: <short>" BODY_FILE=<file> bash scripts/wiki-append-entry.sh`
- Discussion (Idea): `gh discussion create -R <owner>/<repo> --category "Ideas" --title "<title>" --body-file -`
- Issue (work item): `gh issue create -R <owner>/<repo> -F .github/ISSUE_TEMPLATE/<form>.yml`
- Add Issue to Project: `gh project item-add --owner <user|org> --number <proj> --url $(gh issue view <n> -R <owner>/<repo> --json url -q .url)`
- PR: `gh pr create --fill --draft --head <branch> --base main` → `gh pr merge --auto --squash`
- Release: `gh release create <tag> -R <owner>/<repo> --generate-notes`
- GraphQL fallbacks: `createProjectV2`, `createProjectV2Field`, `addProjectV2ItemById`, `updateProjectV2ItemFieldValue`, `createDiscussionCategory`, `createDiscussion`.

## Prereqs (Agent‑Ready)
- `gh` authenticated (repo + project scopes, and Discussions if private). `jq` installed.
- Token can manage Wiki/Discussions/Issues/PRs/Projects/Repo settings.

## Subagent Test Protocol
1) Ensure board + fields: `OWNER=<owner> TITLE="Repo: <owner>/<repo>" bash ensure-project-graphql.sh`
2) Enable Wiki and seed pages: `OWNER=<owner> REPO=<repo> bash scripts/wiki-ensure-pages.sh`
3) Append Journal and Decision sample entries via `wiki-append-entry.sh`.
4) Ensure Discussions has an Ideas category only: `OWNER=<owner> REPO=<repo> bash scripts/ensure-discussion-categories.sh`
5) Issue → add to Project → Status="In Progress" using `scripts/project-status.sh`.
6) Draft PR with “Closes #<id>”; optionally merge and set Status="Done".

## Acceptance Criteria
- All core actions work via CLI/API only.
- Artifacts linked; status derives from evidence.
- No ad‑hoc notes in the repo tree.

## Helpers
- scripts/ensure-project-graphql.sh
- scripts/ensure-discussion-categories.sh (Ideas only)
- scripts/wiki-ensure-pages.sh (create/seed Journal.md and Decisions.md)
- scripts/wiki-append-entry.sh (append timestamped entries)
- scripts/project-status.sh
- scripts/bootstrap-repo.sh (optional)
- scripts/install-templates-into-repo.sh (bug/idea templates only)
- scripts/test-run.sh (sandbox verification)
