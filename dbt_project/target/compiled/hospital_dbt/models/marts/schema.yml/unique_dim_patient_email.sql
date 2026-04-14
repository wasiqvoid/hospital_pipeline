
    
    

select
    email as unique_field,
    count(*) as n_records

from "neondb"."public_marts"."dim_patient"
where email is not null
group by email
having count(*) > 1


