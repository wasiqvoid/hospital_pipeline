with doctor_revenue as (
    select
        d.doctor_id,
        d.first_name || ' ' || d.last_name as doctor_name,
        d.specialization,
        sum(b.amount) as total_revenue,
        count(a.appointment_id) as total_appointments,
        round(sum(b.amount) / nullif(count(a.appointment_id), 0), 2) as revenue_per_visit
    from doctors d
    join appointments a using (doctor_id)
    join treatments  t using (appointment_id)
    join billing     b using (treatment_id)
    where b.payment_status = 'Paid'
    group by d.doctor_id, doctor_name, d.specialization
)
select *,
    rank() over (partition by specialization order by total_revenue desc) as rank_in_specialization
from doctor_revenue
order by total_revenue desc;
