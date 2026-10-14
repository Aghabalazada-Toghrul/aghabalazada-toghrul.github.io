# One-off migration: swaps CDN Tailwind / Google Fonts for the precompiled stylesheet,
# adds SEO + social-preview tags, optimized images, and safer reveal-animation JS.
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$pages = @(
    @{ file = 'index.html';    lang = 'en'; locale = 'en_US'; fonts = @() },
    @{ file = 'index_az.html'; lang = 'az'; locale = 'az_AZ'; fonts = @('latin-ext') },
    @{ file = 'index_tr.html'; lang = 'tr'; locale = 'tr_TR'; fonts = @('latin-ext') },
    @{ file = 'index_ru.html'; lang = 'ru'; locale = 'ru_RU'; fonts = @('cyrillic') }
)

function Esc([string]$s) { return ($s -replace '&', '&amp;' -replace '"', '&quot;') }

foreach ($p in $pages) {
    $path = Join-Path $root $p.file
    $html = [System.IO.File]::ReadAllText($path, $utf8)

    $title = [regex]::Match($html, '<title>(.*?)</title>').Groups[1].Value
    $desc = [regex]::Match($html, '<meta name="description" content="(.*?)">').Groups[1].Value
    $pageUrl = if ($p.file -eq 'index.html') { '__SITE_URL__/' } else { '__SITE_URL__/' + $p.file }

    $preloads = '    <link rel="preload" href="assets/fonts/inter-latin.woff2" as="font" type="font/woff2" crossorigin>' + "`n"
    foreach ($f in $p.fonts) {
        $preloads += '    <link rel="preload" href="assets/fonts/inter-' + $f + '.woff2" as="font" type="font/woff2" crossorigin>' + "`n"
    }

    $block = @"
<!-- Link previews (Open Graph / Twitter) -->
    <meta property="og:type" content="website">
    <meta property="og:site_name" content="Toghrul Aghabalazada">
    <meta property="og:title" content="$title">
    <meta property="og:description" content="$desc">
    <meta property="og:url" content="$pageUrl">
    <meta property="og:image" content="__SITE_URL__/assets/img/og-image.jpg">
    <meta property="og:image:width" content="1200">
    <meta property="og:image:height" content="630">
    <meta property="og:image:alt" content="Toghrul Aghabalazada - Sales Manager, Microsoft Cloud &amp; Dynamics 365">
    <meta property="og:locale" content="$($p.locale)">
    <meta name="twitter:card" content="summary_large_image">
    <meta name="twitter:title" content="$title">
    <meta name="twitter:description" content="$desc">
    <meta name="twitter:image" content="__SITE_URL__/assets/img/og-image.jpg">

    <!-- Canonical + language alternates -->
    <link rel="canonical" href="$pageUrl">
    <link rel="alternate" hreflang="en" href="__SITE_URL__/">
    <link rel="alternate" hreflang="az" href="__SITE_URL__/index_az.html">
    <link rel="alternate" hreflang="tr" href="__SITE_URL__/index_tr.html">
    <link rel="alternate" hreflang="ru" href="__SITE_URL__/index_ru.html">
    <link rel="alternate" hreflang="x-default" href="__SITE_URL__/">

    <!-- Icons -->
    <link rel="icon" type="image/png" sizes="48x48" href="assets/img/favicon-48.png">
    <link rel="apple-touch-icon" href="assets/img/apple-touch-icon.png">

    <!-- Rendering consistency across browsers / in-app WebViews -->
    <meta name="color-scheme" content="light">
    <meta name="format-detection" content="telephone=no">
$preloads    <link rel="stylesheet" href="assets/site.css">
    <script>document.documentElement.className += ' js';</script>
"@

    # 1) Replace Google Fonts + Tailwind CDN + inline <style> with the block above
    $html = [regex]::Replace($html, '(?s)<!-- Google Fonts: Inter -->.*?</style>', { param($m) $block })
    # 2) Remove placeholder canonical in the original head
    $html = [regex]::Replace($html, '[ \t]*<link rel="canonical" href="\[ADD: canonical URL\]">\r?\n', '')

    # 3) Optimized assets
    $html = $html.Replace('logos/novum_icon.jpg', 'assets/img/novum_icon.png').Replace('logos/novum.png', 'assets/img/novum.png')
    $html = [regex]::Replace($html, '<img src="toghrul_transparent\.png" alt="([^"]*)" class="([^"]*)">', {
        param($m)
        '<picture class="contents">' + "`n" +
        '                                <source srcset="assets/img/toghrul.webp" type="image/webp">' + "`n" +
        '                                <img src="assets/img/toghrul.png" alt="' + $m.Groups[1].Value + '" width="768" height="1029" fetchpriority="high" decoding="async" class="' + $m.Groups[2].Value + '">' + "`n" +
        '                            </picture>'
    })

    # 4) Reveal animation: never leave content hidden if IntersectionObserver is unavailable
    $html = $html.Replace('const revealObserver = new IntersectionObserver((entries, observer) => {', "const revealObserver = ('IntersectionObserver' in window) ? new IntersectionObserver((entries, observer) => {")
    $html = $html.Replace("}, { rootMargin: '0px 0px -100px 0px', threshold: 0.1 });", "}, { rootMargin: '0px 0px -100px 0px', threshold: 0.1 }) : null;")
    $html = $html.Replace("document.querySelectorAll('.reveal').forEach(el => revealObserver.observe(el));", "document.querySelectorAll('.reveal').forEach(el => revealObserver ? revealObserver.observe(el) : el.classList.add('active'));")

    [System.IO.File]::WriteAllText($path, $html, $utf8)
    "{0}: cdn={1} gfonts={2} tailwindScript={3}" -f $p.file, ($html -match 'cdn\.tailwindcss'), ($html -match 'fonts\.googleapis'), ($html -match 'tailwind\.config')
}
