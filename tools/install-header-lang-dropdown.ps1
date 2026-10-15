$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$jsonText = [System.IO.File]::ReadAllText((Join-Path $PSScriptRoot 'dropdown-assets.json'), $utf8)
$data = $jsonText | ConvertFrom-Json

$flags = $data.flags
$languages = $data.languages

foreach ($prop in $data.pages.PSObject.Properties) {
    $fileName = $prop.Name
    $pageCfg = $prop.Value
    $currLang = $pageCfg.lang
    $bookText = $pageCfg.bookText
    $emailText = $pageCfg.emailText

    $filePath = Join-Path $root $fileName
    $content = [System.IO.File]::ReadAllText($filePath, $utf8)

    # 1. Remove the floating widget from after </header>
    $content = [regex]::Replace($content, '(?s)\s*<!-- Floating Language Switcher Widget \(Option C\) -->.*?<\/aside>', '')

    # 2. Build the Desktop Dropdown items and Mobile Dropdown items
    $currFlag = $flags.$currLang
    $currCode = ($languages | Where-Object { $_.id -eq $currLang }).code

    $desktopItems = ''
    $mobileItems = ''
    foreach ($lang in $languages) {
        $lId = $lang.id
        $lFlag = $flags.$lId
        $lCode = $lang.code
        $lName = $lang.name
        $lFile = $lang.file

        if ($lId -eq $currLang) {
            $desktopItems += @"
                <a href="$lFile" class="flex items-center gap-3 px-3.5 py-2.5 text-xs font-bold text-novum-navy bg-blue-50/70 transition-colors">
                    $lFlag
                    <span>$lName</span>
                    <svg class="w-3.5 h-3.5 ml-auto text-novum-navy" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                </a>
"@
            $mobileItems += @"
                <a href="$lFile" class="flex items-center gap-2.5 px-3 py-2 text-xs font-bold text-novum-navy bg-blue-50/70 transition-colors">
                    $lFlag
                    <span>$lName</span>
                    <svg class="w-3 h-3 ml-auto text-novum-navy" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="3"><path stroke-linecap="round" stroke-linejoin="round" d="M5 13l4 4L19 7"/></svg>
                </a>
"@
        } else {
            $desktopItems += @"
                <a href="$lFile" class="flex items-center gap-3 px-3.5 py-2.5 text-xs font-semibold text-slate-700 hover:text-novum-navy hover:bg-slate-50 transition-colors">
                    $lFlag
                    <span>$lName</span>
                </a>
"@
            $mobileItems += @"
                <a href="$lFile" class="flex items-center gap-2.5 px-3 py-2 text-xs font-semibold text-slate-700 hover:text-novum-navy hover:bg-slate-50 transition-colors">
                    $lFlag
                    <span>$lName</span>
                </a>
"@
        }
    }

    $desktopDropdownHtml = @"
                <!-- Language Dropdown (Desktop) -->
                <div class="relative ml-1" id="lang-dropdown-wrapper">
                    <button id="lang-menu-btn" type="button" aria-expanded="false" aria-haspopup="true" class="flex items-center gap-2 px-3 py-2 rounded-xl bg-slate-50 hover:bg-blue-50/70 border border-slate-200 text-novum-dark font-bold text-xs transition-all shadow-xs cursor-pointer group">
                        $currFlag
                        <span>$currCode</span>
                        <svg class="w-3.5 h-3.5 text-slate-400 group-hover:text-novum-navy transition-transform duration-200" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/></svg>
                    </button>
                    <div id="lang-menu-dropdown" class="hidden absolute right-0 mt-2 w-48 rounded-2xl bg-white border border-slate-200 shadow-xl py-1.5 z-50">
$desktopItems
                    </div>
                </div>
            </div>
"@

    # Remove any existing desktop lang dropdown first
    $content = [regex]::Replace($content, '(?s)\s*<!-- Language Dropdown \(Desktop\) -->.*?<\/div>\s*<\/div>\s*<\/div>', '            </div>')

    # Insert into desktop-nav right after Contact Me link
    $content = [regex]::Replace($content, '(?s)(<a href="#contact" class="px-6 py-2\.5 bg-novum-navy text-white rounded-full hover:bg-novum-hover transition-all font-semibold shadow-sm">.*?</a>)\s*</div>', "`$1`r`n$desktopDropdownHtml")

    # Ensure gap in desktop-nav is clean
    $content = $content.Replace('hidden lg:flex items-center gap-8 text-sm font-semibold', 'hidden lg:flex items-center gap-5 text-sm font-semibold')

    # 3. Mobile Header: insert mobile language dropdown next to hamburger button
    $mobileHeaderControls = @"
            <!-- Mobile Header Controls: Flag Dropdown + Hamburger -->
            <div class="flex items-center gap-2 lg:hidden">
                <div class="relative" id="mobile-lang-dropdown-wrapper">
                    <button id="mobile-lang-menu-btn" type="button" aria-expanded="false" aria-haspopup="true" class="flex items-center gap-1.5 px-2.5 py-1.5 rounded-xl bg-slate-100 hover:bg-slate-200 text-novum-dark font-bold text-xs transition-all border border-slate-200 shadow-xs cursor-pointer">
                        $currFlag
                        <span>$currCode</span>
                        <svg class="w-3 h-3 text-slate-500" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2.5"><path stroke-linecap="round" stroke-linejoin="round" d="M19 9l-7 7-7-7"/></svg>
                    </button>
                    <div id="mobile-lang-menu-dropdown" class="hidden absolute right-0 mt-2 w-44 rounded-2xl bg-white border border-slate-200 shadow-xl py-1.5 z-50">
$mobileItems
                    </div>
                </div>

                <button id="mobile-menu-btn" type="button" class="p-2 text-novum-dark hover:text-novum-navy focus:outline-none">
                    <svg class="w-6 h-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" stroke-width="2" id="menu-icon-open">
                        <path stroke-linecap="round" stroke-linejoin="round" d="M4 6h16M4 12h16M4 18h16" />
                    </svg>
                </button>
            </div>
"@

    # Remove existing mobile header controls or old mobile-menu-btn
    $content = [regex]::Replace($content, '(?s)\s*<!-- Mobile (Hamburger Toggle Button|Header Controls:).*?<\/div>\s*<\/nav>', "$mobileHeaderControls`r`n        </nav>")
    $content = [regex]::Replace($content, '(?s)\s*<button id="mobile-menu-btn".*?<\/button>\s*<\/nav>', "$mobileHeaderControls`r`n        </nav>")

    # 4. Action buttons in #contact: remove Chat on WhatsApp button so only Book call & Send Email remain
    $newActionBtns = @"
                <!-- Action Buttons -->
                <div class="flex flex-col sm:flex-row justify-center items-center gap-4 mb-10">
                    <a href="mailto:toghrul.aghabalazada@novum.tech" class="w-full sm:w-auto px-8 py-4 bg-novum-navy text-white font-bold rounded-xl hover:bg-novum-hover hover:shadow-lg transition-all text-center">
                        $bookText
                    </a>
                    <a href="mailto:toghrulaghabalazada@gmail.com" class="w-full sm:w-auto px-8 py-4 bg-white text-novum-navy font-bold rounded-xl border-2 border-novum-navy hover:bg-novum-navy hover:text-white transition-colors shadow-sm text-center">
                        $emailText
                    </a>
                </div>
"@

    $content = [regex]::Replace($content, '(?s)<!-- Action Buttons -->\s*<div class="flex flex-col sm:flex-row justify-center items-center gap-[^"]*mb-10">.*?<\/div>', $newActionBtns)

    # 5. Dropdown toggle script
    $dropdownScript = @"

        // Language Dropdown Toggle (Desktop & Mobile)
        function setupLangDropdown(btnId, menuId) {
            var btn = document.getElementById(btnId);
            var menu = document.getElementById(menuId);
            if (!btn || !menu) return;
            btn.addEventListener('click', function(e) {
                e.stopPropagation();
                var isOpen = !menu.classList.contains('hidden');
                document.querySelectorAll('[id$="lang-menu-dropdown"]').forEach(function(m) { m.classList.add('hidden'); });
                document.querySelectorAll('[id$="lang-menu-btn"]').forEach(function(b) { b.setAttribute('aria-expanded', 'false'); });
                if (!isOpen) {
                    menu.classList.remove('hidden');
                    btn.setAttribute('aria-expanded', 'true');
                }
            });
        }
        setupLangDropdown('lang-menu-btn', 'lang-menu-dropdown');
        setupLangDropdown('mobile-lang-menu-btn', 'mobile-lang-menu-dropdown');

        document.addEventListener('click', function(e) {
            if (!e.target.closest('#lang-dropdown-wrapper') && !e.target.closest('#mobile-lang-dropdown-wrapper')) {
                document.querySelectorAll('[id$="lang-menu-dropdown"]').forEach(function(m) { m.classList.add('hidden'); });
                document.querySelectorAll('[id$="lang-menu-btn"]').forEach(function(b) { b.setAttribute('aria-expanded', 'false'); });
            }
        });

        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                document.querySelectorAll('[id$="lang-menu-dropdown"]').forEach(function(m) { m.classList.add('hidden'); });
                document.querySelectorAll('[id$="lang-menu-btn"]').forEach(function(b) { b.setAttribute('aria-expanded', 'false'); });
            }
        });
"@

    # Remove existing dropdown script if present
    $content = [regex]::Replace($content, '(?s)\s*\/\/ Language Dropdown Toggle.*?document\.addEventListener\(''keydown'', function\(e\).*?\}\);', '')

    # Insert before </script>
    $content = $content.Replace('</script>', "$dropdownScript`r`n    </script>")

    [System.IO.File]::WriteAllText($filePath, $content, $utf8)
    Write-Host "$fileName successfully updated with Nav Flag Dropdown & WhatsApp single card"
}
