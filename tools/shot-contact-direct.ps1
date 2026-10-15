$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$shots = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch'
$outMobile = Join-Path $shots 'contact_mobile.png'
$outDesktop = Join-Path $shots 'contact_desktop.png'

# We can create a lightweight test HTML page that contains JUST the #contact section or copies index.html with an onload scroll
$contactPage = [System.IO.File]::ReadAllText('dist/index.html')
# Insert a small auto-scroll script at the top of <body>
$scrollScript = '<script>window.addEventListener("DOMContentLoaded", () => { setTimeout(() => { document.getElementById("contact").scrollIntoView(); }, 300); });</script>'
$contactPageWithScroll = $contactPage.Replace('<body id="top"', $scrollScript + '<body id="top"')
[System.IO.File]::WriteAllText('dist\_contact_preview.html', $contactPageWithScroll)

# Desktop screenshot
$aDesk = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=1280,1000', '--virtual-time-budget=3000', "--screenshot=$outDesktop", 'http://localhost:8123/_contact_preview.html')
Start-Process -FilePath $edge -ArgumentList $aDesk -Wait -WindowStyle Hidden

# Mobile screenshot
$aMob = @('--headless=new', '--disable-gpu', '--hide-scrollbars', '--window-size=500,1000', '--virtual-time-budget=3000', "--screenshot=$outMobile", 'http://localhost:8123/_contact_preview.html')
Start-Process -FilePath $edge -ArgumentList $aMob -Wait -WindowStyle Hidden

Write-Host "Desktop shot: $(Test-Path $outDesktop)"
Write-Host "Mobile shot: $(Test-Path $outMobile)"
