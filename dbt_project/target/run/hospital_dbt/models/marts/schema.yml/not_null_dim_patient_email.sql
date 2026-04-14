
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select email
from "neondb"."public_marts"."dim_patient"
where email is null



  
  
      
    ) dbt_internal_test