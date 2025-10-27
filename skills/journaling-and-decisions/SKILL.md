---
name: journaling-and-decisions
description: Use during day-to-day work — always write down noteworthy insights and irreversible choices. Keep a single GitHub Wiki page for Journal and a single GitHub Wiki page for Decisions. Append new entries to those pages. Use Discussions only for Ideas.
---

# Journaling & Decisions

## Why
Capture knowledge for future agents and reduce rework. Short entries beat perfect essays.

## Where
- GitHub Wiki (preferred)
  - Page: Journal — working notes, insights, troubleshooting
  - Page: Decisions — irreversible choices with rationale (ADR-style)
- GitHub Discussions (only for Ideas)
  - Category: Ideas — brainstorming that benefits from threaded conversation

## Journal Entries (template)
- Context: task/area
- Observation: what you discovered
- Implication: how it affects code/process
- Next step: what you’ll do (or link to Issue)

## Decision Entries (template)
- Decision: concise statement
- Alternatives considered: (bullets)
- Rationale: why this path
- Effective date/version: when it applies
- Links: Issues/PRs/commits

## CLI Hints (Wiki workflow)
```
# 1) Enable Wiki on the repo (idempotent)
gh repo edit <owner>/<repo> --enable-wiki

# 2) Ensure Journal.md and Decisions.md exist with instructions
OWNER=<owner> REPO=<repo> \
bash skills/github-program-manager/scripts/wiki-ensure-pages.sh

# 3) Append a Journal entry (adds timestamp and author)
OWNER=<owner> REPO=<repo> PAGE=Journal TITLE="<topic>" \
  BODY_FILE=<(cat <<'MD'
Context: ...
Observation: ...
Implication: ...
Next step: ...
MD
) \
  bash skills/github-program-manager/scripts/wiki-append-entry.sh

# 4) Append a Decision entry
OWNER=<owner> REPO=<repo> PAGE=Decisions TITLE="ADR: <short decision>" \
  BODY_FILE=<(cat <<'MD'
Decision: ...
Alternatives: ...
Rationale: ...
Effective: YYYY-MM-DD / version
Links: #<issue> PR #<n>
MD
) \
  bash skills/github-program-manager/scripts/wiki-append-entry.sh
```

If Wiki is temporarily unavailable, keep minimal notes in the PR description and migrate to the Wiki when available. Use Discussions only for Ideas.
