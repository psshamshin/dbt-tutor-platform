@echo off
cd /d "c:\Pasha\MGIMO\dbt-lab\tutor_platform"

echo [%DATE% %TIME%] === Запуск пайплайна dbt: Репетиторская платформа ===

echo [%DATE% %TIME%] Шаг 1: Загрузка исходных данных (seed)...
dbt seed --full-refresh
if %errorlevel% neq 0 (
    echo [%DATE% %TIME%] ОШИБКА при загрузке seeds! Прерывание.
    exit /b 1
)

echo [%DATE% %TIME%] Шаг 2: Сборка моделей...
dbt run
if %errorlevel% neq 0 (
    echo [%DATE% %TIME%] ОШИБКА при сборке моделей! Прерывание.
    exit /b 1
)

echo [%DATE% %TIME%] Шаг 3: Запуск тестов качества данных...
dbt test
if %errorlevel% neq 0 (
    echo [%DATE% %TIME%] ПРЕДУПРЕЖДЕНИЕ: Тесты не прошли!
    exit /b 1
)

echo [%DATE% %TIME%] === Пайплайн завершён успешно ===
