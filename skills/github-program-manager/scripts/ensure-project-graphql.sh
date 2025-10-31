#!/usr/bin/env bash
set -euo pipefail

# Ensure a Projects (v2) board exists (GraphQL) and create core fields via API.
# Usage: OWNER=<login> TITLE="Repo: <owner>/<repo>" bash skills/github-program-manager/scripts/ensure-project-graphql.sh

OWNER=${OWNER:-}
TITLE=${TITLE:-}
if [[ -z "$OWNER" || -z "$TITLE" ]]; then
  echo "Set OWNER and TITLE" >&2
  exit 1
fi

gh auth status >/dev/null

echo "==> Resolve ownerId for $OWNER"
# Try user first
OWNER_ID=$(gh api graphql -f query='query($login:String!){ user(login:$login){ id } }' -F login="$OWNER" --jq '.data.user.id' 2>/dev/null || true)
if [[ -z "$OWNER_ID" || "$OWNER_ID" == null ]]; then
  # Fallback to organization
  OWNER_ID=$(gh api graphql -f query='query($login:String!){ organization(login:$login){ id } }' -F login="$OWNER" --jq '.data.organization.id' 2>/dev/null || true)
fi
if [[ -z "$OWNER_ID" || "$OWNER_ID" == null ]]; then
  echo "Could not resolve ownerId for $OWNER" >&2
  exit 1
fi

echo "==> Find existing project by title"
PROJ_JSON=$(gh api graphql -f query='query($ownerId:ID!){ node(id:$ownerId){ __typename ... on User{ projectsV2(first:100){ nodes{ id number title } }} ... on Organization{ projectsV2(first:100){ nodes{ id number title } }}}}' -F ownerId="$OWNER_ID")
PROJ_ID=$(echo "$PROJ_JSON" | jq -r --arg TITLE "$TITLE" '.data.node.projectsV2.nodes[] | select(.title==$TITLE) | .id' | head -n1)
PROJ_NUM=$(echo "$PROJ_JSON" | jq -r --arg TITLE "$TITLE" '.data.node.projectsV2.nodes[] | select(.title==$TITLE) | .number' | head -n1)

if [[ -z "$PROJ_ID" || "$PROJ_ID" == null ]]; then
  echo "==> Creating project: $TITLE"
  CREATE=$(gh api graphql -f query='mutation($owner:ID!,$title:String!){ createProjectV2(input:{ownerId:$owner,title:$title}){ projectV2{ id number title } }}' -F owner="$OWNER_ID" -F title="$TITLE")
  PROJ_ID=$(echo "$CREATE" | jq -r '.data.createProjectV2.projectV2.id')
  PROJ_NUM=$(echo "$CREATE" | jq -r '.data.createProjectV2.projectV2.number')
fi

echo "Project: $PROJ_NUM ($PROJ_ID)"

echo "==> Ensure core fields (Status, Priority, Size)"
FIELDS=$(gh api graphql -f query='query($id:ID!){ node(id:$id){ ... on ProjectV2 { fields(first:50){ nodes{ __typename ... on ProjectV2FieldCommon { id name dataType } ... on ProjectV2SingleSelectField { id name options{ id name } } } } } }}' -F id="$PROJ_ID")

have_field(){ echo "$FIELDS" | jq -e --arg NAME "$1" '.data.node.fields.nodes[] | select(.name==$NAME)' >/dev/null; }

if ! have_field Status; then
  echo "Creating Status field"
  gh api graphql -f query='mutation($pid:ID!){ createProjectV2Field(input:{ projectId:$pid, name:"Status", dataType:SINGLE_SELECT, singleSelectOptions:[{name:"Backlog",description:"Planned, not started.",color:GRAY},{name:"In Progress",description:"Actively being worked.",color:YELLOW},{name:"In Review",description:"Awaiting review/QA.",color:ORANGE},{name:"Done",description:"Merged/closed; work complete.",color:GREEN}]}){ projectV2Field{ __typename } }}' -F pid="$PROJ_ID" >/dev/null
fi

if ! have_field Priority; then
  echo "Creating Priority field"
  gh api graphql -f query='mutation($pid:ID!){ createProjectV2Field(input:{ projectId:$pid, name:"Priority", dataType:SINGLE_SELECT, singleSelectOptions:[{name:"High",description:"High",color:RED},{name:"Medium",description:"Medium",color:YELLOW},{name:"Low",description:"Low",color:GREEN}]}){ projectV2Field{ __typename } }}' -F pid="$PROJ_ID" >/dev/null
fi

if ! have_field Size; then
  echo "Creating Size field"
  gh api graphql -f query='mutation($pid:ID!){ createProjectV2Field(input:{ projectId:$pid, name:"Size", dataType:NUMBER }){ projectV2Field{ __typename } }}' -F pid="$PROJ_ID" >/dev/null
fi

echo "$PROJ_NUM"
