# ============ Correcao DEFINITIVA do index.html ============
$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html"
$bytes = [System.IO.File]::ReadAllBytes($path)
$t = [System.Text.Encoding]::UTF8.GetString($bytes)

# ---- ETAPA 1: Reverter double-encoding (conserta acentos) ----
$b = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($t)
$t = [System.Text.Encoding]::UTF8.GetString($b)

$R = [string][char]0xFFFD

# ---- ETAPA 2: Corrigir ACENTOS que sobraram (padrao U+FFFD + 'f' + letra) ----
$t = $t -replace ($R + 'fµ'), 'õ'
$t = $t -replace ($R + 'f§'), 'ç'
$t = $t -replace ($R + 'f£'), 'ã'
$t = $t -replace ($R + 'f¡'), 'á'
$t = $t -replace ($R + 'f³'), 'ó'
$t = $t -replace ($R + 'fª'), 'ê'
$t = $t -replace ($R + 'f©'), 'é'
$t = $t -replace ($R + 'f­'), 'í'
$t = $t -replace ($R + 'fº'), 'º'
$t = $t -replace ($R + 'f¢'), 'â'
$t = $t -replace ($R + 'fa'), 'à'
$t = $t -replace ($R + 'f¼'), 'ü'
$t = $t -replace ($R + 'f-'), '-'
# Restos de "intima" -> "íntima" (caso tenha ficado "ni")
# nada aqui

# ---- ETAPA 3: Corrigir emojis corrompidos ----
# Carrinho de compras (🛍️)
$t = $t.Replace($R + '?��', '🛍️')
$t = $t.Replace($R + '?o¶', '🛍️')
# Instagram (📷) e (📸)
$t = $t.Replace($R + '?o-', '📷')
$t = $t.Replace($R + '?o¸', '📸')
# WhatsApp (📲) e (💬)
$t = $t.Replace($R + '?o²', '📲')
$t = $t.Replace($R + '?T¬', '💬')
# Check (✅)
$t = $t.Replace($R + '?', '✅')
# X (✕)
$t = $t.Replace($R + 'ï¸', '')
# ---- ETAPA 4: Limpar QUALQUER U+FFFD restante ----
$t = [regex]::Replace($t, [regex]::Escape($R) + '[^\s<>"'']{0,6}', '')
$t = [regex]::Replace($t, [regex]::Escape($R), '')

# ---- ETAPA 5: Ajustes de espacos ----
$t = $t -replace '  +', ' '
$t = $t -replace '>\s+<', '><'

# ---- Salvar ----
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($path, $t, $utf8NoBOM)

$restam = ([regex]::Matches($t, [regex]::Escape($R))).Count
"Concluido. U+FFFD restantes: $restam"
"Tamanho final: $($t.Length) chars"
