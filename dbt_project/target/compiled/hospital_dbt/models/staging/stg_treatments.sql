-- models/staging/stg_treatments.sql

with source as (
    select * from "neondb"."public"."treatments"
)

select
    treatment_id,
    appointment_id,
    treatment_type,
    description,
    cost::decimal(10,2)                      as cost,
    treatment_date::date                     as treatment_date,
    to_char(treatment_date::date, 'YYYYMMDD')::int as date_key
from source
where treatment_id     is not null
  and appointment_id   is not null
  and cost             >= 0