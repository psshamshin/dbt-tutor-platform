with source as (
    select * from {{ ref('tutors') }}
)

select
    tutor_id,
    full_name,
    subject_id,
    experience_years,
    hourly_rate,
    city,
    cast(is_active as boolean) as is_active
from source
