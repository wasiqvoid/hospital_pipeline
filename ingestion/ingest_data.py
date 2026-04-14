"""
Hospital Pipeline — Idempotent Ingestion Script
Loads all 5 CSVs into Neon PostgreSQL in dependency order.
"""
import os
import logging
import pandas as pd
from sqlalchemy import create_engine, text
from sqlalchemy.pool import NullPool

logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
log = logging.getLogger(__name__)

DATABASE_URL = os.environ["DATABASE_URL"]
DATA_DIR = os.environ.get("DATA_DIR", "./data")

engine = create_engine(DATABASE_URL, poolclass=NullPool)


def load_table(df: pd.DataFrame, table: str, pk: str) -> None:
    with engine.begin() as conn:
        conn.execute(text(f"DELETE FROM {table}"))
    df.to_sql(table, engine, if_exists="append", index=False, method="multi")
    log.info(f"✓ {table}: {len(df)} rows loaded")


def load_doctors() -> None:
    log.info("Loading doctors...")
    df = pd.read_csv(f"{DATA_DIR}/doctors.csv")
    load_table(df, "doctors", "doctor_id")


def load_patients() -> None:
    log.info("Loading patients...")
    df = pd.read_csv(f"{DATA_DIR}/patients.csv")
    df["date_of_birth"] = pd.to_datetime(df["date_of_birth"], errors="coerce").dt.date
    df["registration_date"] = pd.to_datetime(df["registration_date"], errors="coerce").dt.date
    df = df.dropna(subset=["patient_id", "first_name", "last_name", "date_of_birth"])
    # Fix duplicate emails — use patient_id-based synthetic email
    df["email"] = df["patient_id"].str.lower() + "@hospital.com"
    load_table(df, "patients", "patient_id")


def load_appointments() -> None:
    log.info("Loading appointments...")
    df = pd.read_csv(f"{DATA_DIR}/appointments.csv")
    df["appointment_date"] = pd.to_datetime(df["appointment_date"], errors="coerce").dt.date
    load_table(df, "appointments", "appointment_id")


def load_treatments() -> None:
    log.info("Loading treatments...")
    df = pd.read_csv(f"{DATA_DIR}/treatments.csv")
    df["treatment_date"] = pd.to_datetime(df["treatment_date"], errors="coerce").dt.date
    df["cost"] = pd.to_numeric(df["cost"], errors="coerce").fillna(0).round(2)
    load_table(df, "treatments", "treatment_id")


def load_billing() -> None:
    log.info("Loading billing...")
    df = pd.read_csv(f"{DATA_DIR}/billing.csv")
    df["bill_date"] = pd.to_datetime(df["bill_date"], errors="coerce").dt.date
    df["amount"] = pd.to_numeric(df["amount"], errors="coerce").fillna(0).round(2)
    load_table(df, "billing", "bill_id")


def main() -> None:
    log.info("=== Hospital Pipeline Ingestion ===")
    load_doctors()
    load_patients()
    load_appointments()
    load_treatments()
    load_billing()
    log.info("✅ Done!")


if __name__ == "__main__":
    main()