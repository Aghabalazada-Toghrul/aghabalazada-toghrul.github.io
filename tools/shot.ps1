param([string]$Page = 'dist\index.html', [string]$Tag = 'new')
$root = Split-Path -Parent $PSScriptRoot
$edge = (Get-Command msedge -ErrorAction SilentlyContinue).Source
if (-not $edge) { $edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }
$shots = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch'
New-Item -ItemType Directory -Force $shots | Out-Null
$url = 'file:///' + ((Resolve-Path (Join-Path $root $Page)).Path -replace '\\', '/')
$sizes = @{ desktop = '1280,1500'; mobile = '500,1700' }
foreach ($k in $sizes.Keys) {
    $out = Join-Path $shots "$Tag`_$k.png"
    Remove-Item $out -ErrorAction SilentlyContinue
    $a = @('--headless=new', '--disable-gpu', '--hide-scrollbars', "--window-size=$($sizes[$k])", '--virtual-time-budget=4000', "--screenshot=$out", $url)
    $proc = Start-Process -FilePath $edge -ArgumentList $a -PassThru -Wait -WindowStyle Hidden
    "{0}: {1}" -f $out, (Test-Path $out)
}

