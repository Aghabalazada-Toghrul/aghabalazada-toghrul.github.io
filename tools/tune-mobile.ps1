$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$files = @('index.html', 'index_az.html', 'index_tr.html', 'index_ru.html')

foreach ($f in $files) {
    $p = Join-Path $root $f
    $h = [System.IO.File]::ReadAllText($p, $utf8)

    # 1. Container padding: px-4 on tiny screens, px-6 on sm+, px-12 on md+
    $h = $h.Replace('max-w-7xl mx-auto px-6 md:px-12', 'max-w-7xl mx-auto px-4 sm:px-6 md:px-12')
    $h = $h.Replace('max-w-4xl mx-auto px-6 md:px-12', 'max-w-4xl mx-auto px-4 sm:px-6 md:px-12')
    $h = $h.Replace('max-w-7xl mx-auto px-6 flex flex-col md:flex-row', 'max-w-7xl mx-auto px-4 sm:px-6 flex flex-col md:flex-row')
    $h = $h.Replace('border-t border-slate-200 px-6 py-4 space-y-2', 'border-t border-slate-200 px-4 sm:px-6 py-4 space-y-2')

    # 2. Language selector buttons: compact on 320px
    $h = $h.Replace('lang-selector-btn px-2.5 sm:px-3.5 py-1.5 rounded-lg text-xs', 'lang-selector-btn px-2 min-[380px]:px-2.5 sm:px-3.5 py-1 min-[380px]:py-1.5 rounded-lg text-[11px] min-[380px]:text-xs')

    # 3. Headings: scale down gracefully for Russian / long titles
    $h = $h.Replace('font-display text-3xl sm:text-4xl font-extrabold text-novum-dark', 'font-display text-2xl min-[400px]:text-3xl sm:text-4xl font-extrabold text-novum-dark')
    $h = $h.Replace('font-display text-3xl md:text-4xl font-extrabold text-novum-dark', 'font-display text-2xl min-[400px]:text-3xl md:text-4xl font-extrabold text-novum-dark')
    $h = $h.Replace('font-display text-3xl sm:text-4xl md:text-5xl font-extrabold', 'font-display text-2xl min-[400px]:text-3xl md:text-5xl font-extrabold')

    # 4. Timeline items: left padding and inner padding
    $h = $h.Replace('relative pl-10 md:pl-12 reveal', 'relative pl-7 sm:pl-10 md:pl-12 reveal')
    $h = $h.Replace('glass-panel p-6 sm:p-8 rounded-2xl group border-l-4', 'glass-panel p-4 min-[400px]:p-6 sm:p-8 rounded-2xl group border-l-4')
    $h = $h.Replace('glass-panel p-6 sm:p-8 rounded-2xl group', 'glass-panel p-4 min-[400px]:p-6 sm:p-8 rounded-2xl group')
    $h = $h.Replace('glass-panel p-6 sm:p-8 rounded-2xl', 'glass-panel p-4 min-[400px]:p-6 sm:p-8 rounded-2xl')

    # Timeline logo and titles
    $h = $h.Replace('w-12 h-12 sm:w-14 sm:h-14 rounded-2xl bg-white p-2 sm:p-2.5', 'w-11 h-11 sm:w-14 sm:h-14 rounded-2xl bg-white p-1.5 sm:p-2.5')
    $h = $h.Replace('w-11 h-11 sm:w-14 sm:h-14 rounded-2xl bg-white p-2 sm:p-2.5', 'w-11 h-11 sm:w-14 sm:h-14 rounded-2xl bg-white p-1.5 sm:p-2.5')
    $h = $h.Replace('font-display text-lg sm:text-2xl font-bold text-novum-dark leading-tight break-words', 'font-display text-base min-[400px]:text-lg sm:text-2xl font-bold text-novum-dark leading-tight break-words')
    $h = $h.Replace('font-display text-lg sm:text-xl font-bold text-novum-dark leading-tight break-words', 'font-display text-base min-[400px]:text-lg sm:text-2xl font-bold text-novum-dark leading-tight break-words')

    # Timeline badge
    $h = $h.Replace('px-3.5 py-1.5 bg-novum-ice border border-blue-200 rounded-full text-xs font-bold text-novum-navy tracking-wider whitespace-nowrap self-start sm:self-center', 'px-2.5 min-[380px]:px-3.5 py-1 min-[380px]:py-1.5 bg-novum-ice border border-blue-200 rounded-full text-[11px] min-[380px]:text-xs font-bold text-novum-navy tracking-wider whitespace-nowrap self-start sm:self-center')
    $h = $h.Replace('px-3.5 py-1.5 bg-slate-100 border border-slate-200 rounded-full text-xs font-bold text-slate-600 tracking-wider whitespace-nowrap self-start sm:self-center', 'px-2.5 min-[380px]:px-3.5 py-1 min-[380px]:py-1.5 bg-slate-100 border border-slate-200 rounded-full text-[11px] min-[380px]:text-xs font-bold text-slate-600 tracking-wider whitespace-nowrap self-start sm:self-center')

    # Multi-line match for all timeline header blocks: ensure flex container has min-w-0 flex-1
    $h = [regex]::Replace($h, 'class="flex items-center gap-3\.5 sm:gap-4">\s*(<div[^>]*>.*?</div>|<!--.*?-->\s*<div[^>]*>.*?</div>)\s*<div>\s*<h3', {
        param($m)
        'class="flex items-center gap-3 sm:gap-4 min-w-0 flex-1">' + "`r`n" +
        '                                    ' + $m.Groups[1].Value.Trim() + "`r`n" +
        '                                    <div class="min-w-0 flex-1">' + "`r`n" +
        '                                        <h3'
    }, [System.Text.RegularExpressions.RegexOptions]::Singleline)

    # 5. Skills & Education cards: replace excessive p-10 with responsive padding
    $h = $h.Replace('glass-panel p-10 rounded-3xl reveal delay-100 flex flex-col justify-between', 'glass-panel p-5 min-[400px]:p-8 sm:p-10 rounded-3xl reveal delay-100 flex flex-col justify-between')
    $h = $h.Replace('glass-panel p-10 rounded-3xl reveal', 'glass-panel p-5 min-[400px]:p-8 sm:p-10 rounded-3xl reveal')
    $h = $h.Replace('font-display text-2xl font-bold text-novum-dark mb-6 flex items-center gap-3', 'font-display text-xl sm:text-2xl font-bold text-novum-dark mb-6 flex items-center gap-3')
    $h = $h.Replace('font-display text-2xl font-bold text-novum-dark mb-6', 'font-display text-xl sm:text-2xl font-bold text-novum-dark mb-6')
    $h = $h.Replace('mb-10 bg-novum-soft p-6 rounded-2xl border border-slate-200', 'mb-10 bg-novum-soft p-4 sm:p-6 rounded-2xl border border-slate-200')
    $h = $h.Replace('h4 class="font-bold text-novum-navy text-lg"', 'h4 class="font-bold text-novum-navy text-base sm:text-lg break-words"')

    # Other cards with static p-8
    $h = $h.Replace('glass-panel p-8 rounded-2xl flex flex-col relative overflow-hidden group', 'glass-panel p-5 min-[400px]:p-6 sm:p-8 rounded-2xl flex flex-col relative overflow-hidden group')
    $h = $h.Replace('bg-novum-gradient rounded-3xl p-10 md:p-12 flex flex-col', 'bg-novum-gradient rounded-3xl p-6 sm:p-10 md:p-12 flex flex-col')

    # 6. Languages grid: 1 column on phone (<sm), 2 columns on sm+
    $h = $h.Replace('<div class="grid grid-cols-2 gap-4 text-sm">', '<div class="grid grid-cols-1 sm:grid-cols-2 gap-3 sm:gap-4 text-sm">')
    $h = $h.Replace('<div class="bg-novum-soft p-4 rounded-xl border border-slate-200">', '<div class="bg-novum-soft p-3.5 sm:p-4 rounded-xl border border-slate-200 flex items-center justify-between sm:block">')
    $h = $h.Replace('<strong class="text-novum-dark block mb-1">', '<strong class="text-novum-dark block sm:mb-1">')

    # 7. Contact email cards: min-w-0 flex-1
    $h = $h.Replace('class="glass-panel p-4 rounded-xl flex items-center gap-3.5 group hover:-translate-y-0.5 transition-all">', 'class="glass-panel p-4 rounded-xl flex items-center gap-3.5 group hover:-translate-y-0.5 transition-all min-w-0">')
    $h = [regex]::Replace($h, 'class="glass-panel p-4 rounded-xl flex items-center gap-3\.5 group hover:-translate-y-0\.5 transition-all min-w-0">\s*([^\r\n]+)\s*<div>\s*<p class="text-xs', {
        param($m)
        'class="glass-panel p-4 rounded-xl flex items-center gap-3.5 group hover:-translate-y-0.5 transition-all min-w-0">' + "`r`n" +
        '                        ' + $m.Groups[1].Value.Trim() + "`r`n" +
        '                        <div class="min-w-0 flex-1">' + "`r`n" +
        '                            <p class="text-xs'
    })

    [System.IO.File]::WriteAllText($p, $h, $utf8)
    Write-Host "$f patched successfully"
}
