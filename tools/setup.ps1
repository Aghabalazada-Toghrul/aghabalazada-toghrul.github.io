$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'
$root = Split-Path -Parent $PSScriptRoot
New-Item -ItemType Directory -Force "$root\assets\fonts", "$root\tools" | Out-Null

if (-not (Test-Path "$root\tools\tailwindcss.exe")) {
    Invoke-WebRequest -Uri 'https://github.com/tailwindlabs/tailwindcss/releases/download/v3.4.17/tailwindcss-windows-x64.exe' -OutFile "$root\tools\tailwindcss.exe"
}
foreach ($s in 'latin', 'latin-ext', 'cyrillic') {
    $out = "$root\assets\fonts\inter-$s.woff2"
    if (-not (Test-Path $out)) {
        Invoke-WebRequest -Uri "https://cdn.jsdelivr.net/fontsource/fonts/inter:vf@latest/$s-wght-normal.woff2" -OutFile $out
    }
}
Get-ChildItem "$root\tools", "$root\assets\fonts" | Select-Object Name, Length
