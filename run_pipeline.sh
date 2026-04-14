#!/bin/bash
set -e

cd "$(dirname "$0")"
source .venv/bin/activate

# ── CREDENTIALS ─────────────────────────────────────────────
export DB_HOST=ep-rough-surf-a4xm7d20.us-east-1.aws.neon.tech
export DB_USER=neondb_owner
export DB_PASSWORD=npg_Vc9KPmHpdk8b
export DB_NAME=neondb
export DATABASE_URL="postgresql://${DB_USER}:${DB_PASSWORD}@${DB_HOST}/${DB_NAME}?sslmode=require"
export DATA_DIR=./data
# ────────────────────────────────────────────────────────────

echo "=== 1. Schema ==="
python3 -c "
from sqlalchemy import create_engine, text
import os
engine = create_engine(os.environ['DATABASE_URL'])
with open('sql/schema.sql') as f:
    sql = f.read()
with engine.begin() as conn:
    conn.execute(text(sql))
print('Schema done')
"

echo "=== 2. Ingest all data ==="
python ingestion/ingest_data.py

echo "=== 3. dbt run + test ==="
cd dbt_project
cp profiles.yml ~/.dbt/profiles.yml
dbt run && dbt test

echo ""
echo "Pipeline complete!"
