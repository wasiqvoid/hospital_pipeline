import os
import sys
import logging
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text, inspect
from sqlalchemy.pool import NullPool

# ─────────────────────────────────────────
# SETUP
# ─────────────────────────────────────────
load_dotenv()

DATABASE_URL = os.environ.get("DATABASE_URL")
DATA_DIR     = Path(os.environ.get("DATA_DIR", "./data"))

if not DATABASE_URL:
    sys.exit("❌ DATABASE_URL not set in .env")

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

engine = create_engine(DATABASE_URL, poolclass=NullPool)


# ─────────────────────────────────────────
# HELPERS
# ─────────────────────────────────────────

def clean_strings(df):
    for col in df.select_dtypes(include="object").columns:
        df[col] = df[col].str.strip()
    return df


def create_table_if_not_exists(df, table):
    inspector = inspect(engine)
    if table not in inspector.get_table_names():
        log.info(f"Creating table: {table}")
        df.head(0).to_sql(table, engine, if_exists="replace", index=False)


def load_table(df, table, pk, unique_cols=None):
    if df.empty:
        log.warning(f"{table}: empty, skipping")
        return

    create_table_if_not_exists(df, table)

    # ✅ Remove duplicates
    if unique_cols:
        df = df.drop_duplicates(subset=unique_cols)
    else:
        df = df.drop_duplicates(subset=[pk])

    # ✅ Delete existing rows (idempotent)
    values = df[pk].tolist()
    placeholders = ", ".join([f"'{v}'" for v in values])

    with engine.begin() as conn:
        conn.execute(text(f"DELETE FROM {table} WHERE {pk} IN ({placeholders})"))

    # ✅ Insert
    df.to_sql(table, engine, if_exists="append", index=False, method="multi")

    log.info(f"✓ {table}: {len(df)} rows loaded")


# ─────────────────────────────────────────
# LOADERS
# ─────────────────────────────────────────

def load_doctors():
    log.info("Loading doctors...")
    df = pd.read_csv(DATA_DIR / "doctors.csv")
    df = clean_strings(df)

    df["years_experience"] = pd.to_numeric(df["years_experience"], errors="coerce").fillna(0)

    df = df.dropna(subset=["doctor_id", "first_name", "last_name", "email"])

    load_table(df, "doctors", "doctor_id")


def load_patients():
    log.info("Loading patients...")
    df = pd.read_csv(DATA_DIR / "patients.csv")
    df = clean_strings(df)

    df["date_of_birth"] = pd.to_datetime(df["date_of_birth"], errors="coerce").dt.date
    df["registration_date"] = pd.to_datetime(df["registration_date"], errors="coerce").dt.date

    df = df.dropna(subset=["patient_id", "email"])

    # 🔥 IMPORTANT: handle UNIQUE email
    load_table(df, "patients", "patient_id", unique_cols=["email"])


def load_appointments():
    log.info("Loading appointments...")
    df = pd.read_csv(DATA_DIR / "appointments.csv")
    df = clean_strings(df)

    df["appointment_date"] = pd.to_datetime(df["appointment_date"], errors="coerce").dt.date

    df = df.dropna(subset=["appointment_id", "patient_id", "doctor_id"])

    load_table(df, "appointments", "appointment_id")


def load_treatments():
    log.info("Loading treatments...")
    df = pd.read_csv(DATA_DIR / "treatments.csv")
    df = clean_strings(df)

    df["cost"] = pd.to_numeric(df["cost"], errors="coerce").fillna(0)

    df = df.dropna(subset=["treatment_id", "appointment_id"])

    load_table(df, "treatments", "treatment_id")


def load_billing():
    log.info("Loading billing...")
    df = pd.read_csv(DATA_DIR / "billing.csv")
    df = clean_strings(df)

    df["amount"] = pd.to_numeric(df["amount"], errors="coerce").fillna(0)

    df = df.dropna(subset=["bill_id", "patient_id"])

    load_table(df, "billing", "bill_id")


# ─────────────────────────────────────────
# MAIN
# ─────────────────────────────────────────

def main():
    log.info("=== Hospital Pipeline Ingestion ===")

    load_doctors()
    load_patients()
    load_appointments()
    load_treatments()
    load_billing()

    log.info("✅ Done!")


if __name__ == "__main__":
    main()