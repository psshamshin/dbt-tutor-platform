-- Витрина: Популярность предметов
-- Рейтинг предметов по количеству занятий, выручке и средней оценке репетиторов.
with subjects as (
    select * from {{ ref('stg_subjects') }}
),

lessons as (
    select * from {{ ref('stg_lessons') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

reviews as (
    select * from {{ ref('stg_reviews') }}
),

lesson_stats as (
    select
        l.subject_id,
        count(*)                                                        as total_lessons,
        count(case when l.status = 'completed' then 1 end)             as completed_lessons,
        count(distinct l.tutor_id)                                      as active_tutors,
        count(distinct l.student_id)                                    as active_students,
        sum(l.duration_minutes)                                         as total_minutes
    from lessons l
    group by l.subject_id
),

payment_stats as (
    select
        l.subject_id,
        sum(p.confirmed_amount)                                         as total_revenue
    from lessons l
    join payments p on p.lesson_id = l.lesson_id
    where l.status = 'completed'
    group by l.subject_id
),

review_stats as (
    select
        l.subject_id,
        round(avg(r.rating), 2)                                         as avg_rating,
        count(r.review_id)                                              as total_reviews
    from lessons l
    join reviews r on r.lesson_id = l.lesson_id
    group by l.subject_id
)

select
    s.subject_id,
    s.subject_name,
    s.category,
    coalesce(ls.total_lessons, 0)                                       as total_lessons,
    coalesce(ls.completed_lessons, 0)                                   as completed_lessons,
    coalesce(ls.active_tutors, 0)                                       as active_tutors,
    coalesce(ls.active_students, 0)                                     as active_students,
    coalesce(ls.total_minutes, 0)                                       as total_minutes,
    coalesce(ps.total_revenue, 0)                                       as total_revenue,
    coalesce(rs.avg_rating, 0)                                          as avg_rating,
    coalesce(rs.total_reviews, 0)                                       as total_reviews,
    rank() over (order by coalesce(ls.completed_lessons, 0) desc)      as popularity_rank
from subjects s
left join lesson_stats ls on ls.subject_id = s.subject_id
left join payment_stats ps on ps.subject_id = s.subject_id
left join review_stats rs on rs.subject_id = s.subject_id
order by popularity_rank
