$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$ProgressPreference = 'SilentlyContinue'
$root = Split-Path -Parent $PSScriptRoot
$tools = Join-Path $root 'tools'
$zip = Join-Path $tools 'libwebp.zip'
if (-not (Test-Path (Join-Path $tools 'cwebp.exe'))) {
    Invoke-WebRequest -Uri 'https://storage.googleapis.com/downloads.webmproject.org/releases/webp/libwebp-1.4.0-windows-x64.zip' -OutFile $zip
    Expand-Archive -Path $zip -DestinationPath (Join-Path $tools 'libwebp') -Force
    Copy-Item (Get-ChildItem (Join-Path $tools 'libwebp') -Recurse -Filter cwebp.exe | Select-Object -First 1).FullName (Join-Path $tools 'cwebp.exe')
    Remove-Item $zip, (Join-Path $tools 'libwebp') -Recurse -Force
}
$img = Join-Path $root 'assets\img'
cmd /c "`"$tools\cwebp.exe`" -q 86 -alpha_q 90 -m 6 `"$img\toghrul.png`" -o `"$img\toghrul.webp`" >nul 2>&1"
Get-ChildItem $img -Filter toghrul.* | Select-Object Name, Length
