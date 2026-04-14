
    
    

with child as (
    select appointment_id as from_field
    from "neondb"."public"."treatments"
    where appointment_id is not null
),

parent as (
    select appointment_id as to_field
    from "neondb"."public"."appointments"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


