# Diff estrutural: pega as funcoes extras do index revertido
$idx = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html")
$b = [System.Text.Encoding]::GetEncoding("ISO-8859-1").GetBytes($idx)
$idxRev = [System.Text.Encoding]::UTF8.GetString($b)
# usa o index JÁ corrigido (leva1) que está no disco
$idx = $idx  # ja corrigido

$bom = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\Sua Lingerie - Site.html")

# Lista funcoes
$fBom = [regex]::Matches($bom, 'function\s+(\w+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
$fIdx = [regex]::Matches($idx, 'function\s+(\w+)') | ForEach-Object { $_.Groups[1].Value } | Sort-Object -Unique
Write-Output "=== Funcoes SO no index (novas) ==="
(Compare-Object $fBom $fIdx | Where-Object { $_.SideIndicator -eq '=>' }).InputObject

# Pega o HTML das funcionalidades novas - procura 'banner' e 'destaque' no index
Write-Output ""
Write-Output "=== Ocorrencias de 'destaque'/'banner' no index (linha) ==="
$linhas = ($idx -split "`n")
for ($i=0; $i -lt $linhas.Count; $i++) {
  if ($linhas[$i] -match 'destaque|banner|Banner|Destaque') {
    Write-Output ("L{0}: {1}" -f ($i+1), $linhas[$i].Trim().Substring(0,[Math]::Min(90,$linhas[$i].Trim().Length)))
  }
}
