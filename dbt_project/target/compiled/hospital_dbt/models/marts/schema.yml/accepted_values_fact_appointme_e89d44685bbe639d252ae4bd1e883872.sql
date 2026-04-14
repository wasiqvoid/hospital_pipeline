
    
    

with all_values as (

    select
        payment_status as value_field,
        count(*) as n_records

    from "neondb"."public_marts"."fact_appointments"
    group by payment_status

)

select *
from all_values
where value_field not in (
    'Pending','Paid','Failed','None'
)


