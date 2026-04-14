
    
    

with all_values as (

    select
        treatment_type as value_field,
        count(*) as n_records

    from "neondb"."public_marts"."fact_appointments"
    group by treatment_type

)

select *
from all_values
where value_field not in (
    'Chemotherapy','MRI','ECG','Physiotherapy','X-Ray'
)


