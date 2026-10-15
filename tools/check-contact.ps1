$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$shots = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch'
$out = Join-Path $shots 'contact_section_check.png'

# We load the page and run JS to scroll to #contact before screenshotting
$script = @"
const edge = '$edge';
"@

# Take full height shot of contact section by viewport sizing or scroll
$a = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=1200,1000', '--virtual-time-budget=3000', "--screenshot=$out", 'http://localhost:8123/index.html')
# Let's use an html wrapper that directly scrolls the window
$wrapHtml = @"
<!DOCTYPE html>
<html>
<body style="margin:0;overflow:hidden;">
<iframe id="f" src="http://localhost:8123/index.html" style="width:1200px;height:2400px;border:none;margin-top:-3800px;"></iframe>
</body>
</html>
"@
$wrapFile = Join-Path $shots 'wrap_contact.html'
[System.IO.File]::WriteAllText($wrapFile, $wrapHtml)

$a2 = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=1200,900', '--virtual-time-budget=2000', "--screenshot=$out", "file:///$($wrapFile.Replace('\', '/'))")
Start-Process -FilePath $edge -ArgumentList $a2 -Wait -WindowStyle Hidden
Write-Host "Contact shot: $(Test-Path $out)"
