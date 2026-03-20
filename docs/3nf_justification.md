# EAS 550 — Phase 1: 3NF Justification Report
## Hospital Management Database Schema Design

## 1. Entities Identified

| Entity | Description |
|--------|-------------|
| **doctors** | Doctors specializations and branches |
| **patients** | Registered patients with demographics and insurance data |
| **appointments** | Appointment between a patient and doctor |
| **treatments** | Treatment provided during an apointment |
| **billing** | Billing data for treatment |

## 2. Relationships

- A doctor manages numerous **appointments** (one-to-many)
- A patient is associated with numerous **appointments** (one-to-many)
- An apointment is associated with numerous **treatments** (one-to-many)
- A treatment is associated with one **billing** (one-to-one)

## 3. Normalization Walkthrough

### First Normal Form (1NF)

All the tables are in 1NF since:
- All tables have a primary key.
- All tables do not have any repeating groups or array.
- All tables do not have any columns containing commaseparated values.

---

### Second Normal Form (2NF)

All the tables are in 2NF since:
- All tables have a primary key and it is a single column.
- All tables do not have any partial dependencies.
**Example improvement:**
In the raw data, `insurance_provider` and `insurance_number` were in the `appointments` data. These fields are for the patient and not the appointment. They should be in the `patients` table.

---

### Third Normal Form (3NF)

All tables are in 3NF:
- There are no transitive dependencies.
- Non-key attributes depend only on the primary key and not on other non-key attributes.

**Key design decisions:**

1. **Doctor information normalization**
   - Only the `doctors` table contains information such as `specialization` and `hospital_branch`.
   - Only the `appointments` table contains the `doctor_id` as a foreign key.

2. **Patient information normalization**
   - Patient information such as insurance details is stored in the `patients` table.
   - There is no duplication of information in the `appointments` table.
3. **Treatment and billing information normalization**
   - Treatment information such as type, cost, and description of treatment is stored in the `treatments` table.
   - Payment information such as `payment_method` and `payment_status` is stored in the `billing` table.

4. **Normalization of the billing table**
   - There is no `patient_id` in the `billing` table.
   - Patient information can be obtained from:
     **billing → treatment → appointment → patient**

## 4. Many-to-Many Resolution
There are no direct many-to-many relationships in the final schema.

The **patients** and **doctors** table relationship is a natural many-to-many relationship because:
- A patient can visit many doctors.
- A doctor can have many patients.
- 
This has been resolved by introducing the **appointments** table, which has created a one-to-many relationship between **patients** and **doctors**.

---

## 5. Prevention of Data Anomalies

| Type of Anomaly | Prevention Strategy |
|-----------------|---------------------|
| **Insertion Anomaly** | Doctor and patient can be inserted independently without the need for an appointment. |
| **Update Anomaly** | Patient and doctor information can be stored in a single table, thus preventing update anomalies. |
| **Deletion Anomaly** | Remove a billing entry will not remove treatment information due to proper table separation. |

## 6. Constraints Used

| Constraint | Location | Purpose |
|------------|----------|---------|
| PRIMARY KEY | All tables | Ensures each record is uniquely identifiable |
| FOREIGN KEY | appointments, treatments, billing | Maintains referential integrity |
| NOT NULL | Required columns | Prevents incomplete or invalid data |
| UNIQUE | email columns | Ensures no duplicate user accounts exist |
| CHECK | status, payment_status, cost, amount | Validates data against domain constraints |
| DECIMAL(10,2) | cost, amount | Ensures accurate financial calculations |
| TIMESTAMPTZ | created_at | Supports timezone-aware timestamps |

---
