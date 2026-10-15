New-Item -ItemType Directory -Force (Join-Path $PSScriptRoot 'flags') | Out-Null
foreach ($c in 'gb','az','tr','ru') {
    $out = Join-Path $PSScriptRoot ("flags\" + $c + ".svg")
    Invoke-WebRequest -UseBasicParsing -Uri ("https://cdn.jsdelivr.net/gh/lipis/flag-icons@7.2.3/flags/4x3/" + $c + ".svg") -OutFile $out
    Write-Host ($c + " " + (Get-Item $out).Length)
}
