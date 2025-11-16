#!/bin/bash
set -e

echo "🔁 Starting ETL pipeline..."

# --- Environment variables are injected by GitHub Actions or Codespaces ---
# Python will read PG_VENDOR_PASS, AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION directly

# --- Configure AWS CLI ---
echo "🔧 Configuring AWS CLI..."
aws configure set aws_access_key_id "$AWS_ACCESS_KEY_ID"
aws configure set aws_secret_access_key "$AWS_SECRET_ACCESS_KEY"
aws configure set default.region "$AWS_DEFAULT_REGION"
aws configure set default.output "json"

# --- Run ETL Python script ---
echo "🚀 Running ETL script..."
python etl_rds_to_delta.py

echo "✅ ETL pipeline finished."
