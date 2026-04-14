with source as (
    select * from {{ source('hospital_raw', 'billing') }}
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