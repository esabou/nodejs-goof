#!/bin/bash
set -e

# Check that SNYK_ADMIN_TOKEN is set
if [ -z "$SNYK_ADMIN_TOKEN" ]; then
  echo "❌ SNYK_ADMIN_TOKEN is not set"
  exit 1
fi

API_BASE="https://api.snyk.io"

# Fetch all groups
groups_json=$(curl -s -X GET "$API_BASE/rest/groups?version=2024-10-15" \
  -H "Authorization: token $SNYK_ADMIN_TOKEN" \
  -H "Content-Type: application/json")

echo "Available groups:"
echo "$groups_json" | jq -r '.groups[] | "\(.name) -> \(.id)"'

# Select the first group (or customize logic)
GROUP_ID=$(echo "$groups_json" | jq -r '.groups[0].id')
echo "✅ Using GROUP_ID: $GROUP_ID"

# Fetch all service accounts in that group
accounts_json=$(curl -s -X GET "$API_BASE/rest/groups/$GROUP_ID/service_accounts?version=2024-10-15" \
  -H "Authorization: token $SNYK_ADMIN_TOKEN" \
  -H "Content-Type: application/json")

echo "Available service accounts:"
echo "$accounts_json" | jq -r '.serviceAccounts[] | "\(.name) -> \(.id)"'

# Select the first service account (or customize logic)
SERVICE_ACCOUNT_ID=$(echo "$accounts_json" | jq -r '.serviceAccounts[0].id')
echo "✅ Using SERVICE_ACCOUNT_ID: $SERVICE_ACCOUNT_ID"

# Export for GitHub Actions
echo "GROUP_ID=$GROUP_ID" >> $GITHUB_ENV
echo "SERVICE_ACCOUNT_ID=$SERVICE_ACCOUNT_ID" >> $GITHUB_ENV
