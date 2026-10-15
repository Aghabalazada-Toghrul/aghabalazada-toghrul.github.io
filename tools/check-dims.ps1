Add-Type -AssemblyName System.Drawing
$img = [System.Drawing.Image]::FromFile('C:\Users\ToghrulAghabalazadaN\.gemini\antigravity\brain\e2ae9ec6-eabb-4d96-82e2-784080b7d9d0\scratch\final_mobile_en.png')
Write-Host "Width = $($img.Width), Height = $($img.Height)"
$img.Dispose()
