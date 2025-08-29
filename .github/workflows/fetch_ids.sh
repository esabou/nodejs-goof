#!/bin/bash
set -e

# Ensure the admin token is set
if [ -z "$SNYK_ADMIN_TOKEN" ]; then
  echo "❌ SNYK_ADMIN_TOKEN is not set"
  exit 1
fi

API_BASE="https://api.snyk.io"

# -------------------------------
# Step 1: Fetch Groups
# -------------------------------
groups_json=$(curl -s -X GET "$API_BASE/rest/groups?version=2024-10-15" \
  -H "Authorization: token $SNYK_ADMIN_TOKEN" \
  -H "Content-Type: application/json")

echo "Raw API response for groups:"
echo "$groups_json" | jq .

# Check that we have groups
groups_count=$(echo "$groups_json" | jq '.data | length')
if [ "$groups_count" -eq 0 ]; then
  echo "❌ No groups found. Check SNYK_ADMIN_TOKEN and account permissions."
  exit 1
fi

# Select the first group (customize if needed)
GROUP_ID=$(echo "$groups_json" | jq -r '.data[0].id')
echo "✅ Using GROUP_ID: $GROUP_ID"

# -------------------------------
# Step 2: Fetch Service Accounts
# -------------------------------
accounts_json=$(curl -s -X GET "$API_BASE/rest/groups/$GROUP_ID/service_accounts?version=2024-10-15" \
  -H "Authorization: token $SNYK_ADMIN_TOKEN" \
  -H "Content-Type: application/json")

echo "Raw API response for service accounts:"
echo "$accounts_json" | jq .

accounts_count=$(echo "$accounts_json" | jq '.serviceAccounts | length')
if [ "$accounts_count" -eq 0 ]; then
  echo "❌ No service accounts found in group $GROUP_ID."
  exit 1
fi

# Select the first service account (customize if needed)
SERVICE_ACCOUNT_ID=$(echo "$accounts_json" | jq -r '.serviceAccounts[0].id')
echo "✅ Using SERVICE_ACCOUNT_ID: $SERVICE_ACCOUNT_ID"

# -------------------------------
# Step 3: Export for GitHub Actions
# -------------------------------
echo "GROUP_ID=$GROUP_ID" >> $GITHUB_ENV
echo "SERVICE_ACCOUNT_ID=$SERVICE_ACCOUNT_ID" >> $GITHUB_ENV
