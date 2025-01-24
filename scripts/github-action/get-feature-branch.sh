#!/bin/bash

# Exit on error
set -e

# Ensure the script is run from the Git repository
if [ ! -d ".git" ]; then
  echo "Error: This script must be run from the root of a Git repository."
  exit 1
fi

# Get the hash of the most recent merge commit
merge_commit=$(git log --merges --pretty=format:"%H" -n 1)

# Check if a merge commit exists
if [ -z "$merge_commit" ]; then
  echo "Error: No recent merge commit found in the main branch."
  exit 1
fi

# Extract the branch name using basic string matching
commit_message=$(git log -1 --pretty=%B "$merge_commit")
full_branch_name=$(echo "$commit_message" | sed -n 's/.*from \([^ ]*\).*/\1/p')

# Validate the branch name
if [ -z "$full_branch_name" ]; then
  echo "Error: Unable to determine the feature branch name from the merge commit."
  exit 1
fi

# Extract the last part of the branch name
feature_branch=$(basename "$full_branch_name")

# Output the feature branch name
echo "$feature_branch"
