with source as (
    select * from {{ ref('subjects') }}
)

select
    subject_id,
    subject_name,
    category
from source
