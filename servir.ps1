# Servidor HTTP simples em PowerShell (sem Python/Node)
$pasta = "C:\Users\Edinaldo\Downloads\Sua Lingerie"
$porta = 5500
$prefixo = "http://localhost:$porta/"

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($prefixo)
$listener.Start()
Write-Host "Servindo $pasta em $prefixo (Ctrl+C para parar)"

$mime = @{
  ".html"="text/html; charset=utf-8"
  ".htm"="text/html; charset=utf-8"
  ".css"="text/css; charset=utf-8"
  ".js"="application/javascript; charset=utf-8"
  ".json"="application/json; charset=utf-8"
  ".png"="image/png"
  ".jpg"="image/jpeg"
  ".jpeg"="image/jpeg"
  ".gif"="image/gif"
  ".svg"="image/svg+xml"
  ".webp"="image/webp"
  ".ico"="image/x-icon"
}

while ($listener.IsListening) {
  try {
    $ctx = $listener.GetContext()
    $req = $ctx.Request
    $res = $ctx.Response
    $caminhoUrl = [System.Uri]::UnescapeDataString($req.Url.LocalPath).TrimStart("/")
    if ([string]::IsNullOrWhiteSpace($caminhoUrl)) { $caminhoUrl = "index.html" }
    $caminho = Join-Path $pasta $caminhoUrl

    if (Test-Path $caminho -PathType Leaf) {
      $ext = [System.IO.Path]::GetExtension($caminho).ToLower()
      $tipo = if ($mime.ContainsKey($ext)) { $mime[$ext] } else { "application/octet-stream" }
      $bytes = [System.IO.File]::ReadAllBytes($caminho)
      $res.ContentType = $tipo
      $res.ContentLength64 = $bytes.Length
      $res.OutputStream.Write($bytes, 0, $bytes.Length)
    } else {
      $res.StatusCode = 404
      $msg = [System.Text.Encoding]::UTF8.GetBytes("404 - Nao encontrado")
      $res.OutputStream.Write($msg, 0, $msg.Length)
    }
    $res.OutputStream.Close()
  } catch {
    Write-Host "Erro: $_"
  }
}
