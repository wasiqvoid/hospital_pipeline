
    
    

select
    bill_id as unique_field,
    count(*) as n_records

from "neondb"."public"."billing"
where bill_id is not null
group by bill_id
having count(*) > 1


