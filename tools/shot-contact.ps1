$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$shots = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch'
$outMobile = Join-Path $shots 'contact_mobile.png'
$outDesktop = Join-Path $shots 'contact_desktop.png'

# Mobile view of Contact section
$htmlMobile = @'
<!DOCTYPE html>
<html><body style="margin:0;padding:0;">
<iframe id="f" src="index.html#contact" style="width:390px;height:1200px;border:none;"></iframe>
<script>
window.onload = () => setTimeout(() => {
    const f = document.getElementById('f');
    f.contentDocument.querySelector('#contact').scrollIntoView();
}, 1000);
</script>
</body></html>
'@
$wrapMob = 'dist\_wrap_mobile_contact.html'
[System.IO.File]::WriteAllText($wrapMob, $htmlMobile)

$aMobile = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=400,950', '--virtual-time-budget=4000', "--screenshot=$outMobile", "http://localhost:8123/_wrap_mobile_contact.html")
Start-Process -FilePath $edge -ArgumentList $aMobile -Wait -WindowStyle Hidden

# Desktop view
$htmlDesktop = @'
<!DOCTYPE html>
<html><body style="margin:0;padding:0;">
<iframe id="f" src="index.html#contact" style="width:1280px;height:1200px;border:none;"></iframe>
<script>
window.onload = () => setTimeout(() => {
    const f = document.getElementById('f');
    f.contentDocument.querySelector('#contact').scrollIntoView();
}, 1000);
</script>
</body></html>
'@
$wrapDesk = 'dist\_wrap_desk_contact.html'
[System.IO.File]::WriteAllText($wrapDesk, $htmlDesktop)

$aDesk = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=1280,950', '--virtual-time-budget=4000', "--screenshot=$outDesktop", "http://localhost:8123/_wrap_desk_contact.html")
Start-Process -FilePath $edge -ArgumentList $aDesk -Wait -WindowStyle Hidden

Write-Host "Mobile Contact shot: $(Test-Path $outMobile)"
Write-Host "Desktop Contact shot: $(Test-Path $outDesktop)"
