param([string]$InputFile = '.local/missing-cover-books.json')
$ErrorActionPreference='Stop'
Set-Location (Split-Path $PSScriptRoot -Parent)
$destination=Join-Path $PWD 'src/main/resources/static/images/books/fallback'
New-Item -ItemType Directory -Force $destination | Out-Null
$palettes=@(@('#173f64','#ebd8ad'),@('#714638','#f5dfb9'),@('#285c58','#e8dfb9'),@('#3f496d','#e5d6c4'))
foreach($book in (Get-Content -Raw $InputFile | ConvertFrom-Json)){
 $colors=$palettes[[int]$book.id % $palettes.Count]
 $lines=New-Object System.Collections.Generic.List[string]
 $current=''
 foreach($word in ($book.title -split '\s+')){
  if(($current+' '+$word).Trim().Length -gt 20 -and $current){$lines.Add($current);$current=$word}else{$current=($current+' '+$word).Trim()}
 }
 if($current){$lines.Add($current)}
 $texts='';$y=133
 foreach($line in ($lines | Select-Object -First 7)){$escaped=[Security.SecurityElement]::Escape($line);$texts+="<tspan x='200' y='$y'>$escaped</tspan>";$y+=39}
 $author=[Security.SecurityElement]::Escape([string]$book.author)
 $svg=@"
<svg xmlns="http://www.w3.org/2000/svg" width="400" height="570" viewBox="0 0 400 570" role="img">
<title>Bìa dự phòng: $([Security.SecurityElement]::Escape([string]$book.title))</title>
<defs><linearGradient id="spine"><stop stop-color="#000" stop-opacity=".25"/><stop offset="1" stop-color="#fff" stop-opacity=".06"/></linearGradient><pattern id="grain" width="5" height="5" patternUnits="userSpaceOnUse"><circle cx="1" cy="1" r=".45" fill="#fff" opacity=".08"/></pattern></defs>
<rect width="400" height="570" rx="2" fill="$($colors[0])"/><rect width="400" height="570" fill="url(#grain)"/><rect width="18" height="570" fill="url(#spine)"/>
<rect x="32" y="27" width="339" height="515" fill="none" stroke="$($colors[1])" stroke-opacity=".65"/>
<text x="200" y="67" text-anchor="middle" fill="$($colors[1])" font-family="Arial,sans-serif" font-size="12" letter-spacing="5">TỦ SÁCH MỘC</text>
<text text-anchor="middle" fill="$($colors[1])" font-family="Georgia,serif" font-size="31" font-weight="bold">$texts</text>
<g fill="none" stroke="$($colors[1])" stroke-width="1.4" opacity=".7"><circle cx="200" cy="409" r="48"/><path d="M156 433q23-18 44-4q23-14 44 4v-54q-23-10-44 4q-23-14-44-4zM200 383v46M144 455h112"/></g>
<text x="200" y="493" text-anchor="middle" fill="$($colors[1])" font-family="Arial,sans-serif" font-size="13" >$author</text>
<text x="200" y="526" text-anchor="middle" fill="$($colors[1])" opacity=".65" font-family="Arial,sans-serif" font-size="8" letter-spacing="2">BÌA MINH HỌA · MỘC SÁCH</text>
</svg>
"@
 [IO.File]::WriteAllText((Join-Path $destination ($book.id.ToString()+'.svg')),$svg,[Text.UTF8Encoding]::new($false))
}
Write-Host 'Generated title-specific fallback covers.'
