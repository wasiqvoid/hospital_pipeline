# 🏥 Hospital Management Analytics — EAS 550

## Phase 1: Infrastructure, Schema & Data Ingestion

---

## Project Structure

```
hospital_pipeline/
├── sql/
│   ├── schema.sql          # All CREATE TABLE statements (OLTP, 3NF)
│   └── security.sql        # RBAC roles (Bonus Step 1.4)
├── ingestion/
│   └── ingest_data.py      # Idempotent ELT pipeline
├── docs/
│   ├── Usage of tools.txt
│   ├── EAS_550_Group_4_Proposal.pdf         # REPROT OF PROPOSAL
│   ├── EAS_550_Group_4_Phase_1.pdf          # REPORT OF PHASE 1
│   ├── 3nf_justification.md                 # Schema design report
│   ├── ERD.html #web page
│   └── ERD_Diargam.png                      # ER diagram   
├── data/                                    # CSV files (gitignored)
├── requirements.txt
├── .gitignore
└── README.md
```

---

## Dataset

**Hospital Management Dataset**
https://www.kaggle.com/datasets/kanakbaghel/hospital-management-dataset

| File | Rows |
|------|------|
| doctors.csv | 10 |
| patients.csv | 50 |
| appointments.csv | 200 |
| treatments.csv | 200 |
| billing.csv | 200 |

---

## Setup Instructions

### 1. Clone the repo
```bash
git clone https://github.com/YOUR_USERNAME/hospital_pipeline.git
cd hospital_pipeline
```

### 2. Create virtual environment
```bash
python -m venv venv
venv\Scripts\activate      # Windows
source venv/bin/activate   # Mac/Linux
```

### 3. Install dependencies
```bash
pip install -r requirements.txt
```

### 4. Create .env file
```
DATABASE_URL=postgresql://neondb_owner:YOUR_PASSWORD@ep-divine-river-a4tph9vx-pooler.us-east-1.aws.neon.tech/neondb?sslmode=require
DATA_DIR=./data
```

### 5. Run schema on Neon
Paste `sql/schema.sql` into the Neon SQL Editor and click Run.

### 6. Add CSV files to data/ folder
Download from Kaggle and place all CSVs inside `data/`

### 7. Run ingestion
```bash
python ingestion/ingest_data.py
```

Expected output:
```
✓ doctors:      10 rows loaded
✓ patients:     50 rows loaded
✓ appointments: 200 rows loaded
✓ treatments:   200 rows loaded
✓ billing:      200 rows loaded
✅  Ingestion complete!
```

---

## GitHub Secrets Required

| Secret | Value |
|--------|-------|
| `DATABASE_URL` | Full Neon connection string |

---

## Team Members
- [Wasiq Nabi Bakhsh]
- [Vishal Anand]
- [Pankhudi Saraswat]
- [Srivardhan Baba Vemula]

**Demo Video:** [https://www.youtube.com/watch?v=p1CfzJpFD18] 
