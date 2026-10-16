$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html"
$t = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
function MK([int[]]$a){ -join ($a | ForEach-Object { [System.Char]::ConvertFromUtf32($_) }) }
$E2=[string][char]0x00E2; $DQ=[string][char]0x0022; $SQ=[string][char]0x0027
$A=[char]0x00E1; $AO=[char]0x00E3; $C=[char]0x00E7; $O=[char]0x00F5; $U=[char]0x00FA; $I=[char]0x00ED
$LQ9 = MK @(0x2039); $RQ9 = MK @(0x203A); $MIN = MK @(0x2212)
$LT = MK @(0x25C0); $RT = MK @(0x25B6); $BUL = MK @(0x2022); $AG = [char]0x00E0
$PIC = MK @(0x1F5BC,0xFE0F)

$reps = @()
$reps += ,@(('title="Foto anterior">' + $E2 + '</button><button class="pnav next" title="Pr' + [char]0x00F3 + 'xima foto">' + $E2 + '</button>'), ('title="Foto anterior">' + $LQ9 + '</button><button class="pnav next" title="Pr' + [char]0x00F3 + 'xima foto">' + $RQ9 + '</button>'))
$reps += ,@(('class="pd-nav prev" title="Anterior">' + $E2 + '</button><button class="pd-nav next" title="Pr' + [char]0x00F3 + 'xima">' + $E2 + '</button>'), ('class="pd-nav prev" title="Anterior">' + $LQ9 + '</button><button class="pd-nav next" title="Pr' + [char]0x00F3 + 'xima">' + $RQ9 + '</button>'))
$reps += ,@(('data-m>' + $E2 + '</button>'), ('data-m>' + $MIN + '</button>'))
# L1140 tags: space+peca -> Ultima peca
$reps += ,@(("'Mais vendido','" + [char]0x0020 + " pe" + $C + "a','Kit'"), ("'Mais vendido','" + [char]0x00DA + "ltima pe" + $C + "a','Kit'"))
# L456 escolher foto (com 008F control)
$reps += ,@(('>' + $DQ + [char]0x00BC + [char]0x00EF + [char]0x00B8 + [char]0x008F + ' Escolher foto</button>'), ('>' + $PIC + ' Escolher foto</button>'))

foreach ($r in $reps) {
  if ($t.Contains($r[0])) { $t = $t.Replace($r[0], $r[1]) }
  else { Write-Output ("MISS: " + [System.BitConverter]::ToString([System.Text.Encoding]::UTF8.GetBytes($r[0])).Substring(0,60)) }
}

# L1305 conservacao: '--  ' (2014 0020 00A0 0020) -> bullet; and 00A0 -> 'a grave'
$t = $t.Replace(($(MK @(0x2014)) + ' Lave ' + [char]0x00A0 + ' m' + $AO + 'o'), ($BUL + ' Lave ' + $AG + ' m' + $AO + 'o'))
$t = $t.Replace(($(MK @(0x2014)) + ' N' + $AO + 'o use alvejante'), ($BUL + ' N' + $AO + 'o use alvejante'))
$t = $t.Replace(($(MK @(0x2014)) + ' N' + $AO + 'o passe a ferro'), ($BUL + ' N' + $AO + 'o passe a ferro'))
$t = $t.Replace(($(MK @(0x2014)) + ' Seque ' + [char]0x00A0 + ' sombra'), ($BUL + ' Seque ' + $AG + ' sombra'))

[System.IO.File]::WriteAllText($path, $t, (New-Object System.Text.UTF8Encoding($false)))
Write-Output ("after: " + $t.Length + "  E2rem: " + ($t.Split([char]0x00E2).Length-1))
