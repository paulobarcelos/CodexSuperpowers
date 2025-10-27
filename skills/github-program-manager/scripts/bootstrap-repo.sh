#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a project repository for repo-local PM workflows
# Required env:
#   OWNER=<user_or_org> REPO=<repo>
# Optional:
#   PROJECT_NAME="Repo: <owner>/<repo>"

OWNER=${OWNER:-}
REPO=${REPO:-}
PROJECT_NAME=${PROJECT_NAME:-}

if [[ -z "${OWNER}" || -z "${REPO}" ]]; then
  echo "Set OWNER and REPO env vars" >&2
  exit 1
fi

[[ -n "$PROJECT_NAME" ]] || PROJECT_NAME="Repo: ${OWNER}/${REPO}"

echo "==> gh auth"
gh auth status || gh auth login

echo "==> Ensure repo ${OWNER}/${REPO} exists"
if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  echo "Repo exists"
else
  gh repo create "$OWNER/$REPO" --private --confirm
fi

echo "==> Enable Discussions"
gh api repos/:owner/:repo -X PATCH -F owner="$OWNER" -F repo="$REPO" -f has_discussions=true >/dev/null
echo "(Add categories in the UI to match your workflow: Journal, Ideas, Decisions)"

echo "==> Seed labels"
for row in \
  "priority:high FF0000 Highest priority" \
  "priority:medium FBCA04 Medium priority" \
  "priority:low 0E8A16 Lowest priority" \
  "type:bug D73A4A Bug" \
  "type:feature 1D76DB Feature" \
  "type:journal 5319E7 Journal entry" \
  "type:decision 006B75 Decision/ADR" \
  "type:task C2E0C6 Task"; do
  IFS=' ' read -r name color desc <<<"$row"
  gh label create "$name" -R "$OWNER/$REPO" --color "$color" -d "$desc" 2>/dev/null || true
done

echo "==> (Optional) Add branch protections on main — edit as needed"
gh api repos/:owner/:repo/branches/main/protection -X PUT \
  -F owner="$OWNER" -F repo="$REPO" \
  -H "Accept: application/vnd.github+json" \
  -f required_status_checks='{"strict":true,"contexts":[]}' \
  -f enforce_admins=true \
  -f required_pull_request_reviews='{"required_approving_review_count":1}' \
  -f restrictions='null' >/dev/null || true

echo "==> Ensure user/org Project (v2): $PROJECT_NAME"
OWNER_KIND="--owner $OWNER"
PROJ_NUM=$(gh project list $OWNER_KIND --format json | jq -r ".[] | select(.title==\"$PROJECT_NAME\") | .number" | head -n1)
if [[ -z "$PROJ_NUM" || "$PROJ_NUM" == null ]]; then
  gh project create "$PROJECT_NAME" --owner "$OWNER" >/dev/null
  PROJ_NUM=$(gh project list $OWNER_KIND --format json | jq -r ".[] | select(.title==\"$PROJECT_NAME\") | .number" | head -n1)
fi

echo "==> Ensure standard fields on Project $PROJ_NUM"
gh project field-create --owner "$OWNER" --number "$PROJ_NUM" --name "Status" --data-type SINGLE_SELECT --options "Backlog,Selected,In Progress,Review,Done" 2>/dev/null || true
gh project field-create --owner "$OWNER" --number "$PROJ_NUM" --name "Priority" --data-type SINGLE_SELECT --options "High,Medium,Low" 2>/dev/null || true
gh project field-create --owner "$OWNER" --number "$PROJ_NUM" --name "Size" --data-type NUMBER 2>/dev/null || true
gh project field-create --owner "$OWNER" --number "$PROJ_NUM" --name "Iteration" --data-type ITERATION --iteration-duration 14 2>/dev/null || true
gh project field-create --owner "$OWNER" --number "$PROJ_NUM" --name "Agent" --data-type TEXT 2>/dev/null || true

cat <<EOF
==> Next steps
- Add Issue templates to .github/ISSUE_TEMPLATE/ in $OWNER/$REPO (samples in skills/github-program-manager/scripts/templates)
- Create a saved Project (v2) view filtered to "repo:${OWNER}/${REPO}" (via UI)
EOF

