-- models/staging/stg_appointments.sql
-- Cleans and standardises appointments for the mart layer.

with source as (
    select * from {{ source('hospital_raw', 'appointments') }}
),

cleaned as (
    select
        appointment_id,
        patient_id,
        doctor_id,
        appointment_date::date                          as appointment_date,
        appointment_time::time                          as appointment_time,
        reason_for_visit,
        status,

        -- Derived date parts for dim_date join
        to_char(appointment_date::date, 'YYYYMMDD')::int as date_key,

        -- Flag completed visits
        (status = 'Completed')                          as is_completed,
        (status = 'No-show')                            as is_no_show,

        extract(month from appointment_date::date)::int as appt_month,
        extract(dow   from appointment_date::date)::int as appt_dow,
        extract(year  from appointment_date::date)::int as appt_year
    from source
    where appointment_id is not null
      and patient_id     is not null
      and doctor_id      is not null
)

select * from cleaned
