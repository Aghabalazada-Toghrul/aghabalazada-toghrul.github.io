$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$shots = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch'

# 1. Desktop dropdown open
$htmlDropdown = @'
<!DOCTYPE html>
<html><body style="margin:0;padding:0;">
<iframe id="f" src="index.html" style="width:1280px;height:700px;border:none;"></iframe>
<script>
window.onload = () => setTimeout(() => {
    const f = document.getElementById('f');
    const doc = f.contentDocument;
    const btn = doc.getElementById('lang-menu-btn');
    if (btn) btn.click();
}, 800);
</script>
</body></html>
'@
[System.IO.File]::WriteAllText('dist\_showcase_dropdown.html', $htmlDropdown)
$outDrop = Join-Path $shots 'showcase_lang_dropdown.png'
$a1 = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=1280,450', '--virtual-time-budget=3000', "--screenshot=$outDrop", 'http://localhost:8123/_showcase_dropdown.html')
Start-Process -FilePath $edge -ArgumentList $a1 -Wait -WindowStyle Hidden

# 2. Contact Section preview page (shows contact section directly at top)
$contactHtml = @'
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <link rel="stylesheet" href="assets/site.css">
    <link rel="preload" href="assets/fonts/inter-latin.woff2" as="font" type="font/woff2" crossorigin>
</head>
<body class="bg-novum-light p-8">
    <div id="contact-wrap" class="max-w-4xl mx-auto">
    </div>
    <script>
    fetch('index.html')
        .then(r => r.text())
        .then(html => {
            const parser = new DOMParser();
            const doc = parser.parseFromString(html, 'text/html');
            const contact = doc.getElementById('contact');
            document.getElementById('contact-wrap').appendChild(contact);
        });
    </script>
</body>
</html>
'@
[System.IO.File]::WriteAllText('dist\_showcase_contact.html', $contactHtml)
$outContact = Join-Path $shots 'showcase_contact_section.png'
$a2 = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=1200,750', '--virtual-time-budget=3000', "--screenshot=$outContact", 'http://localhost:8123/_showcase_contact.html')
Start-Process -FilePath $edge -ArgumentList $a2 -Wait -WindowStyle Hidden

# 3. Mobile Header (iframe 390px inside a container)
$mobileHeaderHtml = @'
<!DOCTYPE html>
<html>
<body style="margin:0;padding:20px;background:#f1f5f9;display:flex;justify-content:center;">
    <div style="width:390px;box-shadow:0 10px 30px rgba(0,0,0,0.15);border-radius:24px;overflow:hidden;background:#fff;border:1px solid #cbd5e1;">
        <iframe id="f" src="index.html" style="width:390px;height:400px;border:none;display:block;"></iframe>
    </div>
</body>
</html>
'@
[System.IO.File]::WriteAllText('dist\_showcase_mobile.html', $mobileHeaderHtml)
$outMob = Join-Path $shots 'showcase_mobile_header.png'
$a3 = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=600,500', '--virtual-time-budget=3000', "--screenshot=$outMob", 'http://localhost:8123/_showcase_mobile.html')
Start-Process -FilePath $edge -ArgumentList $a3 -Wait -WindowStyle Hidden

Write-Host "Dropdown shot: $(Test-Path $outDrop)"
Write-Host "Contact shot: $(Test-Path $outContact)"
Write-Host "Mobile header shot: $(Test-Path $outMob)"
