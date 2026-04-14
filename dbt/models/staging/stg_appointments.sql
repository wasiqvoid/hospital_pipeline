select
    appointment_id,
    patient_id,
    doctor_id,
    appointment_date,
    status
from {{ source('public', 'appointments') }}
where appointment_id is not null