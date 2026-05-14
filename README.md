# Репетиторская платформа — dbt проект

**Лабораторная работа №3** по курсу «Большие данные» (МГИМО)  
Тема: автоматизация работы с хранилищами данных с использованием фреймворка dbt (data build tool)

---

## О проекте

Проект моделирует аналитическое хранилище данных для репетиторской платформы. Исходные данные содержат информацию о репетиторах, учениках, предметах, расписании занятий, оплате и отзывах. На их основе строятся витрины данных для аналитики.

**Стек:**
- [dbt-core 1.11](https://docs.getdbt.com/) — фреймворк трансформации данных
- [DuckDB](https://duckdb.org/) — встроенная аналитическая СУБД (сервер не требуется)

---

## Структура проекта

```
tutor_platform/
├── seeds/                        # Исходные данные (CSV)
│   ├── subjects.csv              # Предметы (10 записей)
│   ├── tutors.csv                # Репетиторы (10 записей)
│   ├── students.csv              # Ученики (12 записей)
│   ├── lessons.csv               # Занятия (30 записей)
│   ├── payments.csv              # Оплаты (29 записей)
│   └── reviews.csv               # Отзывы (23 записи)
│
├── models/
│   ├── staging/                  # Слой очистки и типизации (VIEW)
│   │   ├── stg_subjects.sql
│   │   ├── stg_tutors.sql
│   │   ├── stg_students.sql
│   │   ├── stg_lessons.sql
│   │   ├── stg_payments.sql
│   │   ├── stg_reviews.sql
│   │   └── schema.yml            # Документация и тесты
│   │
│   └── marts/                    # Витрины данных (TABLE)
│       ├── mart_tutor_performance.sql
│       ├── mart_student_progress.sql
│       ├── mart_lesson_schedule.sql
│       ├── mart_payment_summary.sql
│       ├── mart_subject_popularity.sql
│       └── schema.yml
│
├── dbt_project.yml               # Конфигурация проекта
└── run_dbt.bat                   # Скрипт автозапуска
```

---

## Установка и запуск

### 1. Установить зависимости

```bash
pip install dbt-duckdb
```

### 2. Создать профиль подключения

Создать файл `C:\Users\<ваш_пользователь>\.dbt\profiles.yml`:

```yaml
tutor_platform:
  target: dev
  outputs:
    dev:
      type: duckdb
      path: "C:/Pasha/MGIMO/dbt-lab/tutor_platform/tutor_platform.duckdb"
      threads: 1
```

### 3. Перейти в папку проекта

```bash
cd c:\Pasha\MGIMO\dbt-lab\tutor_platform
```

### 4. Запустить пайплайн

**Загрузить исходные данные из CSV:**
```bash
dbt seed
```

**Собрать все модели (витрины):**
```bash
dbt run
```

**Запустить тесты качества данных:**
```bash
dbt test
```

**Или всё сразу одной командой:**
```bash
dbt build
```

**Или через готовый скрипт:**
```bash
run_dbt.bat
```

---

## Витрины данных

### 1. `mart_tutor_performance` — Эффективность репетиторов

Агрегированная статистика по каждому репетитору.

| Поле | Описание |
|---|---|
| tutor_name | ФИО репетитора |
| subject_name | Преподаваемый предмет |
| completed_lessons | Количество проведённых занятий |
| unique_students | Количество уникальных учеников |
| total_hours_taught | Суммарное время занятий (часы) |
| total_revenue | Суммарный доход (руб.) |
| avg_rating | Средняя оценка от учеников |
| performance_tier | Категория: Топ репетитор / Хороший / Новый / Нет уроков |

**Пример результата:**

| tutor_name | subject_name | completed_lessons | avg_rating | total_revenue | performance_tier |
|---|---|---|---|---|---|
| Смирнова Ольга Николаевна | Английский язык | 6 | 5.0 | 18 000 ₽ | Топ репетитор |
| Иванов Алексей Петрович | Математика | 7 | 4.8 | 10 500 ₽ | Топ репетитор |
| Морозов Сергей Александрович | Информатика | 3 | 5.0 | 11 250 ₽ | Хороший репетитор |

---

### 2. `mart_student_progress` — Прогресс учеников

Статистика активности и расходов каждого ученика.

| Поле | Описание |
|---|---|
| student_name | ФИО ученика |
| grade | Класс |
| completed_lessons | Количество занятий |
| subjects_studied | Количество изученных предметов |
| total_hours | Суммарное время занятий (часы) |
| total_spent | Потраченная сумма (руб.) |
| favourite_subject | Самый посещаемый предмет |
| student_tier | Категория: Активный / Регулярный / Начинающий / Нет занятий |

**Пример результата:**

| student_name | grade | completed_lessons | total_spent | favourite_subject | student_tier |
|---|---|---|---|---|---|
| Петров Иван Андреевич | 9 | 5 | 7 500 ₽ | Математика | Регулярный ученик |
| Сидорова Анна Викторовна | 8 | 5 | 15 000 ₽ | Английский язык | Регулярный ученик |
| Соколов Никита Евгеньевич | 11 | 3 | 11 250 ₽ | Информатика | Начинающий |

---

### 3. `mart_lesson_schedule` — Журнал занятий

Детальный журнал всех занятий с информацией об участниках и оплате.

| Поле | Описание |
|---|---|
| lesson_date | Дата занятия |
| day_of_week_name | День недели (на русском) |
| tutor_name | ФИО репетитора |
| student_name | ФИО ученика |
| subject_name | Предмет |
| duration_minutes | Длительность (минуты) |
| status | Статус: completed / cancelled / scheduled |
| lesson_revenue | Выручка за занятие (руб.) |
| payment_method | Способ оплаты: card / cash |

---

### 4. `mart_payment_summary` — Финансовая аналитика

Сводка по платежам в разрезе месяца, репетитора, предмета и способа оплаты.

| Поле | Описание |
|---|---|
| payment_year / payment_month | Период |
| tutor_name | Репетитор |
| subject_name | Предмет |
| payment_method | Способ оплаты |
| payment_count | Количество платежей |
| net_revenue | Подтверждённая выручка (руб.) |
| refunded_amount | Возвраты (руб.) |
| avg_payment | Средний чек (руб.) |

---

### 5. `mart_subject_popularity` — Популярность предметов

Рейтинг предметов по востребованности на платформе.

**Пример результата:**

| popularity_rank | subject_name | category | completed_lessons | total_revenue |
|---|---|---|---|---|
| 1 | Математика | Точные науки | 9 | 12 700 ₽ |
| 2 | Английский язык | Иностранные языки | 8 | 24 600 ₽ |
| 3 | Физика | Точные науки | 3 | 5 400 ₽ |
| 3 | Информатика | Точные науки | 3 | 11 250 ₽ |

---

## Тесты качества данных

В проекте настроено **30 автоматических тестов**:

- **unique** — уникальность первичных ключей
- **not_null** — отсутствие пустых значений в обязательных полях
- **accepted_values** — допустимые значения для статусов и оценок

```bash
dbt test
# Done. PASS=30 WARN=0 ERROR=0 SKIP=0 TOTAL=30
```

---

## Автоматический запуск по расписанию

Скрипт `run_dbt.bat` зарегистрирован в Windows Task Scheduler и запускается **ежедневно в 07:00**. Лог каждого запуска сохраняется в `dbt_run.log`.

Управление задачей:
```powershell
# Запустить вручную
Start-ScheduledTask -TaskName "dbt_tutor_platform"

# Проверить статус
Get-ScheduledTaskInfo -TaskName "dbt_tutor_platform"

# Удалить задачу
Unregister-ScheduledTask -TaskName "dbt_tutor_platform"
```

---

## Просмотр результатов

```bash
# Предпросмотр в терминале
dbt show --select mart_tutor_performance

# Через Python
python -c "
import duckdb, sys
sys.stdout.reconfigure(encoding='utf-8')
con = duckdb.connect('tutor_platform.duckdb')
con.execute('SELECT * FROM main_marts.mart_tutor_performance').df().to_csv('result.csv', index=False)
"
```

Или открыть файл `tutor_platform.duckdb` в [DBeaver](https://dbeaver.io/) с драйвером DuckDB.
