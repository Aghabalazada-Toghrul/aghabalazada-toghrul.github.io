# Generates optimized, mobile-friendly images used by the site (run once, or after replacing source photos).
Add-Type -AssemblyName System.Drawing
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$out = Join-Path $root 'assets\img'
New-Item -ItemType Directory -Force $out | Out-Null

function New-Resized([string]$src, [int]$width, [int]$height = 0) {
    $img = [System.Drawing.Image]::FromFile($src)
    if ($height -le 0) { $height = [int][math]::Round($img.Height * $width / $img.Width) }
    $bmp = New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
    $g = [System.Drawing.Graphics]::FromImage($bmp)
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.CompositingQuality = [System.Drawing.Drawing2D.CompositingQuality]::HighQuality
    $g.DrawImage($img, 0, 0, $width, $height)
    $g.Dispose(); $img.Dispose()
    return $bmp
}

function Save-Jpeg($bmp, [string]$path, [int]$quality) {
    $codec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $p = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $p.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, [long]$quality)
    $bmp.Save($path, $codec, $p)
}

# 1) Portrait (transparent PNG), 768px wide
$b = New-Resized (Join-Path $root 'toghrul_transparent.png') 768
$b.Save((Join-Path $out 'toghrul.png'), [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()

# 2) NOVUM wordmark logo (was 4500px wide)
$b = New-Resized (Join-Path $root 'logos\novum.png') 640
$b.Save((Join-Path $out 'novum.png'), [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()

# 3) NOVUM icon (header brand mark) + favicons
$icon = Join-Path $root 'logos\novum_icon.png'
$b = New-Resized $icon 160;  $b.Save((Join-Path $out 'novum_icon.png'), [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()
$b = New-Resized $icon 180;  $b.Save((Join-Path $out 'apple-touch-icon.png'), [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()
$b = New-Resized $icon 48;   $b.Save((Join-Path $out 'favicon-48.png'), [System.Drawing.Imaging.ImageFormat]::Png); $b.Dispose()

# 4) Open Graph / link-preview card (1200x630)
$W = 1200; $H = 630
$card = New-Object System.Drawing.Bitmap($W, $H, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$g = [System.Drawing.Graphics]::FromImage($card)
$g.SmoothingMode = 'HighQuality'; $g.TextRenderingHint = 'AntiAliasGridFit'; $g.InterpolationMode = 'HighQualityBicubic'
$rect = New-Object System.Drawing.Rectangle(0, 0, $W, $H)
$grad = New-Object System.Drawing.Drawing2D.LinearGradientBrush($rect, [System.Drawing.ColorTranslator]::FromHtml('#F5F9FF'), [System.Drawing.ColorTranslator]::FromHtml('#DCEBFF'), 90)
$g.FillRectangle($grad, $rect)

# portrait on right, anchored to bottom
$por = [System.Drawing.Image]::FromFile((Join-Path $root 'toghrul_transparent.png'))
$ph = 600; $pw = [int]($por.Width * $ph / $por.Height)
$g.DrawImage($por, ($W - $pw - 40), ($H - $ph), $pw, $ph)
$por.Dispose()

# brand icon
$ic = [System.Drawing.Image]::FromFile($icon)
$g.DrawImage($ic, 70, 64, 64, 64); $ic.Dispose()

$navy = [System.Drawing.ColorTranslator]::FromHtml('#0D2B75')
$dark = [System.Drawing.ColorTranslator]::FromHtml('#081B4B')
$slate = [System.Drawing.ColorTranslator]::FromHtml('#475569')
$fPill = New-Object System.Drawing.Font('Segoe UI Semibold', 22, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fName = New-Object System.Drawing.Font('Segoe UI', 70, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
$fRole = New-Object System.Drawing.Font('Segoe UI Semibold', 40, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$fTag = New-Object System.Drawing.Font('Segoe UI', 30, [System.Drawing.FontStyle]::Regular, [System.Drawing.GraphicsUnit]::Pixel)
$g.DrawString('NOVUM TECH', $fPill, (New-Object System.Drawing.SolidBrush($navy)), 150, 82)
$g.DrawString('Toghrul', $fName, (New-Object System.Drawing.SolidBrush($dark)), 64, 200)
$g.DrawString('Aghabalazada', $fName, (New-Object System.Drawing.SolidBrush($dark)), 64, 280)
$g.DrawString('Sales Manager', $fRole, (New-Object System.Drawing.SolidBrush($navy)), 68, 388)
$g.DrawString('Microsoft Cloud & Dynamics 365', $fTag, (New-Object System.Drawing.SolidBrush($slate)), 68, 454)
$g.DrawString('Azerbaijan  |  UAE  |  Bahrain  |  Uzbekistan', $fTag, (New-Object System.Drawing.SolidBrush($slate)), 68, 498)
$g.Dispose()
Save-Jpeg $card (Join-Path $out 'og-image.jpg') 88
$card.Dispose()

Get-ChildItem $out | Select-Object Name, Length
