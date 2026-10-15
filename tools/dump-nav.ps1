$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$out = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch\nav_dom.txt'

$a = @('--headless=new', '--disable-gpu', '--window-size=390,844', '--dump-dom', 'http://localhost:8123/index.html')
$proc = Start-Process -FilePath $edge -ArgumentList $a -RedirectStandardOutput $out -Wait -PassThru
$html = [System.IO.File]::ReadAllText($out)
$m = [regex]::Match($html, '(?s)<nav.*?</nav>')
if ($m.Success) {
    Write-Host $m.Value
}
