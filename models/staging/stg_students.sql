with source as (
    select * from {{ ref('students') }}
)

select
    student_id,
    full_name,
    birth_year,
    grade,
    city,
    parent_contact,
    2026 - birth_year as age
from source
