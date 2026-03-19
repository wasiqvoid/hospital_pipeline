# EAS 550 — Phase 1: 3NF Justification Report
## Hospital Management Database Schema Design

---

## 1. Entities Identified

| Entity | Description |
|--------|-------------|
| **doctors** | Physicians with specialization and hospital branch |
| **patients** | Registered patients with insurance info |
| **appointments** | Scheduled visits between a patient and doctor |
| **treatments** | Medical procedures performed during an appointment |
| **billing** | Financial records for treatments per patient |

---

## 2. Relationships

- A **doctor** handles many **appointments** (one-to-many)
- A **patient** has many **appointments** (one-to-many)
- An **appointment** has one **treatment** (one-to-one in this dataset)
- A **patient** has many **billing** records (one-to-many)
- A **treatment** has one **billing** record (one-to-one)

---

## 3. Normalization Walkthrough

### First Normal Form (1NF)
All tables have a single primary key and atomic column values.
No repeating groups or comma-separated lists exist in any column.

### Second Normal Form (2NF)
All non-key attributes depend on the entire primary key.
No partial dependencies exist since all tables use single-column PKs.

**Example fix:** The raw CSV had `insurance_provider` and `insurance_number`
inside `appointments`. These describe the patient, not the appointment,
so they were kept only in `patients`.

### Third Normal Form (3NF)
No transitive dependencies — non-key attributes depend only on the PK.

**Example fixes:**
1. `hospital_branch` and `specialization` stayed in `doctors` only —
   removed from `appointments` where they originally appeared.
2. `payment_method` and `payment_status` stayed in `billing` only —
   not duplicated in `treatments`.
3. `doctor` details (name, specialization) are not repeated in
   `appointments` — only `doctor_id` FK is stored.

---

## 4. Many-to-Many Resolutions

No direct many-to-many relationships exist in this schema.
The `appointments` table naturally resolves the patient ↔ doctor
relationship (a patient sees many doctors; a doctor sees many patients).

---

## 5. Data Anomaly Prevention

| Anomaly | How Prevented |
|---------|--------------|
| **Insertion** | Doctor info stored independently — can add a doctor with no appointments yet |
| **Update** | Patient name stored once in `patients` — changing it updates one row only |
| **Deletion** | Deleting a billing record does not affect patient or treatment data |

---

## 6. Constraints Used

| Constraint | Where Applied | Purpose |
|------------|--------------|---------|
| PRIMARY KEY | All tables | Uniquely identify each row |
| FOREIGN KEY | appointments, treatments, billing | Enforce referential integrity |
| NOT NULL | Required fields | Prevent incomplete records |
| UNIQUE | email columns | No duplicate accounts |
| CHECK | status, payment_status, cost, amount | Enforce valid values |
| DECIMAL(10,2) | cost, amount | Precise currency storage |
| TIMESTAMPTZ | created_at | Timezone-aware audit timestamps |
