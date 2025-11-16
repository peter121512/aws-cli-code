#!/bin/bash

# --- Verify AWS CLI auth ---
echo "Verifying AWS CLI authentication..."
aws sts get-caller-identity || {
  exit 1
}

# --- Run ETL Python script ---
echo "Running ETL script..."
python etl_rds_to_delta.py

echo "ETL run complete."
