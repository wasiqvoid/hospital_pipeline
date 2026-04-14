-- models/marts/fact_appointments.sql
-- Central fact table of the Star Schema.
-- Grain: one row per appointment.

with appointments as (
    select * from {{ ref('stg_appointments') }}
),

treatments as (
    select * from {{ ref('stg_treatments') }}
),

billing as (
    select * from {{ ref('stg_billing') }}
)

select
    -- Keys
    a.appointment_id,
    a.patient_id,
    a.doctor_id,

    -- Descriptive
    a.appointment_date,
    a.appointment_time,
    a.reason_for_visit,
    a.status,
    t.treatment_type,
    t.description                               as treatment_description,

    -- Flags (computed here)
    case when a.status = 'Completed'  then true else false end  as is_completed,
    case when a.status = 'No-show'    then true else false end  as is_no_show,
    case when b.payment_status = 'Paid'    then true else false end as is_paid,
    case when b.payment_status = 'Pending' then true else false end as is_pending,
    case when b.payment_status = 'Failed'  then true else false end as is_failed,

    -- Measures
    t.cost                                      as treatment_cost,
    b.billed_amount,
    b.payment_method,
    b.payment_status,

    -- Date parts
    extract(year  from a.appointment_date)::int as appt_year,
    extract(month from a.appointment_date)::int as appt_month,
    extract(dow   from a.appointment_date)::int as appt_dow

from appointments   a
left join treatments t using (appointment_id)
left join billing    b using (treatment_id)