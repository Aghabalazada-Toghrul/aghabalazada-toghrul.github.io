$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$utf8 = New-Object System.Text.UTF8Encoding($false)

$files = @('index.html', 'index_az.html', 'index_tr.html', 'index_ru.html')

$cleanHeadScript = "<script>document.documentElement.className += ' js';</script>"

$dropdownJs = @"

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

foreach ($f in $files) {
    $p = Join-Path $root $f
    $h = [System.IO.File]::ReadAllText($p, $utf8)

    # 1. Clean head script: remove any dropdown functions injected into head
    $h = [regex]::Replace($h, '(?s)<script>document\.documentElement\.className \+= '' js'';.*?<\/script>\s*<\/head>', "$cleanHeadScript`r`n</head>")

    # 2. Responsive brand link in navbar: match regardless of translated alt and span
    $brandPattern = '(?s)<a href="#top" class="font-display font-bold [^"]*text-novum-dark tracking-tight flex items-center gap-[^"]*">\s*<img src="assets/img/novum_icon\.png" alt="([^"]*)" class="[^"]*">\s*<span[^>]*>([^<]*)</span>\s*</a>'
    $brandReplacement = @"
<a href="#top" class="font-display font-bold text-base min-[400px]:text-lg sm:text-xl text-novum-dark tracking-tight flex items-center gap-2 sm:gap-3 min-w-0 flex-shrink">
                <img src="assets/img/novum_icon.png" alt="`$1" class="w-8 h-8 sm:w-9 sm:h-9 rounded-lg object-cover shadow-xs border border-blue-100 flex-shrink-0">
                <span class="truncate">`$2</span>
            </a>
"@
    $h = [regex]::Replace($h, $brandPattern, $brandReplacement)

    # 3. Clean bottom script: ensure setupLangDropdown is present once before </script> in body
    # Remove any existing setupLangDropdown blocks in body
    $h = [regex]::Replace($h, '(?s)\s*\/\/ Language Dropdown Toggle.*?document\.addEventListener\(''keydown'', function\(e\).*?\}\);', '')
    
    # Insert before the last </script>
    $lastScriptIdx = $h.LastIndexOf('</script>')
    if ($lastScriptIdx -gt 0) {
        $h = $h.Substring(0, $lastScriptIdx) + $dropdownJs + "`r`n    " + $h.Substring($lastScriptIdx)
    }

    [System.IO.File]::WriteAllText($p, $h, $utf8)
    Write-Host "$f cleaned and perfected"
}
