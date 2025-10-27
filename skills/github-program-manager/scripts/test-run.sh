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

echo "==> Enable Discussions via REST (idempotent)"
gh api repos/$OWNER/$REPO -X PATCH -f has_discussions=true -H "Accept: application/vnd.github+json" -H "X-GitHub-Api-Version: 2022-11-28" >/dev/null || true

echo "==> Scenario A: Issue → Project → Status → Draft PR → (optional) merge"
# Create Issue via REST
ISSUE_JSON=$(gh api repos/$OWNER/$REPO/issues -f title='Test: journaling via CLI' -f body='Testing program-manager skill setup' -f labels[]='type:journal')
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

echo "==> Scenario B: Idea capture → Project Backlog"
IDEA_JSON=$(gh api repos/$OWNER/$REPO/issues -f title='Idea: CLI-only workflow' -f body='Short context' -f labels[]='type:idea' -f labels[]='priority:medium')
IDEA_NUM=$(echo "$IDEA_JSON" | jq -r .number)
IDEA_URL=$(echo "$IDEA_JSON" | jq -r .html_url)
IDEA_ID=$(gh api graphql -f query='query($o:String!,$r:String!,$n:Int!){ repository(owner:$o,name:$r){ issue(number:$n){ id } }}' -F o="$OWNER" -F r="$REPO" -F n=$IDEA_NUM --jq '.data.repository.issue.id')
ITEM2_ID=$(gh api graphql -f query='mutation($p:ID!,$c:ID!){ addProjectV2ItemById(input:{projectId:$p,contentId:$c}){ item{ id } }}' -F p="$PROJ_ID" -F c="$IDEA_ID" --jq '.data.addProjectV2ItemById.item.id')
OWNER="$OWNER" PROJ_NUM="$PROJ_NUM" ITEM_ID="$ITEM2_ID" STATUS="Backlog" bash "$(dirname "$0")/project-status.sh"
echo "Idea #$IDEA_NUM -> $IDEA_URL (item: $ITEM2_ID)"

echo "==> Results"
echo "ISSUE_URL=$ISSUE_URL"
echo "PR_URL=$PR_URL"
echo "IDEA_URL=$IDEA_URL"
echo "ITEM_ID=$ITEM_ID"
echo "ITEM2_ID=$ITEM2_ID"
echo "PROJ_ID=$PROJ_ID"
echo "PROJ_NUM=$PROJ_NUM"

echo "Done."
