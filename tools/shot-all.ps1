$root = Split-Path -Parent $PSScriptRoot
$edge = (Get-Command msedge -ErrorAction SilentlyContinue).Source
if (-not $edge) { $edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }
$shots = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch'
New-Item -ItemType Directory -Force $shots | Out-Null

$pages = @(
    @{ file = 'dist\index.html'; tag = 'en_390' },
    @{ file = 'dist\index_az.html'; tag = 'az_390' },
    @{ file = 'dist\index_tr.html'; tag = 'tr_390' },
    @{ file = 'dist\index_ru.html'; tag = 'ru_390' }
)

foreach ($p in $pages) {
    $out = Join-Path $shots "$($p.tag).png"
    $url = 'http://localhost:8123/' + (Split-Path -Leaf $p.file)
    $a = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=390,844', '--virtual-time-budget=3000', "--screenshot=$out", $url)
    Start-Process -FilePath $edge -ArgumentList $a -Wait -WindowStyle Hidden
    "{0}: {1}" -f $out, (Test-Path $out)
}
