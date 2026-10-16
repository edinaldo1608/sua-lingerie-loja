$idx = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html")
$a = [string][char]0x00E2
$ms = [regex]::Matches($idx, '.{0,22}' + [regex]::Escape($a) + '.{0,22}')
$n=0
foreach ($m in $ms) {
  $n++
  $ctx = $m.Value -replace '[\r\n]',' '
  Write-Output ("[{0}] {1}" -f $n, $ctx)
}
Write-Output "TOTAL: $($ms.Count)"
