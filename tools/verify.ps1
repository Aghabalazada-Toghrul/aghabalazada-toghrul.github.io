Set-Location (Split-Path -Parent $PSScriptRoot)
& .\tools\build.ps1 | Select-Object -Last 2
Copy-Item tools\overflow-test.html dist\_overflow_test.html
& .\tools\run-overflow-test.ps1 | Where-Object { $_ -notmatch 'ERROR:' }
