#!/usr/bin/env bash
set -euo pipefail

# Update a Project (v2) item's Status by option name
# Usage:
#   OWNER=<user_or_org> PROJ_NUM=<number> ITEM_ID=<id> STATUS="In Progress" bash project-status.sh

OWNER=${OWNER:-}
PROJ_NUM=${PROJ_NUM:-}
ITEM_ID=${ITEM_ID:-}
STATUS=${STATUS:-}
if [[ -z "$OWNER" || -z "$PROJ_NUM" || -z "$ITEM_ID" || -z "$STATUS" ]]; then
  echo "Set OWNER, PROJ_NUM, ITEM_ID, STATUS" >&2
  exit 1
fi

# Resolve project id (prefer user, fallback org)
PROJ_ID=$(gh api graphql -f query='query($owner:String!,$n:Int!){ user(login:$owner){ projectV2(number:$n){ id } }}' -F owner="$OWNER" -F n="$PROJ_NUM" --jq '.data.user.projectV2.id' 2>/dev/null || true)
if [[ -z "$PROJ_ID" || "$PROJ_ID" == null ]]; then
  PROJ_ID=$(gh api graphql -f query='query($owner:String!,$n:Int!){ organization(login:$owner){ projectV2(number:$n){ id } }}' -F owner="$OWNER" -F n="$PROJ_NUM" --jq '.data.organization.projectV2.id' 2>/dev/null || true)
fi

FIELDS=$(gh api graphql -f query='query($id:ID!){ node(id:$id){ ... on ProjectV2 { fields(first:50){ nodes{ __typename ... on ProjectV2SingleSelectField{ id name options{ id name } } ... on ProjectV2FieldCommon { id name dataType } } } } }}' -F id="$PROJ_ID")
STATUS_FIELD_ID=$(echo "$FIELDS" | jq -r '.data.node.fields.nodes[] | select(.name=="Status") | .id')
OPTION_ID=$(echo "$FIELDS" | jq -r ".data.node.fields.nodes[] | select(.name==\"Status\") | .options[] | select(.name==\"$STATUS\") | .id")

if [[ -z "$OPTION_ID" || "$OPTION_ID" == null ]]; then
  # Try common synonyms to avoid UI coupling
  case "$STATUS" in
    "Backlog") for alt in "Backlog" "To do" "To Do" "Todo"; do 
        OPTION_ID=$(echo "$FIELDS" | jq -r ".data.node.fields.nodes[] | select(.name==\"Status\") | .options[] | select(.name==\"$alt\") | .id"); [[ -n "$OPTION_ID" && "$OPTION_ID" != null ]] && break; done;;
    "In Progress") for alt in "In Progress" "In progress"; do 
        OPTION_ID=$(echo "$FIELDS" | jq -r ".data.node.fields.nodes[] | select(.name==\"Status\") | .options[] | select(.name==\"$alt\") | .id"); [[ -n "$OPTION_ID" && "$OPTION_ID" != null ]] && break; done;;
    "Review") for alt in "Review" "In review" "In Review"; do 
        OPTION_ID=$(echo "$FIELDS" | jq -r ".data.node.fields.nodes[] | select(.name==\"Status\") | .options[] | select(.name==\"$alt\") | .id"); [[ -n "$OPTION_ID" && "$OPTION_ID" != null ]] && break; done;;
    "Done") for alt in "Done" "Closed"; do 
        OPTION_ID=$(echo "$FIELDS" | jq -r ".data.node.fields.nodes[] | select(.name==\"Status\") | .options[] | select(.name==\"$alt\") | .id"); [[ -n "$OPTION_ID" && "$OPTION_ID" != null ]] && break; done;;
  esac
fi

if [[ -z "$STATUS_FIELD_ID" || -z "$OPTION_ID" || "$OPTION_ID" == null ]]; then
  echo "Could not resolve Status field or option id" >&2
  echo "Available Status options:" >&2
  echo "$FIELDS" | jq -r '.data.node.fields.nodes[] | select(.name=="Status") | .options[] | .name' >&2
  exit 1
fi

# GraphQL mutation to update item field value
gh api graphql -f query='mutation($proj:ID!,$item:ID!,$field:ID!,$opt:String!){ updateProjectV2ItemFieldValue(input:{projectId:$proj,itemId:$item,fieldId:$field,value:{ singleSelectOptionId:$opt }}){ projectV2Item{ id } }}' -F proj="$PROJ_ID" -F item="$ITEM_ID" -F field="$STATUS_FIELD_ID" -F opt="$OPTION_ID" >/dev/null
echo "Updated item $ITEM_ID to Status=$STATUS"

