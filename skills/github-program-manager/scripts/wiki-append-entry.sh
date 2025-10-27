#!/usr/bin/env bash
set -euo pipefail

# Append an entry to the GitHub Wiki Journal.md or Decisions.md
# Env:
#   OWNER, REPO
#   PAGE   (Journal|Decisions)
#   TITLE  (short title)
#   BODY_FILE (path to file with body) OR BODY (string)
# Optional:
#   AUTHOR (defaults to gh api user login)

OWNER=${OWNER:-}
REPO=${REPO:-}
PAGE=${PAGE:-}
TITLE=${TITLE:-}
BODY_FILE=${BODY_FILE:-}
BODY=${BODY:-}

if [[ -z "$OWNER" || -z "$REPO" || -z "$PAGE" || -z "$TITLE" ]]; then
  echo "OWNER, REPO, PAGE, TITLE are required" >&2
  exit 1
fi

if [[ -z "${BODY_FILE}" && -z "${BODY}" ]]; then
  echo "Provide BODY_FILE or BODY" >&2
  exit 1
fi

if [[ -n "${BODY_FILE}" ]]; then
  BODY=$(cat "$BODY_FILE")
fi

AUTHOR=${AUTHOR:-$(gh api user --jq .login 2>/dev/null || echo "unknown")}
DATE=$(date +%F)

gh repo edit "$OWNER/$REPO" --enable-wiki >/dev/null || true

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
git clone "https://github.com/$OWNER/$REPO.wiki.git" "$tmp/wiki" -q
cd "$tmp/wiki"

file="$PAGE.md"
if [[ ! -f "$file" ]]; then
  echo "Page $file not found. Run wiki-ensure-pages.sh first." >&2
  exit 1
fi

cat >>"$file" <<EOF

## ${DATE} — ${TITLE}

Author: @${AUTHOR}

${BODY}
EOF

git config user.name "codex-bot"
git config user.email "codex@example.com"
git add "$file"
git commit -m "wiki(${PAGE}): append entry — ${DATE} ${TITLE}" >/dev/null
git push -u origin HEAD >/dev/null

echo "Appended entry to $OWNER/$REPO wiki page $PAGE"

