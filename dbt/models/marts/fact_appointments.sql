with appointments as (select * from {{ ref('stg_appointments') }}),
     treatments  as (select * from {{ ref('stg_treatments') }}),
     billing     as (select * from {{ ref('stg_billing') }})
select
    a.appointment_id,
    a.patient_id,
    a.doctor_id,
    a.appointment_date,
    a.status,
    t.cost       as treatment_cost,
    b.amount     as billed_amount,
    b.payment_status
from appointments a
left join treatments t using (appointment_id)
left join billing   b using (treatment_id)