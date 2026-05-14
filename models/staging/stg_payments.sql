with source as (
    select * from {{ ref('payments') }}
)

select
    payment_id,
    lesson_id,
    amount,
    cast(paid_at as timestamp) as paid_at,
    payment_method,
    status,
    cast(paid_at as date) as payment_date,
    case when status = 'paid' then amount else 0 end as confirmed_amount
from source
