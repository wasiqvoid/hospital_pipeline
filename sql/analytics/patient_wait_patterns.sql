with first_appointments as (
    select patient_id, min(appointment_date) as first_visit
    from appointments group by patient_id
),
patient_stats as (
    select
        p.patient_id,
        p.insurance_provider,
        fa.first_visit,
        count(a.appointment_id) as visit_count,
        sum(b.amount) as lifetime_value
    from patients p
    join first_appointments fa using (patient_id)
    join appointments a using (patient_id)
    left join treatments t using (appointment_id)
    left join billing b using (treatment_id)
    group by p.patient_id, p.insurance_provider, fa.first_visit
)
select *,
    ntile(4) over (order by lifetime_value desc) as value_quartile
from patient_stats;