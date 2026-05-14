-- Витрина: Сводка по оплатам
-- Финансовая аналитика платформы: выручка по месяцам, репетиторам и способам оплаты.
with payments as (
    select * from {{ ref('stg_payments') }}
),

lessons as (
    select * from {{ ref('stg_lessons') }}
),

tutors as (
    select * from {{ ref('stg_tutors') }}
),

subjects as (
    select * from {{ ref('stg_subjects') }}
),

combined as (
    select
        p.payment_id,
        p.payment_date,
        extract(year from p.payment_date)                               as payment_year,
        extract(month from p.payment_date)                              as payment_month,
        p.amount,
        p.confirmed_amount,
        p.payment_method,
        p.status                                                        as payment_status,
        l.tutor_id,
        t.full_name                                                     as tutor_name,
        t.city,
        sub.subject_name,
        sub.category                                                    as subject_category,
        l.duration_minutes
    from payments p
    join lessons l on l.lesson_id = p.lesson_id
    join tutors t on t.tutor_id = l.tutor_id
    join subjects sub on sub.subject_id = l.subject_id
)

select
    payment_year,
    payment_month,
    tutor_name,
    city,
    subject_name,
    subject_category,
    payment_method,
    count(*)                                                            as payment_count,
    sum(amount)                                                         as gross_amount,
    sum(confirmed_amount)                                               as net_revenue,
    sum(amount) - sum(confirmed_amount)                                 as refunded_amount,
    round(avg(confirmed_amount), 2)                                     as avg_payment,
    sum(duration_minutes)                                               as total_minutes_paid
from combined
group by
    payment_year,
    payment_month,
    tutor_name,
    city,
    subject_name,
    subject_category,
    payment_method
order by payment_year, payment_month, net_revenue desc
