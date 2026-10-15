$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

$harness = @'
<!DOCTYPE html>
<html>
<body style="margin:0;padding:0;overflow:hidden;">
<div style="display:flex;flex-direction:column;gap:10px;">
  <iframe id="f320" src="http://localhost:8123/index.html" style="width:320px;height:300px;border:none;"></iframe>
  <iframe id="f360" src="http://localhost:8123/index.html" style="width:360px;height:300px;border:none;"></iframe>
  <iframe id="f375" src="http://localhost:8123/index.html" style="width:375px;height:300px;border:none;"></iframe>
  <iframe id="f390" src="http://localhost:8123/index.html" style="width:390px;height:300px;border:none;"></iframe>
</div>
<pre id="out"></pre>
<script>
window.onload = () => {
    setTimeout(() => {
        const out = [];
        for (const w of [320, 360, 375, 390]) {
            const doc = document.getElementById('f' + w).contentDocument;
            const nav = doc.querySelector('nav');
            const brand = doc.querySelector('a[href="#top"]');
            const controls = doc.querySelector('.lg\\:hidden');
            const burgerBtn = doc.getElementById('mobile-menu-btn');
            const cw = doc.documentElement.clientWidth;
            
            const rBurger = burgerBtn ? burgerBtn.getBoundingClientRect() : null;
            const rBrand = brand ? brand.getBoundingClientRect() : null;
            const rControls = controls ? controls.getBoundingClientRect() : null;
            
            out.push(`Width ${w} (client=${cw}): brand=[${rBrand.left.toFixed(0)}..${rBrand.right.toFixed(0)}] controls=[${rControls.left.toFixed(0)}..${rControls.right.toFixed(0)}] burger=[${rBurger.left.toFixed(0)}..${rBurger.right.toFixed(0)}] overflow=${rBurger.right > cw}`);
        }
        document.getElementById('out').textContent = 'TEST_START\n' + out.join('\n') + '\nTEST_END';
    }, 1500);
};
</script>
</body>
</html>
'@

$harnessPath = 'C:\Users\ToghrulAghabalazadaN\Desktop\Novum\HTML\dist\_nav_multi.html'
[System.IO.File]::WriteAllText($harnessPath, $harness, [System.Text.Encoding]::UTF8)

$outPath = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch\multi_out.txt'
$a = @('--headless=new', '--disable-gpu', '--window-size=1000,1400', '--virtual-time-budget=6000', '--dump-dom', 'http://localhost:8123/_nav_multi.html')
Start-Process -FilePath $edge -ArgumentList $a -RedirectStandardOutput $outPath -Wait -WindowStyle Hidden
$res = [System.IO.File]::ReadAllText($outPath)
$m = [regex]::Match($res, '(?s)TEST_START(.*?)TEST_END')
if ($m.Success) {
    Write-Host $m.Groups[1].Value
} else {
    Write-Host "Failed: $res"
}
