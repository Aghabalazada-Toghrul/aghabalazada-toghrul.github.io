param([string]$Dir = 'dist', [int]$Port = 8123)
$root = (Resolve-Path (Join-Path (Split-Path -Parent $PSScriptRoot) $Dir)).Path
$mime = @{ '.html'='text/html; charset=utf-8'; '.css'='text/css'; '.js'='text/javascript'; '.png'='image/png'; '.jpg'='image/jpeg'; '.webp'='image/webp'; '.svg'='image/svg+xml'; '.woff2'='font/woff2'; '.xml'='application/xml'; '.txt'='text/plain' }
$l = New-Object System.Net.HttpListener
$l.Prefixes.Add("http://localhost:$Port/")
$l.Start()
"Serving $root on http://localhost:$Port/"
while ($l.IsListening) {
    $c = $l.GetContext()
    $rel = [Uri]::UnescapeDataString($c.Request.Url.AbsolutePath.TrimStart('/'))
    if ($rel -eq '') { $rel = 'index.html' }
    $file = Join-Path $root $rel
    if ((Test-Path $file -PathType Leaf) -and $file.StartsWith($root)) {
        $bytes = [System.IO.File]::ReadAllBytes($file)
        $ext = [IO.Path]::GetExtension($file).ToLower()
        $c.Response.ContentType = if ($mime[$ext]) { $mime[$ext] } else { 'application/octet-stream' }
        $c.Response.ContentLength64 = $bytes.Length
        $c.Response.OutputStream.Write($bytes, 0, $bytes.Length)
    } else { $c.Response.StatusCode = 404 }
    $c.Response.Close()
}
