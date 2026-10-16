$bom = [System.IO.File]::ReadAllText("C:\Users\Edinaldo\Downloads\Sua Lingerie\Sua Lingerie - Site.html")
$pats = @{
  'lb-close'   = 'class="lb-close"[^>]*>([^<]*)<'
  'lb-nav-prev'= 'class="lb-nav prev"[^>]*>([^<]*)<'
  'lb-nav-next'= 'class="lb-nav next"[^>]*>([^<]*)<'
  'cadTit'     = 'id="cadTit">([^<]*)<'
  'cadFotoRem' = 'id="cadFotoRem"[^>]*>([^<]*)<'
  'cadDestaque'= 'id="cadDestaque"[^>]*>([^<]*)<'
  'ftWa'       = 'id="ftWa">([^<]*)<'
  'ftIG'       = 'id="ftIG">([^<]*)<'
  'ftTel'      = 'id="ftTel">([^<]*)<'
  'abrirCad'   = 'onclick="abrirCad\(\)">([^<]*)<'
  'lerDoApp'   = 'onclick="lerDoApp\(\)">([^<]*)<'
  'cadAddTams' = "cadAddCustom\('tams'[^>]*>([^<]*)<"
}
foreach ($k in $pats.Keys) {
  $m = [regex]::Match($bom, $pats[$k])
  if ($m.Success) {
    $codes = ($m.Groups[1].Value.ToCharArray() | ForEach-Object { "U+{0:X4}" -f [int]$_ }) -join ' '
    Write-Output ("{0,-12} => {1}" -f $k, $codes)
  } else {
    Write-Output ("{0,-12} => (nao achou)" -f $k)
  }
}
