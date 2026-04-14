
    
    

with all_values as (

    select
        payment_method as value_field,
        count(*) as n_records

    from "neondb"."public"."billing"
    group by payment_method

)

select *
from all_values
where value_field not in (
    'Insurance','Credit Card','Cash'
)


