# EAS 550 — Phase 1: 3NF Justification Report
## Hospital Management Database Schema Design

---

## 1. Entities Identified

| Entity | Description |
|--------|-------------|
| **doctors** | Physicians with specialization and hospital branch |
| **patients** | Registered patients with demographic and insurance information |
| **appointments** | Scheduled visits between a patient and a doctor |
| **treatments** | Medical procedures performed during an appointment |
| **billing** | Financial records associated with individual treatments |

---

## 2. Relationships

- A **doctor** handles many **appointments** (one-to-many)
- A **patient** has many **appointments** (one-to-many)
- An **appointment** can have multiple **treatments** (one-to-many)
- A **treatment** has one associated **billing** record (one-to-one)

---

## 3. Normalization Walkthrough

### First Normal Form (1NF)

All tables satisfy 1NF:
- Each table has a clearly defined primary key.
- All attributes contain atomic values (no arrays or repeating groups).
- No column contains multiple values or comma-separated data.

---

### Second Normal Form (2NF)

All tables satisfy 2NF:
- Each table uses a single-column primary key.
- All non-key attributes are fully dependent on the primary key.
- No partial dependencies exist.

**Example improvement:**
In the raw dataset, `insurance_provider` and `insurance_number` were present in the `appointments` data. These attributes describe the patient, not the appointment. Therefore, they were moved to the `patients` table to ensure proper dependency.

---

### Third Normal Form (3NF)

All tables satisfy 3NF:
- There are no transitive dependencies.
- Non-key attributes depend only on the primary key and not on other non-key attributes.

**Key design decisions:**

1. **Doctor information normalization**
   - Attributes such as `specialization` and `hospital_branch` are stored only in the `doctors` table.
   - The `appointments` table stores only `doctor_id` as a foreign key, avoiding redundancy.

2. **Patient information normalization**
   - Patient-specific attributes such as insurance details are stored only in the `patients` table.
   - This prevents duplication across multiple appointments.

3. **Treatment and billing separation**
   - Treatment details (type, cost, description) are stored in the `treatments` table.
   - Payment-related attributes (`payment_method`, `payment_status`) are stored in the `billing` table.

4. **Elimination of transitive dependency in billing**
   - The `billing` table does not store `patient_id`.
   - Patient information can be derived through:
     **billing → treatment → appointment → patient**
   - This ensures that all non-key attributes in `billing` depend only on `bill_id`, maintaining strict 3NF compliance.

---

## 4. Many-to-Many Resolution

There are no direct many-to-many relationships in the final schema.

The relationship between **patients** and **doctors** is naturally many-to-many:
- A patient can visit multiple doctors
- A doctor can see multiple patients

This is resolved through the **appointments** table, which acts as a bridge entity and converts the relationship into two one-to-many relationships.

---

## 5. Data Anomaly Prevention

| Anomaly Type | Prevention Strategy |
|-------------|-------------------|
| **Insertion Anomaly** | Doctors and patients can be inserted independently without requiring appointments |
| **Update Anomaly** | Patient and doctor details are stored in a single location, preventing inconsistent updates |
| **Deletion Anomaly** | Deleting a billing record does not remove treatment or patient data due to proper table separation |

---

## 6. Constraints Used

| Constraint | Location | Purpose |
|------------|----------|---------|
| PRIMARY KEY | All tables | Ensures each record is uniquely identifiable |
| FOREIGN KEY | appointments, treatments, billing | Maintains referential integrity |
| NOT NULL | Required columns | Prevents incomplete or invalid records |
| UNIQUE | email columns | Ensures no duplicate user accounts |
| CHECK | status, payment_status, cost, amount | Enforces valid domain values |
| DECIMAL(10,2) | cost, amount | Provides accurate financial precision |
| TIMESTAMPTZ | created_at | Stores timezone-aware timestamps |

---