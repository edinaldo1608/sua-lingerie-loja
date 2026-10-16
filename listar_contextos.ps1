# Lista contextos de 'a-circ + espaco' no index e checa se existe no bom
$idx = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html")
$bom = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\Sua Lingerie - Site.html")
$a = [string][char]0x00E2

$ms = [regex]::Matches($idx, '.{0,20}' + [regex]::Escape($a + ' ') + '.{0,20}')
$n = 0
foreach ($m in $ms) {
  $ctx = $m.Value -replace '[\r\n]',' '
  $n++
  Write-Output ("[{0}] {1}" -f $n, $ctx)
}
Write-Output "TOTAL contexts 'a-circ+space': $($ms.Count)"
