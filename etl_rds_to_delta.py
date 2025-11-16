import os
import psycopg2  # using psycopg2-binary
import pandas as pd
from deltalake.writer import write_deltalake
from deltalake import DeltaTable

# --- Load environment variables ---
pg_pass = os.getenv("PG_VENDOR_PASS")  # from GitHub secret

# --- Database connection ---
conn = psycopg2.connect(
    host="vendor.cnmmeac4u941.eu-north-1.rds.amazonaws.com",
    dbname="vendor",
    user="postgres",
    password=pg_pass,
    sslmode="require"
)

# --- Discover all tables in public schema ---
tables_query = """
    SELECT tablename
    FROM pg_tables
    WHERE schemaname = 'public';
"""
tables_df = pd.read_sql(tables_query, conn)
tables = tables_df['tablename'].tolist()

print(f"Found {len(tables)} tables in public schema: {tables}")

# --- Iterate over tables and export each to Delta Lake ---
bucket = "s3://vendor-etl-delta"

for table in tables:
    print(f"Extracting table: {table}")
    df = pd.read_sql(f"SELECT * FROM {table};", conn)
    print(f"Extracted {len(df)} rows from {table}")

    target_path = f"{bucket}/{table}_delta/"
    print(f"Writing Delta table to {target_path}")

    write_deltalake(
        target_path,
        df,
        mode="overwrite",
        storage_options={"AWS_REGION": "eu-north-1"}
    )

    # Optional verification
    dt = DeltaTable(target_path, storage_options={"AWS_REGION": "eu-north-1"})
    print(f"Preview of {table} Delta table:")
    print(dt.to_pandas().head())

conn.close()
print("✅ ETL complete: all public tables written to Delta Lake")

# --- AWS credentials from GitHub secrets ---
aws_access_key = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_region     = os.getenv("AWS_DEFAULT_REGION")
