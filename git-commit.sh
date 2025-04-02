#!/bin/bash

# Ask for a commit message
read -p "Enter commit message: " commit_message

# Stage all changes
git add .

# Commit with the provided message
git commit -m "$commit_message"

# Get the current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)

# Push to the current branch
git push origin "$current_branch"

echo "✅ Changes pushed to $current_branch!"
