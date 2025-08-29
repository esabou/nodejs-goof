#!/bin/bash
set -e

# Ensure secrets are set
if [ -z "$SNYK_ADMIN_TOKEN" ]; then
  echo "❌ SNYK_ADMIN_TOKEN is not set"
  exit 1
fi

if [ -z "$GROUP_ID" ]; then
  echo "❌ GROUP_ID is not set. Add it as a GitHub Secret."
  exit 1
fi

API_BASE="https://api.snyk.io"

# -------------------------------
# Step 1: Fetch Service Accounts for the predefined group
# -------------------------------
accounts_json=$(curl -s -X GET "$API_BASE/rest/groups/$GROUP_ID/service_accounts?version=2024-10-15" \
  -H "Authorization: token $SNYK_ADMIN_TOKEN" \
  -H "Content-Type: application/json")

echo "Raw API response for service accounts:"
echo "$accounts_json" | jq .

accounts_count=$(echo "$accounts_json" | jq '.data | length')
if [ "$accounts_count" -eq 0 ]; then
  echo "❌ No service accounts found in group $GROUP_ID."
  exit 1
fi

# Select the first service account (or add logic if you have multiple)
SERVICE_ACCOUNT_ID=$(echo "$accounts_json" | jq -r '.data[0].id')
echo "✅ Using SERVICE_ACCOUNT_ID: $SERVICE_ACCOUNT_ID"

# -------------------------------
# Step 2: Export for GitHub Actions
# -------------------------------
echo "GROUP_ID=$GROUP_ID" >> $GITHUB_ENV
echo "SERVICE_ACCOUNT_ID=$SERVICE_ACCOUNT_ID" >> $GITHUB_ENV
