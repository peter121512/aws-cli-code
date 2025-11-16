import os
import psycopg2
import pandas as pd
from deltalake.writer import write_deltalake
from deltalake import DeltaTable
from dotenv import load_dotenv

# --- Load environment variables ---
load_dotenv()
pg_pass = os.getenv("PG_VENDOR_PASS")

# --- Database connection ---
conn = psycopg2.connect(
    host="vendor.cnmmeac4u941.eu-north-1.rds.amazonaws.com",
    dbname="vendor",
    user="postgres",
    password=pg_pass,
    sslmode="require"
)

# --- Extract ---
query = "SELECT * FROM ev_vehicle_registration;"
df = pd.read_sql(query, conn)
conn.close()
print(f"Extracted {len(df)} rows from RDS")

# --- Load to S3 in Delta format ---
target_path = "s3://vendor-etl-delta/ev_vehicle_registration_delta/"
write_deltalake(
    target_path,
    df,
    mode="overwrite",
    storage_options={"AWS_REGION": "eu-north-1"}
)
print("ETL complete: data written to Delta at", target_path)

# --- Optional: Verify by reading back ---
dt = DeltaTable(target_path, storage_options={"AWS_REGION": "eu-north-1"})
print("Preview of Delta table:")
print(dt.to_pandas().head())
