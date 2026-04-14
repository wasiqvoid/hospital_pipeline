
    
    

select
    treatment_id as unique_field,
    count(*) as n_records

from "neondb"."public"."treatments"
where treatment_id is not null
group by treatment_id
having count(*) > 1


