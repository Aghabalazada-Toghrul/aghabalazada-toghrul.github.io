$edge = 'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe'

$flagSets = @(
    @('--headless=new', '--window-size=390,844'),
    @('--headless=new', '--window-size=390,844', '--force-device-scale-factor=1'),
    @('--headless', '--window-size=390,844'),
    @('--headless=new', '--window-size=390,844', '--use-mobile-user-agent', '--user-agent="Mozilla/5.0 (iPhone; CPU iPhone OS 16_0 like Mac OS X)"')
)

foreach ($flags in $flagSets) {
    $outPath = "C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch\test_$($flags.Count).txt"
    $a = $flags + @('--dump-dom', 'http://localhost:8123/_dpi_test.html')
    Start-Process -FilePath $edge -ArgumentList $a -RedirectStandardOutput $outPath -Wait -WindowStyle Hidden
    $res = [System.IO.File]::ReadAllText($outPath)
    $m = [regex]::Match($res, '(?s)DPI_START(.*?)DPI_END')
    Write-Host ("Flags: " + ($flags -join ' '))
    if ($m.Success) {
        Write-Host $m.Groups[1].Value
    }
}
