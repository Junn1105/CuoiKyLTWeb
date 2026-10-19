$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
Set-Location $root
$release = Join-Path $root 'dist/MocSach-0.1.0'
if (Test-Path $release) { throw 'Release folder already exists; archive it before packaging again.' }
$reports = @(Get-ChildItem 'target/surefire-reports/TEST-*.xml')
if ($reports.Count -lt 2) { throw 'Run mvn clean verify first.' }
foreach ($report in $reports) {
    [xml]$result = Get-Content $report.FullName
    if ([int]$result.testsuite.failures -gt 0 -or [int]$result.testsuite.errors -gt 0) { throw 'Tests failed.' }
}
foreach ($dir in @('target','.local/native','tools','database','docs','test-results')) {
    New-Item -ItemType Directory -Force -Path (Join-Path $release $dir) | Out-Null
}
Copy-Item 'target/moc-sach.war' "$release/target/"
# Only this public native driver is copied from .local. Never copy local configuration.
Copy-Item '.local/native/mssql-jdbc_auth-13.2.1.x64.dll' "$release/.local/native/"
Copy-Item 'tools/start-app.ps1','tools/configure-gmail.ps1' "$release/tools/"
Copy-Item 'database/009-authentication.sql','database/010-book-reviews.sql','database/011-account-settings.sql','database/012-book-details.sql' "$release/database/"
Copy-Item 'docs/DangNhapVaGmail.md','docs/TrangChu.md','docs/TaiKhoan.md','docs/ChiTietSach.md','docs/home-preview.jpg' "$release/docs/"
Copy-Item 'target/surefire-reports/*.txt' "$release/test-results/"
Copy-Item 'docs/BanGiao.md' "$release/README.md"
@'
@echo off
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\start-app.ps1"
pause
'@ | Set-Content "$release/Chay-MocSach.cmd" -Encoding ASCII
Get-FileHash "$release/target/moc-sach.war" -Algorithm SHA256 | ForEach-Object { "$($_.Hash)  target/moc-sach.war" } | Set-Content "$release/SHA256SUMS.txt" -Encoding ASCII
Write-Host "Prepared $release. Smoke-test before creating the final ZIP."
