#!/usr/bin/env bash
set -euo pipefail

# Install GitHub Issue templates and optional policy workflow into a repo via gh
# Requirements: gh authenticated with repo scope; jq
# Usage:
#   OWNER=<user_or_org> REPO=<repo> bash install-templates-into-repo.sh

OWNER=${OWNER:-}
REPO=${REPO:-}
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [[ -z "$OWNER" || -z "$REPO" ]]; then
  echo "Set OWNER and REPO env vars" >&2
  exit 1
fi

gh auth status >/dev/null

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

echo "==> Cloning $OWNER/$REPO"
gh repo clone "$OWNER/$REPO" "$TMPDIR/$REPO" -- -q
pushd "$TMPDIR/$REPO" >/dev/null

git checkout -b chore/pm-templates
mkdir -p .github/ISSUE_TEMPLATE .github/workflows

echo "==> Copying templates (bug, idea)"
cp -f "$SCRIPT_DIR/templates/bug.yml" .github/ISSUE_TEMPLATE/
cp -f "$SCRIPT_DIR/templates/idea.yml" .github/ISSUE_TEMPLATE/

# No policy workflows; we prefer guidance over strict enforcement

git add .github
git commit -m "chore(pm): add issue templates (bug, idea)"
git push -u origin HEAD

echo "==> Opening PR"
gh pr create --title "chore(pm): add PM templates" --body "Adds repo-local PM templates (bug, idea)."

echo "==> Done. Review and merge the PR in $OWNER/$REPO."
