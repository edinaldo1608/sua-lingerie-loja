# ============ Correcao DEFINITIVA do index.html (v2 - sem emojis literais) ============
$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html"
$bytes = [System.IO.File]::ReadAllBytes($path)
$t = [System.Text.Encoding]::UTF8.GetString($bytes)

# ---- ETAPA 1: Reverter double-encoding (conserta acentos) ----
$b = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($t)
$t = [System.Text.Encoding]::UTF8.GetString($b)

$R = [string][char]0xFFFD

# ---- ETAPA 2: Corrigir ACENTOS que sobraram ----
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

# ---- ETAPA 3: Construir emojis por code point (ASCII puro no script) ----
# 📷 = U+1F4F7 ; 📸 = U+1F4F8 ; 🛍 = U+1F6CD (com FE0F) ; 📲 = U+1F4F2 ; 💬 = U+1F4AC
# 🕐 = U+1F550 ; 📍 = U+1F4CD ; 🔒 = U+1F512 ; 📤 = U+1F4E4 ; 📥 = U+1F4E5
# 📝 = U+1F4DD ; 🗑 = U+1F5D1 ; 🖼 = U+1F5BC ; 💾 = U+1F4BE ; 💕 = U+1F495
# 👙 = U+1F459 ; ✅ = U+2705 ; ➕ = U+2795 ; 🔍 = U+1F50D ; ⚙ = U+2699
function Emoji([int]$cp) { return [System.Char]::ConvertFromUtf32($cp) }

$E_insta  = Emoji 0x1F4F7   # 📷
$E_insta2 = Emoji 0x1F4F8   # 📸
$E_cart   = (Emoji 0x1F6CD) + [char]0xFE0F  # 🛍️
$E_wa     = Emoji 0x1F4F2   # 📲
$E_chat   = Emoji 0x1F4AC   # 💬
$E_clock  = Emoji 0x1F550   # 🕐
$E_pin    = Emoji 0x1F4CD   # 📍
$E_lock   = Emoji 0x1F512   # 🔒
$E_up     = Emoji 0x1F4E4   # 📤
$E_down   = Emoji 0x1F4E5   # 📥
$E_memo   = Emoji 0x1F4DD   # 📝
$E_trash  = Emoji 0x1F5D1   # 🗑
$E_img    = Emoji 0x1F5BC   # 🖼
$E_save   = Emoji 0x1F4BE   # 💾
$E_heart  = Emoji 0x1F495   # 💕
$E_ling   = Emoji 0x1F459   # 👙
$E_check  = Emoji 0x2705    # ✅
$E_plus   = Emoji 0x2795    # ➕
$E_search = Emoji 0x1F50D   # 🔍
$E_gear   = Emoji 0x2699    # ⚙ (configuracoes)
$E_edit   = (Emoji 0x270F) + [char]0xFE0F  # ✏️

# ---- ETAPA 4: Substituir emojis corrompidos (padroes com U+FFFD) ----
# Carrinho de compras
$t = $t.Replace($R + '?��', $E_cart)
$t = $t.Replace($R + '?o¶', $E_cart)
# Instagram
$t = $t.Replace($R + '?o-', $E_insta)
$t = $t.Replace($R + '?o¸', $E_insta2)
# WhatsApp / chat
$t = $t.Replace($R + '?o²', $E_wa)
$t = $t.Replace($R + '?T¬', $E_chat)
# lupa de busca
$t = $t.Replace($R + '?�', $E_search)

# ---- ETAPA 5: Limpar QUALQUER U+FFFD restante ----
$t = [regex]::Replace($t, [regex]::Escape($R) + '[^\s<>"'']{0,6}', '')
$t = [regex]::Replace($t, [regex]::Escape($R), '')

# ---- ETAPA 6: Ajustes de espacos ----
$t = $t -replace '  +', ' '
$t = $t -replace '>\s+<', '><'

# ---- Salvar ----
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($path, $t, $utf8NoBOM)

$restam = ([regex]::Matches($t, [regex]::Escape($R))).Count
"Concluido. U+FFFD restantes: $restam"
"Tamanho final: $($t.Length) chars"
