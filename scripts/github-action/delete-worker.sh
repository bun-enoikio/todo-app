#!/bin/bash
# Check if a branch name is provided

# Ensure environment variables are set
if [ -z "$CF_ACCOUNT_ID" ] || [ -z "$CF_API_TOKEN" ]; then
  echo "CF_ACCOUNT_ID and CF_API_TOKEN must be set"
  exit 1
fi

if [ -z "$1" ]; then
  echo "Usage: $0 <branch name>"
  exit 1
fi

BRANCH_NAME="$1"
WORKERS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/workers/scripts" \
-H "Authorization: Bearer $CF_API_TOKEN" \
-H "Content-Type: application/json" | jq -r '.result[]?.id')

echo "Fetched workers: $WORKERS"  # Debug information

if [ -z "$WORKERS" ]; then
  echo "No worker found for branch $BRANCH_NAME"
  exit 1
fi

MAIN_WORKER="$BRANCH_NAME"
SERVICE_WORKER=($(echo "$WORKERS" | grep -v "^$MAIN_WORKER"))

echo "Deleting worker $MAIN_WORKER"

for worker in "${SERVICE_WORKER[@]}"; do
  if [ -n "$worker" ]; then
    echo "Deleting worker $worker"
    curl -s -X DELETE "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/workers/scripts/$worker" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" | jq .
  fi
done
echo "Branch Name $BRANCH_NAME is detected!"