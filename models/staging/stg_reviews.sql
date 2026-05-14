with source as (
    select * from {{ ref('reviews') }}
)

select
    review_id,
    lesson_id,
    student_id,
    tutor_id,
    rating,
    comment,
    cast(created_at as timestamp) as created_at
from source
