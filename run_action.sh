#!/bin/bash
set -e

# Name of the workflow as defined in .github/workflows/etl.yml
WORKFLOW_NAME="Run ETL Pipeline"

# Trigger the workflow ad-hoc
echo "Triggering GitHub Action: $WORKFLOW_NAME"
gh workflow run "$WORKFLOW_NAME"

# Optional: list runs to confirm
gh run list --workflow="$WORKFLOW_NAME" --limit 5
