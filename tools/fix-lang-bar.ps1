$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)
foreach ($f in 'index.html', 'index_az.html', 'index_tr.html', 'index_ru.html') {
    $p = Join-Path $root $f
    $h = [System.IO.File]::ReadAllText($p, $utf8)

    # Language bar fits 320-360px phones
    $h = $h.Replace('<div class="w-full flex justify-center lg:justify-end items-center gap-2 mb-4">', '<div class="w-full flex flex-wrap justify-center lg:justify-end items-center gap-2 mb-4">')
    $h = $h.Replace('<span class="text-xs font-bold text-slate-500 uppercase tracking-wider mr-1">', '<span class="hidden sm:inline text-xs font-bold text-slate-500 uppercase tracking-wider mr-1">')
    $h = $h.Replace('lang-selector-btn px-3.5 py-1.5', 'lang-selector-btn px-2.5 sm:px-3.5 py-1.5')

    # Headlines scale down on small phones so long words never overflow
    $h = $h.Replace('font-display text-5xl sm:text-6xl lg:text-7xl', 'font-display text-[2.5rem] min-[440px]:text-5xl sm:text-6xl lg:text-7xl')
    $h = $h.Replace('font-display text-3xl sm:text-4xl font-extrabold text-novum-dark tracking-tight', 'font-display text-2xl min-[400px]:text-3xl sm:text-4xl font-extrabold text-novum-dark tracking-tight')
    $h = $h.Replace('font-display text-4xl md:text-5xl font-extrabold', 'font-display text-3xl sm:text-4xl md:text-5xl font-extrabold')
    $h = $h.Replace('font-display text-4xl font-extrabold', 'font-display text-3xl sm:text-4xl font-extrabold')
    $h = $h.Replace('font-display text-5xl md:text-6xl font-extrabold', 'font-display text-3xl sm:text-5xl md:text-6xl font-extrabold')

    [System.IO.File]::WriteAllText($p, $h, $utf8)
    "{0}: langbar={1} h1={2}" -f $f, ([regex]::Matches($h, 'px-2\.5 sm:px-3\.5 py-1\.5')).Count, ($h -match 'min-\[440px\]:text-5xl')
}
