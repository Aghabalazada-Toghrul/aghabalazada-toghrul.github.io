$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$cfgJson = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'fix-all-final.json'), $utf8)
$data = $cfgJson | ConvertFrom-Json

$phone = $data.phone
$dispPhone = $data.displayPhone

$globeSvg = '<svg class="w-3.5 h-3.5 ml-2 mr-1 text-slate-400 hidden min-[400px]:inline-block flex-shrink-0" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" aria-hidden="true"><path stroke-linecap="round" stroke-linejoin="round" d="M21 12a9 9 0 01-9 9m9-9a9 9 0 00-9-9m9 9H3m9 9a9 9 0 01-9-9m9 9c1.657 0 3-4.03 3-9s-1.343-9-3-9m0 18c-1.657 0-3-4.03-3-9s1.343-9 3-9m-9 9a9 9 0 019-9"/></svg>'

foreach ($prop in $data.pages.PSObject.Properties) {
    $fileName = $prop.Name
    $pageCfg = $prop.Value
    $currLang = $pageCfg.lang
    $waText = $pageCfg.waText

    $filePath = Join-Path $root $fileName
    $content = [System.IO.File]::ReadAllText($filePath, $utf8)

    # 1. Fix WhatsApp URLs
    $fullWaUrl = "https://wa.me/$phone" + "?text=" + $waText
    # Replace action button href
    $content = [regex]::Replace($content, 'href="https://wa\.me/[^"]*"\s+target="_blank"\s+rel="noopener noreferrer"\s+class="w-full sm:w-auto px-7 py-4 bg-\[#25D366\]', "href=`"$fullWaUrl`" target=`"_blank`" rel=`"noopener noreferrer`" class=`"w-full sm:w-auto px-7 py-4 bg-[#25D366]`"")
    # Replace card href
    $content = [regex]::Replace($content, 'href="https://wa\.me/[^"]*"\s+target="_blank"\s+rel="noopener noreferrer"\s+class="glass-panel p-4 rounded-xl flex items-center gap-3\.5 group hover:-translate-y-0\.5 transition-all min-w-0 border-emerald-200/80', "href=`"$fullWaUrl`" target=`"_blank`" rel=`"noopener noreferrer`" class=`"glass-panel p-4 rounded-xl flex items-center gap-3.5 group hover:-translate-y-0.5 transition-all min-w-0 border-emerald-200/80`"")
    # Replace footer href
    $content = [regex]::Replace($content, 'href="https://wa\.me/[^"]*"\s+target="_blank"\s+rel="noopener noreferrer"\s+class="hover:text-\[#25D366\]', "href=`"https://wa.me/$phone`" target=`"_blank`" rel=`"noopener noreferrer`" class=`"hover:text-[#25D366]`"")

    # In contact card: ensure clean phone number
    $content = [regex]::Replace($content, '(<span class="block text-sm font-bold text-novum-dark group-hover:text-\[#25D366\] truncate transition-colors">)[^<]*(</span>)', "`$1$dispPhone`$2")

    # 2. Build clean Floating Language Switcher Widget (Option C)
    $pillDef = @(
        @{ code = 'EN'; file = 'index.html'; id = 'en' },
        @{ code = 'AZ'; file = 'index_az.html'; id = 'az' },
        @{ code = 'TR'; file = 'index_tr.html'; id = 'tr' },
        @{ code = 'RU'; file = 'index_ru.html'; id = 'ru' }
    )

    $pills = ''
    foreach ($p in $pillDef) {
        if ($p.id -eq $currLang) {
            $pills += "`n            <a href=`"$($p.file)`" class=`"px-2.5 py-1 rounded-lg text-xs font-bold transition-all bg-novum-navy text-white shadow-xs`" data-lang=`"$($p.id)`">$($p.code)</a>"
        } else {
            $pills += "`n            <a href=`"$($p.file)`" class=`"px-2.5 py-1 rounded-lg text-xs font-bold transition-all text-slate-700 hover:text-novum-navy hover:bg-blue-50/70`" data-lang=`"$($p.id)`">$($p.code)</a>"
        }
    }

    $widget = @"
    <!-- Floating Language Switcher Widget (Option C) -->
    <aside aria-label="Language selection" class="fixed top-24 right-4 sm:top-24 sm:right-8 z-40">
        <div class="glass-panel p-1 rounded-xl shadow-md border border-slate-200/90 flex items-center gap-0.5 backdrop-blur-md bg-white/95" id="floating-lang-widget">
            $globeSvg$pills
        </div>
    </aside>
"@

    # Remove existing floating widget and replace
    $content = [regex]::Replace($content, '(?s)\s*<!-- Floating Language Switcher Widget \(Option C\) -->.*?<\/aside>', '')
    $content = $content.Replace('</header>', "</header>`r`n$widget")

    [System.IO.File]::WriteAllText($filePath, $content, $utf8)
    Write-Host "$fileName updated successfully"
}
