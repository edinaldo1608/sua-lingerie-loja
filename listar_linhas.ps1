$idx = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html")
$bom = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\Sua Lingerie - Site.html")
$a = [string][char]0x00E2

# Lista todas as linhas com a-circ e tenta achar equivalente no bom (texto ASCII)
$linhas = ($idx -split "`r`n")
$n = 0
for ($i=0; $i -lt $linhas.Count; $i++) {
  if ($linhas[$i].Contains($a)) {
    $n++
    $orig = $linhas[$i]
    # tenta achar no bom pelo texto ao redor
    $codes = ($orig.ToCharArray() | Where-Object { [int]$_ -ge 0x80 -or [int]$_ -eq 0x22 } | ForEach-Object { "U+{0:X4}" -f [int]$_ }) -join ' '
    Write-Output ("L{0}| {1}" -f ($i+1), ($orig.Trim() -replace '[^\x20-\x7E]','_' ).Substring(0,[Math]::Min(85,($orig.Trim() -replace '[^\x20-\x7E]','_').Length)))
    Write-Output ("      high: {0}" -f $codes)
  }
  if ($n -ge 25) { break }
}
Write-Output "TOTAL linhas com a-circ: $n (mostradas até 25)"
