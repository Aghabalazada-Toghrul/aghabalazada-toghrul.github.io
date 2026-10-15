Add-Type -AssemblyName System.Drawing
foreach ($f in 'toghrul_transparent.png', 'logos\novum_icon.png', 'logos\novum.png', 'logos\novum_icon.jpg') {
    $img = [System.Drawing.Image]::FromFile((Join-Path (Split-Path -Parent $PSScriptRoot) $f))
    "{0}: {1}x{2}" -f $f, $img.Width, $img.Height
    $img.Dispose()
}
