# Para cada contexto com 'a-circ', mostra o equivalente no arquivo bom
$idx = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html")
$bom = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\Sua Lingerie - Site.html")
$a = [string][char]0x00E2

# Pega amostras do index e do bom e mostra code points do char problematico
$msIdx = [regex]::Matches($idx, '(.{0,15})' + [regex]::Escape($a) + '(.{0,15})')
$vistos = @{}
foreach ($m in $msIdx) {
  $antes = $m.Groups[1].Value -replace '[\r\n]',' '
  $depois = $m.Groups[2].Value -replace '[\r\n]',' '
  $chave = $antes.Substring([Math]::Max(0,$antes.Length-8)) + '|' + $depois.Substring(0,[Math]::Min(8,$depois.Length))
  if (-not $vistos.ContainsKey($chave)) { $vistos[$chave] = 1 }
}

# Mostra chars seguintes ao a-circ
$seg = [regex]::Matches($idx, [regex]::Escape($a) + '(.)')
$cont = @{}
foreach ($m in $seg) {
  $c = $m.Groups[1].Value
  $cp = [int][char]$c
  $k = "U+{0:X4}" -f $cp
  if ($cont.ContainsKey($k)) { $cont[$k]++ } else { $cont[$k] = 1 }
}
Write-Output "=== Char imediatamente APOS 'a-circ' ==="
$cont.GetEnumerator() | Sort-Object Value -Descending | ForEach-Object { Write-Output ("{0} x{1}" -f $_.Key, $_.Value) }
