# ============ Correcao DEFINITIVA do index.html (v4 - 100% ASCII no script) ============
$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html"
$bytes = [System.IO.File]::ReadAllBytes($path)
$t = [System.Text.Encoding]::UTF8.GetString($bytes)

# ---- ETAPA 1: Reverter double-encoding (conserta acentos) ----
$latin1 = [System.Text.Encoding]::GetEncoding("ISO-8859-1")
$b = $latin1.GetBytes($t)
$t = [System.Text.Encoding]::UTF8.GetString($b)

$R   = [string][char]0xFFFD            # U+FFFD
$eth = [string][char]0x00F0            # inicio dos emojis 4-byte corrompidos

# letras acentuadas por code point (evita encoding do script)
$c_o_til   = [string][char]0x00F5  # o tilde
$c_c_ced   = [string][char]0x00E7  # c cedilha
$c_a_til   = [string][char]0x00E3  # a tilde
$c_a_ag    = [string][char]0x00E1  # a agudo
$c_o_ag    = [string][char]0x00F3  # o agudo
$c_e_cir   = [string][char]0x00EA  # e circunflexo
$c_e_ag    = [string][char]0x00E9  # e agudo
$c_i_ag    = [string][char]0x00ED  # i agudo
$c_o_ord   = [string][char]0x00BA  # o ordinal
$c_a_cir   = [string][char]0x00E2  # a circunflexo
$c_a_cra   = [string][char]0x00E0  # a crase
$c_u_dia   = [string][char]0x00FC  # u diaeresis

# ---- ETAPA 2: Corrigir ACENTOS que sobraram (U+FFFD + 'f' + letra) ----
$t = $t -replace ($R + 'f' + [char]0x00B5), $c_o_til   # microfone 'µ' -> o tilde
$t = $t -replace ($R + 'f' + [char]0x00A7), $c_c_ced   # '§' -> c cedilha
$t = $t -replace ($R + 'f' + [char]0x00A3), $c_a_til   # '£' -> a tilde
$t = $t -replace ($R + 'f' + [char]0x00A1), $c_a_ag    # '¡' -> a agudo
$t = $t -replace ($R + 'f' + [char]0x00B3), $c_o_ag    # '³' -> o agudo
$t = $t -replace ($R + 'f' + [char]0x00AA), $c_e_cir   # 'ª' -> e circunflexo
$t = $t -replace ($R + 'f' + [char]0x00A9), $c_e_ag    # '©' -> e agudo
$t = $t -replace ($R + 'f' + [char]0x00AD), $c_i_ag    # soft hyphen -> i agudo
$t = $t -replace ($R + 'f' + [char]0x00BA), $c_o_ord   # 'º' -> o ordinal
$t = $t -replace ($R + 'f' + [char]0x00A2), $c_a_cir   # '¢' -> a circunflexo
$t = $t -replace ($R + 'f' + 'a'), $c_a_cra            # 'a' -> a crase
$t = $t -replace ($R + 'f' + [char]0x00BC), $c_u_dia   # '¼' -> u diaeresis
$t = $t -replace ($R + 'f-'), '-'

# ---- ETAPA 3: Emojis por code point ----
function Emoji([int]$cp) { return [System.Char]::ConvertFromUtf32($cp) }
$E_insta  = Emoji 0x1F4F7
$E_insta2 = Emoji 0x1F4F8
$E_cart   = (Emoji 0x1F6CD) + [char]0xFE0F
$E_wa     = Emoji 0x1F4F2
$E_chat   = Emoji 0x1F4AC

# ---- ETAPA 4: Substituir emojis corrompidos ----
$t = [regex]::Replace($t, [regex]::Escape($eth + [char]0x0178 + $R + '?o-'), $E_insta)
$t = [regex]::Replace($t, [regex]::Escape($eth + [char]0x0178 + $R + '?o' + [char]0x00B8), $E_insta2)
$t = [regex]::Replace($t, [regex]::Escape($eth + [char]0x0178 + $R + '?' + $R + $R + '?T'), $E_cart)
$t = [regex]::Replace($t, [regex]::Escape($eth + [char]0x0178 + $R + '?o' + [char]0x00B2), $E_wa)
$t = [regex]::Replace($t, [regex]::Escape($eth + [char]0x0178 + $R + '?T' + [char]0x00AC), $E_chat)

# ---- ETAPA 5: Limpar residuos ----
$t = [regex]::Replace($t, [regex]::Escape($eth + [char]0x0178) + '[^\s<>"'']{0,8}', '')
$t = [regex]::Replace($t, [regex]::Escape($eth) + '[^\s<>"'']{0,8}', '')
$t = [regex]::Replace($t, [regex]::Escape($R)   + '[^\s<>"'']{0,8}', '')
$t = [regex]::Replace($t, [regex]::Escape($R), '')

# ---- Salvar ----
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($path, $t, $utf8NoBOM)

$restam = ([regex]::Matches($t, [regex]::Escape($R))).Count
$restEth = ([regex]::Matches($t, [regex]::Escape($eth))).Count
"Concluido. U+FFFD restantes: $restam | eth restantes: $restEth"
"Tamanho final: $($t.Length) chars"
