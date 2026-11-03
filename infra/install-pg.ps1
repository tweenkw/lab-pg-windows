# Установка не выполняется этим скриптом: в Windows установка PostgreSQL — через инсталлятор.
# Здесь мы фиксируем шаги инициализации и создания объектов БД через psql.

$PG_BIN = "C:\Program Files\PostgreSQL\15\bin"
$PSQL   = "$PG_BIN\psql.exe"
$DB_NAME = "test_lab"
$USER    = "postgres"

# Создать базу данных
& $PSQL -U $USER -c "CREATE DATABASE $DB_NAME;"

# Создать тестового пользователя (если нужно)
& $PSQL -U $USER -d $DB_NAME -c "CREATE USER IF NOT EXISTS lab_user WITH PASSWORD 'lab_password';"

Write-Host "База данных $DB_NAME создана."