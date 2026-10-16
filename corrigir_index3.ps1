# ============ Correcao DEFINITIVA do index.html (v3 - code points puros) ============
$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html"
$bytes = [System.IO.File]::ReadAllBytes($path)
$t = [System.Text.Encoding]::UTF8.GetString($bytes)

# ---- ETAPA 1: Reverter double-encoding (conserta acentos) ----
$b = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($t)
$t = [System.Text.Encoding]::UTF8.GetString($b)

$R   = [string][char]0xFFFD   # caractere de substituicao
$eth = [string][char]0x00F0   # 'eth' (inicio dos emojis 4-byte corrompidos)

# ---- ETAPA 2: Corrigir ACENTOS que sobraram (U+FFFD + 'f' + letra) ----
$t = $t -replace ($R + 'fµ'), 'õ'
$t = $t -replace ($R + 'f§'), 'ç'
$t = $t -replace ($R + 'f£'), 'ã'
$t = $t -replace ($R + 'f¡'), 'á'
$t = $t -replace ($R + 'f³'), 'ó'
$t = $t -replace ($R + 'fª'), 'ê'
$t = $t -replace ($R + 'f©'), 'é'
$t = $t -replace ($R + 'f[­]'), [char]0x00ED   # í
$t = $t -replace ($R + 'fº'), 'º'
$t = $t -replace ($R + 'f¢'), 'â'
$t = $t -replace ($R + 'fa'), 'à'
$t = $t -replace ($R + 'f¼'), 'ü'
$t = $t -replace ($R + 'f-'), '-'
# Resto tipo "Moda <R>fni" nao deveria ocorrer; limpeza geral abaixo resolve

# ---- ETAPA 3: Emojis por code point (ASCII puro no script) ----
function Emoji([int]$cp) { return [System.Char]::ConvertFromUtf32($cp) }
$E_insta  = Emoji 0x1F4F7              # camera
$E_insta2 = Emoji 0x1F4F8              # camera flash
$E_cart   = (Emoji 0x1F6CD) + [char]0xFE0F   # sacola de compras
$E_wa     = Emoji 0x1F4F2              # celular (whatsapp)
$E_chat   = Emoji 0x1F4AC              # balao de fala
$E_search = Emoji 0x1F50D              # lupa

# ---- ETAPA 4: Substituir emojis corrompidos usando regex com code points ----
# Monta os padroes com [char] para nao depender do encoding do script
$pInsta   = [regex]::Escape($eth + [char]0x0178 + $R + '?o-')
$pInsta2  = [regex]::Escape($eth + [char]0x0178 + $R + '?o' + [char]0x00B8)
$pCart    = [regex]::Escape($eth + [char]0x0178 + $R + '?' + $R + $R + '?T')
$pWa      = [regex]::Escape($eth + [char]0x0178 + $R + '?o' + [char]0x00B2)
$pChat    = [regex]::Escape($eth + [char]0x0178 + $R + '?T' + [char]0x00AC)
$pSearchP = [regex]::Escape($R + '?')          # uso generico de lupa

$t = [regex]::Replace($t, $pInsta,  $E_insta)
$t = [regex]::Replace($t, $pInsta2, $E_insta2)
$t = [regex]::Replace($t, $pCart,   $E_cart)
$t = [regex]::Replace($t, $pWa,     $E_wa)
$t = [regex]::Replace($t, $pChat,   $E_chat)

# ---- ETAPA 5: Limpar QUALQUER residuo (eth+...+FFFD e FFFD sozinho) ----
$t = [regex]::Replace($t, [regex]::Escape($eth) + '[^\s<>"'']{0,6}', '')
$t = [regex]::Replace($t, [regex]::Escape($R)   + '[^\s<>"'']{0,6}', '')
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
