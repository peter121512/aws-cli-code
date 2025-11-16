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

bucket = "s3://vendor-etl-delta"

# --- Iterate over tables and export each to Delta Lake in chunks ---
for table in tables:
    print(f"Extracting table: {table}")
    target_path = f"{bucket}/{table}_delta/"

    # Stream rows in chunks to avoid memory blowups
    for i, chunk in enumerate(pd.read_sql(f"SELECT * FROM {table};", conn, chunksize=50000)):
        print(f"  Writing chunk {i+1} of {table}, rows={len(chunk)}")
        write_deltalake(
            target_path,
            chunk,
            mode="append",  # append chunks to same Delta table
            storage_options={"AWS_REGION": "eu-north-1"}
        )

    print(f"✅ Finished writing {table} to {target_path}")

    # Optional verification (schema only, safer than full read)
    try:
        dt = DeltaTable(target_path, storage_options={"AWS_REGION": "eu-north-1"})
        print(f"Schema of {table} Delta table:")
        print(dt.schema().json())
    except Exception as e:
        print(f"⚠️ Could not preview {table}: {e}")

conn.close()
print("✅ ETL complete: all public tables written to Delta Lake")

# --- AWS credentials from GitHub secrets ---
aws_access_key = os.getenv("AWS_ACCESS_KEY_ID")
aws_secret_key = os.getenv("AWS_SECRET_ACCESS_KEY")
aws_region     = os.getenv("AWS_DEFAULT_REGION")
