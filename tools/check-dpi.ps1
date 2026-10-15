$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$harness = @'
<!DOCTYPE html>
<html><body><pre id="out"></pre>
<script>
document.getElementById('out').textContent = 'DPI_START\n' + JSON.stringify({
    dpr: window.devicePixelRatio,
    innerWidth: window.innerWidth,
    innerHeight: window.innerHeight,
    outerWidth: window.outerWidth,
    outerHeight: window.outerHeight,
    screenW: window.screen.width,
    screenH: window.screen.height
}) + '\nDPI_END';
</script></body></html>
'@
[System.IO.File]::WriteAllText('dist\_dpi_test.html', $harness)

$outPath = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch\dpi_out.txt'
$a = @('--headless=new', '--disable-gpu', '--window-size=390,844', '--dump-dom', 'http://localhost:8123/_dpi_test.html')
Start-Process -FilePath $edge -ArgumentList $a -RedirectStandardOutput $outPath -Wait -WindowStyle Hidden
$res = [System.IO.File]::ReadAllText($outPath)
$m = [regex]::Match($res, '(?s)DPI_START(.*?)DPI_END')
if ($m.Success) {
    Write-Host $m.Groups[1].Value
}
