$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$script = @'
(() => {
    const nav = document.querySelector('nav');
    const brand = nav ? nav.querySelector('a[href="#top"]') : null;
    const mobileControls = nav ? nav.querySelector('.lg\\:hidden') : null;
    const langBtn = document.getElementById('mobile-lang-menu-btn');
    const burgerBtn = document.getElementById('mobile-menu-btn');
    
    function r(el) {
        if (!el) return null;
        const b = el.getBoundingClientRect();
        return { tag: el.tagName, id: el.id, left: Math.round(b.left), top: Math.round(b.top), width: Math.round(b.width), height: Math.round(b.height), right: Math.round(b.right) };
    }
    
    return JSON.stringify({
        viewportWidth: window.innerWidth,
        nav: r(nav),
        brand: r(brand),
        mobileControls: r(mobileControls),
        langBtn: r(langBtn),
        burgerBtn: r(burgerBtn)
    }, null, 2);
})()
'@

$resFile = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch\nav_measure.json'

# Use a test html page or load index.html with JS evaluation
# We can do this by running edge with a temporary script or node/pwsh
Write-Host "Edge binary exists: $(Test-Path $edge)"
