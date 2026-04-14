# 🏥 Hospital Operations Analytics Platform — EAS 550

A cloud-native, end-to-end data engineering pipeline built on Neon PostgreSQL, dbt Core, and Streamlit. Covers data ingestion, dimensional modelling, CI/CD automation, and an interactive analytics dashboard.

**Team:** Wasiq Nabi Bakhsh · Vishal Anand · Pankhudi Saraswat · Srivardhan Baba Vemula

---

## Project Structure

```
hospital_pipeline/
├── run_pipeline.sh                  # ONE command — runs everything end to end
├── sql/
│   ├── schema.sql                   # 3NF OLTP schema (Neon PostgreSQL)
│   ├── security.sql                 # RBAC roles
│   └── advanced_queries.sql         # Phase 2 analytical SQL
├── ingestion/
│   └── ingest_data.py               # Idempotent ELT pipeline (all 5 CSVs)
├── data/                            # CSV source files (gitignored)
│   ├── doctors.csv
│   ├── patients.csv
│   ├── appointments.csv
│   ├── treatments.csv
│   └── billing.csv
├── dbt_project/
│   ├── dbt_project.yml
│   ├── packages.yml
│   ├── profiles.yml
│   ├── models/
│   │   ├── staging/
│   │   │   ├── sources.yml
│   │   │   ├── stg_appointments.sql
│   │   │   ├── stg_billing.sql
│   │   │   └── stg_treatments.sql
│   │   └── marts/
│   │       ├── schema.yml
│   │       ├── dim_date.sql
│   │       ├── dim_doctor.sql
│   │       ├── dim_patient.sql
│   │       └── fact_appointments.sql
│   └── .github/
│       └── workflows/
│           └── ci.yml               # GitHub Actions — SQLFluff + dbt test
├── docs/
│   ├── 3nf_justification.md
│   └── performance_tuning_report.md
├── requirements.txt
├── .gitignore
└── README.md
```

---

## Dataset

**Source:** [Hospital Management Dataset — Kaggle](https://www.kaggle.com/datasets/kanakbaghel/hospital-management-dataset)

| File | Rows | Key Columns |
|------|------|-------------|
| doctors.csv | 10 | doctor_id, specialization, years_experience |
| patients.csv | 50 | patient_id, gender, date_of_birth, insurance_provider |
| appointments.csv | 200 | appointment_id, patient_id, doctor_id, status |
| treatments.csv | 200 | treatment_id, appointment_id, treatment_type, cost |
| billing.csv | 200 | bill_id, patient_id, treatment_id, amount, payment_status |

---

## Stack

| Layer | Technology |
|-------|-----------|
| Cloud Database | Neon PostgreSQL (serverless) |
| Ingestion | Python · Pandas · SQLAlchemy |
| Transformation | dbt Core 1.10 · dbt-utils |
| CI/CD | GitHub Actions · SQLFluff |
| Dashboard | Streamlit (Phase 3) |
| Deployment | Render |

---

## Setup Instructions

### 1. Clone the repo
```bash
git clone https://github.com/wasiqvoid/hospital_pipeline.git
cd hospital_pipeline
```

### 2. Create and activate virtual environment
```bash
python -m venv .venv
source .venv/bin/activate        # Mac/Linux
.venv\Scripts\activate           # Windows
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Add CSV files
Download from Kaggle and place all 5 CSVs inside `data/`

### 5. Set your Neon credentials in run_pipeline.sh
Open `run_pipeline.sh` and update:
```bash
export DB_HOST=your-neon-host.neon.tech
export DB_USER=neondb_owner
export DB_PASSWORD=YOUR_PASSWORD_HERE
export DB_NAME=neondb
```

### 6. Run the full pipeline
```bash
bash run_pipeline.sh
```

This single command will:
- Drop and recreate the schema on Neon
- Load all 5 CSV files (50 patients, 200 appointments, 200 treatments, 200 billing rows)
- Run all 7 dbt models
- Execute all 65 dbt data quality tests

Expected output:
```
=== 1. Schema ===
Schema done

=== 2. Ingest all data ===
✓ doctors:      10 rows loaded
✓ patients:     50 rows loaded
✓ appointments: 200 rows loaded
✓ treatments:   200 rows loaded
✓ billing:      200 rows loaded

=== 3. dbt run + test ===
Done. PASS=7  WARN=0 ERROR=0 SKIP=0  TOTAL=7
Done. PASS=65 WARN=0 ERROR=0 SKIP=0  TOTAL=65

Pipeline complete!
```

---

## dbt Models

### Staging (Views)
| Model | Description |
|-------|-------------|
| stg_appointments | Cleaned appointments with typed columns |
| stg_treatments | Treatments with cost as numeric |
| stg_billing | Billing with payment_status and patient_id |

### Marts (Materialized Tables)
| Model | Rows | Description |
|-------|------|-------------|
| dim_date | 731 | Date spine (2022–2024) with week/month/quarter |
| dim_doctor | 10 | Doctor attributes with experience_band |
| dim_patient | 50 | Patient demographics with age_group |
| fact_appointments | 200 | Central fact table joining all dimensions |

---

## Data Quality Tests

65 dbt tests covering:
- **Uniqueness** — all primary keys across every model and source
- **Not-null** — required fields on all tables
- **Accepted values** — status, payment_status, gender, treatment_type, age_group
- **Relationships** — all foreign keys validated (patient → appointment → treatment → billing)
- **Range checks** — billed_amount ≥ 0, treatment_cost ≥ 0, month between 1–12

---

## CI/CD Pipeline

Every pull request to `main` triggers:
1. **SQLFluff** — lints all SQL files against dbt conventions
2. **dbt test** — runs all 65 data quality tests against Neon

### GitHub Secrets Required

| Secret | Description |
|--------|-------------|
| `DB_HOST` | Neon direct host (not pooler) |
| `DB_USER` | neondb_owner |
| `DB_PASSWORD` | Neon password |
| `DB_NAME` | neondb |

---

## Schema Design (3NF)

Five tables in Third Normal Form with full referential integrity:

```
doctors ──< appointments >── patients
                │
            treatments
                │
            billing
```

Key design decisions:
- `billing` carries `patient_id` directly (matches source CSV) with a FK to patients
- `payment_status` allows `Pending`, `Paid`, `Failed`, `Partial`, `Waived`
- Patient emails are synthetic (`p001@hospital.com`) to resolve duplicates in source data
- All tables include `created_at TIMESTAMPTZ` for audit trail

---

## Known Data Issues & Fixes

| Issue | Root Cause | Fix Applied |
|-------|-----------|-------------|
| Only 39/50 patients loaded | Duplicate emails in CSV | Replaced with `patient_id@hospital.com` |
| Billing `patient_id` missing | Original schema omitted it | Added column + FK to schema |
| `payment_status` check violation | Schema missing `Failed` value | Added `Failed` to CHECK constraint |

---

## Demo Video
[[YouTube Link Here](https://www.youtube.com/watch?v=p1CfzJpFD18)]
