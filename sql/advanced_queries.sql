
WITH doctor_revenue AS (
    SELECT
        d.doctor_id,
        d.first_name || ' ' || d.last_name      AS doctor_name,
        d.specialization,
        d.hospital_branch,
        COUNT(a.appointment_id)                  AS total_appointments,
        COUNT(CASE WHEN a.status = 'Completed'
                   THEN 1 END)                   AS completed_appointments,
        ROUND(SUM(b.amount)::NUMERIC, 2)         AS total_revenue,
        ROUND(AVG(b.amount)::NUMERIC, 2)         AS avg_revenue_per_visit
    FROM doctors        d
    LEFT JOIN appointments  a ON d.doctor_id    = a.doctor_id
    LEFT JOIN treatments    t ON a.appointment_id = t.appointment_id
    LEFT JOIN billing       b ON t.treatment_id = b.treatment_id
    WHERE b.payment_status = 'Paid'
    GROUP BY d.doctor_id, d.first_name, d.last_name, d.specialization, d.hospital_branch
)

SELECT
    doctor_name,
    specialization,
    hospital_branch,
    total_appointments,
    completed_appointments,
    total_revenue,
    avg_revenue_per_visit,
    -- Rank within specialization by revenue
    RANK() OVER (
        PARTITION BY specialization
        ORDER BY total_revenue DESC
    )                                            AS revenue_rank_in_specialization,
    ROUND(
        100.0 * PERCENT_RANK() OVER (
            ORDER BY total_revenue
        )::NUMERIC, 1
    )                                            AS revenue_percentile
FROM doctor_revenue
ORDER BY total_revenue DESC;


-- ─────────────────────────────────────────
-- QUERY 2: Monthly Revenue Trend
-- with Rolling 3-Month Average
-- Uses: CTE + LAG() + rolling window frame
-- ─────────────────────────────────────────
WITH monthly_stats AS (
    SELECT
        DATE_TRUNC('month', b.bill_date)::date   AS bill_month,
        COUNT(DISTINCT b.bill_id)                AS total_bills,
        COUNT(DISTINCT b.patient_id)             AS unique_patients,
        ROUND(SUM(b.amount)::NUMERIC, 2)         AS total_billed,
        ROUND(SUM(CASE WHEN b.payment_status = 'Paid'
                       THEN b.amount ELSE 0 END)::NUMERIC, 2) AS collected,
        ROUND(SUM(CASE WHEN b.payment_status = 'Pending'
                       THEN b.amount ELSE 0 END)::NUMERIC, 2) AS pending
    FROM billing b
    GROUP BY DATE_TRUNC('month', b.bill_date)
)

SELECT
    bill_month,
    total_bills,
    unique_patients,
    total_billed,
    collected,
    pending,
    -- Month-over-month change
    ROUND(
        total_billed - LAG(total_billed) OVER (ORDER BY bill_month)
    , 2)                                         AS mom_change,
    -- Rolling 3-month average
    ROUND(AVG(total_billed) OVER (
        ORDER BY bill_month
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    )::NUMERIC, 2)                               AS rolling_3mo_avg,
    -- Cumulative revenue for the year
    ROUND(SUM(total_billed) OVER (
        ORDER BY bill_month
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )::NUMERIC, 2)                               AS cumulative_revenue
FROM monthly_stats
ORDER BY bill_month;


-- ─────────────────────────────────────────
-- QUERY 3: Patient Treatment History
-- Full journey per patient with running total cost
-- Uses: CTE + ROW_NUMBER() + SUM() running total
-- ─────────────────────────────────────────
WITH patient_journey AS (
    SELECT
        p.patient_id,
        p.first_name || ' ' || p.last_name      AS patient_name,
        p.insurance_provider,
        a.appointment_id,
        a.appointment_date::date                 AS visit_date,
        a.reason_for_visit,
        a.status                                 AS appointment_status,
        t.treatment_type,
        t.cost                                   AS treatment_cost,
        b.payment_status,
        b.payment_method
    FROM patients       p
    JOIN appointments   a ON p.patient_id    = a.patient_id
    LEFT JOIN treatments t ON a.appointment_id = t.appointment_id
    LEFT JOIN billing    b ON t.treatment_id  = b.treatment_id
)

SELECT
    patient_id,
    patient_name,
    insurance_provider,
    visit_date,
    reason_for_visit,
    appointment_status,
    treatment_type,
    treatment_cost,
    payment_status,
    payment_method,
    -- Visit number for this patient
    ROW_NUMBER() OVER (
        PARTITION BY patient_id
        ORDER BY visit_date
    )                                            AS visit_number,
    -- Running total spend per patient
    ROUND(SUM(treatment_cost) OVER (
        PARTITION BY patient_id
        ORDER BY visit_date
        ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
    )::NUMERIC, 2)                               AS running_total_cost,
    -- Average cost across all their visits
    ROUND(AVG(treatment_cost) OVER (
        PARTITION BY patient_id
    )::NUMERIC, 2)                               AS avg_cost_per_visit
FROM patient_journey
ORDER BY patient_id, visit_date;


-- ─────────────────────────────────────────
-- QUERY 4: No-Show Rate by Doctor & Month
-- Uses: CTE + ROUND + conditional aggregation
-- ─────────────────────────────────────────
WITH monthly_noshow AS (
    SELECT
        d.first_name || ' ' || d.last_name      AS doctor_name,
        d.specialization,
        DATE_TRUNC('month', a.appointment_date::date)::date AS month,
        COUNT(*)                                 AS total_appointments,
        COUNT(CASE WHEN a.status = 'No-show'
                   THEN 1 END)                   AS no_shows,
        COUNT(CASE WHEN a.status = 'Completed'
                   THEN 1 END)                   AS completed
    FROM doctors        d
    JOIN appointments   a ON d.doctor_id = a.doctor_id
    GROUP BY d.first_name, d.last_name, d.specialization,
             DATE_TRUNC('month', a.appointment_date::date)
)

SELECT
    doctor_name,
    specialization,
    month,
    total_appointments,
    no_shows,
    completed,
    ROUND(100.0 * no_shows / NULLIF(total_appointments, 0), 1) AS no_show_rate_pct,
    -- Rank months by no-show rate per doctor
    RANK() OVER (
        PARTITION BY doctor_name
        ORDER BY no_shows DESC
    )                                            AS worst_month_rank
FROM monthly_noshow
ORDER BY no_show_rate_pct DESC, month;
