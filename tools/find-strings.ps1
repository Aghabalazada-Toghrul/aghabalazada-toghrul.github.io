$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($f in 'index.html','index_az.html','index_tr.html','index_ru.html') {
    $lines = [System.IO.File]::ReadAllLines((Join-Path (Split-Path -Parent $PSScriptRoot) $f), $utf8)
    for ($i=0; $i -lt $lines.Length; $i++) {
        $l = $lines[$i]
        if ($l -match 'structured methodology|UAE|#contact" class="[^"]*">\s*$|Connect with|&rarr;|wa\.me/994702899778"' -or $l.Contains([string][char]0x2192)) {
            $t = $l.Trim(); if ($t.Length -gt 200) { $t = $t.Substring(0,200) }
            Write-Host ("{0}:{1}: {2}" -f $f, ($i+1), $t)
        }
    }
}
