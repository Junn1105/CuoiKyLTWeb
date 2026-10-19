$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$localDir = Join-Path $projectRoot '.local'
New-Item -ItemType Directory -Force -Path $localDir | Out-Null
$email = (Read-Host 'Gmail gui OTP (vi du ten@gmail.com)').Trim()
if ($email -notmatch '^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$') { throw 'Email khong hop le.' }
$securePassword = Read-Host 'Mat khau ung dung Google 16 ky tu (khong phai mat khau Gmail)' -AsSecureString
$pointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($securePassword)
try {
    $appPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($pointer) -replace '\s', ''
    if ($appPassword -notmatch '^[a-zA-Z]{16}$') { throw 'Can mat khau ung dung Google 16 chu cai.' }
    $mailFile = Join-Path $localDir 'mail.properties'
    [IO.File]::WriteAllText($mailFile, "spring.mail.username=$email`nspring.mail.password=$appPassword`napp.mail.from=$email`n", [Text.UTF8Encoding]::new($false))
    $acl = New-Object System.Security.AccessControl.FileSecurity
    $acl.SetAccessRuleProtection($true, $false)
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent().User
    $acl.AddAccessRule([Security.AccessControl.FileSystemAccessRule]::new($identity, 'FullControl', 'Allow'))
    Set-Acl -LiteralPath $mailFile -AclObject $acl
} finally {
    [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($pointer)
    $appPassword = $null
    $securePassword.Dispose()
}
Write-Host 'Da luu cau hinh rieng tren may (.local, duoc gitignore). Khoi dong lai ung dung de ap dung.'
