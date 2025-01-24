#!/bin/bash
# Check if a branch name is provided
if [ -z "$1"]; then
  echo "Usage: $0 <branch name"
  exit 1
fi

BRANCH_NAME = "$1"

echo "Branch Name '$BRANCH_NAME' is detected!"