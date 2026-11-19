param(
    [string]$DbHost = "localhost",
    [string]$DbUser = "postgres",
    [string]$DbPassword = "5535",
    [string]$DbName = "test_lab",
    [string]$MigrationsDir = ".\db\migrations"
)

$PsqlPath = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$PgIsReadyPath = "C:\Program Files\PostgreSQL\18\bin\pg_isready.exe"
$env:PGPASSWORD = $DbPassword

Write-Host "[1/4] Searching for dangerous commands..."
$dangerous = Get-ChildItem -Path "$MigrationsDir\*.sql" -ErrorAction SilentlyContinue |
    Select-String -Pattern "DROP|TRUNCATE|DELETE\s+FROM" -CaseSensitive:$false

if ($dangerous) {
    Write-Host "ERROR: Potentially dangerous commands found:" -ForegroundColor Red
    $dangerous | ForEach-Object {
        Write-Host " - $($_.Path): line $($_.LineNumber)"
    }
    exit 1
} else {
    Write-Host "OK: No dangerous commands found." -ForegroundColor Green
}

Write-Host "[2/4] Checking SQL syntax..."
Get-ChildItem -Path "$MigrationsDir\*.sql" -ErrorAction SilentlyContinue |
ForEach-Object {
    $file = $_.FullName
    Write-Host "  Checking: $file"
    & $PsqlPath -h $DbHost -U $DbUser -d $DbName -f $file -v ON_ERROR_STOP=1 >$null 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "    OK: Syntax is correct." -ForegroundColor Green
    } else {
        Write-Host "    ERROR: Syntax error (exit code: $LASTEXITCODE)." -ForegroundColor Red
        exit 1
    }
}

Write-Host "[3/4] Checking service status..."
$service = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
if ($service -and $service.Status -eq "Running") {
    Write-Host "OK: PostgreSQL service is running." -ForegroundColor Green
} else {
    Write-Host "ERROR: Service is not running or not found." -ForegroundColor Red
    exit 1
}

Write-Host "[4/4] Checking connection..."
& $PgIsReadyPath -h $DbHost -U $DbUser >$null 2>&1
if ($LASTEXITCODE -eq 0) {
    Write-Host "OK: Server is accepting connections." -ForegroundColor Green
} else {
    Write-Host "ERROR: Server is not accepting connections (exit code: $LASTEXITCODE)." -ForegroundColor Red
    exit 1
}

Write-Host "Validation completed successfully" -ForegroundColor Cyan