-- models/marts/dim_doctor.sql
-- Doctor dimension with specialization and experience band.

with doctors as (
    select * from {{ source('hospital_raw', 'doctors') }}
)

select
    doctor_id,
    first_name,
    last_name,
    first_name || ' ' || last_name      as full_name,
    specialization,
    hospital_branch,
    years_experience,
    case
        when years_experience < 5   then 'Junior'
        when years_experience < 15  then 'Mid-Level'
        else 'Senior'
    end                                 as experience_band,
    email
from doctors
