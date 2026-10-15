$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'
$testHtml = @'
<!DOCTYPE html>
<html><body>
<script>
window.location.href = "http://localhost:8123/index.html";
</script>
</body></html>
'@

# Or let's create a small script that injects a dump script into index.html temporarily or uses a test harness
$harness = @'
<!DOCTYPE html>
<html>
<body style="margin:0;padding:0;">
<iframe id="f" src="http://localhost:8123/index.html" style="width:390px;height:844px;border:none;"></iframe>
<pre id="out"></pre>
<script>
window.onload = () => {
    setTimeout(() => {
        const doc = document.getElementById('f').contentDocument;
        const nav = doc.querySelector('nav');
        const brand = doc.querySelector('a[href="#top"]');
        const brandSpan = brand ? brand.querySelector('span') : null;
        const brandImg = brand ? brand.querySelector('img') : null;
        const controls = doc.querySelector('.lg\\:hidden');
        const langBtn = doc.getElementById('mobile-lang-menu-btn');
        const burgerBtn = doc.getElementById('mobile-menu-btn');
        
        function info(name, el) {
            if (!el) return name + ': null';
            const r = el.getBoundingClientRect();
            const cs = doc.defaultView.getComputedStyle(el);
            return `${name}: left=${r.left.toFixed(1)}, right=${r.right.toFixed(1)}, width=${r.width.toFixed(1)}, display=${cs.display}, overflow=${cs.overflow}, flexShrink=${cs.flexShrink}`;
        }
        
        const lines = [
            `Window width: 390, iframe width: ${doc.documentElement.clientWidth}`,
            info('nav', nav),
            info('brand', brand),
            info('brandImg', brandImg),
            info('brandSpan', brandSpan),
            info('controls', controls),
            info('langBtn', langBtn),
            info('burgerBtn', burgerBtn)
        ];
        document.getElementById('out').textContent = 'DEBUG_START\n' + lines.join('\n') + '\nDEBUG_END';
    }, 1500);
};
</script>
</body>
</html>
'@

$harnessPath = 'C:\Users\ToghrulAghabalazadaN\Desktop\Novum\HTML\dist\_nav_debug.html'
[System.IO.File]::WriteAllText($harnessPath, $harness, [System.Text.Encoding]::UTF8)

$outPath = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch\debug_out.txt'
$a = @('--headless=new', '--disable-gpu', '--window-size=600,1000', '--virtual-time-budget=5000', '--dump-dom', 'http://localhost:8123/_nav_debug.html')
Start-Process -FilePath $edge -ArgumentList $a -RedirectStandardOutput $outPath -Wait -WindowStyle Hidden
$res = [System.IO.File]::ReadAllText($outPath)
$m = [regex]::Match($res, '(?s)DEBUG_START(.*?)DEBUG_END')
if ($m.Success) {
    Write-Host $m.Groups[1].Value
} else {
    Write-Host "Failed to get debug output. Preview:"
    Write-Host $res.Substring(0, [Math]::Min(500, $res.Length))
}
