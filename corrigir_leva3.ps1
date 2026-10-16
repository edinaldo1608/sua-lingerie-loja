param([switch]$Write)
$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html"
$t = [System.IO.File]::ReadAllText($path, [System.Text.Encoding]::UTF8)
$before = $t.Length

function MK([int[]]$arr){ -join ($arr | ForEach-Object { [System.Char]::ConvertFromUtf32($_) }) }

$E2  = [string][char]0x00E2
$DQ  = [string][char]0x0022
$SQ  = [string][char]0x0027
$EMD = MK @(0x2014); $BUL = MK @(0x2022); $LT = MK @(0x25C0); $RT = MK @(0x25B6)
$ARR = MK @(0x2194,0xFE0F); $TRA = MK @(0x1F5D1,0xFE0F); $CKE = MK @(0x2705)
$CRS = MK @(0x2715); $XHV = MK @(0x2716); $MIN = MK @(0x2212); $CLK = MK @(0x1F550)
$PIC = MK @(0x1F5BC,0xFE0F); $DSK = MK @(0x1F4BE); $STR = MK @(0x2B50); $SRH = MK @(0x1F50D)
$PEN = MK @(0x270F,0xFE0F)
$A   = [char]0x00E1; $AO = [char]0x00E3; $C = [char]0x00E7; $O = [char]0x00F5
$E   = [char]0x00E9; $U = [char]0x00FA; $UU = [char]0x00DA; $I = [char]0x00ED
$OA  = [char]0x00F4; $AG = [char]0x00E0

$P = New-Object System.Collections.ArrayList

# [search, replace]
$P.Add(@(('WhatsApp: <b id="ftWa">' + $E2 + '</b>'), ('WhatsApp: <b id="ftWa">' + $EMD + '</b>'))) | Out-Null
$P.Add(@(('<li> Seg a S' + $A + 'b, 8h  ' + $AG + 's 18h</li>'), ('<li>' + $CLK + ' Seg a S' + $A + 'b, 8h ' + $AG + 's 18h</li>'))) | Out-Null
$P.Add(@(('>' + $DQ + [char]0x00BC + [char]0x00EF + [char]0x00B8 + ' Escolher foto</button>'), ('>' + $PIC + ' Escolher foto</button>'))) | Out-Null
$P.Add(@(($XHV + ' Remover ' + [char]0x00BA + 'ltima</button>'), ($XHV + ' Remover ' + $U + 'ltima</button>'))) | Out-Null
$P.Add(@(('use ' + $E2 + $DQ + ' ' + $E2 + $DQ + [char]0x00B6 + ' para reordenar'), ('use ' + $LT + ' ' + $RT + ' para reordenar'))) | Out-Null
$P.Add(@(('<span class="big-i"></span>Nenhum produto encontrado.'), ('<span class="big-i">' + $SRH + '</span>Nenhum produto encontrado.'))) | Out-Null
$P.Add(@(('title="Foto anterior">' + $E2 + '</button><button class="pnav next" title="Pr' + $OA + 'xima foto">' + $E2 + '</button>'), ('title="Foto anterior">' + (MK @(0x2039)) + '</button><button class="pnav next" title="Pr' + $OA + 'xima foto">' + (MK @(0x203A)) + '</button>'))) | Out-Null
$P.Add(@(('<button data-up title="Mover para tr' + $A + 's">' + $E2 + '</button><button data-del title="Excluir">' + $DQ + '</button>'), ('<button data-up title="Mover para tr' + $A + 's">' + $ARR + '</button><button data-del title="Excluir">' + $TRA + '</button>'))) | Out-Null
$P.Add(@(('id="oM">' + $E2 + '</button>'), ('id="oM">' + $MIN + '</button>'))) | Out-Null
$P.Add(@(('class="pd-nav prev" title="Anterior">' + $E2 + '</button><button class="pd-nav next" title="Pr' + $OA + 'xima">' + $E2 + '</button>'), ('class="pd-nav prev" title="Anterior">' + (MK @(0x2039)) + '</button><button class="pd-nav next" title="Pr' + $OA + 'xima">' + (MK @(0x203A)) + '</button>'))) | Out-Null
$P.Add(@(('fecharProduto()">' + $E2 + $DQ + '</button>'), ('fecharProduto()">' + $CRS + '</button>'))) | Out-Null
$P.Add(@(('id="pdM">' + $E2 + '</button>'), ('id="pdM">' + $MIN + '</button>'))) | Out-Null
$P.Add(@(('join(' + $SQ + '  ' + $SQ + ')</small><div class="qty"><button data-m>' + $E2 + '</button>'), ('join(' + $SQ + ' ' + (MK @(0x00B7)) + ' ' + $SQ + ')</small><div class="qty"><button data-m>' + $MIN + '</button>'))) | Out-Null
$P.Add(@(('data-x title="Remover">' + $DQ + '</button>'), ('data-x title="Remover">' + $TRA + '</button>'))) | Out-Null
$P.Add(@(("toast('Configura" + $C + $O + "es salvas " + $E2 + $DQ + "')"), ("toast('Configura" + $C + $O + "es salvas " + $CKE + "')"))) | Out-Null
$P.Add(@(("CFG.wa?('+'+CFG.wa):'" + $E2 + $SQ), ("CFG.wa?('+'+CFG.wa):'" + $EMD + $SQ))) | Out-Null
$P.Add(@(("produtos carregados do app " + $E2 + $DQ), ("produtos carregados do app " + $CKE))) | Out-Null
$P.Add(@(("produtos carregados " + $E2 + $DQ), ("produtos carregados " + $CKE))) | Out-Null
$P.Add(@(("x.textContent='" + $E2 + $DQ + $SQ), ("x.textContent='" + $CRS + $SQ))) | Out-Null
$P.Add(@(("adicionada " + $E2 + $DQ + "')"), ("adicionada " + $CKE + "')"))) | Out-Null
$P.Add(@(("adicionados " + $E2 + $DQ + "')"), ("adicionados " + $CKE + "')"))) | Out-Null
$P.Add(@(("use " + $PEN + " " + $DQ + " " + $EMD + " nos produtos')"), ("use " + $PEN + " " + $TRA + " " + $ARR + " nos produtos')"))) | Out-Null
$P.Add(@(("'Mais vendido','" + [char]0x0020 + " pe" + $C + "a','Kit'"), ("'Mais vendido','" + $UU + "ltima pe" + $C + "a','Kit'"))) | Out-Null
$P.Add(@(("'Biqu" + $I + "ni','Mai','Robe'"), ("'Biqu" + $I + "ni','Mai" + $OA + "','Robe'"))) | Out-Null
$P.Add(@(("$('#cadSalvar').textContent=p?' Salvar altera" + $C + $O + "es':' Salvar produto';"), ("$('#cadSalvar').textContent=p?'" + $DSK + " Salvar altera" + $C + $O + "es':'" + $DSK + " Salvar produto';"))) | Out-Null
$sL = $SQ + '+(i===0?' + $SQ + ' disabled' + $SQ + ':' + $SQ + $SQ + ")+'>"
$sR = $SQ + '+(i===cadFotos.length-1?' + $SQ + ' disabled' + $SQ + ':' + $SQ + $SQ + ")+'>"
$P.Add(@(($sL + $E2 + $DQ + '</button>'), ($sL + $LT + '</button>'))) | Out-Null
$P.Add(@(($sR + $E2 + $DQ + [char]0x00B6 + '</button>'), ($sR + $RT + '</button>'))) | Out-Null
$P.Add(@(('class="slot-x" title="Remover esta foto">' + $E2 + $DQ + $DQ + '</button>'), ('class="slot-x" title="Remover esta foto">' + $XHV + '</button>'))) | Out-Null
$P.Add(@(("toast('Foto carregada " + $E2 + $DQ + "')"), ("toast('Foto carregada " + $CKE + "')"))) | Out-Null
$P.Add(@(("toast(cadEditIdx!=null?'Produto atualizado " + $E2 + $DQ + "':'Produto adicionado " + $E2 + $DQ + "')"), ("toast(cadEditIdx!=null?'Produto atualizado " + $CKE + "':'Produto adicionado " + $CKE + "')"))) | Out-Null
$P.Add(@(("toast('Produto exclu" + $I + "do " + $DQ + "')"), ("toast('Produto exclu" + $I + "do " + $TRA + "')"))) | Out-Null
$P.Add(@(("toast('Ordem atualizada " + $E2 + "')"), ("toast('Ordem atualizada " + $ARR + "')"))) | Out-Null
$P.Add(@(("s" + [char]0x00F3 + " n" + [char]0x00BA + "meros"), ("s" + [char]0x00F3 + " n" + $U + "meros"))) | Out-Null
$P.Add(@(("n" + [char]0x00BA + "mero, bairro"), ("n" + $U + "mero, bairro"))) | Out-Null

$ic1 = "{'suti" + $AO + "':'" + $DQ + "','calcinha':'','conjunto':'','body':'" + $DQ + "','camisola':''','pijama':'','meia':'','biqu" + $I + "ni':'" + $DQ + "'}"
$ic2 = "{'suti" + $AO + "':'" + (MK @(0x1F459)) + "','calcinha':'" + (MK @(0x1FA72)) + "','conjunto':'" + (MK @(0x1F49D)) + "','body':'" + (MK @(0x1F457)) + "','camisola':'" + (MK @(0x1F6CC)) + "','pijama':'" + (MK @(0x1F380)) + "','meia':'" + (MK @(0x1F9E6)) + "','biqu" + $I + "ni':'" + (MK @(0x1F459)) + "'}"

$log = New-Object System.Collections.ArrayList
$cntIc = $t.Split($ic1).Length - 1
$log.Add("IC occurrences: $cntIc") | Out-Null
if ($cntIc -gt 0) { $t = $t.Replace($ic1, $ic2) }

$hit = 0; $miss = 0
foreach ($r in $P) {
  $n = $t.Split($r[0]).Length - 1
  if ($n -gt 0) { $t = $t.Replace($r[0], $r[1]); $hit+= $n }
  else { $miss++; $log.Add("MISS: " + $r[0].Substring(0,[Math]::Min(50,$r[0].Length))) | Out-Null }
}
$log.Add("HITS: $hit  MISS: $miss") | Out-Null

if ($Write) {
  [System.IO.File]::WriteAllText($path, $t, (New-Object System.Text.UTF8Encoding($false)))
  $log.Add("WROTE. before=$before after=" + $t.Length) | Out-Null
} else {
  $log.Add("DRY-RUN. before=$before wouldbe=" + $t.Length) | Out-Null
}
$log | Out-File -Encoding utf8 "C:\Users\Edinaldo\Downloads\Sua Lingerie\leva3_out.txt"
