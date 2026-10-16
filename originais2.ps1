$bom = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\Sua Lingerie - Site.html")
$pats = @(
  'id="ftWa">([^<]*)<',
  'Mover para tr[^"]*"[^>]*>([^<]*)<',
  'id="oM">([^<]*)<',
  'id="pdM">([^<]*)<',
  'data-m>([^<]*)<',
  'fecharProduto\(\)">([^<]*)<',
  'Ordem atualizada ([^''"]*)',
  'Foto carregada ([^''"]*)',
  'adicionada ([^''"]*)',
  'adicionados ([^''"]*)',
  'Configura..es salvas ([^''"]*)',
  ":'([^']*)';",
  'Produto atualizado ([^''"]*)',
  'Remover esta foto">([^<]*)<',
  'title="Anterior">([^<]*)<',
  'title="Pr.xima">([^<]*)<',
  'class="lb-nav prev" title="Foto anterior">([^<]*)<',
  'class="lb-nav next" title="Pr.xima foto">([^<]*)<'
)
$i=0
foreach ($p in $pats) {
  $i++
  $m = [regex]::Match($bom, $p)
  if ($m.Success) {
    $val = $m.Groups[1].Value
    $codes = ($val.ToCharArray() | ForEach-Object { "U+{0:X4}" -f [int]$_ }) -join ' '
    Write-Output ("[{0}] {1}" -f $i, $codes)
  } else {
    Write-Output ("[{0}] (nao achou) {1}" -f $i, $p)
  }
}
