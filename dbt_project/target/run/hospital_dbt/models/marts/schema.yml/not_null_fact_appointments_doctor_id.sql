
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select doctor_id
from "neondb"."public_marts"."fact_appointments"
where doctor_id is null



  
  
      
    ) dbt_internal_test