$path = "C:\Users\Edinaldo\Downloads\Sua Lingerie\index.html"
$t = [System.IO.File]::ReadAllText($path,[System.Text.Encoding]::UTF8)
function MK([int[]]$a){ -join ($a | ForEach-Object { [System.Char]::ConvertFromUtf32($_) }) }
$SQ=[string][char]0x0027; $DQ=[string][char]0x0022
$AO=[char]0x00E3; $I=[char]0x00ED; $C=[char]0x00E7; $A=[char]0x00E1; $AG=[char]0x00A0
$MID=[char]0x00B7

$I_SUT=MK @(0x1F459); $I_CAL=MK @(0x1FA72); $I_CON=MK @(0x1F49D); $I_BOD=MK @(0x1F457)
$I_CAM=MK @(0x1F6CC); $I_PIJ=MK @(0x1F380); $I_MEI=MK @(0x1F9E6)
$CLK=MK @(0x1F550)

# CATS_SUGERIDAS rows (replace icon + fix Camisola row quote)
$t=$t.Replace(("['" + $DQ + "','Suti" + $AO + "',"), ("['" + $I_SUT + "','Suti" + $AO + "',"))
$t=$t.Replace(("['','Calcinha',"), ("['" + $I_CAL + "','Calcinha',"))
$t=$t.Replace(("['','Conjunto',"), ("['" + $I_CON + "','Conjunto',"))
$t=$t.Replace(("['" + $DQ + "','Body',"), ("['" + $I_BOD + "','Body',"))
$t=$t.Replace(("['" + $SQ + $SQ + "','Camisola',"), ("['" + $I_CAM + "','Camisola',"))
$t=$t.Replace(("['','Pijama',"), ("['" + $I_PIJ + "','Pijama',"))
$t=$t.Replace(("['','Meia-cal" + $C + "a','',''],"), ("['" + $I_MEI + "','Meia-cal" + $C + "a','',''],"))
$t=$t.Replace(("['" + $DQ + "','Biqu" + $I + "ni','','']"), ("['" + $I_SUT + "','Biqu" + $I + "ni','','']"))

# Seg a Sab: <li> Seg a S\u00E1b, 8h \u00A0s 18h</li>
$t=$t.Replace(("<li> Seg a S" + $A + "b, 8h " + $AG + "s 18h</li>"), ("<li>" + $CLK + " Seg a S" + $A + "b, 8h " + [char]0x00E0 + "s 18h</li>"))

[System.IO.File]::WriteAllText($path,$t,(New-Object System.Text.UTF8Encoding($false)))
"done " + $t.Length
