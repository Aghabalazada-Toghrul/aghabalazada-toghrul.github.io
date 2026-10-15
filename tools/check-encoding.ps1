$utf8 = New-Object System.Text.UTF8Encoding($false)
$text = [System.IO.File]::ReadAllText('index.html', $utf8)
$m = [regex]::Match($text, '(?s)<div id="lang-menu-dropdown".*?</div>\s*</div>')
if ($m.Success) {
    # Print each character in the dropdown
    foreach ($line in $m.Value -split "`r?`n") {
        if ($line -match '<span>(.*?)</span>') {
            $span = $Matches[1]
            $charCodes = ($span.ToCharArray() | ForEach-Object { "[{0}: U+{1:X4}]" -f $_, [int]$_ }) -join " "
            Write-Host "$span -> $charCodes"
        }
    }
}
