with source as (
    select * from {{ ref('lessons') }}
)

select
    lesson_id,
    tutor_id,
    student_id,
    subject_id,
    cast(scheduled_at as timestamp) as scheduled_at,
    duration_minutes,
    status,
    cast(scheduled_at as date)                           as lesson_date,
    extract(year from cast(scheduled_at as timestamp))   as lesson_year,
    extract(month from cast(scheduled_at as timestamp))  as lesson_month,
    extract(dow from cast(scheduled_at as timestamp))    as day_of_week
from source
