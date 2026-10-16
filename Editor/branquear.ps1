# Recolore tons de pele/tecido (quentes) para BRANCO, preservando luminosidade.
# Fundos cinza/neutros (R~G~B) ficam intactos. Salva como *_branco.jpeg
Add-Type -AssemblyName System.Drawing

$dir = "c:\Users\Edinaldo\Downloads\Editor"

1..5 | ForEach-Object {
    $srcPath = Join-Path $dir "$_.jpeg"
    $dstPath = Join-Path $dir "${_}_branco.jpeg"

    $src = New-Object System.Drawing.Bitmap($srcPath)
    $w = $src.Width; $h = $src.Height
    $dst = New-Object System.Drawing.Bitmap($w, $h)
    $g = [System.Drawing.Graphics]::FromImage($dst)
    $g.DrawImage($src, 0, 0, $w, $h)

    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $c = $src.GetPixel($x, $y)
            $r = [int]$c.R; $gr = [int]$c.G; $b = [int]$c.B

            # "calor" da cor: quanto R supera B (pele/tecido quente)
            $warmth = $r - $b
            $maxc = [Math]::Max($r, [Math]::Max($gr, $b))
            $minc = [Math]::Min($r, [Math]::Min($gr, $b))
            $sat = $maxc - $minc

            # luminosidade percebida
            $lum = 0.299 * $r + 0.587 * $gr + 0.114 * $b

            # Peso: só recolore se for quente E não for cinza de fundo.
            # Fundo cinza tem R~G~B (warmth ~ 0). Pele/tecido tem warmth alto.
            $peso = 0.0
            if ($sat -gt 18 -and $warmth -gt 12) {
                $peso = [Math]::Min(1.0, ($warmth - 12) / 45.0)
            }

            if ($peso -le 0.01) {
                # mantém original
                $nr = $r; $ng = $gr; $nb = $b
            } else {
                # Branco preservando a sombra: valor = luminosidade um pouco realçada
                $brilho = [Math]::Min(255, $lum * 1.18 + 18)
                # leve tom frio pra parecer "branco de tecido"
                $tr = [Math]::Min(255, $brilho * 1.00)
                $tg = [Math]::Min(255, $brilho * 1.00)
                $tb = [Math]::Min(255, $brilho * 1.02)

                $nr = [int]($r  * (1 - $peso) + $tr * $peso)
                $ng = [int]($gr * (1 - $peso) + $tg * $peso)
                $nb = [int]($b  * (1 - $peso) + $tb * $peso)
            }

            if ($nr -gt 255) { $nr = 255 }; if ($ng -gt 255) { $ng = 255 }; if ($nb -gt 255) { $nb = 255 }
            if ($nr -lt 0) { $nr = 0 }; if ($ng -lt 0) { $ng = 0 }; if ($nb -lt 0) { $nb = 0 }

            $dst.SetPixel($x, $y, [System.Drawing.Color]::FromArgb($nr, $ng, $nb))
        }
    }

    $g.Dispose()
    $encoder = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() | Where-Object { $_.MimeType -eq 'image/jpeg' }
    $ep = New-Object System.Drawing.Imaging.EncoderParameters(1)
    $ep.Param[0] = New-Object System.Drawing.Imaging.EncoderParameter([System.Drawing.Imaging.Encoder]::Quality, 92L)
    $dst.Save($dstPath, $encoder, $ep)

    $dst.Dispose(); $src.Dispose()
    Write-Host "Gerado: ${_}_branco.jpeg"
}
Write-Host "Concluido."
