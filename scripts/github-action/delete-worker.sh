#!/bin/bash

# Check if a branch name is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <branch name>"
  exit 1
fi

BRANCH_NAME="$1"

if [ -z "$CF_API_TOKEN" ]; then
  echo "Error: CF_API_TOKEN is not set"
  exit 1
fi

if [ -z "$CF_ACCOUNT_ID" ]; then
  echo "Error: CF_ACCOUNT_ID is not set"
  exit 1
fi

echo "Deleting Cloudflare workers for branch: $BRANCH_NAME"
echo "CF_API_TOKEN detected"

WORKERS=$(curl -s -X GET "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/workers/scripts" \
-H "Authorization: Bearer $CF_API_TOKEN" \
-H "Content-Type: application/json" | jq -r '.result[]?.id')

if [ -z "$WORKERS" ]; then
  echo "No worker found for branch $BRANCH_NAME"
  exit 1
fi

MAIN_WORKER="$BRANCH_NAME"
SERVICE_WORKER=($(echo "$WORKERS" | grep -v "^$MAIN_WORKER"))

for worker in "${SERVICE_WORKER[@]}"; do
  if [ -n "$worker" ]; then
    echo "Deleting worker: $worker"
    curl -s -X DELETE "https://api.cloudflare.com/client/v4/accounts/$CF_ACCOUNT_ID/workers/scripts/$worker" \
    -H "Authorization: Bearer $CF_API_TOKEN" \
    -H "Content-Type: application/json" | jq .
  fi
done

echo "Branch $BRANCH_NAME cleanup completed!"
