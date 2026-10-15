$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$shots = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch'

$wrapDesktop = @'
<!DOCTYPE html>
<html><body style="margin:0;padding:0;">
<iframe id="f" src="index.html" style="width:1280px;height:800px;border:none;"></iframe>
<script>
window.onload = () => {
    setTimeout(() => {
        const f = document.getElementById('f');
        const doc = f.contentDocument;
        const btn = doc.getElementById('lang-menu-btn');
        if (btn) btn.click();
    }, 1000);
};
</script>
</body></html>
'@
$htmlDesk = 'dist\_test_open_desk.html'
[System.IO.File]::WriteAllText($htmlDesk, $wrapDesktop)

$outDesk = Join-Path $shots 'dropdown_open_desktop.png'
$aDesk = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=1280,800', '--virtual-time-budget=4000', "--screenshot=$outDesk", "http://localhost:8123/_test_open_desk.html")
Start-Process -FilePath $edge -ArgumentList $aDesk -Wait -WindowStyle Hidden

Write-Host "Dropdown desktop shot: $(Test-Path $outDesk)"
