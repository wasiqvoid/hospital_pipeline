import os
import sys
import logging
from pathlib import Path

import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.pool import NullPool

load_dotenv()


DATABASE_URL = os.environ.get("DATABASE_URL")   
BASE_DIR = Path(__file__).resolve().parent.parent
_data_dir_env = os.environ.get("DATA_DIR")
DATA_DIR = (BASE_DIR / _data_dir_env) if _data_dir_env and not Path(_data_dir_env).is_absolute() else Path(_data_dir_env) if _data_dir_env else BASE_DIR / "data"
if not DATABASE_URL:
    sys.exit("DATABASE_URL not set in .env")

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

engine = create_engine(DATABASE_URL, poolclass=NullPool)

# HELPERS
def clean_strings(df):
    for col in df.select_dtypes(include="object").columns:
        df[col] = df[col].str.strip()
    return df


def load_table(df, table, pk, unique_cols=None):
    if df.empty:
        log.warning(f"{table}: empty, skipping")
        return

    # Remove duplicates
    if unique_cols:
        df = df.drop_duplicates(subset=unique_cols)
    else:
        df = df.drop_duplicates(subset=[pk])

    values = df[pk].dropna().tolist()

    if not values:
        log.warning(f"{table}: no valid PK values, skipping delete")
    else:
        with engine.begin() as conn:
            params = {f"id_{i}": v for i, v in enumerate(values)}
            placeholders = ", ".join(f":id_{i}" for i in range(len(values)))
            conn.execute(
                text(f"DELETE FROM {table} WHERE {pk} IN ({placeholders})"),
                params
            )

    # Insert
    df.to_sql(table, engine, if_exists="append", index=False, method="multi")

    log.info(f"✓ {table}: {len(df)} rows loaded")


# LOADERS

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
    df = df.dropna(subset=["bill_id", "treatment_id"])

    load_table(df, "billing", "bill_id")


# MAIN
def main():
    log.info("=== Hospital Pipeline Ingestion ===")

    load_doctors()
    load_patients()
    load_appointments()
    load_treatments()
    load_billing()

    log.info("Done!")


if __name__ == "__main__":
    main()
