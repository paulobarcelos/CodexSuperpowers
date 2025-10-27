---
name: github-program-manager
description: Use when running a project entirely inside GitHub (Issues, Discussions, PRs, Milestones, Projects, Releases) via the GitHub CLI and API. Lean rituals and commands let a solo dev or consultant plan, execute, and release without the web UI. Prefers Discussions for journaling/decisions; Issues for work.
---

# GitHub Program Manager

## Overview
Run project management entirely in GitHub using `gh` and the API. Source of truth: Discussions (journal, decisions, ideation), Issues (work), PRs (change), Projects v2 (planning), Milestones/Releases (cadence). Prefer Discussions/Issues over ad‑hoc `.md` notes in the repo.

## When to Use
- Solo or consulting projects managed inside a single repo (repo‑local).
- You want an agent to operate without the web UI.

## Principles (Short)
- Status from evidence (Issues/PRs/Project items).
- Link everything (PRs ↔ Issues ↔ Project ↔ Milestone ↔ Release).
- CLI/API first; UI only as last resort.
- Keep artifacts repo‑local; avoid stray `.md` notes.

## Rituals (Lean)
- Bootstrap (once): labels, Discussions enabled with categories (Journal, Decision Log, Ideas), Issue forms (bug/feature), branch protection, Projects v2 board with Status/Priority/Size.
- Intake: use Discussions for journal/ideas/decisions; Issues for executable work. Label, size, and add Issues to Project (Status=Backlog).
- Plan: pick scope by Milestone; save views (Backlog/Now/Next).
- Execute: draft PRs early; “Closes #<id>”; update Status when PR opens/merges.
- Review: checks green; at least one review.
- Release: tag, generate notes, close milestone, announce.

## Quick Reference
- Discussion (Journal/Decision): `gh discussion create -R <owner>/<repo> --category "Journal" --title "YYYY-MM-DD: <title>" --body-file -` (stdin body)
- Discussion comment (heartbeat): `gh discussion comment <url|number> -R <owner>/<repo> --body "<text>"`
- Issue (work item): `gh issue create -R <owner>/<repo> -F .github/ISSUE_TEMPLATE/<form>.yml`
- Add Issue to Project: `gh project item-add --owner <user|org> --number <proj> --url $(gh issue view <n> -R <owner>/<repo> --json url -q .url)`
- PR: `gh pr create --fill --draft --head <branch> --base main` → `gh pr merge --auto --squash`
- Release: `gh release create <tag> -R <owner>/<repo> --generate-notes`
- GraphQL fallbacks: `createProjectV2`, `createProjectV2Field`, `addProjectV2ItemById`, `updateProjectV2ItemFieldValue`, `createDiscussionCategory`, `createDiscussion`.

## Prereqs (Agent‑Ready)
- `gh` authenticated (repo + project scopes, and Discussions if private). `jq` installed.
- Token can manage Discussions/Issues/PRs/Projects/Repo settings.

## Subagent Test Protocol
1) Ensure board + fields: `OWNER=<owner> TITLE="Repo: <owner>/<repo>" bash skills/github-program-manager/ensure-project-graphql.sh`
2) Ensure Discussions categories (Journal, Decision Log): `OWNER=<owner> REPO=<repo> bash skills/github-program-manager/scripts/ensure-discussion-categories.sh`
3) Create a Journal discussion, post a heartbeat comment.
4) Issue → add to Project → Status="In Progress" using `skills/github-program-manager/scripts/project-status.sh`.
5) Draft PR with “Closes #<id>”; optionally merge and set Status="Done".

## Acceptance Criteria
- All core actions work via CLI/API only.
- Artifacts linked; status derives from evidence.
- No ad‑hoc notes in the repo tree.

## Helpers (this repo)
- skills/github-program-manager/scripts/ensure-project-graphql.sh
- skills/github-program-manager/scripts/ensure-discussion-categories.sh
- skills/github-program-manager/scripts/project-status.sh
- skills/github-program-manager/scripts/bootstrap-repo.sh (optional)
- skills/github-program-manager/scripts/install-templates-into-repo.sh (templates PR)
- skills/github-program-manager/scripts/test-run.sh (sandbox verification)
