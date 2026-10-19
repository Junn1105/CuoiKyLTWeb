param([string]$BaseUrl = 'http://127.0.0.1:8082')
$ErrorActionPreference = 'Stop'
$checks = [Collections.Generic.List[string]]::new()
function Check([bool]$condition, [string]$name) {
    if (-not $condition) { throw "FAIL: $name" }
    $checks.Add("PASS: $name")
}
$session = New-Object Microsoft.PowerShell.Commands.WebRequestSession
$homeResponse = Invoke-WebRequest "$BaseUrl/home" -UseBasicParsing -WebSession $session
Check ($homeResponse.StatusCode -eq 200 -and $homeResponse.Content.Contains('Mộc Sách')) 'Home JSP renders'
$paths = [regex]::Matches($homeResponse.Content, '(?:src|href)="([^"]+)"') | ForEach-Object { $_.Groups[1].Value } | Where-Object { $_ -match '^/(images/|css/|js/|webjars/)' } | Sort-Object -Unique
foreach ($path in $paths) {
    $asset = Invoke-WebRequest "$BaseUrl$path" -UseBasicParsing
    Check ($asset.StatusCode -eq 200 -and $asset.RawContentLength -gt 0) "Asset $path"
}
$search = Invoke-WebRequest "$BaseUrl/home?q=Nguy%E1%BB%85n%20Du" -UseBasicParsing
Check ($search.Content.Contains('Truyện Kiều')) 'Search returns matching book'
$login = Invoke-WebRequest "$BaseUrl/login" -UseBasicParsing -WebSession $session
$csrf = [regex]::Match($login.Content, 'name="_csrf"\s+value="([^"]+)"').Groups[1].Value
Check ($csrf.Length -gt 0) 'Login CSRF token present'
$signedIn = Invoke-WebRequest "$BaseUrl/auth/login" -Method Post -Body @{identifier='khang';password='123456';_csrf=$csrf} -WebSession $session -UseBasicParsing
Check ($signedIn.BaseResponse.RequestMessage.RequestUri.AbsolutePath -eq '/home' -and $signedIn.Content.Contains('Nguyễn Minh Khang')) 'Demo login redirects to authenticated home'
$csrf = [regex]::Match($signedIn.Content, 'name="_csrf"\s+value="([^"]+)"').Groups[1].Value
$logout = Invoke-WebRequest "$BaseUrl/logout" -Method Post -Body @{_csrf=$csrf} -WebSession $session -UseBasicParsing
Check ($logout.BaseResponse.RequestMessage.RequestUri.AbsolutePath -eq '/login') 'Logout redirects to login'
$checks
