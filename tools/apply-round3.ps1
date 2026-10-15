$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$svgs = @{
  gb = '<svg class="w-full h-full block" viewBox="0 0 640 480" aria-hidden="true" focusable="false"><path fill="#012169" d="M0 0h640v480H0z"/><path fill="#FFF" d="m75 0 244 181L562 0h78v62L400 241l240 178v61h-80L320 301 81 480H0v-60l239-178L0 64V0z"/><path fill="#C8102E" d="m424 281 216 159v40L369 281zm-184 20 6 35L54 480H0zM640 0v3L391 191l2-44L590 0zM0 0l239 176h-60L0 42z"/><path fill="#FFF" d="M241 0v480h160V0zM0 160v160h640V160z"/><path fill="#C8102E" d="M0 193v96h640v-96zM273 0v480h96V0z"/></svg>'
  az = '<svg class="w-full h-full block" viewBox="0 0 640 480" aria-hidden="true" focusable="false"><path fill="#3f9c35" d="M.1 0h640v480H.1z"/><path fill="#ed2939" d="M.1 0h640v320H.1z"/><path fill="#00b9e4" d="M.1 0h640v160H.1z"/><circle cx="304" cy="240" r="72" fill="#fff"/><circle cx="320" cy="240" r="60" fill="#ed2939"/><path fill="#fff" d="m384 200 7.7 21.5 20.6-9.8-9.8 20.7L424 240l-21.5 7.7 9.8 20.6-20.6-9.8L384 280l-7.7-21.5-20.6 9.8 9.8-20.6L344 240l21.5-7.7-9.8-20.6 20.6 9.8z"/></svg>'
  tr = '<svg class="w-full h-full block" viewBox="0 0 640 480" aria-hidden="true" focusable="false"><g fill-rule="evenodd"><path fill="#e30a17" d="M0 0h640v480H0z"/><path fill="#fff" d="M407 247.5c0 66.2-54.6 119.9-122 119.9s-122-53.7-122-120 54.6-119.8 122-119.8 122 53.7 122 119.9"/><path fill="#e30a17" d="M413 247.5c0 53-43.6 95.9-97.5 95.9s-97.6-43-97.6-96 43.7-95.8 97.6-95.8 97.6 42.9 97.6 95.9z"/><path fill="#fff" d="m430.7 191.5-1 44.3-41.3 11.2 40.8 14.5-1 40.7 26.5-31.8 40.2 14-23.2-34.1 28.3-33.9-43.5 12-25.8-37z"/></g></svg>'
  ru = '<svg class="w-full h-full block" viewBox="0 0 640 480" aria-hidden="true" focusable="false"><path fill="#fff" d="M0 0h640v160H0z"/><path fill="#0039a6" d="M0 160h640v160H0z"/><path fill="#d52b1e" d="M0 320h640v160H0z"/></svg>'
}
$wrapOpen = '<span class="w-6 h-[18px] rounded-[3px] overflow-hidden ring-1 ring-black/10 shadow-sm inline-flex flex-shrink-0">'

$flagPattern = '(?s)<span class="w-5 h-3\.5 rounded-xs shadow-xs overflow-hidden border border-slate-200 inline-flex flex-shrink-0">\s*<svg[^>]*viewBox="([^"]+)".*?</svg>\s*</span>'
$flagEval = {
    param($m)
    $vb = $m.Groups[1].Value
    $k = switch ($vb) { '0 0 60 30' {'gb'} '0 0 1200 600' {'az'} '0 0 1200 800' {'tr'} '0 0 900 600' {'ru'} default {$null} }
    if (-not $k) { return $m.Value }
    return $wrapOpen + $svgs[$k] + '</span>'
}

foreach ($f in 'index.html','index_az.html','index_tr.html','index_ru.html') {
    $p = Join-Path $root $f
    $h = [System.IO.File]::ReadAllText($p, $utf8)

    # 1. Remove arrow from the "Connect" hero button
    $h = [regex]::Replace($h, '\s*<span class="text-lg transition-transform duration-300 group-hover:translate-x-1">[^<]*</span>', '')

    # 2. Remove footer WhatsApp link (next to LinkedIn)
    $h = [regex]::Replace($h, '(?s)\s*<a href="https://wa\.me/994702899778" target="_blank"[^>]*>.*?</a>', '')

    # 3. "the UAE" -> "UAE" (English)
    $h = $h.Replace('Azerbaijan, the UAE, Bahrain', 'Azerbaijan, UAE, Bahrain')

    # 4. Remove approach description paragraph
    $h = [regex]::Replace($h, '(?s)(<h2 id="value-heading"[^>]*>[^<]*</h2>)\s*<p class="text-slate-600 text-lg">.*?</p>', '$1')

    # 5. Higher quality flags
    $h = [regex]::Replace($h, $flagPattern, $flagEval)

    [System.IO.File]::WriteAllText($p, $h, $utf8)
    Write-Host ($f + ' updated')
}
