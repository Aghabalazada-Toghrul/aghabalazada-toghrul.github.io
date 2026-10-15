$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($f in 'index.html','index_az.html','index_tr.html','index_ru.html') {
    $p = Join-Path $root $f
    $h = [System.IO.File]::ReadAllText($p, $utf8)

    # 1. Remove intro paragraph under the Solutions heading
    $h = [regex]::Replace($h, '(?s)(<h2 id="solutions-heading"[^>]*>[^<]*</h2>)\s*<p class="text-slate-600 text-lg">.*?</p>', '$1')

    # 2. Remove descriptions of the 4 stage cards inside the value section
    $s = $h.IndexOf('<section id="value"')
    $e = $h.IndexOf('</section>', $s)
    $sec = $h.Substring($s, $e - $s)
    $sec = [regex]::Replace($sec, '(?s)\s*<p class="text-sm text-slate-600 leading-relaxed">.*?</p>', '')
    $sec = $sec.Replace('font-display font-bold text-2xl text-novum-dark mb-3">', 'font-display font-bold text-2xl text-novum-dark">')
    $h = $h.Substring(0, $s) + $sec + $h.Substring($e)

    [System.IO.File]::WriteAllText($p, $h, $utf8)
    Write-Host ($f + ' updated')
}
