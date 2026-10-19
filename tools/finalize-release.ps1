$ErrorActionPreference = 'Stop'
$root = Split-Path $PSScriptRoot -Parent
$release = Join-Path $root 'dist/MocSach-0.1.0'
$smoke = Join-Path $release 'test-results/war-smoke.txt'
if (-not (Test-Path $smoke) -or -not ((Get-Content $smoke -Raw).Contains('PASS: Logout redirects to login'))) { throw 'WAR smoke test must pass first.' }
$files = @(Get-ChildItem $release -Recurse -File -Force)
foreach ($file in $files) {
    $relative = $file.FullName.Substring($release.Length + 1).Replace('\','/')
    if ($relative -like '.local/*' -and $relative -ne '.local/native/mssql-jdbc_auth-13.2.1.x64.dll') { throw "Private local file: $relative" }
    if ($file.Name -match '^(mail|application)\.properties$|^\.env') { throw 'Private configuration detected.' }
}
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = Join-Path $root 'dist/MocSach-0.1.0.zip'
if (Test-Path $zip) { throw 'ZIP already exists.' }
[IO.Compression.ZipFile]::CreateFromDirectory($release, $zip, [IO.Compression.CompressionLevel]::Optimal, $true)
$archive = [IO.Compression.ZipFile]::OpenRead($zip)
try {
    if (@($archive.Entries | Where-Object { $_.Length -gt 0 }).Count -ne $files.Count) { throw 'ZIP file count mismatch.' }
    $entry = $archive.GetEntry('MocSach-0.1.0/target/moc-sach.war')
    if (-not $entry) { throw 'WAR missing from ZIP.' }
    $stream = $entry.Open()
    $sha = [Security.Cryptography.SHA256]::Create()
    try { $hash = [BitConverter]::ToString($sha.ComputeHash($stream)).Replace('-','') }
    finally { $stream.Dispose(); $sha.Dispose() }
    if ($hash -ne (Get-FileHash "$release/target/moc-sach.war").Hash) { throw 'WAR integrity mismatch.' }
} finally { $archive.Dispose() }
Get-FileHash $zip -Algorithm SHA256 | ForEach-Object { "$($_.Hash)  MocSach-0.1.0.zip" } | Set-Content "$zip.sha256" -Encoding ASCII
Get-Item $zip | Select-Object FullName, Length
