$utf8 = New-Object System.Text.UTF8Encoding($false)
$files = @('index.html', 'index_az.html', 'index_tr.html', 'index_ru.html')

foreach ($f in $files) {
    $text = [System.IO.File]::ReadAllText($f, $utf8)
    
    # Check if there is stray code between revealObserver and Language Dropdown Toggle
    $pattern = '(?s)document\.querySelectorAll\(''\.reveal''\)\.forEach\(el => revealObserver \? revealObserver\.observe\(el\) : el\.classList\.add\(''active''\)\);.*?\/\/ Language Dropdown Toggle'
    
    $cleanSection = @"
document.querySelectorAll('.reveal').forEach(el => revealObserver ? revealObserver.observe(el) : el.classList.add('active'));

        // Language Dropdown Toggle
"@
    
    if ($text -match $pattern) {
        $text = [regex]::Replace($text, $pattern, $cleanSection)
        [System.IO.File]::WriteAllText($f, $text, $utf8)
        Write-Host "$($f): Cleaned stray JS before dropdown toggle"
    } else {
        Write-Host "$($f): Pattern not matched"
    }
}
