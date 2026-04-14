
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    



select specialization
from "neondb"."public"."doctors"
where specialization is null



  
  
      
    ) dbt_internal_test