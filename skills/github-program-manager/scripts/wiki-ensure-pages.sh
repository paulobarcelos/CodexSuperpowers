#!/usr/bin/env bash
set -euo pipefail

# Ensure Wiki is enabled and that Journal.md and Decisions.md exist with header + instructions
# Env: OWNER, REPO

OWNER=${OWNER:-}
REPO=${REPO:-}

if [[ -z "$OWNER" || -z "$REPO" ]]; then
  echo "OWNER and REPO env vars are required" >&2
  exit 1
fi

gh repo edit "$OWNER/$REPO" --enable-wiki >/dev/null || true

HAS_WIKI=$(gh api "repos/$OWNER/$REPO" --jq '.has_wiki' 2>/dev/null || echo "false")
if [[ "$HAS_WIKI" != "true" ]]; then
  echo "Wiki is not enabled for $OWNER/$REPO (has_wiki=$HAS_WIKI). Enable it in repository settings or upgrade plan." >&2
  exit 1
fi

TOKEN=$(gh auth token 2>/dev/null || true)
if [[ -z "$TOKEN" ]]; then
  echo "gh auth token unavailable; run 'gh auth login' with repo scope." >&2
  exit 1
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
GIT_URL="https://x-access-token:${TOKEN}@github.com/$OWNER/$REPO.wiki.git"
fresh_repo=false
if GIT_TERMINAL_PROMPT=0 git clone "$GIT_URL" "$tmp/wiki" -q; then
  cd "$tmp/wiki"
else
  fresh_repo=true
  mkdir -p "$tmp/wiki"
  cd "$tmp/wiki"
  git init >/dev/null
  git checkout -b master >/dev/null 2>&1 || git checkout master >/dev/null 2>&1
  git remote add origin "$GIT_URL"
fi

ensure_page() {
  local page="$1"; shift
  local title="$1"; shift
  local intro="$*"
  if [[ ! -f "$page" ]]; then
    cat >"$page" <<EOF
# $title

Instructions
- Append new entries to the bottom of this page.
- Use '## YYYY-MM-DD — <short title>' per entry.
- Keep entries concise; link Issues/PRs/commits for details.

Entries

EOF
    echo "$intro" >>"$page"
  fi
}

ensure_page Journal.md "Journal" ""
ensure_page Decisions.md "Decisions" ""

git config user.name "codex-bot"
git config user.email "codex@example.com"
git add .
if ! git diff --cached --quiet; then
  git commit -m "wiki: seed Journal.md and Decisions.md with instructions" >/dev/null
  git push -u origin HEAD >/dev/null
else
  if [[ "$fresh_repo" == true ]]; then
    # fresh repo but no changes implies instructions already present locally
    git push -u origin HEAD >/dev/null 2>&1 || true
  else
    echo "Wiki pages already present; nothing to do."
  fi
fi

echo "Done."
