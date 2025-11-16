#!/bin/bash
set -e

echo "Installing Python dependencies from requirements.txt..."
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

echo "Dependencies installed successfully."

if [ -f run_etl.sh ]; then
  chmod +x run_etl.sh
  echo "Made run_etl.sh executable."
fi

echo "Initialization complete."
