
    
    

with all_values as (

    select
        status as value_field,
        count(*) as n_records

    from "neondb"."public_marts"."fact_appointments"
    group by status

)

select *
from all_values
where value_field not in (
    'Scheduled','Completed','No-show','Cancelled'
)


