#!/bin/bash
set -e

# --- Ensure .env exists ---
if [ ! -f .env ]; then
  echo ".env file not found. Please create one with AWS and PG credentials."
  exit 1
fi

# --- Load environment variables from .env ---
export $(grep -v '^#' .env | xargs)

# --- Add .env to .gitignore if not already there ---
if ! grep -q "^\.env$" .gitignore 2>/dev/null; then
  echo ".env" >> .gitignore
  echo "Added .env to .gitignore"
fi

# --- Verify AWS CLI auth ---
echo "Verifying AWS CLI authentication..."
aws sts get-caller-identity || {
  echo "AWS CLI authentication failed. Check your IAM keys in .env."
  exit 1
}

# --- Run ETL Python script ---
echo "Running ETL script..."
python etl_rds_to_delta.py

echo "ETL run complete."
