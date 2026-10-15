$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$phone = '994702899778'
$displayPhone = '+994 70 289 97 78'

$globeSvg = '<svg class="w-3.5 h-3.5 text-slate-400 hidden min-[400px]:inline-block flex-shrink-0 mr-1" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2"><path stroke-linecap="round" stroke-linejoin="round" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"/></svg>'

$pages = @(
    @{
        file = 'index.html'
        lang = 'en'
        waText = 'Hello%20Toghrul,%20I%20would%20like%20to%20discuss%20Microsoft%20solutions.'
        langLabel = 'Language:'
    },
    @{
        file = 'index_az.html'
        lang = 'az'
        waText = 'Salam%20To%C4%9Frul,%20Microsoft%20h%C9%99ll%C9%99ri%20haqq%C4%B1nda%20m%C3%BCzakir%C9%99%20etm%C9%99k%20ist%C9%99rdim.'
        langLabel = 'Dil:'
    },
    @{
        file = 'index_tr.html'
        lang = 'tr'
        waText = 'Merhaba%20To%C4%9Frul,%20Microsoft%20%C3%A7%C3%B6z%C3%BCmleri%20hakk%C4%B1nda%20g%C3%B6r%C3%BC%C5%9Fmek%20istiyorum.'
        langLabel = 'Dil:'
    },
    @{
        file = 'index_ru.html'
        lang = 'ru'
        waText = '%D0%97%D0%B4%D1%80%D0%B0%D0%B2%D1%81%D1%82%D0%B2%D1%83%D0%B9%D1%82%D0%B5,%20%D0%A2%D0%BE%D0%B3%D1%80%D1%83%D0%BB!%20%D0%AF%20%D1%85%D0%BE%D1%82%D0%B5%D0%BB%20%D0%B1%D1%8B%20%D0%BE%D0%B1%D1%81%D1%83%D0%B4%D0%B8%D1%82%D1%8C%20%D1%80%D0%B5%D1%88%D0%B5%D0%BD%D0%B8%D1%8F%20Microsoft.'
        langLabel = 'Язык:'
    }
)

foreach ($p in $pages) {
    $f = $p.file
    $filePath = Join-Path $root $f
    $h = [System.IO.File]::ReadAllText($filePath, $utf8)

    # Clean any corrupted emoji strings
    $h = [regex]::Replace($h, 'ðŸŒ[^\s<]*', '')

    # 1. Update WhatsApp links with real phone number & prefilled message
    $waUrl = "https://wa.me/$phone?text=$($p.waText)"
    $h = [regex]::Replace($h, 'href="https://wa\.me/[^"]*"', "href=`"$waUrl`"")
    # Footer direct link without long prefilled message
    $h = [regex]::Replace($h, 'href="https://wa\.me/[^"]*"\s+target="_blank"\s+rel="noopener noreferrer"\s+class="hover:text-\[#25D366\]', "href=`"https://wa.me/$phone`" target=`"_blank`" rel=`"noopener noreferrer`" class=`"hover:text-[#25D366]`"")

    # In Contact card: ensure formatted phone number is shown
    $h = [regex]::Replace($h, '(<span class="block text-sm font-bold text-novum-dark group-hover:text-\[#25D366\] truncate transition-colors">)[^<]*(</span>)', "`$1$displayPhone`$2")

    # 2. Floating widget pills
    $pills = @(
        @{ code = 'EN'; file = 'index.html'; id = 'en'; title = 'English' },
        @{ code = 'AZ'; file = 'index_az.html'; id = 'az'; title = 'Azərbaycan dili' },
        @{ code = 'TR'; file = 'index_tr.html'; id = 'tr'; title = 'Türkçe' },
        @{ code = 'RU'; file = 'index_ru.html'; id = 'ru'; title = 'Русский' }
    )

    $pillHtml = ''
    foreach ($pill in $pills) {
        if ($pill.id -eq $p.lang) {
            $pillHtml += "`n            <a href=`"$($pill.file)`" class=`"px-2.5 py-1 rounded-lg text-xs font-bold transition-all bg-novum-navy text-white shadow-xs`" title=`"$($pill.title)`" data-lang=`"$($pill.id)`">$($pill.code)</a>"
        } else {
            $pillHtml += "`n            <a href=`"$($pill.file)`" class=`"px-2.5 py-1 rounded-lg text-xs font-bold transition-all text-slate-700 hover:text-novum-navy hover:bg-blue-50/70`" title=`"$($pill.title)`" data-lang=`"$($pill.id)`">$($pill.code)</a>"
        }
    }

    $floatingWidget = @"
    <!-- Floating Language Switcher Widget (Option C) -->
    <aside aria-label="Language selection" class="fixed top-24 right-4 sm:top-24 sm:right-8 z-40">
        <div class="glass-panel p-1 rounded-xl shadow-md border border-slate-200/90 flex items-center gap-0.5 backdrop-blur-md bg-white/95" id="floating-lang-widget">
            <span class="pl-2 hidden min-[400px]:inline-flex items-center" aria-hidden="true">$globeSvg</span>$pillHtml
        </div>
    </aside>
"@

    # Replace existing floating widget
    $h = [regex]::Replace($h, '(?s)\s*<!-- Floating Language Switcher Widget \(Option C\) -->.*?<\/aside>', '')
    $h = $h.Replace('</header>', "</header>`r`n$floatingWidget")

    [System.IO.File]::WriteAllText($filePath, $h, $utf8)
    Write-Host "$f updated with clean SVG globe & exact WhatsApp links"
}
