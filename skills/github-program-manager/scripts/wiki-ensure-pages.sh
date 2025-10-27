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

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git clone "https://github.com/$OWNER/$REPO.wiki.git" "$tmp/wiki" -q || {
  echo "Failed to clone wiki. Ensure the repo exists and you have access." >&2
  exit 1
}

cd "$tmp/wiki"

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
  git commit -m "wiki: seed Journal.md and Decisions.md with instructions"
  git push -u origin HEAD >/dev/null
else
  echo "Wiki pages already present; nothing to do."
fi

echo "Done."

