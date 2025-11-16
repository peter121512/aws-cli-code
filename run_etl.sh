#!/bin/bash
set -e

echo "🔁 Starting ETL pipeline..."

# --- Export secrets from environment ---
export PG_VENDOR_PASS="${PG_VENDOR_PASS}"
export VENDOR_API_KEY="${VENDOR_API_KEY}"
export AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}"
export AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}"
export AWS_DEFAULT_REGION="${AWS_DEFAULT_REGION}"

# --- Sanity check for required secrets ---
missing=false

check_secret() {
  local name="$1"
  local value="${!name}"
  if [ -z "$value" ]; then
    echo "❌ Missing secret: $name"
    missing=true
  else
    echo "✅ Found secret: $name"
  fi
}

check_secret "PG_VENDOR_PASS"
check_secret "VENDOR_API_KEY"
check_secret "AWS_ACCESS_KEY_ID"
check_secret "AWS_SECRET_ACCESS_KEY"
check_secret "AWS_DEFAULT_REGION"

if [ "$missing" = true ]; then
  echo "🚫 Aborting: one or more required secrets are missing."
  exit 1
fi

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
