-- models/marts/dim_patient.sql
-- Patient dimension with demographics and age groupings.

with patients as (
    select * from {{ source('hospital_raw', 'patients') }}
)

select
    patient_id,
    first_name,
    last_name,
    first_name || ' ' || last_name              as full_name,
    gender,
    date_of_birth::date                         as date_of_birth,
    date_part('year', age(date_of_birth::date))::int as age_years,
    case
        when date_part('year', age(date_of_birth::date)) < 18  then 'Pediatric'
        when date_part('year', age(date_of_birth::date)) < 40  then 'Young Adult'
        when date_part('year', age(date_of_birth::date)) < 65  then 'Middle Aged'
        else 'Senior'
    end                                         as age_group,
    insurance_provider,
    insurance_number,
    registration_date::date                     as registration_date,
    email
from patients
