$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$jsonPath = Join-Path $PSScriptRoot 'option1-config.json'
$jsonText = [System.IO.File]::ReadAllText($jsonPath, $utf8)
$config = ConvertFrom-Json $jsonText

$jsSnippet = @'

        // Experience Timeline Toggle (Option 1)
        (function() {
            var expBtn = document.getElementById('toggle-experience-btn');
            var expContainer = document.getElementById('earlier-experience');
            var expText = document.getElementById('experience-btn-text');
            var expChevron = document.getElementById('experience-chevron');
            if (!expBtn || !expContainer || !expText || !expChevron) return;

            expBtn.addEventListener('click', function() {
                var isHidden = expContainer.classList.contains('hidden');
                if (isHidden) {
                    expContainer.classList.remove('hidden');
                    expBtn.setAttribute('aria-expanded', 'true');
                    expChevron.classList.add('rotate-180');
                    expText.textContent = expBtn.getAttribute('data-less-text') || 'Show Less';
                    expContainer.querySelectorAll('.reveal').forEach(function(el) {
                        el.classList.add('active');
                    });
                } else {
                    expContainer.classList.add('hidden');
                    expBtn.setAttribute('aria-expanded', 'false');
                    expChevron.classList.remove('rotate-180');
                    expText.textContent = expBtn.getAttribute('data-more-text') || 'View Earlier Experience';
                    expBtn.scrollIntoView({ behavior: 'smooth', block: 'center' });
                }
            });
        })();
'@

foreach ($prop in $config.PSObject.Properties) {
    $file = $prop.Name
    $cfg = $prop.Value
    $moreText = $cfg.more
    $lessText = $cfg.less

    $filePath = Join-Path $root $file
    $content = [System.IO.File]::ReadAllText($filePath, $utf8)

    $pashaIdx = $content.IndexOf('<!-- 4. PASHA Travel -->')
    if ($pashaIdx -lt 0) {
        Write-Error "Could not find <!-- 4. PASHA Travel --> in $file"
        continue
    }

    $caspianCommentIdx = $content.IndexOf('<!-- 11. Caspian Business Hotel -->', $pashaIdx)
    if ($caspianCommentIdx -lt 0) {
        Write-Error "Could not find <!-- 11. Caspian Business Hotel --> in $file"
        continue
    }

    $sectionEndIdx = $content.IndexOf('</section>', $caspianCommentIdx)
    $beforeSection = $content.Substring(0, $sectionEndIdx)
    $timelineCloseIdx = $beforeSection.LastIndexOf('</div>')
    $beforeTimeline = $beforeSection.Substring(0, $timelineCloseIdx)
    $timelineCloseIdx2 = $beforeTimeline.LastIndexOf('</div>')

    $roles4to11 = $content.Substring($pashaIdx, $timelineCloseIdx2 - $pashaIdx).TrimEnd()

    $buttonHtml = @"
                    <!-- Collapsible Earlier Roles (4 to 11) -->
                    <div id="earlier-experience" class="hidden space-y-10 mt-10">
$roles4to11
                    </div>

                    <!-- Earlier Experience Expand Button (Option 1) -->
                    <div class="relative pl-7 sm:pl-10 md:pl-12 pt-2">
                        <button id="toggle-experience-btn" type="button" aria-expanded="false" aria-controls="earlier-experience" data-more-text="$moreText" data-less-text="$lessText" class="inline-flex items-center gap-3 px-6 py-4 rounded-2xl bg-white hover:bg-blue-50/70 border-2 border-dashed border-blue-200 hover:border-novum-navy text-novum-navy font-bold text-sm shadow-xs hover:shadow-md transition-all group cursor-pointer w-full justify-center">
                            <span class="w-7 h-7 rounded-full bg-blue-50 text-novum-navy flex items-center justify-center group-hover:bg-novum-navy group-hover:text-white transition-all transform group-hover:scale-105">
                                <svg class="w-4 h-4 transition-transform duration-300" id="experience-chevron" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/></svg>
                            </span>
                            <span id="experience-btn-text">$moreText</span>
                        </button>
                    </div>

"@

    $newContent = $content.Substring(0, $pashaIdx) + $buttonHtml + $content.Substring($timelineCloseIdx2)

    if (-not $newContent.Contains('// Experience Timeline Toggle')) {
        $lastScript = $newContent.LastIndexOf('</script>')
        $newContent = $newContent.Substring(0, $lastScript) + $jsSnippet + "`r`n    " + $newContent.Substring($lastScript)
    }

    [System.IO.File]::WriteAllText($filePath, $newContent, $utf8)
    Write-Host "$file updated successfully with Option 1"
}
