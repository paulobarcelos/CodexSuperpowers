---
name: journaling-and-decisions
description: Use during day-to-day work — always write down noteworthy insights and irreversible choices. Journal entries capture context and outcomes; Decision entries capture the choice and rationale. Prefer GitHub Discussions over ad‑hoc repo notes.
---

# Journaling & Decisions

## Why
Capture knowledge for future agents and reduce rework. Short entries beat perfect essays.

## Where
- GitHub Discussions
  - Category: Journal → working notes, insights, troubleshooting
  - Category: Decision Log → irreversible choices with rationale

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

## CLI Hints (if Discussions enabled)
```
# Create/update a Journal thread (manual category pick if needed)
gh discussion create -R <owner>/<repo> --category "Journal" \
  --title "YYYY-MM-DD: <topic>" --body-file - <<'MD'
Context: ...
Observation: ...
Implication: ...
Next step: ...
MD

# Comment heartbeat on an existing thread
gh discussion comment <url|number> -R <owner>/<repo> --body "Status: <one-liner>"
```

If Discussions are disabled, keep minimal notes in the PR description and migrate to Discussions once enabled.

