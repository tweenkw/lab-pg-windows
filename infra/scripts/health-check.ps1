$Report = ".\infra\validation-report.txt"
$Psql   = "C:\Program Files\PostgreSQL\18\bin\psql.exe"
$Ready  = "C:\Program Files\PostgreSQL\18\bin\pg_isready.exe"
$env:PGPASSWORD = "5535"

Add-Content $Report ("Date: " + (Get-Date -Format "yyyy-MM-dd HH:mm:ss"))
Add-Content $Report ("User: " + $env:USERNAME)

$StatusOk = $true

$svc = Get-Service -Name "postgresql*" -ErrorAction SilentlyContinue
if ($svc -and $svc.Status -eq "Running") {
    Add-Content $Report "Service: Running"
} else {
    Add-Content $Report "Service: NOT RUNNING"
    $StatusOk = $false
}

& $Ready -h localhost -U postgres > $null 2>&1
if ($LASTEXITCODE -eq 0) {
    Add-Content $Report "pg_isready: OK (exit code 0)"
} else {
    Add-Content $Report "pg_isready: ERROR (exit code $LASTEXITCODE)"
    $StatusOk = $false
}

& $Psql -h localhost -U postgres -d test_lab -c "SELECT 1;" >> $Report 2>&1
if ($LASTEXITCODE -eq 0) {
    Add-Content $Report "Test query: OK"
} else {
    Add-Content $Report "Test query: ERROR"
    $StatusOk = $false
}

if ($StatusOk) {
    Add-Content $Report "Result: service is healthy"
    Write-Host "[health-check] OK" -ForegroundColor Green
    exit 0
} else {
    Add-Content $Report "Result: PROBLEMS DETECTED"
    Write-Host "[health-check] Problems found" -ForegroundColor Red
    exit 1
}