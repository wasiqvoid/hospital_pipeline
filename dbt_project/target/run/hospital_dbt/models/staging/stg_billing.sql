
  create view "neondb"."public_staging"."stg_billing__dbt_tmp"
    
    
  as (
    with source as (
    select * from "neondb"."public"."billing"
)

select
    bill_id,
    patient_id,
    treatment_id,
    bill_date,
    amount         as billed_amount,
    payment_method,
    payment_status,
    created_at
from source
  );