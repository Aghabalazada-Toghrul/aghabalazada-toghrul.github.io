$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$shots = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch'

$pages = @(
    @{ name = 'final_mobile_en.png'; size = '390,844'; url = 'http://localhost:8123/index.html' },
    @{ name = 'final_desktop_en.png'; size = '1280,840'; url = 'http://localhost:8123/index.html' }
)

foreach ($p in $pages) {
    $out = Join-Path $shots $p.name
    $a = @('--headless=new', '--disable-gpu', '--hide-scrollbars', "--window-size=$($p.size)", '--virtual-time-budget=3000', "--screenshot=$out", $p.url)
    Start-Process -FilePath $edge -ArgumentList $a -Wait -WindowStyle Hidden
    Write-Host "$($p.name): $(Test-Path $out)"
}
