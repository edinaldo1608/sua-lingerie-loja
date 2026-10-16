# ============ Correcao FINAL leva 2: emojis especiais restantes ============
$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html"
$t = [System.IO.File]::ReadAllText($path)

function E([int]$cp) { return [System.Char]::ConvertFromUtf32($cp) }
$FE0F = [string][char]0xFE0F
$AC   = [string][char]0x00E2   # a-circ (marcador de corrupcao)

# --- Originais ---
$O_edit  = (E 0x270F) + $FE0F     # lapis
$O_gear  = (E 0x2699) + $FE0F     # engrenagem
$O_x     = E 0x2715               # X fechar
$O_x2    = E 0x2716               # X grosso (remover foto)
$O_plus  = E 0x2795               # +
$O_dash  = E 0x2014               # em dash
$O_prev  = E 0x2039               # < seta
$O_next  = E 0x203A               # > seta
$O_redo  = E 0x21BB               # ↻ atualizar/importar

# --- Padroes corrompidos montados por code points ---
$P_edit = [string]([char]0x00E2 + [char]0x0022 + [char]0x008F + [char]0x00EF + [char]0x00B8 + [char]0x008F)
$P_gear = [string]([char]0x00E2 + [char]0x0161 + [char]0x0022)
$P_gear2= [string]([char]0x00E2 + [char]0x00AD + [char]0x0090)   # engrenagem alt
$P_plus = [string]([char]0x00E2 + [char]0x017E)
$P_dash = [string]([char]0x00E2 + [char]0x0020)                   # em dash (texto)
$P_prev = [string]([char]0x00E2 + [char]0x0022)                   # "â"" generico

# 1) Icones especificos (ordem: mais longos primeiro)
$t = $t.Replace($P_edit, $O_edit)
$t = $t.Replace($P_gear, $O_gear)
$t = $t.Replace($P_gear2, $O_gear)
$t = $t.Replace($P_plus, $O_plus)

# 2) Fechar (lightbox): 'title="Fechar" ...>"â"<'  -> X
$t = $t.Replace('aria-label="Fechar">' + [char]0x00E2 + [char]0x0022, 'aria-label="Fechar">' + $O_x)
$t = $t.Replace('title="Fechar" onclick="event.stopPropagation();fecharLightbox()">' + [char]0x00E2 + [char]0x0022, 'title="Fechar" onclick="event.stopPropagation();fecharLightbox()">' + $O_x)

# 3) Setas do lightbox (prev/next): '...navLightbox(-1,event)">â<'  -> prev
$t = $t.Replace('navLightbox(-1,event)">' + [char]0x00E2 + '<', 'navLightbox(-1,event)">' + $O_prev + '<')
$t = $t.Replace('navLightbox(1,event)">' + [char]0x00E2 + '<', 'navLightbox(1,event)">' + $O_next + '<')

# 4) Importar/atualizar: 'lerDoApp()">â Ler' -> ↻ Ler
$t = $t.Replace('lerDoApp()">' + [char]0x00E2 + ' Ler', 'lerDoApp()">' + $O_redo + ' Ler')

# 5) Remover foto: 'cadRemoverFoto()">â"" Remover' -> X grosso
$t = $t.Replace('cadRemoverFoto()">' + [char]0x00E2 + [char]0x0022 + [char]0x0022 + ' Remover', 'cadRemoverFoto()">' + $O_x2 + ' Remover')

# 6) Demais 'â ' em textos -> em dash
$t = $t.Replace([char]0x00E2 + ' ', $O_dash + ' ')

$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($path, $t, $utf8NoBOM)

$R = [string][char]0xFFFD
"a-circ restantes: " + ([regex]::Matches($t, [regex]::Escape($AC))).Count
"U+FFFD restantes: " + ([regex]::Matches($t, [regex]::Escape($R))).Count
"Tamanho: $($t.Length)"
