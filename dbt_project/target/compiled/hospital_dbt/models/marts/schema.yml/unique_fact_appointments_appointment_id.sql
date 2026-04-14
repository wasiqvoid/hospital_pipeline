
    
    

select
    appointment_id as unique_field,
    count(*) as n_records

from "neondb"."public_marts"."fact_appointments"
where appointment_id is not null
group by appointment_id
having count(*) > 1


