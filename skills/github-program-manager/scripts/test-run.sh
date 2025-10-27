#!/usr/bin/env bash
set -euo pipefail

# Minimal, CLI-only test of the GitHub Program Manager skill
# Runs two scenarios in a sandbox repo with no UI involvement.

OWNER=${OWNER:-paulobarcelos}
REPO=${REPO:-runway-compass-sandbox}
TITLE=${TITLE:-"Repo: ${OWNER}/${REPO}"}

echo "==> Prechecks"
command -v gh >/dev/null || { echo "gh CLI not found" >&2; exit 1; }
command -v jq >/dev/null || { echo "jq not found" >&2; exit 1; }
gh auth status >/dev/null || { echo "gh not authenticated" >&2; exit 1; }

echo "==> Ensure Project board + fields via GraphQL"
PROJ_NUM=$(OWNER="$OWNER" TITLE="$TITLE" bash "$(dirname "$0")/ensure-project-graphql.sh" | tail -n1)
echo "Project number: $PROJ_NUM"

echo "==> Enable Wiki and seed pages"
OWNER="$OWNER" REPO="$REPO" bash "$(dirname "$0")/wiki-ensure-pages.sh" >/dev/null

echo "==> Scenario A: Issue → Project → Status → Draft PR → (optional) merge"
# Create Issue via REST (regular task)
ISSUE_JSON=$(gh api repos/$OWNER/$REPO/issues -f title='Test: program-manager wiring' -f body='Testing PM setup' -f labels[]='type:task')
ISSUE_NUM=$(echo "$ISSUE_JSON" | jq -r .number)
ISSUE_URL=$(echo "$ISSUE_JSON" | jq -r .html_url)
ISSUE_ID=$(gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){ repository(owner:$o,name:$r){ issue(number:$n){ id } }}' -F o="$OWNER" -F r="$REPO" -F n=$ISSUE_NUM --jq '.data.repository.issue.id')
echo "Issue #$ISSUE_NUM -> $ISSUE_URL (node: $ISSUE_ID)"

# Resolve Project id (prefer user; fallback to org)
PROJ_ID=$(gh api graphql -f query='query($owner:String!,$n:Int!){ user(login:$owner){ projectV2(number:$n){ id } }}' -F owner="$OWNER" -F n=$PROJ_NUM --jq '.data.user.projectV2.id' 2>/dev/null || true)
if [[ -z "$PROJ_ID" || "$PROJ_ID" == null ]]; then
  PROJ_ID=$(gh api graphql -f query='query($owner:String!,$n:Int!){ organization(login:$owner){ projectV2(number:$n){ id } }}' -F owner="$OWNER" -F n=$PROJ_NUM --jq '.data.organization.projectV2.id' 2>/dev/null || true)
fi
ITEM_ID=$(gh api graphql -f query='mutation($p:ID!,$c:ID!){ addProjectV2ItemById(input:{projectId:$p,contentId:$c}){ item{ id } }}' -F p="$PROJ_ID" -F c="$ISSUE_ID" --jq '.data.addProjectV2ItemById.item.id')
echo "Project item id: $ITEM_ID"

# Set Status = In Progress
OWNER="$OWNER" PROJ_NUM="$PROJ_NUM" ITEM_ID="$ITEM_ID" STATUS="In Progress" bash "$(dirname "$0")/project-status.sh"

# Create draft PR linking issue
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
git clone "https://github.com/$OWNER/$REPO.git" "$TMP/$REPO" -q
pushd "$TMP/$REPO" >/dev/null
git config user.name sandbox-bot
git config user.email sandbox@example.com
BR="test/auto-pr-$(date +%s)"
git switch -c "$BR" >/dev/null 2>&1 || git checkout -b "$BR" >/dev/null
echo "- $(date -u)" >> README.md
git add README.md && git commit -m "docs: test auto PR" >/dev/null
git push -u origin HEAD >/dev/null
PR_URL=$(gh pr create -R "$OWNER/$REPO" --base main --head "$BR" --title "docs: test auto PR" --body "Closes #$ISSUE_NUM" --draft --json url --jq .url 2>/dev/null || echo "")
popd >/dev/null
echo "Draft PR -> ${PR_URL:-created via gh pr create}"

echo "==> Scenario B: Journal/Decision entries on Wiki and an Idea Discussion"

# Wiki: append Journal entry
OWNER="$OWNER" REPO="$REPO" PAGE=Journal TITLE="Sandbox setup" BODY="Initial wiring with board and PR." \
  bash "$(dirname "$0")/wiki-append-entry.sh" >/dev/null

# Wiki: append Decision entry
OWNER="$OWNER" REPO="$REPO" PAGE=Decisions TITLE="ADR: Use Wiki for journal/decisions" BODY="Centralize knowledge in Wiki; use Discussions for ideas only." \
  bash "$(dirname "$0")/wiki-append-entry.sh" >/dev/null

# Discussion: Idea (optional)
IDEA_URL=$(gh discussion create -R "$OWNER/$REPO" --category "Ideas" --title "Idea: CLI-only workflow" --body "Short context" --json url --jq .url 2>/dev/null || echo "")

if [[ -n "$IDEA_URL" ]]; then
  echo "Created Idea discussion: $IDEA_URL"
else
  echo "WARN: Unable to create Idea discussion via CLI (maybe missing permission?)."
fi

echo "==> Results"
echo "ISSUE_URL=$ISSUE_URL"
echo "PR_URL=$PR_URL"
echo "IDEA_URL=$IDEA_URL"
echo "ITEM_ID=$ITEM_ID"
echo "PROJ_ID=$PROJ_ID"
echo "PROJ_NUM=$PROJ_NUM"

echo "Done."
