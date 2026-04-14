
    select
      count(*) as failures,
      count(*) != 0 as should_warn,
      count(*) != 0 as should_error
    from (
      
    
  
    
    

select
    bill_id as unique_field,
    count(*) as n_records

from "neondb"."public"."billing"
where bill_id is not null
group by bill_id
having count(*) > 1



  
  
      
    ) dbt_internal_test