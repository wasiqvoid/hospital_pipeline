
    
    

select
    email as unique_field,
    count(*) as n_records

from "neondb"."public"."doctors"
where email is not null
group by email
having count(*) > 1


