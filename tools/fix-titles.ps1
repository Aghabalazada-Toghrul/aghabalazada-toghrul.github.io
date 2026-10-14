$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($f in 'index.html', 'index_az.html', 'index_tr.html', 'index_ru.html') {
    $p = Join-Path $root $f
    $h = [System.IO.File]::ReadAllText($p, $utf8)
    # Experience job titles: slightly smaller on tiny phones + safe wrapping
    $h = $h.Replace('font-display text-xl sm:text-2xl font-bold text-novum-dark leading-tight', 'font-display text-lg sm:text-2xl font-bold text-novum-dark leading-tight break-words')
    $h = $h.Replace('font-display text-xl font-bold text-novum-dark leading-tight', 'font-display text-lg sm:text-xl font-bold text-novum-dark leading-tight break-words')
    [System.IO.File]::WriteAllText($p, $h, $utf8)
    "{0}: patched" -f $f
}
