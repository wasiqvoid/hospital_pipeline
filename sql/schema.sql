DROP TABLE IF EXISTS billing      CASCADE;
DROP TABLE IF EXISTS treatments   CASCADE;
DROP TABLE IF EXISTS appointments CASCADE;
DROP TABLE IF EXISTS patients     CASCADE;
DROP TABLE IF EXISTS doctors      CASCADE;

-- DOCTORS
CREATE TABLE doctors (
    doctor_id        VARCHAR(10) PRIMARY KEY,
    first_name       VARCHAR(100) NOT NULL,
    last_name        VARCHAR(100) NOT NULL,
    specialization   VARCHAR(100) NOT NULL,
    phone_number     VARCHAR(20),
    years_experience INT CHECK (years_experience >= 0),
    hospital_branch  VARCHAR(150),
    email            VARCHAR(200) NOT NULL UNIQUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- PATIENTS
CREATE TABLE patients (
    patient_id         VARCHAR(10) PRIMARY KEY,
    first_name         VARCHAR(100) NOT NULL,
    last_name          VARCHAR(100) NOT NULL,
    gender             VARCHAR(10) NOT NULL,
    date_of_birth      DATE NOT NULL,
    contact_number     VARCHAR(20),
    address            TEXT,
    registration_date  DATE,
    insurance_provider VARCHAR(150),
    insurance_number   VARCHAR(50),
    email              VARCHAR(200) NOT NULL UNIQUE,
    created_at         TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- APPOINTMENTS
CREATE TABLE appointments (
    appointment_id   VARCHAR(10) PRIMARY KEY,
    patient_id       VARCHAR(10) NOT NULL REFERENCES patients(patient_id) ON DELETE CASCADE,
    doctor_id        VARCHAR(10) NOT NULL REFERENCES doctors(doctor_id) ON DELETE RESTRICT,
    appointment_date DATE NOT NULL,
    appointment_time TIME,
    reason_for_visit VARCHAR(200),
    status VARCHAR(20) NOT NULL DEFAULT 'Scheduled'
        CHECK (status IN ('Scheduled','Completed','No-show','Cancelled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_appt_patient ON appointments(patient_id);
CREATE INDEX idx_appt_doctor  ON appointments(doctor_id);

-- TREATMENTS
CREATE TABLE treatments (
    treatment_id   VARCHAR(10) PRIMARY KEY,
    appointment_id VARCHAR(10) NOT NULL REFERENCES appointments(appointment_id) ON DELETE CASCADE,
    treatment_type VARCHAR(100) NOT NULL,
    description    TEXT,
    cost           DECIMAL(10,2) NOT NULL CHECK (cost >= 0),
    treatment_date DATE NOT NULL,
    created_at     TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_treat_appt ON treatments(appointment_id);

-- BILLING 
CREATE TABLE billing (
    bill_id        VARCHAR(10) PRIMARY KEY,
    treatment_id   VARCHAR(10) NOT NULL REFERENCES treatments(treatment_id) ON DELETE CASCADE,
    bill_date      DATE NOT NULL,
    amount         DECIMAL(10,2) NOT NULL CHECK (amount >= 0),
    payment_method VARCHAR(50),
    payment_status VARCHAR(20) NOT NULL DEFAULT 'Pending'
        CHECK (payment_status IN ('Pending','Paid','Partial','Waived')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_billing_treatment ON billing(treatment_id);
