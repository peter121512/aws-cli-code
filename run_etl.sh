#!/bin/bash
set -e

echo "Starting ETL pipeline..."

# --- Export secrets from GitHub Actions environment ---
export PG_VENDOR_PASS="${PG_VENDOR_PASS}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"

# --- Sanity check for required secrets ---
if [ -z "$PG_VENDOR_PASS" ] || [ -z "$AWS_ACCESS_KEY_ID" ] || [ -z "$AWS_SECRET_ACCESS_KEY" ] || [ -z "$AWS_DEFAULT_REGION" ]; then
  echo "Error: One or more required secrets are missing."
  exit 1
fi

# --- Configure AWS CLI using secrets ---
echo "Configuring AWS CLI..."
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"
aws configure set default.output "json"

# --- Run ETL Python script ---
echo "Running ETL script..."
python etl_rds_to_delta.py

echo "ETL pipeline finished."
