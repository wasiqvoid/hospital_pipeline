
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
