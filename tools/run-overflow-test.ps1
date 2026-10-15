$edge = (Get-Command msedge -ErrorAction SilentlyContinue).Source
if (-not $edge) { $edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe' }
$out = 'C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch\overflow.html'
$a = @('--headless=new', '--disable-gpu', '--virtual-time-budget=60000', '--dump-dom', 'http://localhost:8123/_overflow_test.html')
$p = Start-Process -FilePath $edge -ArgumentList $a -RedirectStandardOutput $out -PassThru -Wait -WindowStyle Hidden
$t = Get-Content $out -Raw
$m = [regex]::Match($t, '(?s)RESULT_START(.*?)RESULT_END')
if ($m.Success) {
    $r = $m.Groups[1].Value | ConvertFrom-Json
    $r | ForEach-Object { '{0,-14} w={1,-4} scrollW={2,-4} overflow={3,-5} bad={4} js={5} fontsLoaded={6}' -f $_.page, $_.w, $_.scrollWidth, $_.overflow, $_.badCount, $_.js, $_.fontsLoaded }
    '--- offenders ---'
    $r | Where-Object { $_.badCount -gt 0 } | ForEach-Object { "$($_.page) @$($_.w): " + ($_.bad -join ' | ') }
} else { 'No result; head of output:'; $t.Substring(0, [Math]::Min(600, $t.Length)) }
