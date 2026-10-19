# Build the site:  powershell -ExecutionPolicy Bypass -File tools\build.ps1 [-SiteUrl https://your-domain]
#  1. Compiles + minifies Tailwind -> assets\site.css (used by the pages directly, so local preview works)
#  2. Packages a deploy-ready folder  -> dist\  (with __SITE_URL__ replaced in meta tags)
param([string]$SiteUrl = 'https://aghabalazada-toghrul.github.io')
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root
$SiteUrl = $SiteUrl.TrimEnd('/')

# Tailwind: standalone exe if present, otherwise the same version through npx (Node.js)
$useNpx = (-not (Test-Path 'tools\tailwindcss.exe')) -and (Get-Command npx -ErrorAction SilentlyContinue)
if (-not $useNpx -and -not (Test-Path 'tools\tailwindcss.exe')) { & "$PSScriptRoot\setup.ps1" | Out-Null }
$tailwind = if ($useNpx) { 'npx --yes tailwindcss@3.4.17' } else { 'tools\tailwindcss.exe' }

# 1) Compile CSS (native stderr is informational; check exit code instead)
$ErrorActionPreference = 'Continue'
cmd /c "$tailwind -c tailwind.novum.config.js -i src\site.css -o assets\site.css --minify 2>&1"
if ($LASTEXITCODE -ne 0) { throw 'Tailwind build failed' }
$ErrorActionPreference = 'Stop'
"CSS: {0:N1} KB" -f ((Get-Item assets\site.css).Length / 1KB)

# 2) Package dist\
if (Test-Path dist) { Remove-Item dist -Recurse -Force }
New-Item -ItemType Directory dist | Out-Null
$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($f in 'index.html', 'index_az.html', 'index_tr.html', 'index_ru.html') {
    $t = [System.IO.File]::ReadAllText((Join-Path $root $f), $utf8).Replace('__SITE_URL__', $SiteUrl)
    [System.IO.File]::WriteAllText((Join-Path $root "dist\$f"), $t, $utf8)
}
# short language aliases (/az.html etc.)
Copy-Item az.html, tr.html, ru.html dist\
# assets actually used by the pages
New-Item -ItemType Directory dist\assets | Out-Null
Copy-Item assets\site.css, assets\site.js dist\assets\
Copy-Item assets\fonts dist\assets\fonts -Recurse
Copy-Item assets\img dist\assets\img -Recurse
Copy-Item logos dist\logos -Recurse
# helper files for crawlers / GitHub Pages
[System.IO.File]::WriteAllText((Join-Path $root 'dist\.nojekyll'), '', $utf8)
[System.IO.File]::WriteAllText((Join-Path $root 'dist\robots.txt'), "User-agent: *`nAllow: /`nSitemap: $SiteUrl/sitemap.xml`n", $utf8)
$urls = @('/', '/index_az.html', '/index_tr.html', '/index_ru.html') | ForEach-Object { "  <url><loc>$SiteUrl$_</loc></url>" }
[System.IO.File]::WriteAllText((Join-Path $root 'dist\sitemap.xml'), "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n$($urls -join "`n")`n</urlset>`n", $utf8)

$size = (Get-ChildItem dist -Recurse -File | Measure-Object Length -Sum).Sum
"dist\ ready: {0:N0} KB total, site URL = {1}" -f ($size / 1KB), $SiteUrl
