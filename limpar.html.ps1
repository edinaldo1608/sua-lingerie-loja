# Script de limpeza definitiva de caracteres corrompidos
$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\Sua Lingerie - Site (novo).html"
$bytes = [System.IO.File]::ReadAllBytes($path)
$t = [System.Text.Encoding]::UTF8.GetString($bytes)
$R = [char]0xFFFD

# ---- 1. Corrigir ACENTOS (padrões U+FFFD + 'f' + letra) ----
$acentos = @{
  ([string]$R + 'f§') = 'ç';  ([string]$R + 'f£') = 'ã';  ([string]$R + 'f¡') = 'á'
  ([string]$R + 'f³') = 'ó';  ([string]$R + 'fª') = 'ê';  ([string]$R + 'f©') = 'é'
  ([string]$R + 'f­') = 'í';  ([string]$R + 'fº') = 'º';  ([string]$R + 'f¢') = 'â'
  ([string]$R + 'fa') = 'à';  ([string]$R + 'fµ') = 'õ';  ([string]$R + 'f¼') = 'ü'
  ([string]$R + 'f-') = '-'
}
foreach ($k in $acentos.Keys) { $t = $t.Replace($k, $acentos[$k]) }

# ---- 2. SVG inline para reutilizar ----
$svgIG   = '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="2" y="2" width="20" height="20" rx="5" ry="5"/><path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37Z"/><line x1="17.5" y1="6.5" x2="17.51" y2="6.5"/></svg>'
$svgCart = '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"/><circle cx="20" cy="21" r="1"/><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"/></svg>'
$svgWa   = '<svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor"><path d="M17.5 14.4c-.3-.1-1.7-.8-1.9-.9-.3-.1-.5-.1-.6.1s-.7.9-.9 1.1c-.2.2-.3.2-.6.1-.3-.1-1.2-.5-2.3-1.4-.9-.8-1.4-1.7-1.6-2-.2-.3 0-.4.1-.6.1-.1.3-.3.4-.5.1-.2.2-.3.3-.5.1-.2 0-.4 0-.5 0-.1-.6-1.5-.8-2-.2-.5-.4-.4-.6-.4h-.5c-.2 0-.5.1-.7.3-.2.2-.9.9-.9 2.2s.9 2.5 1.1 2.7c.1.2 1.8 2.8 4.5 3.9.6.3 1.1.4 1.5.5.6.2 1.2.2 1.6.1.5-.1 1.7-.7 1.9-1.3.2-.7.2-1.2.2-1.3-.1-.1-.3-.2-.6-.4M12 2a10 10 0 0 0-8.6 15.1L2 22l5-1.3A10 10 0 1 0 12 2Z"/></svg>'
$svgX    = '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="18" y1="6" x2="6" y2="18"/><line x1="6" y1="6" x2="18" y2="18"/></svg>'
$svgCheck= '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2.5" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"/></svg>'
$svgEdit = '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 20h9"/><path d="M16.5 3.5a2.12 2.12 0 0 1 3 3L7 19l-4 1 1-4Z"/></svg>'
$svgGear = '<svg viewBox="0 0 24 24" width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="12" cy="12" r="3"/><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1-2.83 2.83l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-4 0v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1 0-4h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 2.83-2.83l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 4 0v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 0 4h-.09a1.65 1.65 0 0 0-1.51 1Z"/></svg>'

# ---- 3. Substituir emojis corrompidos (na ordem: mais longo primeiro) ----
$subs = [ordered]@{}
# Lixeira / limpar
$subs['[ðŸ][ðŸ][–][ž][ðŸ][?][o][¶][L]'] = ''
# carrinho (variações)
$subs['ðŸ�?��?T'] = $svgCart
$subs['ðŸ�?o¶']   = $svgCart
# Instagram
$subs['ðŸ�?o-']   = $svgIG
$subs['ðŸ�?o¸']   = $svgIG
# WhatsApp
$subs['ðŸ�?T¬']   = $svgWa
$subs['ðŸ�?o²']   = $svgWa
# check
$subs['âœ…']      = $svgCheck
$subs['â�?�…']    = $svgCheck
# X
$subs['âœ•']      = $svgX
$subs['â�"�?�']   = $svgX
# editar / configurações
$subs['âš�"?ï¸�'] = $svgGear
$subs['âš�"�ï¸�'] = $svgGear
$subs['âš™ï¸�']   = $svgGear
$subs['â�"ï¸�']   = $svgEdit
$subs['ðŸ�?oï¸�'] = $svgEdit

# ---- Remover TODOS os demais emojis corrompidos (padrões ðŸ / â seguidos de bytes perdidos) ----
# Remove sequências começando por 'ðŸ' ou 'â' seguidas de 1-4 chars de lixo
$t = [regex]::Replace($t, 'ðŸ[^<\s]{0,6}', '')
$t = [regex]::Replace($t, 'â[\uFFFD\u0090-\uFFFF][^<\s]{0,4}', '')

# ---- 4. Corrigir espaços duplos deixados pelas remoções ----
$t = $t -replace '  +', ' '
$t = $t -replace '>\s+<', '><'

# ---- 5. Salvar ----
$utf8NoBOM = New-Object System.Text.UTF8Encoding $false
[System.IO.File]::WriteAllText($path, $t, $utf8NoBOM)

# ---- 6. Relatório ----
$restam = ([regex]::Matches($t, [regex]::Escape($R))).Count
"Concluido. Caracteres corrompidos restantes: $restam"
