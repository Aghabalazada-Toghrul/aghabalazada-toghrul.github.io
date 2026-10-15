$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$jsonPath = Join-Path $PSScriptRoot 'whatsapp-config.json'
$jsonText = [System.IO.File]::ReadAllText($jsonPath, $utf8)
$configs = $jsonText | ConvertFrom-Json

$waSvg = '<svg class="w-5 h-5 fill-current" viewBox="0 0 24 24"><path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946.003-6.556 5.338-11.891 11.893-11.891 3.181.001 6.167 1.24 8.413 3.488 2.245 2.248 3.481 5.236 3.48 8.414-.003 6.557-5.338 11.892-11.893 11.892-1.99-.001-3.951-.5-5.688-1.448l-6.305 1.654zm6.597-3.807c1.676.995 3.276 1.591 5.392 1.592 5.448 0 9.886-4.434 9.889-9.885.002-5.462-4.415-9.89-9.881-9.892-5.452 0-9.887 4.434-9.889 9.884-.001 2.225.651 3.891 1.746 5.634l-.999 3.648 3.742-.981zm11.387-5.464c-.074-.124-.272-.198-.57-.347-.297-.149-1.758-.868-2.031-.967-.272-.099-.47-.149-.669.149-.198.297-.768.967-.941 1.165-.173.198-.347.223-.644.074-.297-.149-1.255-.462-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.297-.347.446-.521.151-.172.2-.296.3-.495.099-.198.05-.372-.025-.521-.075-.148-.669-1.611-.916-2.206-.242-.579-.487-.501-.669-.51l-.57-.01c-.198 0-.52.074-.792.372s-1.04 1.016-1.04 2.479 1.065 2.876 1.213 3.074c.149.198 2.095 3.2 5.076 4.487.709.306 1.263.489 1.694.626.712.226 1.36.194 1.872.118.571-.085 1.758-.719 2.006-1.413.248-.695.248-1.29.173-1.414z"/></svg>'

foreach ($prop in $configs.PSObject.Properties) {
    $f = $prop.Name
    $cfg = $prop.Value
    $p = Join-Path $root $f
    $h = [System.IO.File]::ReadAllText($p, $utf8)

    # 1. Action Buttons replacement
    $oldBtnsPattern = '(?s)<!-- Action Buttons -->\s*<div class="flex flex-col sm:flex-row justify-center gap-5 mb-10">.*?</div>'
    $newBtns = @"
                <!-- Action Buttons -->
                <div class="flex flex-col sm:flex-row justify-center items-center gap-3.5 sm:gap-4 mb-10">
                    <a href="https://wa.me/" target="_blank" rel="noopener noreferrer" class="w-full sm:w-auto px-7 py-4 bg-[#25D366] text-white font-bold rounded-xl hover:bg-[#20ba59] hover:shadow-lg transition-all shadow-sm flex items-center justify-center gap-2.5">
                        $waSvg
                        <span>$($cfg.btnText)</span>
                    </a>
                    <a href="mailto:toghrul.aghabalazada@novum.tech" class="w-full sm:w-auto px-7 py-4 bg-novum-navy text-white font-bold rounded-xl hover:bg-novum-hover hover:shadow-lg transition-all text-center">
                        $($cfg.bookText)
                    </a>
                    <a href="mailto:toghrulaghabalazada@gmail.com" class="w-full sm:w-auto px-7 py-4 bg-white text-novum-navy font-bold rounded-xl border-2 border-novum-navy hover:bg-novum-navy hover:text-white transition-colors shadow-sm text-center">
                        $($cfg.emailText)
                    </a>
                </div>
"@

    $h = [regex]::Replace($h, $oldBtnsPattern, $newBtns)

    # 2. Direct Contact Cards replacement
    $oldCardsPattern = '(?s)<!-- Direct Email Cards -->\s*<div class="grid grid-cols-1 sm:grid-cols-2 gap-4 max-w-2xl mx-auto mb-14 text-left">.*?</div>\s*</a>\s*</div>'
    $newCards = @"
                <!-- Direct Contact Cards -->
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 max-w-4xl mx-auto mb-14 text-left">
                    <a href="mailto:toghrul.aghabalazada@novum.tech" class="glass-panel p-4 rounded-xl flex items-center gap-3.5 group hover:-translate-y-0.5 transition-all min-w-0">
                        <div class="w-10 h-10 rounded-lg bg-novum-ice text-novum-navy flex items-center justify-center flex-shrink-0 group-hover:bg-novum-navy group-hover:text-white transition-colors">
                            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                            </svg>
                        </div>
                        <div class="min-w-0 flex-1">
                            <span class="block text-[11px] font-bold uppercase tracking-wider text-slate-400">$($cfg.workLabel)</span>
                            <span class="block text-sm font-bold text-novum-dark group-hover:text-novum-navy truncate transition-colors">toghrul.aghabalazada@novum.tech</span>
                        </div>
                    </a>

                    <a href="https://wa.me/" target="_blank" rel="noopener noreferrer" class="glass-panel p-4 rounded-xl flex items-center gap-3.5 group hover:-translate-y-0.5 transition-all min-w-0 border-emerald-200/80 hover:border-emerald-400">
                        <div class="w-10 h-10 rounded-lg bg-emerald-50 text-[#25D366] flex items-center justify-center flex-shrink-0 group-hover:bg-[#25D366] group-hover:text-white transition-colors">
                            $waSvg
                        </div>
                        <div class="min-w-0 flex-1">
                            <span class="block text-[11px] font-bold uppercase tracking-wider text-emerald-600 font-extrabold">$($cfg.cardLabel)</span>
                            <span class="block text-sm font-bold text-novum-dark group-hover:text-[#25D366] truncate transition-colors">$($cfg.cardText)</span>
                        </div>
                    </a>

                    <a href="mailto:toghrulaghabalazada@gmail.com" class="glass-panel p-4 rounded-xl flex items-center gap-3.5 group hover:-translate-y-0.5 transition-all min-w-0">
                        <div class="w-10 h-10 rounded-lg bg-novum-ice text-novum-navy flex items-center justify-center flex-shrink-0 group-hover:bg-novum-navy group-hover:text-white transition-colors">
                            <svg class="w-5 h-5" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2">
                                <path stroke-linecap="round" stroke-linejoin="round" d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z" />
                            </svg>
                        </div>
                        <div class="min-w-0 flex-1">
                            <span class="block text-[11px] font-bold uppercase tracking-wider text-slate-400">$($cfg.personalLabel)</span>
                            <span class="block text-sm font-bold text-novum-dark group-hover:text-novum-navy truncate transition-colors">toghrulaghabalazada@gmail.com</span>
                        </div>
                    </a>
                </div>
"@

    $h = [regex]::Replace($h, $oldCardsPattern, $newCards)

    # 3. Footer link: add WhatsApp if not already present
    if ($h -notmatch 'WhatsApp\s*</a>') {
        $liPattern = '(?s)(<a href="https://www\.linkedin\.com/in/toghrul-aghabalazada-26249719a/".*?LinkedIn\s*</a>)'
        $waFooterLink = @"
`$1
                    <a href="https://wa.me/" target="_blank" rel="noopener noreferrer" class="hover:text-[#25D366] transition-colors flex items-center gap-2 font-semibold text-novum-dark">
                        <svg class="w-4 h-4 text-[#25D366] fill-current" viewBox="0 0 24 24"><path d="M.057 24l1.687-6.163c-1.041-1.804-1.588-3.849-1.587-5.946.003-6.556 5.338-11.891 11.893-11.891 3.181.001 6.167 1.24 8.413 3.488 2.245 2.248 3.481 5.236 3.48 8.414-.003 6.557-5.338 11.892-11.893 11.892-1.99-.001-3.951-.5-5.688-1.448l-6.305 1.654zm6.597-3.807c1.676.995 3.276 1.591 5.392 1.592 5.448 0 9.886-4.434 9.889-9.885.002-5.462-4.415-9.89-9.881-9.892-5.452 0-9.887 4.434-9.889 9.884-.001 2.225.651 3.891 1.746 5.634l-.999 3.648 3.742-.981zm11.387-5.464c-.074-.124-.272-.198-.57-.347-.297-.149-1.758-.868-2.031-.967-.272-.099-.47-.149-.669.149-.198.297-.768.967-.941 1.165-.173.198-.347.223-.644.074-.297-.149-1.255-.462-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.297-.347.446-.521.151-.172.2-.296.3-.495.099-.198.05-.372-.025-.521-.075-.148-.669-1.611-.916-2.206-.242-.579-.487-.501-.669-.51l-.57-.01c-.198 0-.52.074-.792.372s-1.04 1.016-1.04 2.479 1.065 2.876 1.213 3.074c.149.198 2.095 3.2 5.076 4.487.709.306 1.263.489 1.694.626.712.226 1.36.194 1.872.118.571-.085 1.758-.719 2.006-1.413.248-.695.248-1.29.173-1.414z"/></svg>
                        WhatsApp
                    </a>
"@
        $h = [regex]::Replace($h, $liPattern, $waFooterLink)
    }

    [System.IO.File]::WriteAllText($p, $h, $utf8)
    Write-Host "$f updated successfully"
}
