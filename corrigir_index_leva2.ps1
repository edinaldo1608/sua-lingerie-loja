# ============ Correcao leva 2: emojis especiais restantes ============
$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html"
$t = [System.IO.File]::ReadAllText($path)

function Emoji([int]$cp) { return [System.Char]::ConvertFromUtf32($cp) }
$FE0F = [string][char]0xFE0F

# ---- Substitutos por code point (originais do arquivo bom) ----
$E_edit  = (Emoji 0x270F) + $FE0F                 # lapis
$E_gear  = (Emoji 0x2699) + $FE0F                 # engrenagem
$E_x     = Emoji 0x2715                            # X fechar
$E_dash  = Emoji 0x2014                            # em dash
$E_plus  = Emoji 0x2795                            # +
$E_clock = Emoji 0x23F0                            # relogio (se houver)

# ---- Padroes corrompidos (montados por code points) ----
$P_edit  = [string]([char]0x00E2 + [char]0x0022 + [char]0x008F + [char]0x00EF + [char]0x00B8 + [char]0x008F)
$P_gear  = [string]([char]0x00E2 + [char]0x0161 + [char]0x0022)
$P_x     = [string]([char]0x00E2 + [char]0x0022)                     # "â""
$P_dash  = [string]([char]0x00E2 + [char]0x0020)                     # "â "
$P_plus  = [string]([char]0x00E2 + [char]0x017E)                     # "âž"

# Substituicoes especificas (ordem importa: mais longos primeiro)
$t = $t.Replace($P_edit, $E_edit)
$t = $t.Replace($P_gear, $E_gear)
$t = $t.Replace($P_plus, $E_plus)

# 'â"' antes de fechar / label -> X
$t = $t.Replace('aria-label="Fechar">' + [char]0x00E2 + [char]0x0022, 'aria-label="Fechar">' + $E_x)
$t = $t.Replace('fecharCart()" aria-label="Fechar">' + [char]0x00E2 + [char]0x0022, 'fecharCart()" aria-label="Fechar">' + $E_x)

# 'â ' (a-circ + espaco) -> em dash + espaco  (cart-note e outros textos)
$t = $t.Replace([char]0x00E2 + ' ', $E_dash + ' ')

$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($path, $t, $utf8NoBOM)

# Contagem final
$a = [string][char]0x00E2
$R = [string][char]0xFFFD
"a-circ restantes: " + ([regex]::Matches($t, [regex]::Escape($a))).Count
"U+FFFD restantes: " + ([regex]::Matches($t, [regex]::Escape($R))).Count
"Tamanho: $($t.Length)"
