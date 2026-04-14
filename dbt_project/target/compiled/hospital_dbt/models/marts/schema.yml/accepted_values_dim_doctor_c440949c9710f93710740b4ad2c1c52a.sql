
    
    

with all_values as (

    select
        specialization as value_field,
        count(*) as n_records

    from "neondb"."public_marts"."dim_doctor"
    group by specialization

)

select *
from all_values
where value_field not in (
    'Dermatology','Pediatrics','Oncology'
)


