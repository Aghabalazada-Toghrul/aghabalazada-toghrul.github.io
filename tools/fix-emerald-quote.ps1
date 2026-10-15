$utf8 = New-Object System.Text.UTF8Encoding($false)
$files = @('index.html', 'index_az.html', 'index_tr.html', 'index_ru.html')

foreach ($f in $files) {
    $t = [System.IO.File]::ReadAllText($f, $utf8)
    if ($t.Contains('border-emerald-200/80" hover:border-emerald-400">')) {
        $t = $t.Replace('border-emerald-200/80" hover:border-emerald-400">', 'border-emerald-200/80 hover:border-emerald-400">')
        [System.IO.File]::WriteAllText($f, $t, $utf8)
        Write-Host "Fixed quote in $($f)"
    }
}
