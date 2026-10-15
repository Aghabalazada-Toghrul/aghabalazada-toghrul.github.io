$bytes = [System.IO.File]::ReadAllBytes('tools\dropdown-assets.json')
Write-Host "Length: $($bytes.Length)"
$hex = ($bytes[0..3] | ForEach-Object { $_.ToString("X2") }) -join " "
Write-Host "First 4 bytes: $hex"

# Let's search for the bytes where Azərbaycan is
$str = [System.Text.Encoding]::UTF8.GetString($bytes)
$idx = $str.IndexOf("Az")
if ($idx -ge 0) {
    $slice = $str.Substring($idx, 15)
    $chars = $slice.ToCharArray() | ForEach-Object { "[{0}: U+{1:X4}]" -f $_, [int]$_ }
    Write-Host ($chars -join " ")
}
