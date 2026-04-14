
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

with all_values as (

    select
        specialization as value_field,
        count(*) as n_records

    from "neondb"."public"."doctors"
    group by specialization

)

select *
from all_values
where value_field not in (
    'Dermatology','Pediatrics','Oncology'
)



  
  
      
    ) dbt_internal_test