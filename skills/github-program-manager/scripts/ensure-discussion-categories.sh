#!/usr/bin/env bash
set -euo pipefail

# Ensure GitHub Discussions categories exist: Journal, Decision Log, Ideas
# Requires: gh auth login (repo admin), jq

OWNER=${OWNER:-}
REPO=${REPO:-}

if [[ -z "$OWNER" || -z "$REPO" ]]; then
  echo "OWNER and REPO env vars are required" >&2
  exit 1
fi

repoId=$(gh api graphql -f query='query($o:String!,$r:String!){repository(owner:$o,name:$r){id}}' -f o="$OWNER" -f r="$REPO" --jq .data.repository.id)

want=("Journal" "Decision Log" "Ideas")

existing=$(gh api graphql -f query='query($o:String!,$r:String!){repository(owner:$o,name:$r){discussionCategories(first:50){nodes{name}}}}' -f o="$OWNER" -f r="$REPO" --jq '.data.repository.discussionCategories.nodes[].name')

create_cat() {
  local name="$1"
  gh api graphql -f query='mutation($repoId:ID!,$name:String!){createDiscussionCategory(input:{repositoryId:$repoId,name:$name,isAnswerable:false}){discussionCategory{id name}}}' -F repoId="$repoId" -F name="$name" >/dev/null
  echo "Created discussion category: $name"
}

for n in "${want[@]}"; do
  if echo "$existing" | grep -Fxq "$n"; then
    echo "Category exists: $n"
  else
    create_cat "$n" || echo "WARN: could not create category $n (permissions?)" >&2
  fi
done

echo "Done."

