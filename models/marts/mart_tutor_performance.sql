-- Витрина: Эффективность репетиторов
-- Содержит агрегированную статистику по каждому репетитору:
-- количество уроков, доход, средний рейтинг, активность.
with tutors as (
    select * from {{ ref('stg_tutors') }}
),

subjects as (
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
        l.tutor_id,
        count(*)                                                        as total_lessons,
        count(case when l.status = 'completed' then 1 end)             as completed_lessons,
        count(case when l.status = 'cancelled' then 1 end)             as cancelled_lessons,
        count(distinct l.student_id)                                    as unique_students,
        sum(l.duration_minutes)                                         as total_minutes_taught,
        min(l.lesson_date)                                              as first_lesson_date,
        max(l.lesson_date)                                              as last_lesson_date
    from lessons l
    group by l.tutor_id
),

payment_stats as (
    select
        l.tutor_id,
        sum(p.confirmed_amount)                                         as total_revenue,
        avg(p.confirmed_amount)                                         as avg_lesson_revenue
    from lessons l
    join payments p on p.lesson_id = l.lesson_id
    where l.status = 'completed'
    group by l.tutor_id
),

review_stats as (
    select
        tutor_id,
        count(*)                                                        as total_reviews,
        round(avg(rating), 2)                                           as avg_rating,
        count(case when rating = 5 then 1 end)                         as five_star_reviews
    from reviews
    group by tutor_id
)

select
    t.tutor_id,
    t.full_name                                                         as tutor_name,
    s.subject_name,
    s.category                                                          as subject_category,
    t.experience_years,
    t.hourly_rate,
    t.city,
    t.is_active,
    coalesce(ls.total_lessons, 0)                                       as total_lessons,
    coalesce(ls.completed_lessons, 0)                                   as completed_lessons,
    coalesce(ls.cancelled_lessons, 0)                                   as cancelled_lessons,
    coalesce(ls.unique_students, 0)                                     as unique_students,
    coalesce(ls.total_minutes_taught, 0)                                as total_minutes_taught,
    round(coalesce(ls.total_minutes_taught, 0) / 60.0, 1)              as total_hours_taught,
    ls.first_lesson_date,
    ls.last_lesson_date,
    coalesce(ps.total_revenue, 0)                                       as total_revenue,
    coalesce(ps.avg_lesson_revenue, 0)                                  as avg_lesson_revenue,
    coalesce(rs.total_reviews, 0)                                       as total_reviews,
    coalesce(rs.avg_rating, 0)                                          as avg_rating,
    coalesce(rs.five_star_reviews, 0)                                   as five_star_reviews,
    case
        when coalesce(ls.total_lessons, 0) = 0 then 'Нет уроков'
        when coalesce(rs.avg_rating, 0) >= 4.5 and ls.completed_lessons >= 5 then 'Топ репетитор'
        when coalesce(rs.avg_rating, 0) >= 4.0 then 'Хороший репетитор'
        else 'Новый репетитор'
    end                                                                 as performance_tier
from tutors t
left join subjects s on s.subject_id = t.subject_id
left join lesson_stats ls on ls.tutor_id = t.tutor_id
left join payment_stats ps on ps.tutor_id = t.tutor_id
left join review_stats rs on rs.tutor_id = t.tutor_id
order by coalesce(rs.avg_rating, 0) desc, coalesce(ls.completed_lessons, 0) desc
