$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$files = @('index.html', 'index_az.html', 'index_tr.html', 'index_ru.html')

foreach ($f in $files) {
    $p = Join-Path $root $f
    $h = [System.IO.File]::ReadAllText($p, $utf8)

    # Ensure the brand link is explicitly bounded so mobile controls are NEVER pushed off
    $h = [regex]::Replace($h, '<a href="#top" class="[^"]*">(\s*<img src="assets/img/novum_icon\.png"[^>]*>\s*<span[^>]*>[^<]*</span>\s*)</a>', {
        param($m)
        '<a href="#top" class="font-display font-bold text-base min-[400px]:text-lg sm:text-xl text-novum-dark tracking-tight flex items-center gap-2 sm:gap-3 min-w-0 max-w-[calc(100%-116px)] sm:max-w-none flex-shrink">' +
        $m.Groups[1].Value +
        '</a>'
    })

    [System.IO.File]::WriteAllText($p, $h, $utf8)
    Write-Host "$f brand max-w clamped"
}
