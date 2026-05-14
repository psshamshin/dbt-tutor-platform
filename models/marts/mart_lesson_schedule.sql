-- Витрина: Расписание и статистика занятий
-- Детальный журнал занятий с информацией о репетиторе, ученике и предмете.
with lessons as (
    select * from {{ ref('stg_lessons') }}
),

tutors as (
    select * from {{ ref('stg_tutors') }}
),

students as (
    select * from {{ ref('stg_students') }}
),

subjects as (
    select * from {{ ref('stg_subjects') }}
),

payments as (
    select * from {{ ref('stg_payments') }}
)

select
    l.lesson_id,
    l.scheduled_at,
    l.lesson_date,
    l.lesson_year,
    l.lesson_month,
    case l.day_of_week
        when 0 then 'Воскресенье'
        when 1 then 'Понедельник'
        when 2 then 'Вторник'
        when 3 then 'Среда'
        when 4 then 'Четверг'
        when 5 then 'Пятница'
        when 6 then 'Суббота'
    end                                                                 as day_of_week_name,
    t.full_name                                                         as tutor_name,
    t.city                                                              as tutor_city,
    s.full_name                                                         as student_name,
    s.grade                                                             as student_grade,
    sub.subject_name,
    sub.category                                                        as subject_category,
    l.duration_minutes,
    l.status,
    coalesce(p.confirmed_amount, 0)                                     as lesson_revenue,
    p.payment_method,
    p.status                                                            as payment_status
from lessons l
left join tutors t on t.tutor_id = l.tutor_id
left join students s on s.student_id = l.student_id
left join subjects sub on sub.subject_id = l.subject_id
left join payments p on p.lesson_id = l.lesson_id
order by l.scheduled_at
