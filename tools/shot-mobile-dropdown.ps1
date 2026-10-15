$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$shots = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch'

$mobileOpenHtml = @'
<!DOCTYPE html>
<html>
<body style="margin:0;padding:20px;background:#f1f5f9;display:flex;justify-content:center;">
    <div style="width:390px;box-shadow:0 10px 30px rgba(0,0,0,0.15);border-radius:24px;overflow:hidden;background:#fff;border:1px solid #cbd5e1;">
        <iframe id="f" src="index.html" style="width:390px;height:450px;border:none;display:block;"></iframe>
    </div>
<script>
window.onload = () => setTimeout(() => {
    const f = document.getElementById('f');
    const doc = f.contentDocument;
    const btn = doc.getElementById('mobile-lang-menu-btn');
    if (btn) btn.click();
}, 800);
</script>
</body>
</html>
'@
[System.IO.File]::WriteAllText('dist\_showcase_mobile_open.html', $mobileOpenHtml)
$outMobOpen = Join-Path $shots 'showcase_mobile_dropdown_open.png'
$a = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=600,550', '--virtual-time-budget=3000', "--screenshot=$outMobOpen", 'http://localhost:8123/_showcase_mobile_open.html')
Start-Process -FilePath $edge -ArgumentList $a -Wait -WindowStyle Hidden

Write-Host "Mobile dropdown open shot: $(Test-Path $outMobOpen)"
