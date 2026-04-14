
    
    

with all_values as (

    select
        age_group as value_field,
        count(*) as n_records

    from "neondb"."public_marts"."dim_patient"
    group by age_group

)

select *
from all_values
where value_field not in (
    'Pediatric','Young Adult','Middle Aged','Senior'
)


