param([switch]$Build, [string]$JavaHome = $env:JAVA_HOME, [string]$MavenCommand = 'mvn')
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
Set-Location $projectRoot
$candidates = @($JavaHome, 'D:/IntelliJ IDEA 2026.2.1/jbr', 'C:/Program Files/Java/jdk-21')
$java = $null
foreach ($candidate in $candidates) {
    if (-not $candidate) { continue }
    $executable = Join-Path $candidate 'bin/java.exe'
    if (Test-Path -LiteralPath $executable) {
        & $executable --version | Out-Null
        if ($LASTEXITCODE -eq 0) { $java = $executable; $env:JAVA_HOME = $candidate; break }
    }
}
if (-not $java) { throw 'Can JDK 21 hoac 25 hoat dong. Truyen -JavaHome duong-dan-JDK.' }
$localDir = Join-Path $projectRoot '.local'
$nativeDir = Join-Path $localDir 'native'
New-Item -ItemType Directory -Force -Path $nativeDir | Out-Null
$secretFile = Join-Path $localDir 'application.properties'
if (-not (Test-Path -LiteralPath $secretFile)) {
    $bytes = New-Object byte[] 48
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    try { $rng.GetBytes($bytes) } finally { $rng.Dispose() }
    [IO.File]::WriteAllText($secretFile, 'app.auth.secret=' + [Convert]::ToBase64String($bytes), [Text.UTF8Encoding]::new($false))
}
$nativeDll = Join-Path $nativeDir 'mssql-jdbc_auth-13.2.1.x64.dll'
if (-not (Test-Path -LiteralPath $nativeDll)) {
    Invoke-WebRequest -UseBasicParsing 'https://repo.maven.apache.org/maven2/com/microsoft/sqlserver/mssql-jdbc_auth/13.2.1.x64/mssql-jdbc_auth-13.2.1.x64.dll' -OutFile $nativeDll
}
if ($Build -or -not (Test-Path 'target/moc-sach.war')) {
    if (-not (Get-Command $MavenCommand -ErrorAction SilentlyContinue)) {
        $cached = Get-ChildItem (Join-Path $env:USERPROFILE '.m2/wrapper/dists') -Filter mvn.cmd -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1
        if (-not $cached) { throw 'Can Maven 3.6.3+; truyen -MavenCommand duong-dan-mvn.cmd.' }
        $MavenCommand = $cached.FullName
    }
    & $MavenCommand -B package
    if ($LASTEXITCODE -ne 0) { throw 'Build/test that bai.' }
}
Write-Host 'Mo http://127.0.0.1:8080/login ; Ctrl+C de dung.'
& $java '--enable-native-access=ALL-UNNAMED' "-Djdk.net.unixdomain.tmpdir=$localDir" "-Djava.io.tmpdir=$localDir" "-Djava.library.path=$nativeDir" -jar target/moc-sach.war
if ($LASTEXITCODE -ne 0) { throw 'Ung dung da dung do loi. Xem log phia tren.' }
