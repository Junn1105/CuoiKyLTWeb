param(
    [string]$Server = 'localhost',
    [string]$Database = 'WebsiteQuanLyCuaHangSachCu'
)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location $projectRoot

Write-Host "=== Khoi tao Database [$Database] tren SQL Server ($Server) ===" -ForegroundColor Cyan

$scripts = @(
    'database/000-init-base-catalog.sql',
    'database/002-create-core-tables.sql',
    'database/004-seed-demo-data.sql',
    'database/008-rename-demo-accounts.sql',
    'database/009-authentication.sql',
    'database/010-book-reviews.sql',
    'database/011-account-settings.sql',
    'database/012-book-details.sql',
    'database/013-seed-reviews-and-notifications.sql',
    'database/014-seed-staff-admin-roles.sql'
)

sqlcmd -S $Server -d master -E -b -I -Q "IF DB_ID(N'$Database') IS NULL CREATE DATABASE [$Database];"
if ($LASTEXITCODE -ne 0) {
    throw "Khong the ket noi hoac tao database [$Database] tren $Server."
}

foreach ($script in $scripts) {
    if (-not (Test-Path -LiteralPath $script)) { continue }
    Write-Host "-> Dang chay $script ..." -ForegroundColor Yellow
    if ($script -like '*000-init-base-catalog.sql') {
        $hasCategories = sqlcmd -S $Server -d $Database -E -h -1 -W -Q "SET NOCOUNT ON; SELECT CASE WHEN OBJECT_ID(N'dbo.Categories', N'U') IS NOT NULL THEN 1 ELSE 0 END;"
        if (($hasCategories | Out-String).Trim() -eq '1') {
            Write-Host "   (Bo qua 000-init-base-catalog.sql vi bang danh muc da ton tai)" -ForegroundColor DarkGray
            continue
        }
    }
    if ($script -like '*002-create-core-tables.sql') {
        $hasStores = sqlcmd -S $Server -d $Database -E -h -1 -W -Q "SET NOCOUNT ON; SELECT CASE WHEN OBJECT_ID(N'dbo.Stores', N'U') IS NOT NULL THEN 1 ELSE 0 END;"
        if (($hasStores | Out-String).Trim() -eq '1') {
            Write-Host "   (Bo qua 002-create-core-tables.sql vi cac bang nghiep vu da ton tai)" -ForegroundColor DarkGray
            continue
        }
    }
    sqlcmd -S $Server -d $Database -E -b -I -f 65001 -i $script
    if ($LASTEXITCODE -ne 0) {
        throw "Loi khi chay script: $script"
    }
}

Write-Host "=== Hoan tat cai dat Database [$Database] thanh cong! ===" -ForegroundColor Green
Write-Host "Tai khoan dang nhap mau (mat khau chung: 123456):"
Write-Host " - Admin : admin / sang"
Write-Host " - Staff : staff / manager"
Write-Host " - Khach : khang / hoang / van"
