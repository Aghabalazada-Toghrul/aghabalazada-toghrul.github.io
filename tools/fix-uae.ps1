$utf8 = New-Object System.Text.UTF8Encoding($false)
$p = Join-Path (Split-Path -Parent $PSScriptRoot) 'index.html'
$h = [System.IO.File]::ReadAllText($p, $utf8)
$h = $h.Replace('the UAE,', 'UAE,')
[System.IO.File]::WriteAllText($p, $h, $utf8)
Write-Host 'done'
