-- Витрина: Прогресс учеников
-- Агрегированная статистика по каждому ученику:
-- посещённые занятия, изученные предметы, потраченные средства, отзывы.
with students as (
    select * from {{ ref('stg_students') }}
),

lessons as (
    select * from {{ ref('stg_lessons') }}
),

subjects as (
    select * from {{ ref('stg_subjects') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
),

reviews as (
    select * from {{ ref('stg_reviews') }}
),

lesson_stats as (
    select
        l.student_id,
        count(*)                                                        as total_lessons,
        count(case when l.status = 'completed' then 1 end)             as completed_lessons,
        count(distinct l.tutor_id)                                      as unique_tutors,
        count(distinct l.subject_id)                                    as subjects_studied,
        sum(l.duration_minutes)                                         as total_minutes,
        min(l.lesson_date)                                              as first_lesson_date,
        max(l.lesson_date)                                              as last_lesson_date
    from lessons l
    group by l.student_id
),

payment_stats as (
    select
        l.student_id,
        sum(p.confirmed_amount)                                         as total_spent
    from lessons l
    join payments p on p.lesson_id = l.lesson_id
    where l.status = 'completed'
    group by l.student_id
),

review_stats as (
    select
        student_id,
        count(*)                                                        as reviews_written,
        round(avg(rating), 2)                                           as avg_rating_given
    from reviews
    group by student_id
),

top_subject as (
    select
        l.student_id,
        s.subject_name,
        count(*)                                                        as lesson_count,
        row_number() over (
            partition by l.student_id
            order by count(*) desc
        )                                                               as rn
    from lessons l
    join subjects s on s.subject_id = l.subject_id
    where l.status = 'completed'
    group by l.student_id, s.subject_name
)

select
    st.student_id,
    st.full_name                                                        as student_name,
    st.birth_year,
    st.age,
    st.grade,
    st.city,
    coalesce(ls.total_lessons, 0)                                       as total_lessons,
    coalesce(ls.completed_lessons, 0)                                   as completed_lessons,
    coalesce(ls.unique_tutors, 0)                                       as unique_tutors,
    coalesce(ls.subjects_studied, 0)                                    as subjects_studied,
    coalesce(ls.total_minutes, 0)                                       as total_minutes,
    round(coalesce(ls.total_minutes, 0) / 60.0, 1)                     as total_hours,
    ls.first_lesson_date,
    ls.last_lesson_date,
    coalesce(ps.total_spent, 0)                                         as total_spent,
    coalesce(rs.reviews_written, 0)                                     as reviews_written,
    coalesce(rs.avg_rating_given, 0)                                    as avg_rating_given,
    ts.subject_name                                                     as favourite_subject,
    case
        when coalesce(ls.completed_lessons, 0) >= 10 then 'Активный ученик'
        when coalesce(ls.completed_lessons, 0) >= 5  then 'Регулярный ученик'
        when coalesce(ls.completed_lessons, 0) >= 1  then 'Начинающий'
        else 'Нет занятий'
    end                                                                 as student_tier
from students st
left join lesson_stats ls on ls.student_id = st.student_id
left join payment_stats ps on ps.student_id = st.student_id
left join review_stats rs on rs.student_id = st.student_id
left join top_subject ts on ts.student_id = st.student_id and ts.rn = 1
order by coalesce(ls.completed_lessons, 0) desc
