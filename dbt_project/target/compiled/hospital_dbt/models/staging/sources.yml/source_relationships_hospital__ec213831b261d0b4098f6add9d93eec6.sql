
    
    

with child as (
    select treatment_id as from_field
    from "neondb"."public"."billing"
    where treatment_id is not null
),

parent as (
    select treatment_id as to_field
    from "neondb"."public"."treatments"
)

select
    from_field

from child
left join parent
    on child.from_field = parent.to_field

where parent.to_field is null


